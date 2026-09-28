<?php

namespace App\Http\Controllers;

use App\Models\Product;
use App\Support\ActivityLogger;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Http;
use Illuminate\Validation\Rule;

class ProductController extends Controller
{
    public function index()
    {
        $products = Product::query()
            ->leftJoin(
                'tbl_inventory',
                'tbl_product.v_productId',
                '=',
                'tbl_inventory.v_productId'
            )
            ->select(
                'tbl_product.*',
                'tbl_inventory.v_quantityOnHand',
                'tbl_inventory.v_quantityAvailable'
            )
            ->where('tbl_product.v_isActive', 1)
            ->orderBy('tbl_product.v_createdAt', 'desc')
            ->get();

        $products->each(function ($product) {
            $product->image_url = $this->productImageUrl(
                $product->v_productId,
                $product->v_updatedAt,
            );
        });

        return response()->json($products);
    }

    public function uploadImage(Request $request, $id)
    {
        $validated = $request->validate([
            'image' => 'required|image|mimes:jpeg,jpg,png,webp|max:10240',
        ]);

        $product = DB::table('tbl_product')->where('v_productId', $id)->first();
        abort_if(!$product, 404, 'Product not found.');

        $supabaseUrl = config('services.supabase.url');
        $serviceRoleKey = config('services.supabase.service_role_key');
        $bucket = config('services.supabase.storage_bucket');
        if (!$supabaseUrl || !$serviceRoleKey || !$bucket) {
            return response()->json([
                'message' => 'Product image storage is not configured. Set SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, and SUPABASE_STORAGE_BUCKET in the backend environment.',
            ], 503);
        }

        $image = $validated['image'];
        $contentType = $image->getMimeType();
        if (!in_array($contentType, ['image/jpeg', 'image/png', 'image/webp'], true)) {
            return response()->json(['message' => 'Unsupported image format.'], 422);
        }

        $objectPath = "products/{$id}/cover";
        $response = Http::timeout(30)
            ->withHeaders([
                'Authorization' => "Bearer {$serviceRoleKey}",
                'apikey' => $serviceRoleKey,
                'Content-Type' => $contentType,
                'x-upsert' => 'true',
            ])
            ->withBody($image->getContent(), $contentType)
            ->post(
                rtrim($supabaseUrl, '/').'/storage/v1/object/'
                    .rawurlencode($bucket).'/'.$objectPath,
            );

        if ($response->failed()) {
            return response()->json([
                'message' => 'Supabase Storage rejected the image upload.',
                'storage_error' => $response->json('message'),
            ], 502);
        }

        $version = now();
        DB::table('tbl_product')->where('v_productId', $id)
            ->update(['v_updatedAt' => $version]);

        return response()->json([
            'image_url' => $this->productImageUrl($id, $version),
        ]);
    }

    private function productImageUrl($productId, $version = null): ?string
    {
        $supabaseUrl = config('services.supabase.url');
        $bucket = config('services.supabase.storage_bucket');
        if (!$supabaseUrl || !$bucket || !config('services.supabase.service_role_key')) {
            return null;
        }

        $url = rtrim($supabaseUrl, '/')
            .'/storage/v1/object/public/'.rawurlencode($bucket)
            .'/products/'.rawurlencode((string) $productId).'/cover';
        if ($version !== null) {
            $url .= '?v='.rawurlencode((string) $version);
        }

        return $url;
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'sku' => ['nullable', 'string', 'max:60', Rule::unique('tbl_product', 'v_productCode')],
            'name' => 'required|string|max:150',
            'category' => 'nullable|string|max:100',
            'price' => 'nullable|numeric',
            'description' => 'nullable|string',
            'quantity_on_hand' => 'nullable|numeric|min:0',
        ]);

        $id = DB::transaction(function () use ($validated, $request) {
            $id = DB::table('tbl_product')->insertGetId([
                'v_productCode' => $validated['sku'] ?? null,
                'v_productName' => $validated['name'],
                'v_productCategory' => $validated['category'] ?? null,
                'v_currentPrice' => $validated['price'] ?? null,
                'v_productDescription' => $validated['description'] ?? null,
                'v_isActive' => true,
            ], 'v_productId');

            $inventoryId = DB::table('tbl_inventory')->insertGetId([
                'v_productId' => $id,
                'v_quantityOnHand' => $validated['quantity_on_hand'] ?? 0,
                'v_quantityReserved' => 0,
                'v_lastStockUpdate' => now(),
            ], 'v_inventoryId');

            if (($validated['quantity_on_hand'] ?? 0) > 0) {
                DB::table('tbl_inventoryTransaction')->insert([
                    'v_inventoryId' => $inventoryId,
                    'v_transactionType' => 'Adjustment',
                    'v_quantity' => $validated['quantity_on_hand'],
                    'v_referenceType' => 'Product',
                    'v_referenceId' => $id,
                    'v_reason' => 'Initial stock entered during product creation',
                    'v_performedByUserId' => $request->user()->v_userId,
                ]);
            }

            ActivityLogger::record(
                (int) $request->user()->v_userId,
                'created',
                'tbl_product',
                (int) $id,
                "Created product {$validated['name']}.",
                $request->ip(),
            );

            return $id;
        });

        return response()->json(['id' => $id], 201);
    }

    public function update(Request $request, $id)
    {
        $validated = $request->validate([
            'sku' => [
                'nullable',
                'string',
                'max:60',
                Rule::unique('tbl_product', 'v_productCode')->ignore($id, 'v_productId'),
            ],
            'name' => 'required|string|max:150',
            'category' => 'nullable|string|max:100',
            'price' => 'nullable|numeric',
            'description' => 'nullable|string',
            'quantity_on_hand' => 'nullable|numeric|min:0',
        ]);

        DB::transaction(function () use ($validated, $request, $id) {
            $product = DB::table('tbl_product')->where('v_productId', $id)->first();
            abort_if(!$product, 404, 'Product not found.');

            DB::table('tbl_product')->where('v_productId', $id)->update([
                'v_productCode' => $validated['sku'] ?? null,
                'v_productName' => $validated['name'],
                'v_productCategory' => $validated['category'] ?? null,
                'v_currentPrice' => $validated['price'] ?? null,
                'v_productDescription' => $validated['description'] ?? null,
                'v_updatedAt' => now(),
            ]);

            if (isset($validated['quantity_on_hand'])) {
                $inventory = DB::table('tbl_inventory')
                    ->where('v_productId', $id)
                    ->lockForUpdate()
                    ->first();

                if ($inventory) {
                    abort_if(
                        (float) $validated['quantity_on_hand'] <
                            (float) $inventory->v_quantityReserved,
                        422,
                        'On-hand quantity cannot be lower than reserved stock.',
                    );
                    $newQuantity = max(
                        (float) $validated['quantity_on_hand'],
                        (float) $inventory->v_quantityReserved,
                    );
                    DB::table('tbl_inventory')
                        ->where('v_inventoryId', $inventory->v_inventoryId)
                        ->update([
                            'v_quantityOnHand' => $newQuantity,
                            'v_lastStockUpdate' => now(),
                            'v_updatedAt' => now(),
                        ]);

                    $difference = $newQuantity - (float) $inventory->v_quantityOnHand;
                    if ($difference != 0.0) {
                        DB::table('tbl_inventoryTransaction')->insert([
                            'v_inventoryId' => $inventory->v_inventoryId,
                            'v_transactionType' => 'Adjustment',
                            'v_quantity' => abs($difference),
                            'v_referenceType' => 'Product',
                            'v_referenceId' => $id,
                            'v_reason' => 'Admin stock adjustment',
                            'v_performedByUserId' => $request->user()->v_userId,
                        ]);
                    }
                } else {
                    $inventoryId = DB::table('tbl_inventory')->insertGetId([
                        'v_productId' => $id,
                        'v_quantityOnHand' => $validated['quantity_on_hand'],
                        'v_quantityReserved' => 0,
                        'v_lastStockUpdate' => now(),
                    ], 'v_inventoryId');
                    if ($validated['quantity_on_hand'] > 0) {
                        DB::table('tbl_inventoryTransaction')->insert([
                            'v_inventoryId' => $inventoryId,
                            'v_transactionType' => 'Adjustment',
                            'v_quantity' => $validated['quantity_on_hand'],
                            'v_referenceType' => 'Product',
                            'v_referenceId' => $id,
                            'v_reason' => 'Initial stock entered during product update',
                            'v_performedByUserId' => $request->user()->v_userId,
                        ]);
                    }
                }
            }

            ActivityLogger::record(
                (int) $request->user()->v_userId,
                'updated',
                'tbl_product',
                (int) $id,
                "Updated product {$validated['name']}.",
                $request->ip(),
            );
        });

        return response()->json(['message' => 'Product updated.']);
    }

    public function destroy(Request $request, $id)
    {
        $product = DB::table('tbl_product')->where('v_productId', $id)->first();
        abort_if(!$product, 404, 'Product not found.');

        DB::table('tbl_product')->where('v_productId', $id)->update([
            'v_isActive' => false,
            'v_updatedAt' => now(),
        ]);
        ActivityLogger::record(
            (int) $request->user()->v_userId,
            'deleted',
            'tbl_product',
            (int) $id,
            "Archived product {$product->v_productName}.",
            $request->ip(),
        );

        return response()->json(['message' => 'Product removed.']);
    }

}

<?php

namespace App\Http\Controllers;

use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

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

        return response()->json($products);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'sku' => 'nullable|string|max:60',
            'name' => 'required|string|max:150',
            'category' => 'nullable|string|max:100',
            'price' => 'nullable|numeric',
            'description' => 'nullable|string',
        ]);

        $id = DB::table('tbl_product')->insertGetId([
            'v_productCode' => $validated['sku'] ?? null,
            'v_productName' => $validated['name'],
            'v_productCategory' => $validated['category'] ?? null,
            'v_currentPrice' => $validated['price'] ?? null,
            'v_productDescription' => $validated['description'] ?? null,
            'v_isActive' => 1,
        ], 'v_productId');

        DB::table('tbl_inventory')->insert([
            'v_productId' => $id,
            'v_quantityOnHand' => 0,
            'v_quantityReserved' => 0,
        ]);

        return response()->json(['id' => $id], 201);
    }

    public function update(Request $request, $id)
    {
        $validated = $request->validate([
            'sku' => 'nullable|string|max:60',
            'name' => 'required|string|max:150',
            'category' => 'nullable|string|max:100',
            'price' => 'nullable|numeric',
            'description' => 'nullable|string',
        ]);

        DB::table('tbl_product')->where('v_productId', $id)->update([
            'v_productCode' => $validated['sku'] ?? null,
            'v_productName' => $validated['name'],
            'v_productCategory' => $validated['category'] ?? null,
            'v_currentPrice' => $validated['price'] ?? null,
            'v_productDescription' => $validated['description'] ?? null,
        ]);

        return response()->json(['message' => 'Product updated.']);
    }

    public function destroy($id)
    {
        DB::table('tbl_product')->where('v_productId', $id)->update([
            'v_isActive' => 0,
        ]);

        return response()->json(['message' => 'Product removed.']);
    }
}

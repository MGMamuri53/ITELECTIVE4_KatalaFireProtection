<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class OrderController extends Controller
{
    public function store(Request $request)
    {
        $fulfillmentMethod = trim(
            $request->input('fulfillment_method', '')
        );

        if ($fulfillmentMethod === 'Store Pickup') {
            $fulfillmentMethod = 'pickup';
        } elseif ($fulfillmentMethod === 'Delivery') {
            $fulfillmentMethod = 'delivery';
        }

        $request->merge([
            'fulfillment_method' => $fulfillmentMethod,
            'customer_id' => $request->user()->v_customerId,
        ]);

        $validated = $request->validate([
            'customer_id' => 'required|integer',
            'product_id' => 'required|integer',
            'customer_name' => 'required|string',
            'email' => 'nullable|email',
            'contact_number' => 'required|string',
            'address' => 'nullable|string|required_if:fulfillment_method,delivery',
            'quantity' => 'required|integer|min:1',
            'fulfillment_method' => 'required|in:delivery,pickup',
            'payment_method' => 'required|string',
        ]);

        return DB::transaction(function () use ($validated) {
            $customer = DB::table('tbl_customer')
                ->where('v_customerId', $validated['customer_id'])
                ->where('v_isActive', 1)
                ->first();

            if (!$customer) {
                return response()->json([
                    'message' => 'Customer profile not found.'
                ], 403);
            }

            // Get the product from the team database
            $product = DB::table('tbl_product')
                ->where('v_productId', $validated['product_id'])
                ->where('v_isActive', 1)
                ->first();

            if (!$product) {
                return response()->json([
                    'message' => 'Product not found.'
                ], 404);
            }

            $inventory = DB::table('tbl_inventory')
                ->where('v_productId', $validated['product_id'])
                ->lockForUpdate()
                ->first();

            $quantityAvailable = (float) ($inventory->v_quantityAvailable ?? 0);
            if ($quantityAvailable < (float) $validated['quantity']) {
                return response()->json([
                    'message' => 'Insufficient product stock.'
                ], 422);
            }

            $total = $product->v_currentPrice * $validated['quantity'];

            // Create order
            $orderNumber = 'ORD-' . strtoupper(uniqid());

            $orderId = DB::table('tbl_order')->insertGetId([
                'v_orderNumber' => $orderNumber,
                'v_customerId' => $validated['customer_id'],
                'v_orderStatus' => 'Pending Confirmation',
                'v_subtotalAmount' => $total,
                'v_totalAmount' => $total,
            ]);

            // Create order item
            DB::table('tbl_orderItem')->insert([
                'v_orderId' => $orderId,
                'v_productId' => $validated['product_id'],
                'v_productNameSnapshot' => $product->v_productName,
                'v_quantity' => $validated['quantity'],
                'v_unitPrice' => $product->v_currentPrice,
            ]);

            DB::table('tbl_inventory')
                ->where('v_productId', $validated['product_id'])
                ->update([
                    'v_quantityAvailable' =>
                        $quantityAvailable - $validated['quantity'],
                ]);

            // Create delivery/pickup record
            DB::table('tbl_deliveryPickup')->insert([
                'v_orderId' => $orderId,
                'v_fulfillmentType' =>
                    strtolower($validated['fulfillment_method']),
                'v_recipientName' => $validated['customer_name'],
                'v_recipientContactNumber' =>
                    $validated['contact_number'],
                'v_deliveryAddress' => $validated['address'] ?? null,
                'v_fulfillmentStatus' => 'Pending',
            ]);
            DB::table('tbl_payment')->insert([
                'v_orderId' => $orderId,
                'v_customerId' => $validated['customer_id'],
                'v_paymentType' => 'Order Payment',
                'v_paymentMethod' => $validated['payment_method'],
                'v_paymentAmount' => $total,
                'v_paymentStatus' => 'Pending',
            ]);

            return response()->json([
                'message' => 'Order placed successfully.',
                'order_number' => $orderNumber,
                'order_id' => $orderId,
                'total_amount' => $total,
            ], 201);
        });
    }

    public function customerOrders($customerId)
    {
        $authenticatedCustomerId = request()->user()->v_customerId;

        if ((int) $customerId !== (int) $authenticatedCustomerId) {
            return response()->json([
                'message' => 'Unauthorized access to customer data.'
            ], 403);
        }

        return $this->ordersForCustomer($authenticatedCustomerId);
    }

    public function myOrders(Request $request)
    {
        return $this->ordersForCustomer(
            $request->user()->v_customerId
        );
    }

    private function ordersForCustomer($customerId)
    {
        $orders = DB::table('tbl_order as o')
            ->join('tbl_orderItem as oi', 'o.v_orderId', '=', 'oi.v_orderId')
            ->where('o.v_customerId', $customerId)
            ->orderBy('o.v_orderDate', 'desc')
            ->select(
                'o.v_orderId',
                'o.v_orderNumber',
                'o.v_orderDate',
                'o.v_orderStatus',
                'o.v_totalAmount',
                'oi.v_productNameSnapshot',
                'oi.v_quantity'
            )
            ->get();

        return response()->json($orders);
    }
}

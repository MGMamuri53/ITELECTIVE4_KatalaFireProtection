<?php

namespace App\Http\Controllers;

use App\Models\Product;
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
            ->orderBy('tbl_product.v_createdAt', 'desc')
            ->get();

        return response()->json($products);
    }
}
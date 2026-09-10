<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    protected $table = 'tbl_product';

    protected $primaryKey = 'v_productId';

    const CREATED_AT = 'v_createdAt';
    const UPDATED_AT = 'v_updatedAt';

    protected $fillable = [
        'v_productCode',
        'v_productName',
        'v_productCategory',
        'v_brand',
        'v_model',
        'v_productDescription',
        'v_unitOfMeasure',
        'v_currentPrice',
        'v_costPrice',
        'v_supplierReference',
        'v_warrantyPeriod',
        'v_isActive',
    ];

    protected $casts = [
        'v_currentPrice' => 'decimal:2',
        'v_costPrice' => 'decimal:2',
        'v_isActive' => 'boolean',
    ];
}
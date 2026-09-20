<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ProductPriceHistory extends Model
{
    protected $table = 'tbl_productPriceHistory';

    protected $primaryKey = 'v_productPriceHistoryId';

    const CREATED_AT = 'v_createdAt';
    const UPDATED_AT = null;
}
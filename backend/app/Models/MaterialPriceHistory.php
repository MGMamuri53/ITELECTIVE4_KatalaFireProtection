<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MaterialPriceHistory extends Model
{
    protected $table = 'tbl_materialPriceHistory';

    protected $primaryKey = 'v_materialPriceHistoryId';

    const CREATED_AT = 'v_createdAt';
    const UPDATED_AT = null;
}
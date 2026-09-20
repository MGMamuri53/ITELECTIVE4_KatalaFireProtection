<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    protected $table = 'tbl_order';

    protected $primaryKey = 'v_orderId';

    const CREATED_AT = 'v_createdAt';
    const UPDATED_AT = 'v_updatedAt';
}
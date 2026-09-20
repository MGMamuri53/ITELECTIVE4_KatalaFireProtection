<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class OrderItem extends Model
{
    protected $table = 'tbl_orderItem';

    protected $primaryKey = 'v_orderItemId';

    public $timestamps = false;
}
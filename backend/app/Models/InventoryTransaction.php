<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class InventoryTransaction extends Model
{
    protected $table = 'tbl_inventoryTransaction';

    protected $primaryKey = 'v_inventoryTransactionId';

    const CREATED_AT = 'v_createdAt';
    const UPDATED_AT = null;
}
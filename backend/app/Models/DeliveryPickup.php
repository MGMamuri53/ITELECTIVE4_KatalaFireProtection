<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DeliveryPickup extends Model
{
    protected $table = 'tbl_deliveryPickup';

    protected $primaryKey = 'v_deliveryPickupId';

    const CREATED_AT = 'v_createdAt';
    const UPDATED_AT = 'v_updatedAt';
}
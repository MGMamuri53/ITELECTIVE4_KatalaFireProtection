<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Service extends Model
{
    protected $table = 'tbl_service';

    protected $primaryKey = 'v_serviceId';

    const CREATED_AT = 'v_createdAt';
    const UPDATED_AT = 'v_updatedAt';
}
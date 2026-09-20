<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ServiceRequest extends Model
{
    protected $table = 'tbl_serviceRequest';

    protected $primaryKey = 'v_serviceRequestId';

    const CREATED_AT = 'v_createdAt';
    const UPDATED_AT = 'v_updatedAt';
}
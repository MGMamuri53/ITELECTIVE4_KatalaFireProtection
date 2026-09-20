<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class WarrantyClaim extends Model
{
    protected $table = 'tbl_warrantyClaim';

    protected $primaryKey = 'v_warrantyClaimId';

    const CREATED_AT = 'v_createdAt';
    const UPDATED_AT = 'v_updatedAt';
}
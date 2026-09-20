<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Permission extends Model
{
    protected $table = 'tbl_permission';

    protected $primaryKey = 'v_permissionId';

    const CREATED_AT = 'v_createdAt';
    const UPDATED_AT = null;
}
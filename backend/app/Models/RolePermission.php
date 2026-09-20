<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class RolePermission extends Model
{
    protected $table = 'tbl_rolePermission';

    protected $primaryKey = 'v_rolePermissionId';

    const CREATED_AT = 'v_createdAt';
    const UPDATED_AT = null;
}
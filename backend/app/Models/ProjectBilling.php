<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ProjectBilling extends Model
{
    protected $table = 'tbl_projectBilling';

    protected $primaryKey = 'v_projectBillingId';

    const CREATED_AT = 'v_createdAt';
    const UPDATED_AT = 'v_updatedAt';
}
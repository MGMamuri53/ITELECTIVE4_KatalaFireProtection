<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ActivityLog extends Model
{
    protected $table = 'tbl_activityLog';

    protected $primaryKey = 'v_activityLogId';

    const CREATED_AT = 'v_createdAt';
    const UPDATED_AT = null;
}
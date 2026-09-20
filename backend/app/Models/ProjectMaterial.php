<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ProjectMaterial extends Model
{
    protected $table = 'tbl_projectMaterial';

    protected $primaryKey = 'v_projectMaterialId';

    public $timestamps = false;
}
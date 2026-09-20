<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class QuotationItem extends Model
{
    protected $table = 'tbl_quotationItem';

    protected $primaryKey = 'v_quotationItemId';

    public $timestamps = false;
}
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Customer extends Model
{
    protected $table = 'tbl_customer';

    protected $primaryKey = 'v_customerId';

    const CREATED_AT = 'v_createdAt';
    const UPDATED_AT = 'v_updatedAt';

    protected $fillable = [
        'v_customerType',
        'v_firstName',
        'v_middleName',
        'v_lastName',
        'v_companyName',
        'v_contactPerson',
        'v_emailAddress',
        'v_mobileNumber',
        'v_telephoneNumber',
        'v_addressLine',
        'v_barangay',
        'v_cityMunicipality',
        'v_province',
        'v_postalCode',
        'v_notes',
        'v_isActive',
    ];

    protected $casts = [
        'v_isActive' => 'boolean',
        'v_createdAt' => 'datetime',
        'v_updatedAt' => 'datetime',
    ];

    public function users(): HasMany
    {
        return $this->hasMany(
            User::class,
            'v_customerId',
            'v_customerId'
        );
    }

    public function orders(): HasMany
    {
        return $this->hasMany(
            Order::class,
            'v_customerId',
            'v_customerId'
        );
    }

    public function serviceRequests(): HasMany
    {
        return $this->hasMany(
            ServiceRequest::class,
            'v_customerId',
            'v_customerId'
        );
    }

    public function payments(): HasMany
    {
        return $this->hasMany(
            Payment::class,
            'v_customerId',
            'v_customerId'
        );
    }

    public function warranties(): HasMany
    {
        return $this->hasMany(
            Warranty::class,
            'v_customerId',
            'v_customerId'
        );
    }

    public function maintenances(): HasMany
    {
        return $this->hasMany(
            Maintenance::class,
            'v_customerId',
            'v_customerId'
        );
    }
}
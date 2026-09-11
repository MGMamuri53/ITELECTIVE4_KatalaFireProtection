<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    /** @use HasFactory<UserFactory> */
    use HasApiTokens, HasFactory, Notifiable;

    protected $table = 'tbl_user';

    protected $primaryKey = 'v_userId';

    const CREATED_AT = 'v_createdAt';
    const UPDATED_AT = 'v_updatedAt';

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'v_roleId',
        'v_customerId',
        'v_userName',
        'v_passwordHash',
        'v_firstName',
        'v_lastName',
        'v_emailAddress',
        'v_mobileNumber',
        'v_accountStatus',
        'v_isActive',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'v_passwordHash',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'v_lastLoginAt' => 'datetime',
            'v_isActive' => 'boolean',
        ];
    }
}

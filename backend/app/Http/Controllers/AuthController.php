<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Support\ActivityLogger;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $validated = $request->validate([
            'email' => 'required|email',
            'password' => 'required|string',
        ]);

        $user = User::query()
            ->where('v_emailAddress', $validated['email'])
            ->where('v_isActive', 1)
            ->first();

        if (!$user || !$this->passwordMatches($validated['password'], $user->v_passwordHash)) {
            throw ValidationException::withMessages([
                'email' => ['Invalid email or password.'],
            ]);
        }

        $updates = ['v_lastLoginAt' => now()];
        if (Hash::needsRehash($user->v_passwordHash)) {
            $updates['v_passwordHash'] = Hash::make($validated['password']);
        }
        $user->forceFill($updates)->save();

        $role = DB::table('tbl_role')
            ->where('v_roleId', $user->v_roleId)
            ->value('v_roleName') ?? 'Customer';

        return response()->json([
            'token' => $user->createToken('katala-app')->plainTextToken,
            'user' => $this->userPayload($user, $role),
        ]);
    }

    public function register(Request $request)
    {
        $validated = $request->validate([
            'first_name' => 'required|string|max:100',
            'last_name' => 'required|string|max:100',
            'email' => 'required|email|max:150|unique:tbl_user,v_emailAddress',
            'contact_number' => 'nullable|string|max:30',
            'password' => 'required|string|min:8',
        ]);

        return DB::transaction(function () use ($validated) {
            $customerId = DB::table('tbl_customer')->insertGetId([
                'v_customerType' => 'Individual',
                'v_firstName' => $validated['first_name'],
                'v_lastName' => $validated['last_name'],
                'v_emailAddress' => $validated['email'],
                'v_mobileNumber' => $validated['contact_number'] ?? null,
                'v_isActive' => 1,
            ], 'v_customerId');

            $roleId = DB::table('tbl_role')
                ->where('v_roleName', 'Customer')
                ->value('v_roleId');

            $user = User::create([
                'v_roleId' => $roleId,
                'v_customerId' => $customerId,
                'v_userName' => $validated['email'],
                'v_passwordHash' => Hash::make($validated['password']),
                'v_firstName' => $validated['first_name'],
                'v_lastName' => $validated['last_name'],
                'v_emailAddress' => $validated['email'],
                'v_mobileNumber' => $validated['contact_number'] ?? null,
                'v_accountStatus' => 'Active',
                'v_isActive' => 1,
            ]);

            return response()->json([
                'message' => 'Account created successfully.',
                'user' => $this->userPayload($user, 'Customer'),
            ], 201);
        });
    }

    public function me(Request $request)
    {
        $role = DB::table('tbl_role')
            ->where('v_roleId', $request->user()->v_roleId)
            ->value('v_roleName') ?? 'Customer';

        return response()->json([
            'user' => $this->userPayload($request->user(), $role),
        ]);
    }

    public function updateProfile(Request $request)
    {
        $validated = $request->validate([
            'first_name' => 'required|string|max:100',
            'last_name' => 'required|string|max:100',
            'mobile_number' => 'nullable|string|max:30',
        ]);

        $user = $request->user();
        $user->forceFill([
            'v_firstName' => $validated['first_name'],
            'v_lastName' => $validated['last_name'],
            'v_mobileNumber' => $validated['mobile_number'] ?? null,
            'v_updatedAt' => now(),
        ])->save();

        ActivityLogger::record(
            (int) $user->v_userId,
            'updated',
            'tbl_user',
            (int) $user->v_userId,
            'Updated account profile.',
            $request->ip(),
        );

        return response()->json([
            'message' => 'Profile updated.',
            'user' => $this->userPayload($user->refresh(), $this->roleName($user)),
        ]);
    }

    public function updatePassword(Request $request)
    {
        $validated = $request->validate([
            'current_password' => 'required|string',
            'new_password' => 'required|string|min:8|confirmed',
        ]);

        $user = $request->user();
        if (!$this->passwordMatches($validated['current_password'], $user->v_passwordHash)) {
            throw ValidationException::withMessages([
                'current_password' => ['The current password is incorrect.'],
            ]);
        }

        $user->forceFill([
            'v_passwordHash' => Hash::make($validated['new_password']),
            'v_updatedAt' => now(),
        ])->save();

        ActivityLogger::record(
            (int) $user->v_userId,
            'updated',
            'tbl_user',
            (int) $user->v_userId,
            'Changed account password.',
            $request->ip(),
        );

        return response()->json(['message' => 'Password updated.']);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()?->delete();

        return response()->json(['message' => 'Logged out successfully.']);
    }

    private function userPayload(User $user, string $role): array
    {
        return [
            'id' => $user->v_userId,
            'customer_id' => $user->v_customerId,
            'role' => $role,
            'first_name' => $user->v_firstName,
            'last_name' => $user->v_lastName,
            'email' => $user->v_emailAddress,
            'contact_number' => $user->v_mobileNumber,
        ];
    }

    private function roleName(User $user): string
    {
        return DB::table('tbl_role')
            ->where('v_roleId', $user->v_roleId)
            ->value('v_roleName') ?? 'Customer';
    }

    private function passwordMatches(string $plainTextPassword, ?string $storedHash): bool
    {
        if (!$storedHash) {
            return false;
        }

        try {
            if (Hash::check($plainTextPassword, $storedHash)) {
                return true;
            }
        } catch (\RuntimeException) {
            // Some imported Supabase records use $2b$ bcrypt hashes. PHP can
            // verify those even when Laravel's strict hasher rejects the marker.
        }

        return password_verify($plainTextPassword, $storedHash);
    }
}

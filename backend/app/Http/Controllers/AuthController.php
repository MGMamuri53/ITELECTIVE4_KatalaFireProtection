<?php

namespace App\Http\Controllers;

use App\Models\User;
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

        if (!$user || !Hash::check($validated['password'], $user->v_passwordHash)) {
            throw ValidationException::withMessages([
                'email' => ['Invalid email or password.'],
            ]);
        }

        $user->forceFill([
            'v_lastLoginAt' => now(),
        ])->save();

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

            $roleId = DB::table('tbl_role')
                ->where('v_roleName', 'Customer')
                ->where('v_isActive', 1)
                ->value('v_roleId');

            if (!$roleId) {
                return response()->json([
                    'message' => 'Customer role is not configured.',
                ], 500);
            }

            $customerId = DB::table('tbl_customer')->insertGetId([
                'v_customerType' => 'Individual',
                'v_firstName' => $validated['first_name'],
                'v_lastName' => $validated['last_name'],
                'v_emailAddress' => $validated['email'],
                'v_mobileNumber' => $validated['contact_number'] ?? null,
                'v_isActive' => 1,
            ], 'v_customerId');

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

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()?->delete();

        return response()->json([
            'message' => 'Logged out successfully.',
        ]);
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
}
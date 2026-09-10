<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\DB;
use Symfony\Component\HttpFoundation\Response;

class SupabaseAuth
{
    public function handle(Request $request, Closure $next): Response
    {
        $token = $request->bearerToken();

        if (!$token) {
            return response()->json([
                'message' => 'Unauthenticated.'
            ], 401);
        }

        try {
            $response = Http::withHeaders([
                'apikey' => env('SUPABASE_ANON_KEY'),
                'Authorization' => 'Bearer ' . $token,
            ])->get(
                env('SUPABASE_URL') . '/auth/v1/user'
            );

            if (!$response->successful()) {
                return response()->json([
                    'message' => 'Unauthenticated.'
                ], 401);
            }

            $user = $response->json();
            $email = $user['email'] ?? null;

            if (!$email) {
                return response()->json([
                    'message' => 'Unauthenticated.'
                ], 401);
            }

           $customer = DB::table('tbl_customer')
    ->where('v_emailAddress', $email)
    ->where('v_isActive', 1)
    ->first();

// Temporary test-account mapping
if (!$customer && $email === 'ajparis1003@gmail.com') {
    $customer = DB::table('tbl_customer')
        ->where('v_customerId', 1)
        ->where('v_isActive', 1)
        ->first();
}

if (!$customer) {
    return response()->json([
        'message' => 'Customer profile not found.'
    ], 403);
}

            $request->attributes->set(
                'authenticated_customer_id',
                $customer->v_customerId
            );

            return $next($request);

        } catch (\Throwable $e) {
            return response()->json([
                'message' => 'Authentication failed.'
            ], 401);
        }
    }
}
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Symfony\Component\HttpFoundation\Response;

class AdminMiddleware
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if (!$user) {
            return response()->json([
                'message' => 'Unauthenticated.',
            ], 401);
        }

        $isAdmin = DB::table('tbl_role')
            ->where('v_roleId', $user->v_roleId)
            ->where('v_roleName', 'Admin')
            ->where('v_isActive', 1)
            ->exists();

        if (!$isAdmin) {
            return response()->json([
                'message' => 'Forbidden. Admin access required.',
            ], 403);
        }

        return $next($request);
    }
}
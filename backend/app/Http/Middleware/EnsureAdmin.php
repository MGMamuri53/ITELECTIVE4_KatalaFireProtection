<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Symfony\Component\HttpFoundation\Response;

class EnsureAdmin
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();
        $role = $user
            ? DB::table('tbl_role')->where('v_roleId', $user->v_roleId)->value('v_roleName')
            : null;

        if (strtolower((string) $role) !== 'admin') {
            return response()->json(['message' => 'Administrator access required.'], 403);
        }

        return $next($request);
    }
}

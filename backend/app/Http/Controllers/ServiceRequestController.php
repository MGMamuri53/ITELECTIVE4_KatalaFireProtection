<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ServiceRequestController extends Controller
{
    public function store(Request $request)
    {
        $validated = $request->validate([
            'customer_id' => 'required|integer',
            'name' => 'required|string',
            'email' => 'required|email',
            'contact_number' => 'nullable|string',
            'service' => 'required|string',
            'location' => 'nullable|string',
            'details' => 'nullable|string',
        ]);

        $customer = DB::table('tbl_customer')
            ->where('v_customerId', $validated['customer_id'])
            ->where('v_isActive', 1)
            ->first();

        if (!$customer) {
            return response()->json([
                'message' => 'Customer profile not found.'
            ], 403);
        }

        $requestNumber = 'REQ-' . strtoupper(uniqid());

        $serviceRequestId = DB::table('tbl_serviceRequest')->insertGetId([
            'v_serviceRequestNumber' => $requestNumber,
            'v_customerId' => $validated['customer_id'],
            'v_projectName' => $validated['name'],
            'v_projectLocation' => $validated['location'] ?? null,
            'v_projectRequirements' => $validated['details'] ?? null,
            'v_requestStatus' => 'Pending',
        ]);

        return response()->json([
            'message' => 'Service request submitted successfully.',
            'request_number' => $requestNumber,
            'request_id' => $serviceRequestId,
        ], 201);
    }
}
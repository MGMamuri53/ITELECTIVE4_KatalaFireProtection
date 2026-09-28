<?php

namespace App\Http\Controllers;

use App\Support\ActivityLogger;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ServiceRequestController extends Controller
{
    public function store(Request $request)
    {
        $request->merge([
            'customer_id' => $request->user()->v_customerId,
        ]);

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

        $service = DB::table('tbl_service')
            ->where('v_serviceName', $validated['service'])
            ->where('v_isActive', true)
            ->first();
        if (!$service) {
            return response()->json(['message' => 'Selected service is unavailable.'], 422);
        }

        $requestNumber = 'REQ-' . strtoupper(uniqid());

        $serviceRequestId = DB::table('tbl_serviceRequest')->insertGetId([
            'v_serviceRequestNumber' => $requestNumber,
            'v_customerId' => $validated['customer_id'],
            'v_serviceId' => $service->v_serviceId,
            'v_projectName' => $validated['name'],
            'v_projectType' => $validated['service'],
            'v_projectLocation' => $validated['location'] ?? null,
            'v_projectRequirements' => $validated['details'] ?? null,
            'v_requestStatus' => 'Pending',
        ], 'v_serviceRequestId');

        ActivityLogger::record(
            (int) $request->user()->v_userId,
            'created',
            'tbl_serviceRequest',
            (int) $serviceRequestId,
            "Submitted service request {$requestNumber}.",
            $request->ip(),
        );

        return response()->json([
            'message' => 'Service request submitted successfully.',
            'request_number' => $requestNumber,
            'request_id' => $serviceRequestId,
        ], 201);
    }
}

<?php

namespace App\Http\Controllers;

use App\Support\ActivityLogger;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ServiceRequestController extends Controller
{
    public function myRequests(Request $request)
    {
        $customerId = $request->user()->v_customerId;

        $requests = DB::table('tbl_serviceRequest as sr')
            ->leftJoin('tbl_service as s', 'sr.v_serviceId', '=', 's.v_serviceId')
            ->where('sr.v_customerId', $customerId)
            ->orderBy('sr.v_createdAt', 'desc')
            ->select(
                'sr.v_serviceRequestId as id',
                'sr.v_serviceRequestNumber as request_number',
                'sr.v_projectName as project_name',
                'sr.v_projectType as project_type',
                'sr.v_projectLocation as location',
                'sr.v_projectRequirements as details',
                'sr.v_requestStatus as status',
                'sr.v_createdAt as created_at',
                's.v_serviceName as service_name',
                's.v_serviceCategory as category'
            )
            ->get();

        return response()->json($requests);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string',
            'email' => 'required|email',
            'contact_number' => 'nullable|string',
            'service' => 'required|string',
            'location' => 'nullable|string',
            'details' => 'nullable|string',
        ]);

        $customerId = $request->user()->v_customerId;
        if (!$customerId) {
            $customerId = $this->resolveCustomerIdForUser($request, $validated);
        }
        $validated['customer_id'] = $customerId;

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

    private function resolveCustomerIdForUser(Request $request, array $validated): ?int
    {
        $user = $request->user();
        $email = $validated['email'] ?: $user->v_emailAddress;
        $name = trim((string) $validated['name']);

        $customer = DB::table('tbl_customer')
            ->where('v_emailAddress', $email)
            ->where('v_isActive', 1)
            ->first();

        if ($customer) {
            $user->forceFill(['v_customerId' => $customer->v_customerId])->save();

            return (int) $customer->v_customerId;
        }

        $nameParts = preg_split('/\s+/', $name, 2, PREG_SPLIT_NO_EMPTY) ?: [];
        $firstName = $user->v_firstName ?: ($nameParts[0] ?? 'Customer');
        $lastName = $user->v_lastName ?: ($nameParts[1] ?? 'Account');

        $customerId = DB::table('tbl_customer')->insertGetId([
            'v_customerType' => 'Individual',
            'v_firstName' => $firstName,
            'v_lastName' => $lastName,
            'v_emailAddress' => $email,
            'v_mobileNumber' => ($validated['contact_number'] ?? null) ?: $user->v_mobileNumber,
            'v_isActive' => 1,
        ], 'v_customerId');

        $user->forceFill(['v_customerId' => $customerId])->save();

        return (int) $customerId;
    }
}

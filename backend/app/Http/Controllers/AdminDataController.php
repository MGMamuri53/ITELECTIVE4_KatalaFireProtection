<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AdminDataController extends Controller
{
    public function dashboard()
    {
        return response()->json([
            'total_products' => DB::table('tbl_product')->where('v_isActive', 1)->count(),
            'total_services' => DB::table('tbl_service')->where('v_isActive', 1)->count(),
            'pending_quotes' => DB::table('tbl_serviceRequest')->where('v_requestStatus', 'Pending')->count(),
            'recent_activities' => DB::table('tbl_serviceRequest as sr')
                ->join('tbl_customer as c', 'sr.v_customerId', '=', 'c.v_customerId')
                ->orderBy('sr.v_createdAt', 'desc')
                ->limit(5)
                ->select(
                    'sr.v_serviceRequestId as id',
                    'sr.v_projectName as project_name',
                    'sr.v_requestStatus as status',
                    'sr.v_createdAt as created_at',
                    DB::raw("CONCAT(COALESCE(c.v_firstName, ''), ' ', COALESCE(c.v_lastName, '')) as customer_name")
                )
                ->get(),
        ]);
    }

    public function customers()
    {
        return response()->json(
            DB::table('tbl_customer')
                ->orderBy('v_createdAt', 'desc')
                ->get()
                ->map(fn ($customer) => [
                    'id' => $customer->v_customerId,
                    'first_name' => $customer->v_firstName,
                    'last_name' => $customer->v_lastName,
                    'email' => $customer->v_emailAddress,
                    'contact_number' => $customer->v_mobileNumber,
                    'created_at' => $customer->v_createdAt,
                    'is_active' => (bool) $customer->v_isActive,
                ])
        );
    }

    public function services()
    {
        return response()->json(
            DB::table('tbl_service')
                ->where('v_isActive', 1)
                ->orderBy('v_createdAt', 'desc')
                ->get()
                ->map(fn ($service) => $this->servicePayload($service))
        );
    }

    public function storeService(Request $request)
    {
        $validated = $request->validate([
            'service_name' => 'required|string|max:150',
            'category' => 'nullable|string|max:100',
            'description' => 'nullable|string',
            'base_price' => 'nullable|numeric',
        ]);

        $id = DB::table('tbl_service')->insertGetId([
            'v_serviceName' => $validated['service_name'],
            'v_serviceCategory' => $validated['category'] ?? null,
            'v_serviceDescription' => $validated['description'] ?? null,
            'v_basePrice' => $validated['base_price'] ?? null,
            'v_isActive' => 1,
        ]);

        return response()->json(['id' => $id], 201);
    }

    public function updateService(Request $request, $id)
    {
        $validated = $request->validate([
            'service_name' => 'required|string|max:150',
            'category' => 'nullable|string|max:100',
            'description' => 'nullable|string',
            'base_price' => 'nullable|numeric',
        ]);

        DB::table('tbl_service')->where('v_serviceId', $id)->update([
            'v_serviceName' => $validated['service_name'],
            'v_serviceCategory' => $validated['category'] ?? null,
            'v_serviceDescription' => $validated['description'] ?? null,
            'v_basePrice' => $validated['base_price'] ?? null,
        ]);

        return response()->json(['message' => 'Service updated.']);
    }

    public function deleteService($id)
    {
        DB::table('tbl_service')->where('v_serviceId', $id)->update(['v_isActive' => 0]);

        return response()->json(['message' => 'Service removed.']);
    }

    public function requests()
    {
        return response()->json(
            DB::table('tbl_serviceRequest as sr')
                ->join('tbl_customer as c', 'sr.v_customerId', '=', 'c.v_customerId')
                ->leftJoin('tbl_service as s', 'sr.v_serviceId', '=', 's.v_serviceId')
                ->orderBy('sr.v_createdAt', 'desc')
                ->select(
                    'sr.v_serviceRequestId as id',
                    'sr.v_serviceRequestNumber as request_number',
                    'sr.v_projectName as project_name',
                    'sr.v_projectLocation as location',
                    'sr.v_projectRequirements as details',
                    'sr.v_requestStatus as status',
                    'sr.v_createdAt as created_at',
                    's.v_serviceName as service',
                    DB::raw("CONCAT(COALESCE(c.v_firstName, ''), ' ', COALESCE(c.v_lastName, '')) as customer_name"),
                    'c.v_emailAddress as email',
                    'c.v_mobileNumber as contact_number'
                )
                ->get()
        );
    }

    public function updateRequest(Request $request, $id)
    {
        $validated = $request->validate([
            'status' => 'required|string|max:50',
        ]);

        DB::table('tbl_serviceRequest')
            ->where('v_serviceRequestId', $id)
            ->update(['v_requestStatus' => $validated['status']]);

        return response()->json(['message' => 'Request updated.']);
    }

    public function projects()
    {
        return response()->json(
            DB::table('tbl_project')
                ->orderBy('v_createdAt', 'desc')
                ->get()
                ->map(fn ($project) => [
                    'id' => $project->v_projectId,
                    'project_name' => $project->v_projectName,
                    'category' => $project->v_projectStatus,
                    'description' => $project->v_projectDescription,
                    'location' => $project->v_projectLocation,
                    'created_at' => $project->v_createdAt,
                    'image_url' => null,
                ])
        );
    }

    public function appointments()
    {
        return response()->json([]);
    }

    private function servicePayload($service): array
    {
        return [
            'id' => $service->v_serviceId,
            'service_name' => $service->v_serviceName,
            'category' => $service->v_serviceCategory,
            'description' => $service->v_serviceDescription,
            'base_price' => $service->v_basePrice,
            'created_at' => $service->v_createdAt,
            'image_url' => null,
        ];
    }
}

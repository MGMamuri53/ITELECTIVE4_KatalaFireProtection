<?php

namespace App\Http\Controllers;

use App\Support\ActivityLogger;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class AdminDataController extends Controller
{
    public function dashboard()
    {
        $firstMonth = now()->startOfMonth()->subMonths(5);
        $requestVolume = collect(range(0, 5))->map(function ($offset) use ($firstMonth) {
            $from = $firstMonth->copy()->addMonths($offset);
            $to = $from->copy()->addMonth();

            return [
                'month' => $from->format('M'),
                'count' => DB::table('tbl_serviceRequest')
                    ->where('v_createdAt', '>=', $from)
                    ->where('v_createdAt', '<', $to)
                    ->count(),
            ];
        });

        return response()->json([
            'total_products' => DB::table('tbl_product')->where('v_isActive', 1)->count(),
            'total_services' => DB::table('tbl_service')->where('v_isActive', 1)->count(),
            'pending_quotes' => DB::table('tbl_serviceRequest')->where('v_requestStatus', 'Pending')->count(),
            'total_customers' => DB::table('tbl_customer')->where('v_isActive', true)->count(),
            'request_volume' => $requestVolume,
            'request_statuses' => DB::table('tbl_serviceRequest')
                ->select('v_requestStatus as status', DB::raw('COUNT(*) as count'))
                ->groupBy('v_requestStatus')
                ->orderBy('v_requestStatus')
                ->get(),
            'upcoming_appointments' => DB::table('tbl_maintenance as m')
                ->join('tbl_customer as c', 'm.v_customerId', '=', 'c.v_customerId')
                ->leftJoin('tbl_project as p', 'm.v_projectId', '=', 'p.v_projectId')
                ->where('m.v_scheduledDate', '>=', now())
                ->whereNotIn('m.v_maintenanceStatus', ['Completed', 'Cancelled'])
                ->orderBy('m.v_scheduledDate')
                ->limit(5)
                ->get([
                    'm.v_maintenanceId as id',
                    'm.v_scheduledDate as scheduled_date',
                    'm.v_maintenanceStatus as status',
                    'p.v_projectName as project_name',
                    DB::raw("CONCAT(COALESCE(\"c\".\"v_firstName\", ''), ' ', COALESCE(\"c\".\"v_lastName\", '')) as customer_name"),
                ]),
            'recent_activities' => DB::table('tbl_activityLog as al')
                ->leftJoin('tbl_user as u', 'al.v_userId', '=', 'u.v_userId')
                ->orderBy('al.v_createdAt', 'desc')
                ->limit(5)
                ->select(
                    'al.v_activityLogId as id',
                    'al.v_actionType as action_type',
                    'al.v_tableName as table_name',
                    'al.v_recordId as record_id',
                    'al.v_actionDescription as description',
                    'al.v_createdAt as created_at',
                    DB::raw("CONCAT(COALESCE(\"u\".\"v_firstName\", ''), ' ', COALESCE(\"u\".\"v_lastName\", '')) as user_name")
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
            DB::table('tbl_service as s')
                ->leftJoin('tbl_servicecategory as sc', 's.v_servicecategoryid', '=', 'sc.v_servicecategoryid')
                ->where(function ($query) {
                    $query->where('s.v_isActive', true)
                        ->orWhere('s.v_isactive', true);
                })
                ->orderByRaw('COALESCE("s"."v_createdat", "s"."v_createdAt") DESC')
                ->select('s.*', 'sc.v_categoryname as category_name')
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
        ], 'v_serviceId');

        ActivityLogger::record(
            (int) $request->user()->v_userId,
            'created',
            'tbl_service',
            (int) $id,
            "Created service {$validated['service_name']}.",
            $request->ip(),
        );

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

        $service = DB::table('tbl_service')->where('v_serviceId', $id)->first();
        abort_if(! $service, 404, 'Service not found.');

        DB::table('tbl_service')->where('v_serviceId', $id)->update([
            'v_serviceName' => $validated['service_name'],
            'v_serviceCategory' => $validated['category'] ?? null,
            'v_serviceDescription' => $validated['description'] ?? null,
            'v_basePrice' => $validated['base_price'] ?? null,
        ]);

        ActivityLogger::record(
            (int) $request->user()->v_userId,
            'updated',
            'tbl_service',
            (int) $id,
            "Updated service {$validated['service_name']}.",
            $request->ip(),
        );

        return response()->json(['message' => 'Service updated.']);
    }

    public function deleteService(Request $request, $id)
    {
        $service = DB::table('tbl_service')->where('v_serviceId', $id)->first();
        abort_if(! $service, 404, 'Service not found.');

        DB::table('tbl_service')->where('v_serviceId', $id)->update([
            'v_isActive' => false,
            'v_updatedAt' => now(),
        ]);
        ActivityLogger::record(
            (int) $request->user()->v_userId,
            'deleted',
            'tbl_service',
            (int) $id,
            "Archived service {$service->v_serviceName}.",
            $request->ip(),
        );

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
                    'sr.v_notes as admin_response',
                    'sr.v_createdAt as created_at',
                    's.v_serviceName as service',
                    DB::raw("CONCAT(COALESCE(\"c\".\"v_firstName\", ''), ' ', COALESCE(\"c\".\"v_lastName\", '')) as customer_name"),
                    'c.v_emailAddress as email',
                    'c.v_mobileNumber as contact_number'
                )
                ->get()
        );
    }

    public function updateRequest(Request $request, $id)
    {
        $validated = $request->validate([
            'status' => [
                'required',
                'string',
                Rule::in([
                    'Inquiry / Requirements',
                    'Design & Engineering',
                    'Quotation & Approvals',
                    'Payment Arrangement',
                    'Installation Progress',
                    'Completion & Warranty',
                    'Cancelled',
                ]),
            ],
            'admin_response' => 'nullable|string|max:10000',
        ]);

        $exists = DB::table('tbl_serviceRequest')
            ->where('v_serviceRequestId', $id)
            ->exists();
        abort_if(! $exists, 404, 'Service request not found.');

        DB::table('tbl_serviceRequest')
            ->where('v_serviceRequestId', $id)
            ->update([
                'v_requestStatus' => $validated['status'],
                'v_notes' => $validated['admin_response'] ?? null,
                'v_updatedAt' => now(),
            ]);

        ActivityLogger::record(
            (int) $request->user()->v_userId,
            'updated',
            'tbl_serviceRequest',
            (int) $id,
            "Updated request stage to {$validated['status']}.",
            $request->ip(),
        );

        return response()->json(['message' => 'Request updated.']);
    }

    public function projects()
    {
        return response()->json(
            DB::table('tbl_project')
                ->join(
                    'tbl_serviceRequest as sr',
                    'tbl_project.v_serviceRequestId',
                    '=',
                    'sr.v_serviceRequestId',
                )
                ->orderBy('tbl_project.v_createdAt', 'desc')
                ->select(
                    'tbl_project.*',
                    'sr.v_projectType as request_project_type',
                    'sr.v_serviceRequestNumber as request_number',
                    'sr.v_customerId as customer_id',
                    'sr.v_serviceId as service_id',
                )
                ->get()
                ->map(fn ($project) => [
                    'id' => $project->v_projectId,
                    'project_number' => $project->v_projectNumber,
                    'project_name' => $project->v_projectName,
                    'category' => $project->request_project_type ?? 'Uncategorized',
                    'description' => $project->v_projectDescription,
                    'location' => $project->v_projectLocation,
                    'service_request_id' => $project->v_serviceRequestId,
                    'request_number' => $project->request_number,
                    'customer_id' => $project->customer_id,
                    'service_id' => $project->service_id,
                    'status' => $project->v_projectStatus,
                    'target_completion_date' => $project->v_targetCompletionDate,
                    'completion_date' => $project->v_actualCompletionDate,
                    'created_at' => $project->v_createdAt,
                    'image_url' => $this->projectImageUrl(
                        $project->v_projectId,
                        $project->v_updatedAt ?? $project->v_createdAt,
                    ),
                ])
        );
    }

    public function publicProjects()
    {
        return response()->json(
            DB::table('tbl_project as p')
                ->join('tbl_serviceRequest as sr', 'p.v_serviceRequestId', '=', 'sr.v_serviceRequestId')
                ->leftJoin('tbl_service as s', 'sr.v_serviceId', '=', 's.v_serviceId')
                ->where(function ($query) {
                    $query->whereNull('p.v_projectStatus')
                        ->orWhere('p.v_projectStatus', '!=', 'Cancelled');
                })
                ->orderByDesc('p.v_createdAt')
                ->select(
                    'p.v_projectId as id',
                    'p.v_projectName as project_name',
                    DB::raw("COALESCE(\"sr\".\"v_projectType\", \"s\".\"v_serviceName\", 'General') as category"),
                    'p.v_projectDescription as description',
                    'p.v_projectLocation as location',
                    DB::raw("COALESCE(\"p\".\"v_projectStatus\", 'In Progress') as status"),
                    'p.v_actualCompletionDate as completion_date',
                    'p.v_updatedAt as image_version',
                )
                ->get()
                ->map(fn ($project) => [
                    'id' => $project->id,
                    'project_name' => $project->project_name,
                    'category' => $project->category,
                    'description' => $project->description,
                    'location' => $project->location,
                    'status' => $project->status,
                    'completion_date' => $project->completion_date,
                    'image_url' => $this->projectImageUrl(
                        $project->id,
                        $project->image_version,
                    ),
                ])
        );
    }

    public function uploadProjectImage(Request $request, $id)
    {
        $validated = $request->validate([
            'image' => 'required|image|mimes:jpeg,jpg,png,webp|max:10240',
        ]);

        abort_unless(
            DB::table('tbl_project')->where('v_projectId', $id)->exists(),
            404,
            'Project not found.',
        );

        $supabaseUrl = config('services.supabase.url');
        $serviceRoleKey = config('services.supabase.service_role_key');
        $bucket = config('services.supabase.storage_bucket');
        if (! $supabaseUrl || ! $serviceRoleKey || ! $bucket) {
            return response()->json([
                'message' => 'Project image storage is not configured. Set SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, and SUPABASE_STORAGE_BUCKET in the backend environment.',
            ], 503);
        }

        $image = $validated['image'];
        $contentType = $image->getMimeType();
        if (! in_array($contentType, ['image/jpeg', 'image/png', 'image/webp'], true)) {
            return response()->json(['message' => 'Unsupported image format.'], 422);
        }

        $objectPath = "projects/{$id}/cover";
        $response = Http::timeout(30)
            ->withHeaders([
                'Authorization' => "Bearer {$serviceRoleKey}",
                'apikey' => $serviceRoleKey,
                'Content-Type' => $contentType,
                'x-upsert' => 'true',
            ])
            ->withBody($image->getContent(), $contentType)
            ->post(
                rtrim($supabaseUrl, '/').'/storage/v1/object/'
                    .rawurlencode($bucket).'/'.$objectPath,
            );

        if ($response->failed()) {
            return response()->json([
                'message' => 'Supabase Storage rejected the image upload.',
                'storage_error' => $response->json('message'),
            ], 502);
        }

        ActivityLogger::record(
            (int) $request->user()->v_userId,
            'updated',
            'tbl_project',
            (int) $id,
            "Uploaded an image for project {$id}.",
            $request->ip(),
        );

        $version = now();
        DB::table('tbl_project')
            ->where('v_projectId', $id)
            ->update(['v_updatedAt' => $version]);

        return response()->json([
            'image_url' => $this->projectImageUrl(
                $id,
                $version,
            ),
        ]);
    }

    private function projectImageUrl($projectId, $version = null): ?string
    {
        $supabaseUrl = config('services.supabase.url');
        $bucket = config('services.supabase.storage_bucket');
        if (
            ! $supabaseUrl
            || ! $bucket
            || ! config('services.supabase.service_role_key')
        ) {
            return null;
        }

        $url = rtrim($supabaseUrl, '/')
            .'/storage/v1/object/public/'.rawurlencode($bucket)
            .'/projects/'.rawurlencode((string) $projectId).'/cover';
        if ($version !== null) {
            $url .= '?v='.rawurlencode((string) $version);
        }

        return $url;
    }

    public function storeProject(Request $request)
    {
        $validated = $request->validate([
            'service_request_id' => [
                'required',
                'integer',
                Rule::exists('tbl_serviceRequest', 'v_serviceRequestId'),
            ],
            'project_name' => 'required|string|max:150',
            'description' => 'nullable|string',
            'location' => 'nullable|string|max:255',
            'target_completion_date' => 'nullable|date',
            'status' => [
                'required',
                'string',
                Rule::in(['Planning', 'In Progress', 'Completed', 'Cancelled']),
            ],
        ]);

        $projectNumber = 'PRJ-'.Str::upper(Str::random(10));
        $id = DB::table('tbl_project')->insertGetId([
            'v_projectNumber' => $projectNumber,
            'v_serviceRequestId' => $validated['service_request_id'],
            'v_projectName' => $validated['project_name'],
            'v_projectDescription' => $validated['description'] ?? null,
            'v_projectLocation' => $validated['location'] ?? null,
            'v_targetCompletionDate' => $validated['target_completion_date'] ?? null,
            'v_projectStatus' => $validated['status'],
            'v_progressPercentage' => $validated['status'] === 'Completed' ? 100 : 0,
            'v_actualCompletionDate' => $validated['status'] === 'Completed'
                ? now()->toDateString()
                : null,
        ], 'v_projectId');

        ActivityLogger::record(
            (int) $request->user()->v_userId,
            'created',
            'tbl_project',
            (int) $id,
            "Created project {$validated['project_name']}.",
            $request->ip(),
        );

        return response()->json(['id' => $id, 'project_number' => $projectNumber], 201);
    }

    public function updateProject(Request $request, $id)
    {
        $validated = $request->validate([
            'service_request_id' => [
                'required',
                'integer',
                Rule::exists('tbl_serviceRequest', 'v_serviceRequestId'),
            ],
            'project_name' => 'required|string|max:150',
            'description' => 'nullable|string',
            'location' => 'nullable|string|max:255',
            'target_completion_date' => 'nullable|date',
            'status' => [
                'required',
                'string',
                Rule::in(['Planning', 'In Progress', 'Completed', 'Cancelled']),
            ],
        ]);

        $project = DB::table('tbl_project')->where('v_projectId', $id)->first();
        abort_if(! $project, 404, 'Project not found.');

        DB::table('tbl_project')
            ->where('v_projectId', $id)
            ->update([
                'v_serviceRequestId' => $validated['service_request_id'],
                'v_projectName' => $validated['project_name'],
                'v_projectDescription' => $validated['description'] ?? null,
                'v_projectLocation' => $validated['location'] ?? null,
                'v_targetCompletionDate' => $validated['target_completion_date'] ?? null,
                'v_projectStatus' => $validated['status'],
                'v_progressPercentage' => $validated['status'] === 'Completed'
                    ? 100
                    : $project->v_progressPercentage,
                'v_actualCompletionDate' => $validated['status'] === 'Completed'
                    ? ($project->v_actualCompletionDate ?? now()->toDateString())
                    : null,
                'v_updatedAt' => now(),
            ]);

        ActivityLogger::record(
            (int) $request->user()->v_userId,
            'updated',
            'tbl_project',
            (int) $id,
            "Updated project {$validated['project_name']}.",
            $request->ip(),
        );

        return response()->json(['message' => 'Project updated.']);
    }

    public function deleteProject(Request $request, $id)
    {
        $project = DB::table('tbl_project')->where('v_projectId', $id)->first();
        abort_if(! $project, 404, 'Project not found.');

        foreach ([
            'tbl_projectMaterial' => 'v_projectId',
            'tbl_projectBilling' => 'v_projectId',
            'tbl_payment' => 'v_projectId',
            'tbl_warranty' => 'v_projectId',
            'tbl_maintenance' => 'v_projectId',
        ] as $table => $column) {
            if (DB::table($table)->where($column, $id)->exists()) {
                return response()->json([
                    'message' => 'This project has linked operational records and cannot be deleted.',
                ], 409);
            }
        }

        DB::table('tbl_project')->where('v_projectId', $id)->delete();
        ActivityLogger::record(
            (int) $request->user()->v_userId,
            'deleted',
            'tbl_project',
            (int) $id,
            "Deleted project {$project->v_projectName}.",
            $request->ip(),
        );

        return response()->json(['message' => 'Project deleted.']);
    }

    public function appointments()
    {
        return response()->json(
            DB::table('tbl_maintenance as m')
                ->join('tbl_customer as c', 'm.v_customerId', '=', 'c.v_customerId')
                ->leftJoin('tbl_project as p', 'm.v_projectId', '=', 'p.v_projectId')
                ->leftJoin('tbl_service as s', 'm.v_serviceId', '=', 's.v_serviceId')
                ->orderBy('m.v_scheduledDate')
                ->select(
                    'm.v_maintenanceId as id',
                    'm.v_maintenanceNumber as appointment_number',
                    'm.v_maintenanceType as appt_type',
                    'm.v_scheduledDate as appointment_date',
                    'm.v_maintenanceStatus as status',
                    'm.v_customerId as customer_id',
                    'm.v_projectId as project_id',
                    'p.v_projectNumber as project_ref',
                    'p.v_projectName as project_name',
                    'c.v_customerId as customer_record_id',
                    DB::raw("CONCAT(COALESCE(\"c\".\"v_firstName\", ''), ' ', COALESCE(\"c\".\"v_lastName\", '')) as client_name"),
                    's.v_serviceName as service_name',
                )
                ->get()
        );
    }

    public function storeAppointment(Request $request)
    {
        $validated = $request->validate([
            'customer_id' => 'required|integer|exists:tbl_customer,v_customerId',
            'project_id' => 'required|integer|exists:tbl_project,v_projectId',
            'service_id' => 'nullable|integer|exists:tbl_service,v_serviceId',
            'type' => 'required|string|max:100',
            'scheduled_date' => 'required|date|after_or_equal:today',
        ]);

        $project = DB::table('tbl_project as p')
            ->join('tbl_serviceRequest as sr', 'p.v_serviceRequestId', '=', 'sr.v_serviceRequestId')
            ->where('p.v_projectId', $validated['project_id'])
            ->where('sr.v_customerId', $validated['customer_id'])
            ->select('p.v_projectLocation', 'p.v_projectName')
            ->first();
        if (! $project) {
            return response()->json([
                'message' => 'The selected project does not belong to the selected customer.',
            ], 422);
        }

        $number = 'APT-'.Str::upper(Str::random(10));
        $id = DB::table('tbl_maintenance')->insertGetId([
            'v_maintenanceNumber' => $number,
            'v_customerId' => $validated['customer_id'],
            'v_projectId' => $validated['project_id'],
            'v_serviceId' => $validated['service_id'] ?? null,
            'v_maintenanceType' => $validated['type'],
            'v_equipmentSystemDescription' => $project->v_projectName,
            'v_location' => $project->v_projectLocation,
            'v_scheduledDate' => $validated['scheduled_date'],
            'v_maintenanceStatus' => 'Pending',
        ], 'v_maintenanceId');

        ActivityLogger::record(
            (int) $request->user()->v_userId,
            'created',
            'tbl_maintenance',
            (int) $id,
            "Scheduled appointment {$number}.",
            $request->ip(),
        );

        return response()->json(['id' => $id, 'appointment_number' => $number], 201);
    }

    public function updateAppointmentStatus(Request $request, $id)
    {
        $validated = $request->validate([
            'status' => ['required', 'string', Rule::in(['Pending', 'Confirmed', 'Completed', 'Cancelled'])],
        ]);

        $exists = DB::table('tbl_maintenance')->where('v_maintenanceId', $id)->exists();
        abort_if(! $exists, 404, 'Appointment not found.');

        DB::table('tbl_maintenance')
            ->where('v_maintenanceId', $id)
            ->update([
                'v_maintenanceStatus' => $validated['status'],
                'v_completedDate' => $validated['status'] === 'Completed' ? now() : null,
                'v_updatedAt' => now(),
            ]);

        ActivityLogger::record(
            (int) $request->user()->v_userId,
            'updated',
            'tbl_maintenance',
            (int) $id,
            "Updated appointment status to {$validated['status']}.",
            $request->ip(),
        );

        return response()->json(['message' => 'Appointment status updated.']);
    }

    private function servicePayload($service): array
    {
        $id = $service->v_serviceId ?? $service->v_serviceid;
        $serviceName = $service->v_serviceName ?? $service->v_servicename;
        $category = $service->v_serviceCategory
            ?? $service->v_servicecategory
            ?? $service->category_name;
        $description = $service->v_serviceDescription
            ?? $service->v_servicedescription;
        $basePrice = $service->v_basePrice
            ?? $service->v_minprice
            ?? $service->v_maxprice;

        return [
            'id' => $id,
            'v_serviceId' => $service->v_serviceId,
            'v_serviceid' => $service->v_serviceid,
            'service_name' => $serviceName,
            'category' => $category,
            'description' => $description,
            'requirements' => $service->v_servicerequirements,
            'estimated_duration' => $service->v_estimatedduration,
            'base_price' => $basePrice,
            'min_price' => $service->v_minprice,
            'max_price' => $service->v_maxprice,
            'is_inspection_required' => (bool) ($service->v_isinspectionrequired ?? false),
            'created_at' => $service->v_createdAt ?? $service->v_createdat,
            'image_url' => $service->v_serviceimageurl,
        ];
    }
}

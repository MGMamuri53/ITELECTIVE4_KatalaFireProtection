<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\AdminDataController;
use App\Http\Controllers\OrderController;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\ServiceRequestController;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

Route::get('/hello', function () {
    return response()->json([
        'message' => 'Hello from Laravel!'
    ]);
});
Route::get('/products', [ProductController::class, 'index']);

Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/me', [AuthController::class, 'me']);
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::post('/orders', [OrderController::class, 'store']);
    Route::get('/orders/my', [OrderController::class, 'myOrders']);
    Route::get('/orders/customer/{customerId}', [OrderController::class, 'customerOrders']);
    Route::post('/service-requests', [ServiceRequestController::class, 'store']);

    Route::get('/admin/dashboard', [AdminDataController::class, 'dashboard']);
    Route::post('/admin/products', [ProductController::class, 'store']);
    Route::put('/admin/products/{id}', [ProductController::class, 'update']);
    Route::delete('/admin/products/{id}', [ProductController::class, 'destroy']);
    Route::get('/admin/customers', [AdminDataController::class, 'customers']);
    Route::get('/admin/accounts', [AdminDataController::class, 'customers']);
    Route::get('/admin/services', [AdminDataController::class, 'services']);
    Route::post('/admin/services', [AdminDataController::class, 'storeService']);
    Route::put('/admin/services/{id}', [AdminDataController::class, 'updateService']);
    Route::delete('/admin/services/{id}', [AdminDataController::class, 'deleteService']);
    Route::get('/admin/requests', [AdminDataController::class, 'requests']);
    Route::put('/admin/requests/{id}', [AdminDataController::class, 'updateRequest']);
    Route::get('/admin/projects', [AdminDataController::class, 'projects']);
    Route::get('/admin/appointments', [AdminDataController::class, 'appointments']);
});

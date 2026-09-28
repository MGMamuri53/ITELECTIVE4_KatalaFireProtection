<?php

use App\Http\Controllers\AdminDataController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\OrderController;
use App\Http\Controllers\ProductController;
use App\Http\Controllers\ServiceRequestController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

Route::get('/hello', function () {
    return response()->json([
        'message' => 'Hello from Laravel!',
    ]);
});
Route::get('/products', [ProductController::class, 'index']);

Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);
Route::get('/services', [AdminDataController::class, 'services']);
Route::get('/projects', [AdminDataController::class, 'publicProjects']);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/me', [AuthController::class, 'me']);
    Route::put('/me/profile', [AuthController::class, 'updateProfile']);
    Route::put('/me/password', [AuthController::class, 'updatePassword']);
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::post('/orders', [OrderController::class, 'store']);
    Route::get('/orders/my', [OrderController::class, 'myOrders']);
    Route::get('/orders/customer/{customerId}', [OrderController::class, 'customerOrders']);
    Route::post('/service-requests', [ServiceRequestController::class, 'store']);

    Route::middleware('admin')->prefix('admin')->group(function () {
        Route::get('/dashboard', [AdminDataController::class, 'dashboard']);
        Route::post('/products', [ProductController::class, 'store']);
        Route::post('/products/{id}/image', [ProductController::class, 'uploadImage']);
        Route::put('/products/{id}', [ProductController::class, 'update']);
        Route::delete('/products/{id}', [ProductController::class, 'destroy']);
        Route::get('/customers', [AdminDataController::class, 'customers']);
        Route::get('/accounts', [AdminDataController::class, 'customers']);
        Route::get('/services', [AdminDataController::class, 'services']);
        Route::post('/services', [AdminDataController::class, 'storeService']);
        Route::put('/services/{id}', [AdminDataController::class, 'updateService']);
        Route::delete('/services/{id}', [AdminDataController::class, 'deleteService']);
        Route::get('/requests', [AdminDataController::class, 'requests']);
        Route::put('/requests/{id}', [AdminDataController::class, 'updateRequest']);
        Route::get('/projects', [AdminDataController::class, 'projects']);
        Route::post('/projects', [AdminDataController::class, 'storeProject']);
        Route::put('/projects/{id}', [AdminDataController::class, 'updateProject']);
        Route::post('/projects/{id}/image', [AdminDataController::class, 'uploadProjectImage']);
        Route::delete('/projects/{id}', [AdminDataController::class, 'deleteProject']);
        Route::get('/appointments', [AdminDataController::class, 'appointments']);
        Route::post('/appointments', [AdminDataController::class, 'storeAppointment']);
        Route::put('/appointments/{id}', [AdminDataController::class, 'updateAppointmentStatus']);
    });
});

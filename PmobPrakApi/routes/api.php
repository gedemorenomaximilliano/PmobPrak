<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});

Route::post('/logout', [App\Http\Controllers\Api\AuthController::class, 'logout']);
Route::post('/login', [App\Http\Controllers\Api\AuthController::class, 'login']);

Route::get('/categories', [App\Http\Controllers\Api\CategoryController::class, 'index']);
Route::get('/categories/{category}', [App\Http\Controllers\Api\CategoryController::class, 'show']);
Route::get('/items', [App\Http\Controllers\Api\ItemController::class, 'index']);
Route::get('/items/{item}', [App\Http\Controllers\Api\ItemController::class, 'show']);
Route::get('/categories/{id}/items', [App\Http\Controllers\Api\ItemController::class, 'byCategory']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [App\Http\Controllers\Api\AuthController::class, 'logout']);
    
    Route::post('/user/profile', [App\Http\Controllers\Api\AuthController::class, 'updateProfile']);
    
    Route::apiResource('categories', App\Http\Controllers\Api\CategoryController::class)->except(['index', 'show']);
    Route::apiResource('items', App\Http\Controllers\Api\ItemController::class)->except(['index', 'show']);
    
    Route::post('/transactions', [App\Http\Controllers\Api\TransactionController::class, 'store']);
    Route::get('/transactions', [App\Http\Controllers\Api\TransactionController::class, 'index']);
    Route::get('/transactions/{transaction}', [App\Http\Controllers\Api\TransactionController::class, 'show']);
    
    Route::get('/favorites', [App\Http\Controllers\Api\FavoriteController::class, 'index']);
    Route::post('/favorites', [App\Http\Controllers\Api\FavoriteController::class, 'store']);
    Route::delete('/favorites/{item_id}', [App\Http\Controllers\Api\FavoriteController::class, 'destroy']);
    Route::post('/ratings', [App\Http\Controllers\Api\RatingController::class, 'store']);
    Route::delete('/ratings/{id}', [App\Http\Controllers\Api\RatingController::class, 'destroy']);
});

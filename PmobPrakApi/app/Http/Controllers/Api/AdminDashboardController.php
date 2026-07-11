<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Item;
use App\Models\Category;
use App\Models\Transaction;
use App\Models\User;
use Illuminate\Http\Request;

class AdminDashboardController extends Controller
{
    public function index()
    {
        $totalRevenue = Transaction::where('status', 'completed')
            ->sum('total_price');

        $totalOrders = Transaction::count();
        $totalItems = Item::count();
        $totalUsers = User::count();
        $totalCategories = Category::count();

        $isSqlite = \DB::connection()->getDriverName() === 'sqlite';
        $dateFormat = $isSqlite ? "strftime('%Y-%m', created_at)" : "DATE_FORMAT(created_at, '%Y-%m')";

        $monthlyRevenue = Transaction::selectRaw(
            "{$dateFormat} as month, SUM(total_price) as total"
        )
            ->where('status', 'completed')
            ->groupBy('month')
            ->orderBy('month', 'desc')
            ->limit(12)
            ->get()
            ->reverse()
            ->values();

        $monthlyUsers = User::selectRaw(
            "{$dateFormat} as month, COUNT(*) as count"
        )
            ->groupBy('month')
            ->orderBy('month', 'desc')
            ->limit(12)
            ->get()
            ->reverse()
            ->values();


        $recentOrders = Transaction::with('user')
            ->orderBy('created_at', 'desc')
            ->limit(5)
            ->get()
            ->map(function ($tx) {
                return [
                    'id' => $tx->id,
                    'user_name' => $tx->user?->name ?? 'Unknown',
                    'total_price' => $tx->total_price,
                    'status' => $tx->status,
                    'created_at' => $tx->created_at,
                ];
            });

        $recentUsers = User::orderBy('created_at', 'desc')
            ->limit(5)
            ->get()
            ->map(function ($u) {
                return [
                    'id' => $u->id,
                    'name' => $u->name,
                    'email' => $u->email,
                    'created_at' => $u->created_at,
                ];
            });

        return response()->json([
            'success' => true,
            'data' => [
                'total_revenue' => (float) $totalRevenue,
                'total_orders' => $totalOrders,
                'total_items' => $totalItems,
                'total_users' => $totalUsers,
                'total_categories' => $totalCategories,
                'monthly_revenue' => $monthlyRevenue,
                'monthly_users' => $monthlyUsers,
                'recent_orders' => $recentOrders,
                'recent_users' => $recentUsers,
            ],
        ]);
    }
}

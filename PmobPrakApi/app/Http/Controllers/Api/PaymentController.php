<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use Illuminate\Http\Request;
use Illuminate\Support\Str;
use Midtrans\Config;
use Midtrans\Snap;
use Midtrans\Notification;

class PaymentController extends Controller
{
    public function __construct()
    {
        Config::$serverKey = config('midtrans.server_key');
        Config::$clientKey = config('midtrans.client_key');
        Config::$isProduction = config('midtrans.production');
        Config::$is3ds = true;
    }

    public function createSnapToken(Request $request)
    {
        $request->validate([
            'order_id' => 'required|exists:transactions,id',
        ]);

        $transaction = Transaction::findOrFail($request->order_id);

        if ($transaction->snap_token && $transaction->payment_url) {
            return response()->json([
                'success' => true,
                'snap_token' => $transaction->snap_token,
                'redirect_url' => $transaction->payment_url,
            ]);
        }

        $user = $transaction->user;

        $orderId = 'ORDER-' . $transaction->id . '-' . Str::random(8);

        $params = [
            'transaction_details' => [
                'order_id' => $orderId,
                'gross_amount' => (int) $transaction->total_price,
            ],
            'customer_details' => [
                'first_name' => $user->name,
                'email' => $user->email,
                'phone' => $user->phone ?? '',
            ],
        ];

        $response = Snap::createTransaction($params);

        $transaction->snap_token = $response->token;
        $transaction->payment_url = $response->redirect_url;
        $transaction->midtrans_order_id = $orderId;
        $transaction->save();

        return response()->json([
            'success' => true,
            'snap_token' => $response->token,
            'redirect_url' => $response->redirect_url,
        ]);
    }

    public function notification(Request $request)
    {
        $notification = new Notification();

        $orderId = $notification->order_id;
        $transaction = Transaction::where('midtrans_order_id', $orderId)->first();

        if (!$transaction) {
            return response()->json(['message' => 'Transaction not found'], 404);
        }

        $statusMap = [
            'capture' => 'pending',
            'settlement' => 'completed',
            'pending' => 'pending',
            'deny' => 'failed',
            'cancel' => 'cancelled',
            'expire' => 'expired',
            'failure' => 'failed',
        ];

        $txStatus = $notification->transaction_status;
        $transaction->status = $statusMap[$txStatus] ?? $txStatus;
        $transaction->save();

        return response()->json(['message' => 'OK']);
    }
}

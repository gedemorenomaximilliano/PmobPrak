<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Item;
use App\Models\Transaction;
use App\Models\TransactionDetail;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class TransactionController extends Controller
{
    public function index()
    {
        $user = auth()->user();
        if ($user->role === 'admin') {
            $transactions = Transaction::with('details.item', 'user')
                ->latest()
                ->take(50)
                ->get();
        } else {
            $transactions = $user->transactions()
                ->with('details.item')
                ->latest()
                ->get();
        }

        return response()->json([
            'success' => true,
            'data' => $transactions
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'items' => 'required|array',
            'items.*.id' => 'required|exists:items,id',
            'items.*.quantity' => 'required|integer|min:1',
            'tax_rate' => 'nullable|numeric|min:0|max:1',
        ]);

        return DB::transaction(function () use ($request) {
            $totalPrice = 0;
            $itemsToProcess = [];

            foreach ($request->items as $itemData) {
                $item = Item::lockForUpdate()->find($itemData['id']);

                if ($item->stock < $itemData['quantity']) {
                    throw new \Exception("Insufficient stock for item: {$item->name}");
                }

                $price = $item->price * $itemData['quantity'];
                $totalPrice += $price;
                $itemsToProcess[] = [
                    'item' => $item,
                    'quantity' => $itemData['quantity'],
                    'price' => $item->price
                ];
            }

            $taxRate = $request->input('tax_rate', 0.11);
            $tax = round($totalPrice * $taxRate);
            $grandTotal = $totalPrice + $tax;

            $transaction = Transaction::create([
                'user_id' => auth()->id(),
                'total_price' => $grandTotal,
                'status' => 'pending',
            ]);

            foreach ($itemsToProcess as $processData) {
                TransactionDetail::create([
                    'transaction_id' => $transaction->id,
                    'item_id' => $processData['item']->id,
                    'quantity' => $processData['quantity'],
                    'price' => $processData['price']
                ]);

                $processData['item']->decrement('stock', $processData['quantity']);
            }

            return response()->json([
                'success' => true,
                'data' => $transaction->load('details.item')
            ], 201);
        });
    }

    public function show(Transaction $transaction)
    {
        $user = auth()->user();
        if ($user->role !== 'admin' && $transaction->user_id !== $user->id) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        return response()->json([
            'success' => true,
            'data' => $transaction->load('details.item')
        ]);
    }
}

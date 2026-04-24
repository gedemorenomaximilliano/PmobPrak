<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Favorite;
use Illuminate\Http\Request;

class FavoriteController extends Controller
{
    public function index()
    {
        return response()->json([
            'success' => true,
            'data' => auth()->user()->favorites()->with('item')->get()
        ]);
    }

    public function store(Request $request)
    {
        $request->validate(['item_id' => 'required|exists:items,id']);
        
        $fav = Favorite::firstOrCreate([
            'user_id' => auth()->id(),
            'item_id' => $request->item_id
        ]);
        
        return response()->json(['success' => true, 'message' => 'Added to favorites']);
    }

    public function destroy($itemId)
    {
        auth()->user()->favorites()->where('item_id', $itemId)->delete();
        return response()->json(['success' => true, 'message' => 'Removed from favorites']);
    }
}

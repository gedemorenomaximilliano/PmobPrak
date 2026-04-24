<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Rating;
use Illuminate\Http\Request;

class RatingController extends Controller
{
    public function store(Request $request)
    {
        $request->validate([
            'item_id' => 'required|exists:items,id',
            'rating' => 'required|integer|min:1|max:5',
            'comment' => 'nullable|string',
        ]);

        $rating = Rating::create([
            'user_id' => auth()->id(),
            'item_id' => $request->item_id,
            'rating' => $request->rating,
            'comment' => $request->comment,
        ]);

        return response()->json(['success' => true, 'data' => $rating], 201);
    }

    public function destroy($id)
    {
        $rating = Rating::where('id', $id)->where('user_id', auth()->id())->first();

        if (!$rating) {
            return response()->json(['success' => false, 'message' => 'Rating not found or unauthorized'], 404);
        }

        $rating->delete();

        return response()->json(['success' => true, 'message' => 'Comment deleted successfully']);
    }
}

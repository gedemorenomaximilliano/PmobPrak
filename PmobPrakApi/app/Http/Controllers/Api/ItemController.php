<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Item;
use Illuminate\Http\Request;

class ItemController extends Controller
{
    public function index()
    {
        return response()->json([
            'success' => true,
            'data' => Item::with(['category:id,name', 'itineraryItems'])
                ->select(['id', 'category_id', 'name', 'description', 'location', 'price', 'stock', 'rating', 'image', 'itinerary', 'date_start', 'date_end', 'created_at', 'updated_at'])
                ->orderBy('created_at', 'desc')
                ->get()
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'category_id' => 'required|exists:categories,id',
            'name' => 'required',
            'description' => 'required',
            'price' => 'required|numeric',
            'stock' => 'required|integer',
            'itinerary' => 'nullable|string',
            'itinerary_items' => 'nullable|string',
            'image_file' => 'required|image|mimes:jpeg,png,jpg,gif|max:2048',
            'extra_images' => 'nullable|array',
            'extra_images.*' => 'image|mimes:jpeg,png,jpg,gif|max:2048'
        ]);

        $data = $request->except(['image_file', 'extra_images', 'itinerary_items']);

        // Main thumbnail
        if ($request->hasFile('image_file')) {
            $data['image'] = $this->convertFileToBase64($request->file('image_file'));
        }

        $item = Item::create($data);

        // Extra images
        if ($request->hasFile('extra_images')) {
            foreach ($request->file('extra_images') as $file) {
                \App\Models\ItemImage::create([
                    'item_id' => $item->id,
                    'image' => $this->convertFileToBase64($file)
                ]);
            }
        }

        // Itinerary items
        if ($request->filled('itinerary_items')) {
            $itineraryItems = json_decode($request->input('itinerary_items'), true);
            if (is_array($itineraryItems)) {
                foreach ($itineraryItems as $i => $ii) {
                    $item->itineraryItems()->create([
                        'time' => $ii['time'] ?? '',
                        'activity' => $ii['activity'] ?? '',
                        'sort_order' => $i,
                    ]);
                }
            }
        }

        return response()->json([
            'success' => true,
            'data' => $item->load(['images', 'itineraryItems'])
        ], 201);
    }

    private function convertFileToBase64($file)
    {
        $path = $file->getRealPath();
        $type = $file->getClientOriginalExtension();
        return 'data:image/' . $type . ';base64,' . base64_encode(file_get_contents($path));
    }

    public function show(Item $item)
    {
        return response()->json([
            'success' => true,
            'data' => $item->load(['category', 'images', 'ratings.user', 'itineraryItems'])
        ]);
    }

    public function update(Request $request, Item $item)
    {
        $request->validate([
            'category_id' => 'sometimes|exists:categories,id',
            'name' => 'sometimes|required',
            'description' => 'sometimes|required',
            'price' => 'sometimes|numeric',
            'stock' => 'sometimes|integer',
            'location' => 'sometimes|string',
            'date_start' => 'sometimes|date',
            'date_end' => 'sometimes|date',
            'itinerary' => 'nullable|string',
            'itinerary_items' => 'nullable|string',
            'image_file' => 'nullable|image|mimes:jpeg,png,jpg,gif|max:2048',
            'extra_images' => 'nullable|array',
            'extra_images.*' => 'image|mimes:jpeg,png,jpg,gif|max:2048',
        ]);

        $data = $request->except(['image_file', 'extra_images', '_method', 'itinerary_items']);

        if ($request->hasFile('image_file')) {
            $data['image'] = $this->convertFileToBase64($request->file('image_file'));
        }

        $item->update($data);

        if ($request->hasFile('extra_images')) {
            foreach ($request->file('extra_images') as $file) {
                \App\Models\ItemImage::create([
                    'item_id' => $item->id,
                    'image' => $this->convertFileToBase64($file),
                ]);
            }
        }

        // Sync itinerary items
        if ($request->filled('itinerary_items')) {
            $itineraryItems = json_decode($request->input('itinerary_items'), true);
            if (is_array($itineraryItems)) {
                $item->itineraryItems()->delete();
                foreach ($itineraryItems as $i => $ii) {
                    $item->itineraryItems()->create([
                        'time' => $ii['time'] ?? '',
                        'activity' => $ii['activity'] ?? '',
                        'sort_order' => $i,
                    ]);
                }
            }
        }

        return response()->json([
            'success' => true,
            'data' => $item->load(['category', 'images', 'itineraryItems']),
        ]);
    }

    public function destroy(Item $item)
    {
        $item->delete();
        return response()->json([
            'success' => true,
            'message' => 'Item deleted'
        ]);
    }

    public function byCategory($categoryId)
    {
        $items = Item::where('category_id', $categoryId)->get();
        return response()->json([
            'success' => true,
            'data' => $items
        ]);
    }
}

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
            'data' => Item::with(['category', 'images'])->orderBy('created_at', 'desc')->get()
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
            'image_file' => 'required|image|mimes:jpeg,png,jpg,gif|max:2048',
            'extra_images' => 'nullable|array',
            'extra_images.*' => 'image|mimes:jpeg,png,jpg,gif|max:2048'
        ]);

        $data = $request->except(['image_file', 'extra_images']);

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

        return response()->json([
            'success' => true,
            'data' => $item->load('images')
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
            'data' => $item->load(['category', 'images', 'ratings.user'])
        ]);
    }

    public function update(Request $request, Item $item)
    {
        $item->update($request->all());
        return response()->json([
            'success' => true,
            'data' => $item
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

<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Item extends Model
{
    use HasFactory;

    protected $fillable = [
        'category_id',
        'name',
        'description',
        'location',
        'price',
        'stock',
        'image',
        'itinerary',
        'rating',
        'date_start',
        'date_end'
    ];

    public function category()
    {
        return $this->belongsTo(Category::class);
    }

    public function images()
    {
        return $this->hasMany(ItemImage::class);
    }

    public function ratings()
    {
        return $this->hasMany(Rating::class);
    }

    public function itineraryItems()
    {
        return $this->hasMany(ItineraryItem::class)->orderBy('sort_order');
    }
}

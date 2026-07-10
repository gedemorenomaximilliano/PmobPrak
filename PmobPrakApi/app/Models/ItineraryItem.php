<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ItineraryItem extends Model
{
    protected $fillable = [
        'item_id',
        'time',
        'activity',
        'sort_order',
    ];

    public function item()
    {
        return $this->belongsTo(Item::class);
    }
}

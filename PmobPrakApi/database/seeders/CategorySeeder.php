<?php

namespace Database\Seeders;

use App\Models\Category;
use Illuminate\Database\Seeder;

class CategorySeeder extends Seeder
{
    public function run(): void
    {
        $categories = [
            ['name' => 'Alam', 'image' => 'alam.jpg'],
            ['name' => 'Budaya', 'image' => 'budaya.jpg'],
            ['name' => 'Kuliner', 'image' => 'kuliner.jpg'],
        ];

        foreach ($categories as $category) {
            Category::firstOrCreate(
                ['name' => $category['name']],
                ['image' => $category['image']]
            );
        }
    }
}

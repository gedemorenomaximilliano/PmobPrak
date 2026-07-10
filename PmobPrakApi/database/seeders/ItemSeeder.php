<?php

namespace Database\Seeders;

use App\Models\Item;
use App\Models\Category;
use Illuminate\Database\Seeder;

class ItemSeeder extends Seeder
{
    public function run(): void
    {
        $alam = Category::where('name', 'Alam')->first();
        
        $destinations = [
            [
                'name' => 'Teluk Hijau',
                'description' => 'Pantai dengan air berwarna hijau toska yang jernih dan dikelilingi hutan tropis yang lebat.',
                'price' => 75000,
                'stock' => 50,
                'location' => 'Pesanggaran, Banyuwangi',
                'date_start' => '2026-05-01',
                'date_end' => '2026-12-31',
                'rating' => 4.7
            ],
            [
                'name' => 'Taman Nasional Baluran',
                'description' => 'Dijuluki Africa van Java, tempat ini memiliki padang savana luas dan satwa liar.',
                'price' => 100000,
                'stock' => 150,
                'location' => 'Banyuputih, Situbondo/Banyuwangi',
                'date_start' => '2026-04-25',
                'date_end' => '2026-12-31',
                'rating' => 4.9
            ],
            [
                'name' => 'Pantai Boom',
                'description' => 'Destinasi wisata kota dengan pemandangan dermaga dan festival seni budaya.',
                'price' => 10000,
                'stock' => 500,
                'location' => 'Pusat Kota Banyuwangi',
                'date_start' => '2026-04-25',
                'date_end' => '2026-12-31',
                'rating' => 4.4
            ],
            [
                'name' => 'Pulau Menjangan',
                'description' => 'Surga bagi para penyelam dengan terumbu karang yang sangat cantik dan air yang jernih.',
                'price' => 250000,
                'stock' => 30,
                'location' => 'Perairan Banyuwangi Utara',
                'date_start' => '2026-06-01',
                'date_end' => '2026-09-30',
                'rating' => 4.9
            ],
        ];

        $getImageBase64 = function($filename) {
            $paths = [
                database_path('seeders/images/' . $filename),
                base_path('../assets/images/' . $filename),
                base_path('assets/images/' . $filename),
                database_path('seeders/' . $filename),
            ];

            foreach ($paths as $path) {
                if (file_exists($path)) {
                    $mime = 'image/jpeg';
                    if (str_ends_with($filename, '.png')) {
                        $mime = 'image/png';
                    }
                    return 'data:' . $mime . ';base64,' . base64_encode(file_get_contents($path));
                }
            }

            // Fallback to a valid tiny transparent 1x1 PNG base64 if not found
            return 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=';
        };

        $images = [
            'Teluk Hijau' => $getImageBase64('acidicLake.jpg'),
            'Taman Nasional Baluran' => $getImageBase64('baluran.jpg'),
            'Pantai Boom' => $getImageBase64('de-djawatan.jp.jpg'), // maps to de-djawatan.jp.jpg in original
            'Pulau Menjangan' => $getImageBase64('kawahijenvolcano.jpg'), // maps to kawahijenvolcano.jpg in original
        ];

        foreach ($destinations as $dest) {
            Item::firstOrCreate(
                ['name' => $dest['name']],
                [
                    'category_id' => $alam->id,
                    'description' => $dest['description'],
                    'price' => $dest['price'],
                    'stock' => $dest['stock'],
                    'location' => $dest['location'],
                    'date_start' => $dest['date_start'],
                    'date_end' => $dest['date_end'],
                    'rating' => $dest['rating'],
                    'image' => $images[$dest['name']],
                ]
            );
        }
    }
}

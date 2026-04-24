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

        $images = [
            'Teluk Hijau' => 'data:image/jpeg;base64,' . base64_encode(file_get_contents('../assets/images/acidicLake.jpg')),
            'Taman Nasional Baluran' => 'data:image/jpeg;base64,' . base64_encode(file_get_contents('../assets/images/baluran.jpg')),
            'Pantai Boom' => 'data:image/jpeg;base64,' . base64_encode(file_get_contents('../assets/images/de-djawatan.jp.jpg')),
            'Pulau Menjangan' => 'data:image/jpeg;base64,' . base64_encode(file_get_contents('../assets/images/kawahijenvolcano.jpg')),
        ];

        foreach ($destinations as $dest) {
            Item::create([
                'category_id' => $alam->id,
                ...$dest,
                'image' => $images[$dest['name']],
            ]);
        }
    }
}

class Destination {
  final String name;
  final double rating;
  final int reviews;
  final String price;
  final String image;
  final String desc;

  const Destination({
    required this.name,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.image,
    required this.desc,
  });
}

const List<Destination> kDestinations = [
  Destination(
    name: 'Kawah Ijen',
    rating: 4.9,
    reviews: 455,
    price: 'IDR 500K/pax',
    image:
        'https://images.unsplash.com/photo-1588668214407-6ea9a6d8c272?w=640&q=80',
    desc:
        'Ijen Crater is a majestic volcanic wonder famous for its '
        'turquoise acid lake and the rare, electric blue fire. '
        'A highlight of "The Sunrise of Java".',
  ),
  Destination(
    name: 'Green Bay',
    rating: 4.9,
    reviews: 455,
    price: 'IDR 350K/pax',
    image:
        'https://images.unsplash.com/photo-1505118380757-91f5f5632de0?w=640&q=80',
    desc:
        'A pristine hidden beach surrounded by lush green hills and '
        'crystal-clear turquoise waters. Only reachable by a scenic jungle trek.',
  ),
  Destination(
    name: 'Baluran',
    rating: 4.7,
    reviews: 320,
    price: 'IDR 200K/pax',
    image:
        'https://images.unsplash.com/photo-1547471080-7cc2caa01a7e?w=640&q=80',
    desc:
        'Known as "Africa van Java" for its stunning open savanna. '
        'Home to wild bulls, peacocks, and deer roaming freely.',
  ),
];

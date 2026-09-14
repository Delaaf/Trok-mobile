class ListingPreview {
  const ListingPreview({
    required this.id,
    required this.title,
    required this.price,
    required this.commune,
    required this.imageUrl,
    this.isNew = false,
    this.isFavorited = false,
  });

  final String id;
  final String title;
  final double price;
  final String commune;
  final String imageUrl;
  final bool isNew;
  final bool isFavorited;

  String get formattedPrice {
    final s = price.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final posFromEnd = s.length - i;
      buffer.write(s[i]);
      if (posFromEnd > 1 && posFromEnd % 3 == 1) buffer.write(' ');
    }
    return '${buffer.toString()} FCFA';
  }
}

/// Mock temporaire — à remplacer par GET /listings?commune=...
const mockNearbyListings = <ListingPreview>[
  ListingPreview(
    id: '1',
    title: 'Canapé 3 places gris',
    price: 75000,
    commune: 'Cocody',
    imageUrl: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400',
    isNew: true,
  ),
  ListingPreview(
    id: '2',
    title: 'iPhone 13 Pro 128 Go',
    price: 250000,
    commune: 'Angré',
    imageUrl: 'https://images.unsplash.com/photo-1592286927505-1def25115558?w=400',
  ),
  ListingPreview(
    id: '3',
    title: 'Robe wax élégante',
    price: 15000,
    commune: 'Cocody',
    imageUrl: 'https://images.unsplash.com/photo-1568252542512-9fe8fe9c87bb?w=400',
    isFavorited: true,
  ),
  ListingPreview(
    id: '4',
    title: 'MacBook Air M1',
    price: 450000,
    commune: 'Angré',
    imageUrl: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400',
  ),
];

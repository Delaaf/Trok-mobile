class ListingImageModel {
  const ListingImageModel({required this.id, required this.url, required this.position});

  final int id;
  final String url;
  final int position;

  factory ListingImageModel.fromJson(Map<String, dynamic> json) {
    return ListingImageModel(id: json['id'] as int, url: json['url'] as String, position: json['position'] as int);
  }
}

class ListingSellerModel {
  const ListingSellerModel({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    this.username,
    this.isVerifiedSeller = false,
    this.ratingAverage = 0,
  });

  final String id;
  final String fullName;
  final String? avatarUrl;
  final String? username;
  final bool isVerifiedSeller;
  final double ratingAverage;

  factory ListingSellerModel.fromJson(Map<String, dynamic> json) {
    return ListingSellerModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      username: json['username'] as String?,
      isVerifiedSeller: json['is_verified_seller'] as bool? ?? false,
      ratingAverage: (json['rating_average'] as num?)?.toDouble() ?? 0,
    );
  }
}

class ListingCategoryModel {
  const ListingCategoryModel({required this.id, required this.name, this.icon});

  final int id;
  final String name;
  final String? icon;

  factory ListingCategoryModel.fromJson(Map<String, dynamic> json) {
    return ListingCategoryModel(id: json['id'] as int, name: json['name'] as String, icon: json['icon'] as String?);
  }
}

class ListingModel {
  const ListingModel({
    required this.id,
    required this.title,
    required this.price,
    required this.condition,
    this.commune,
    this.city,
    required this.status,
    this.isFree = false,
    this.isNegotiable = false,
    this.acceptsExchange = false,
    this.isBoosted = false,
    this.isFavoritedByViewer = false,
    this.favoritesCount = 0,
    this.viewsCount = 0,
    this.images = const [],
    this.seller,
    this.publishedAt,
    this.createdAt,
    this.description,
    this.attributes = const {},
    this.category,
  });

  final String id;
  final String title;
  final double price;
  final String condition;
  final String? commune;
  final String? city;
  final String status;
  final bool isFree;
  final bool isNegotiable;
  final bool acceptsExchange;
  final bool isBoosted;
  final bool isFavoritedByViewer;
  final int favoritesCount;
  final int viewsCount;
  final List<ListingImageModel> images;
  final ListingSellerModel? seller;
  final DateTime? publishedAt;
  final DateTime? createdAt;
  final String? description;
  final Map<String, dynamic> attributes;
  final ListingCategoryModel? category;

  String get coverImageUrl => images.isNotEmpty ? images.first.url : '';

  /// true si publiée il y a moins de 7 jours — utilisé pour le badge "NEUF".
  bool get isRecentlyPublished {
    if (publishedAt == null) return false;
    return DateTime.now().difference(publishedAt!).inDays < 7;
  }

  String get conditionLabel {
    switch (condition) {
      case 'new':
        return 'Neuf';
      case 'like_new':
        return 'Comme neuf';
      case 'good':
        return 'Bon état';
      case 'fair':
        return 'État correct';
      case 'for_parts':
        return 'Pour pièces';
      default:
        return condition;
    }
  }

  String get formattedPrice {
    if (isFree) return 'Gratuit';
    final s = price.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final posFromEnd = s.length - i;
      buffer.write(s[i]);
      if (posFromEnd > 1 && posFromEnd % 3 == 1) buffer.write(' ');
    }
    return '${buffer.toString()} FCFA';
  }

  factory ListingModel.fromJson(Map<String, dynamic> json) {
    final sellerRaw = json['seller'];
    final categoryRaw = json['category'];

    return ListingModel(
      id: json['id'] as String,
      title: json['title'] as String,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      condition: json['condition'] as String? ?? 'good',
      commune: json['commune'] as String?,
      city: json['city'] as String?,
      status: json['status'] as String? ?? 'published',
      isFree: json['is_free'] as bool? ?? false,
      isNegotiable: json['is_negotiable'] as bool? ?? false,
      acceptsExchange: json['accepts_exchange'] as bool? ?? false,
      isBoosted: json['is_boosted'] as bool? ?? false,
      isFavoritedByViewer: json['is_favorited_by_viewer'] as bool? ?? false,
      favoritesCount: json['favorites_count'] as int? ?? 0,
      viewsCount: json['views_count'] as int? ?? 0,
      images: (json['images'] as List? ?? [])
          .map((e) => ListingImageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      seller: sellerRaw is Map ? ListingSellerModel.fromJson(Map<String, dynamic>.from(sellerRaw)) : null,
      publishedAt: json['published_at'] != null ? DateTime.tryParse(json['published_at'] as String) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      description: json['description'] as String?,
      attributes: json['attributes'] is Map ? Map<String, dynamic>.from(json['attributes'] as Map) : const {},
      category: categoryRaw is Map && (categoryRaw['id'] != null)
          ? ListingCategoryModel.fromJson(Map<String, dynamic>.from(categoryRaw))
          : null,
    );
  }
}

class PaginatedListings {
  const PaginatedListings({required this.items, required this.currentPage, required this.lastPage});

  final List<ListingModel> items;
  final int currentPage;
  final int lastPage;

  bool get hasMore => currentPage < lastPage;

  factory PaginatedListings.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List? ?? [];
    final meta = json['meta'] as Map<String, dynamic>? ?? {};

    return PaginatedListings(
      items: data.map((e) => ListingModel.fromJson(e as Map<String, dynamic>)).toList(),
      currentPage: meta['current_page'] as int? ?? 1,
      lastPage: meta['last_page'] as int? ?? 1,
    );
  }
}

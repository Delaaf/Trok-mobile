class PublicProfileModel {
  const PublicProfileModel({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    this.username,
    this.accountType,
    this.bio,
    this.city,
    this.commune,
    this.isVerifiedSeller = false,
    this.isBusiness = false,
    this.businessName,
    this.ratingAverage = 0,
    this.ratingCount = 0,
    this.listingsCount = 0,
    this.followersCount = 0,
    this.followingCount = 0,
    this.memberSince,
    this.isFollowedByViewer,
  });

  final String id;
  final String fullName;
  final String? avatarUrl;
  final String? username;
  final String? accountType; // 'buyer' | 'seller'
  final String? bio;
  final String? city;
  final String? commune;
  final bool isVerifiedSeller;
  final bool isBusiness;
  final String? businessName;
  final double ratingAverage;
  final int ratingCount;
  final int listingsCount;
  final int followersCount;
  final int followingCount;
  final DateTime? memberSince;
  final bool? isFollowedByViewer;

  factory PublicProfileModel.fromJson(Map<String, dynamic> json) {
    return PublicProfileModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      username: json['username'] as String?,
      accountType: json['account_type'] as String?,
      bio: json['bio'] as String?,
      city: json['city'] as String?,
      commune: json['commune'] as String?,
      isVerifiedSeller: json['is_verified_seller'] as bool? ?? false,
      isBusiness: json['is_business'] as bool? ?? false,
      businessName: json['business_name'] as String?,
      ratingAverage: (json['rating_average'] as num?)?.toDouble() ?? 0,
      ratingCount: json['rating_count'] as int? ?? 0,
      listingsCount: json['listings_count'] as int? ?? 0,
      followersCount: json['followers_count'] as int? ?? 0,
      followingCount: json['following_count'] as int? ?? 0,
      memberSince: json['member_since'] != null ? DateTime.tryParse(json['member_since'] as String) : null,
      isFollowedByViewer: json['is_followed_by_viewer'] as bool?,
    );
  }
}

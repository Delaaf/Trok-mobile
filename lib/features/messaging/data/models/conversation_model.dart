class ConversationListingPreview {
  const ConversationListingPreview({required this.id, required this.title, required this.price, this.coverImageUrl});

  final String id;
  final String title;
  final double price;
  final String? coverImageUrl;

  factory ConversationListingPreview.fromJson(Map<String, dynamic> json) {
    return ConversationListingPreview(
      id: json['id'] as String,
      title: json['title'] as String,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      coverImageUrl: json['cover_image_url'] as String?,
    );
  }
}

class ConversationParticipant {
  const ConversationParticipant({required this.id, required this.fullName, this.avatarUrl});

  final String id;
  final String fullName;
  final String? avatarUrl;

  factory ConversationParticipant.fromJson(Map<String, dynamic> json) {
    return ConversationParticipant(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}

class ConversationModel {
  const ConversationModel({
    required this.id,
    this.listing,
    required this.otherParticipant,
    this.lastMessageBody,
    this.lastMessageAt,
    this.unreadCount = 0,
  });

  final String id;
  final ConversationListingPreview? listing;
  final ConversationParticipant otherParticipant;
  final String? lastMessageBody;
  final DateTime? lastMessageAt;
  final int unreadCount;

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    final listingRaw = json['listing'];

    return ConversationModel(
      id: json['id'] as String,
      listing: listingRaw is Map ? ConversationListingPreview.fromJson(Map<String, dynamic>.from(listingRaw)) : null,
      otherParticipant: ConversationParticipant.fromJson(Map<String, dynamic>.from(json['other_participant'] as Map)),
      lastMessageBody: json['last_message_body'] as String?,
      lastMessageAt: json['last_message_at'] != null ? DateTime.tryParse(json['last_message_at'] as String) : null,
      unreadCount: json['unread_count'] as int? ?? 0,
    );
  }
}

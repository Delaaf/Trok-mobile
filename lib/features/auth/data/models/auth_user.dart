class AuthUser {
  const AuthUser({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.avatarUrl,
    required this.status,
    required this.isEmailVerified,
    required this.isPhoneVerified,
    this.username,
    this.accountType,
  });

  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final String status;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final String? username;
  final String? accountType; // 'buyer' | 'seller'

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    // Le backend peut renvoyer "profile": [] (tableau vide, pas un objet) quand
    // la relation n'a aucun champ chargé — donc on ne caste en Map que si c'en
    // est vraiment une, sinon on traite comme "pas de profil".
    final profileRaw = json['profile'];
    final profile = profileRaw is Map ? Map<String, dynamic>.from(profileRaw) : null;

    return AuthUser(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      status: json['status'] as String,
      isEmailVerified: json['is_email_verified'] as bool? ?? false,
      isPhoneVerified: json['is_phone_verified'] as bool? ?? false,
      username: profile?['username'] as String?,
      accountType: profile?['account_type'] as String?,
    );
  }
}

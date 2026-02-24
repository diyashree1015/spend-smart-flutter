class UserProfile {
  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;

  UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['display_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'display_name': displayName,
      'avatar_url': avatarUrl,
    };
  }
}

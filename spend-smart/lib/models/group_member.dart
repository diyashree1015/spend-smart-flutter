class GroupMember {
  final String id;
  final String groupId;
  final String userId;
  final DateTime joinedAt;
  String? displayName;
  String? email;

  GroupMember({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.joinedAt,
    this.displayName,
    this.email,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      userId: json['user_id'] as String,
      joinedAt: DateTime.parse(json['joined_at'] as String),
      displayName: json['display_name'] as String?,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'group_id': groupId,
      'user_id': userId,
    };
  }
}

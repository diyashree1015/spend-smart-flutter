class Group {
  final String id;
  final String name;
  final String? description;
  final String createdBy;
  final DateTime createdAt;

  Group({
    required this.id,
    required this.name,
    this.description,
    required this.createdBy,
    required this.createdAt,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'created_by': createdBy,
    };
  }
}

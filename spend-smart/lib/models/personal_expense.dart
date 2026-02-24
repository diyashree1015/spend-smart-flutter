class PersonalExpense {
  final String id;
  final String title;
  final double amount;
  final String? category;
  final DateTime createdAt;

  PersonalExpense({
    required this.id,
    required this.title,
    required this.amount,
    this.category,
    required this.createdAt,
  });

  factory PersonalExpense.fromMap(Map<String, dynamic> map) {
    return PersonalExpense(
      id: map['id'],
      title: map['title'],
      amount: (map['amount'] as num).toDouble(),
      category: map['category'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'category': category,
    };
  }
}

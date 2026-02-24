class Expense {
  final String id;
  final String groupId;
  final String title;
  final double amount;
  final String category;
  final String paidBy;
  final DateTime date;
  final String? note;
  final DateTime createdAt;
  String? paidByName;

  Expense({
    required this.id,
    required this.groupId,
    required this.title,
    required this.amount,
    required this.category,
    required this.paidBy,
    required this.date,
    this.note,
    required this.createdAt,
    this.paidByName,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      paidBy: json['paid_by'] as String,
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      paidByName: json['paid_by_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'group_id': groupId,
      'title': title,
      'amount': amount,
      'category': category,
      'paid_by': paidBy,
      'date': date.toIso8601String().split('T')[0],
      'note': note,
    };
  }
}

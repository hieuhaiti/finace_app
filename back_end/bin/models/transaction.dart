class Transaction {
  final String id;
  final String userId;
  final String name;
  final String type; // 'income' or 'outcome'
  final String? spendingPlan; // Optional, for 'outcome'
  final String category;
  final double amount;
  final DateTime date;

  Transaction({
    String? id,
    required this.userId,
    required this.name,
    required this.type,
    this.spendingPlan,
    required this.category,
    required this.amount,
    DateTime? date,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        date = date ?? DateTime.now() {
    _validateTransaction();
  }

  void _validateTransaction() {
    if (type == 'income' && spendingPlan != null) {
      throw ArgumentError(
          'Income transactions should not have a spending plan.');
    }
    if (type == 'outcome' && spendingPlan == null) {
      throw ArgumentError('Outcome transactions must include a spending plan.');
    }
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null ||
        json['userId'] == null ||
        json['name'] == null ||
        json['type'] == null ||
        json['category'] == null ||
        json['amount'] == null ||
        json['date'] == null) {
      throw ArgumentError('Missing required fields in Transaction JSON');
    }
    return Transaction(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      type: json['type'],
      spendingPlan: json['spendingPlan'],
      category: json['category'],
      amount: json['amount'].toDouble(),
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'name': name,
        'type': type,
        'spendingPlan': spendingPlan,
        'category': category,
        'amount': amount,
        'date': date.toIso8601String(),
      };
}

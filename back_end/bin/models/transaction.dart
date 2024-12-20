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
    if (type == 'Income' && spendingPlan != null) {
      throw ArgumentError(
          'Income transactions should not have a spending plan.');
    }
    if (type == 'Outcome' && spendingPlan == null) {
      throw ArgumentError('Outcome transactions must include a spending plan.');
    }
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      userId: json['userId'],
      name: json['name'],
      type: json['type'],
      spendingPlan: json['spendingPlan'],
      category: json['category'],
      amount: (json['amount'] is String)
          ? double.parse(json['amount'])
          : json['amount'].toDouble(),
      date:
          json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
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
  Transaction copyWith({
    String? id,
    String? userId,
    String? name,
    String? type,
    String? spendingPlan,
    String? category,
    double? amount,
    DateTime? date,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      spendingPlan: spendingPlan ?? this.spendingPlan,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
    );
  }
}

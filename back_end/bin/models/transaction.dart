class Transaction {
  final String id;
  final String userId;
  final String name;
  final String type; // 'income' or 'outcome'
  final String? spendingPlan;
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
    required this.date,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString() {
    // handle spendingPlan
    if (type == 'income' && spendingPlan != null) {
      throw ArgumentError('Income transactions should not have a spendingPlan.');
    }
    if (type == 'outcome' && spendingPlan == null) {
      throw ArgumentError('Outcome transactions must have a spendingPlan.');
    }
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

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'],
        userId: json['userId'],
        name: json['name'],
        type: json['type'],
        spendingPlan: json['spendingPlan'],
        category: json['category'],
        amount: json['amount'],
        date: DateTime.parse(json['date']),
      );
}

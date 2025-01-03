class SpendingPlanCategory {
  final double ratio;
  final double amount;

  SpendingPlanCategory({required this.ratio, required this.amount});

  factory SpendingPlanCategory.fromJson(Map<String, dynamic> json) {
    return SpendingPlanCategory(
      ratio: json['ratio'].toDouble(),
      amount: json['amount'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'ratio': ratio,
        'amount': amount,
      };
}

class SpendingPlan {
  final String userId;
  final Map<String, Map<String, double>> categories;

  SpendingPlan({
    required this.userId,
    required this.categories,
  }) {
    _validateCategories();
  }

  void _validateCategories() {
    if (categories.isEmpty) {
      throw ArgumentError('SpendingPlan must have at least one category.');
    }

    final total = categories.values
        .map((value) => value['ratio']!)
        .reduce((a, b) => a + b);
    if (total != 100) {
      throw ArgumentError('Category percentages must sum to 100.');
    }

    if (categories.values.any((value) => value['ratio']! < 0)) {
      throw ArgumentError('Category percentages cannot be negative.');
    }
  }

  factory SpendingPlan.fromJson(Map<String, dynamic> json) {
    if (json['categories'] == null) {
      throw ArgumentError('Missing required field: categories');
    }
    return SpendingPlan(
      userId: json['userId'],
      categories: (json['categories'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          (value as Map<String, dynamic>).map(
            (k, v) => MapEntry(k, v.toDouble()),
          ),
        ),
      ),
    );
  }
  Map<String, dynamic> toJson() => {
        'userId': userId,
        'categories': categories,
      };
}

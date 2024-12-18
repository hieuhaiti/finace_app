class SpendingPlan {
  final String userId;
  final Map<String, int> categories;

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

    final total = categories.values.reduce((a, b) => a + b);
    if (total != 100) {
      throw ArgumentError('Category percentages must sum to 100.');
    }

    if (categories.values.any((value) => value < 0)) {
      throw ArgumentError('Category percentages cannot be negative.');
    }
  }

  factory SpendingPlan.fromJson(Map<String, dynamic> json) {
    if (json['categories'] == null) {
      throw ArgumentError('Missing required field: categories');
    }
    return SpendingPlan(
      userId: json['userId'],
      categories: Map<String, int>.from(json['categories']),
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'categories': categories,
      };
}

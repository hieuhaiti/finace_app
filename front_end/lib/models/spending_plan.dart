import 'package:front_end/models/spending_plan_category.dart';

class SpendingPlan {
  final String userId;
  final Map<String, SpendingPlanCategory> categories;

  SpendingPlan({required this.userId, required this.categories});

  factory SpendingPlan.fromJson(Map<String, dynamic> json) {
    if (json['categories'] == null) {
      throw ArgumentError('Missing required field: categories');
    }

    final categories = (json['categories'] as Map<String, dynamic>).map(
      (key, value) => MapEntry(
        key,
        SpendingPlanCategory.fromJson(value as Map<String, dynamic>),
      ),
    );

    return SpendingPlan(
      userId: json['userId'],
      categories: categories,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'categories': categories.map(
          (key, value) => MapEntry(key, value.toJson()),
        ),
      };
}

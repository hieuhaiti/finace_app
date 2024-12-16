class SpendingPlan {
  final String id;
  final String userId;
  final Map<String, double> categories; // e.g., {"saving": 20, "needs": 50, "wants": 30}

  SpendingPlan({
    required this.id,
    required this.userId,
    required this.categories,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'categories': categories,
      };

  factory SpendingPlan.fromJson(Map<String, dynamic> json) => SpendingPlan(
        id: json['id'],
        userId: json['userId'],
        categories: Map<String, double>.from(json['categories']),
      );
}
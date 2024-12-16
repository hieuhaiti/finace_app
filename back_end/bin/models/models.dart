class User {
  String id;
  String username;
  String password;

  User({required this.id, required this.username, required this.password});

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'password': password,
      };

  static User fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        username: json['username'],
        password: json['password'],
      );
}

class Transaction {
  String id;
  String userId;
  String name;
  String type; // 'income' or 'outcome'
  String category;
  double amount;
  DateTime date;

  Transaction({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.category,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'name': name,
        'type': type,
        'category': category,
        'amount': amount,
        'date': date.toIso8601String(),
      };

  static Transaction fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'],
        userId: json['userId'],
        name: json['name'],
        type: json['type'],
        category: json['category'],
        amount: json['amount'],
        date: DateTime.parse(json['date']),
      );
}

class SpendingPlan {
  String id;
  String userId;
  Map<String, double> categories; // e.g., {"saving": 20, "needs": 50, "wants": 30}

  SpendingPlan({required this.id, required this.userId, required this.categories});

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'categories': categories,
      };

  static SpendingPlan fromJson(Map<String, dynamic> json) => SpendingPlan(
        id: json['id'],
        userId: json['userId'],
        categories: Map<String, double>.from(json['categories']),
      );
}

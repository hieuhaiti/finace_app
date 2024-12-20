import 'package:uuid/uuid.dart';

// User Model
class User {
  final String id;
  final String username;
  final String password;

  User({
    String? id,
    required this.username,
    required this.password,
  }) : id = id ?? Uuid().v4();

  factory User.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null ||
        json['username'] == null ||
        json['password'] == null) {
      throw ArgumentError('Missing required fields in User JSON');
    }
    return User(
      id: json['id'],
      username: json['username'],
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'password': password,
      };
}

// Category Model
class Category {
  static int _idCounter = 1;
  final String id;
  final String userId;
  final String name;
  final String icon;
  final String color;

  Category({
    String? id,
    required this.userId,
    required this.name,
    required this.icon,
    required this.color,
  }) : id = id ?? (_idCounter++).toString();

  factory Category.fromJson(Map<String, dynamic> json) {
    if (json['userId'] == null ||
        json['name'] == null ||
        json['icon'] == null ||
        json['color'] == null) {
      throw ArgumentError('Missing required fields in Category JSON');
    }
    return Category(
      id: json['id'] ?? (_idCounter++).toString(),
      userId: json['userId'],
      name: json['name'],
      icon: json['icon'],
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'name': name,
        'icon': icon,
        'color': color,
      };
}

// SpendingPlan Model
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

// Transaction Model
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
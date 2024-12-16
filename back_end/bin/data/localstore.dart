import 'package:localstore/localstore.dart';
import '../models/transaction.dart';
import '../models/spending_plan.dart';
import '../models/user.dart';
import '../models/category.dart';

class LocalstoreService {
  final _db = Localstore.instance;

  // User CRUD Operations
  Future<void> saveUser(User user) async {
    await _db.collection('users').doc(user.id).set(user.toJson());
  }

  Future<List<User>> getUsers() async {
    final data = await _db.collection('users').get();
    if (data != null) {
      return data.values.map((json) => User.fromJson(json)).toList();
    }
    return [];
  }

  Future<void> updateUser(User user) async {
    await _db.collection('users').doc(user.id).set(user.toJson());
  }

  Future<void> deleteUser(String userId) async {
    await _db.collection('users').doc(userId).delete();
  }

  // Transaction CRUD Operations
  Future<void> saveTransaction(Transaction transaction) async {
    await _db.collection('transactions').doc(transaction.id).set(transaction.toJson());
  }

  Future<List<Transaction>> getTransactions(String userId) async {
    final data = await _db.collection('transactions').get();
    if (data != null) {
      return data.values
          .map((json) => Transaction.fromJson(json))
          .where((transaction) => transaction.userId == userId)
          .toList();
    }
    return [];
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await _db.collection('transactions').doc(transaction.id).set(transaction.toJson());
  }

  Future<void> deleteTransaction(String transactionId) async {
    await _db.collection('transactions').doc(transactionId).delete();
  }

  // Spending Plan CRUD Operations
  Future<void> saveSpendingPlan(SpendingPlan plan) async {
    await _db.collection('spending_plans').doc(plan.id).set(plan.toJson());
  }

  Future<SpendingPlan?> getSpendingPlan(String userId) async {
    final data = await _db.collection('spending_plans').doc(userId).get();
    if (data != null) {
      return SpendingPlan.fromJson(data);
    }
    return null;
  }

  Future<void> updateSpendingPlan(SpendingPlan plan) async {
    await _db.collection('spending_plans').doc(plan.id).set(plan.toJson());
  }

  Future<void> deleteSpendingPlan(String planId) async {
    await _db.collection('spending_plans').doc(planId).delete();
  }

  // Category CRUD Operations
  Future<void> saveCategory(Category category) async {
    await _db.collection('categories').doc(category.id).set(category.toJson());
  }

  Future<List<Category>> getCategories() async {
    final data = await _db.collection('categories').get();
    if (data != null) {
      return data.values.map((json) => Category.fromJson(json)).toList();
    }
    return [];
  }

  Future<void> updateCategory(Category category) async {
    await _db.collection('categories').doc(category.id).set(category.toJson());
  }

  Future<void> deleteCategory(String categoryId) async {
    await _db.collection('categories').doc(categoryId).delete();
  }
}

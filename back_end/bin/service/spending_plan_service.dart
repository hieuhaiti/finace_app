import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../models/spending_plan.dart';
import 'service.dart';
import '../data/spending_plan_storage.dart';
import '../data/user_storage.dart';
import '../data/category_storage.dart';
import '../data/transaction_storage.dart';
import 'dart:collection';

import '../models/user.dart';
import '../models/transaction.dart';

class SpendingPlanService with Service {
  final UserStorage userStorage = UserStorage('bin/data/json/users.json');
  final TransactionStorage transactionStorage =
      TransactionStorage('bin/data/json/transactions.json');
  final SpendingPlanStorage spendingPlanStorage =
      SpendingPlanStorage('bin/data/json/spending_plans.json');
  final CategoryStorage categoryStorage =
      CategoryStorage('bin/data/json/categories.json');
  final _headers = {'Content-Type': 'application/json'};

  /// Default spending plan
  static const Map<String, Map<String, double>> defaultSpendingPlan = {
    "saving": {"ratio": 20, "amount": 0.0},
    "needs": {"ratio": 50, "amount": 0.0},
    "wants": {"ratio": 30, "amount": 0.0}
  };

  /// Initialize default spending plan for a user
  Future<void> initializeDefaultSpendingPlan(String userId) async {
    final spendingPlan =
        SpendingPlan(userId: userId, categories: defaultSpendingPlan);
    await spendingPlanStorage.save(userId, spendingPlan);
  }

  /// Get Spending Plan Handler
  Future<Response> getSpendingPlansHandler(
      Request request, String userId) async {
    try {
      final spendingPlan = await spendingPlanStorage.fetchById(userId);
      if (spendingPlan == null) {
        await initializeDefaultSpendingPlan(userId);
        return Response.ok(
            jsonEncode({
              'message': 'Initialized default spending plan.',
              'spendingPlan': defaultSpendingPlan
            }),
            headers: _headers);
      }
      return Response.ok(jsonEncode(spendingPlan.toJson()), headers: _headers);
    } catch (e) {
      return Response.internalServerError(
          body: 'Error fetching spending plan: $e', headers: _headers);
    }
  }

  /// add spending plan amount
  /// amount split for each category by ratio (e.g 1000 amount with savingratio 20% will be 200, needs 50% will be 500, wants 30% will be 300)
  Future<Response> addSpendingPlanAmountHandler(
      Request request, String userId, double amount) async {
    try {
      final spendingPlan = await spendingPlanStorage.fetchById(userId);
      if (spendingPlan == null) {
        return Response.notFound('Spending plan not found for userId: $userId',
            headers: _headers);
      }

      final updatedCategories =
          Map<String, Map<String, double>>.from(spendingPlan.categories);
      updatedCategories.forEach((key, value) {
        updatedCategories[key]!['amount'] =
            value['amount']! + (amount * value['ratio']! ~/ 100);
      });

      final updatedSpendingPlan =
          SpendingPlan(userId: userId, categories: updatedCategories);
      await spendingPlanStorage.save(userId, updatedSpendingPlan);

      return Response.ok(jsonEncode({'message': 'Amount added successfully'}),
          headers: _headers);
    } catch (e) {
      return Response.internalServerError(
          body: 'Error adding amount to spending plan: $e', headers: _headers);
    }
  }

  /// subtract spending plan amount
  Future<Response> subtractSpendingPlanAmountHandler(
      Request request, String userId, String category, double amount) async {
    try {
      final spendingPlan = await spendingPlanStorage.fetchById(userId);
      if (spendingPlan == null) {
        return Response.notFound('Spending plan not found for userId: $userId',
            headers: _headers);
      }

      final updatedCategories =
          Map<String, Map<String, double>>.from(spendingPlan.categories);
      if (updatedCategories.containsKey(category)) {
        updatedCategories[category]!['amount'] =
            updatedCategories[category]!['amount']! + amount;
      }

      final updatedSpendingPlan =
          SpendingPlan(userId: userId, categories: updatedCategories);
      await spendingPlanStorage.save(userId, updatedSpendingPlan);
      return Response.ok(
          jsonEncode({'message': 'Amount subtracted successfully'}),
          headers: _headers);
    } catch (e) {
      return Response.internalServerError(
          body: 'Error subtracting amount from spending plan: $e',
          headers: _headers);
    }
  }

  /// Update Spending Plan Handler
  Future<Response> updateSpendingPlanHandler(
      Request request, String userId) async {
    try {
      final body = await parseRequestBody(request);
      final newCategories =
          Map<String, Map<String, double>>.from(body['categories']);

      if (newCategories.isEmpty) {
        return Response.badRequest(
            body: 'Spending plan must have at least one category.',
            headers: _headers);
      }

      final totalPercentage = newCategories.values
          .map((value) => value['ratio']!)
          .reduce((a, b) => a + b);
      if (totalPercentage != 100) {
        return Response.badRequest(
            body: 'Total percentage must equal 100%.', headers: _headers);
      }

      final updatedSpendingPlan =
          SpendingPlan(userId: userId, categories: newCategories);
      await spendingPlanStorage.save(userId, updatedSpendingPlan);

      return Response.ok(
          jsonEncode({'message': 'Spending plan updated successfully'}),
          headers: _headers);
    } catch (e) {
      return Response.internalServerError(
          body: 'Error updating spending plan: $e', headers: _headers);
    }
  }

  /// Delete a Category in Spending Plan with enhanced error handling
  Future<Response> deleteCategoryHandler(
      Request request, String userId, String spentPlan) async {
    try {
      final spendingPlan = await spendingPlanStorage.fetchById(userId);
      if (spendingPlan == null) {
        return Response.notFound('Spending plan not found for userId: $userId',
            headers: _headers);
      }

      final updatedCategories =
          Map<String, Map<String, double>>.from(spendingPlan.categories);
      updatedCategories.remove(spentPlan);

      if (updatedCategories.isEmpty) {
        return Response.badRequest(
            body: jsonEncode({
              'error':
                  'At least one category must remain in the spending plan.',
              'suggestion': 'Consider updating the remaining category instead.'
            }),
            headers: _headers);
      }

      // Adjust remaining category to maintain a total of 100%
      final remainingCategory = updatedCategories.keys.first;
      updatedCategories[remainingCategory]!['ratio'] = 100;

      final updatedSpendingPlan =
          SpendingPlan(userId: userId, categories: updatedCategories);
      await spendingPlanStorage.save(userId, updatedSpendingPlan);

      return Response.ok(
          jsonEncode({'message': 'Category deleted successfully'}),
          headers: _headers);
    } catch (e) {
      return Response.internalServerError(
          body: jsonEncode({
            'error': 'Error deleting category',
            'details': e.toString(),
            'suggestion':
                'Ensure the category exists and the request data is valid.'
          }),
          headers: _headers);
    }
  }

  //getSpendingPlansDetailHandler
  //..get('/api/v1/spending-plans/<userId>/<category>/<type>',
  // spendingPlanService.getSpendingPlansDetailHandler);
  // input spendingPlan like (saving, needs, wants)
// type like (Income , Outcome , Combined)
  /// if type == Income thì truy vấn tất cả các giao dịch có type == Income
  /// vì giao dịch có type == Income thì không có spending plan nên sẽ chỉ
  /// lấy type == Income
  /// if type == Outcome thì truy vấn tất cả các giao dịch có type == Outcome
  /// và kết hợp với spending plan
  /// if type == Combined thì truy vấn tất cả các giao dịch có type == Income và Outcome
  /// lưu ý các giao dịch có type == Outcome thì cần kết hợp với spending plan
  /// kết quả trả về là một map với key là năm, value là một map với key là các tháng, value là tổng số tiền
  /// e.g:{
  ///  "2024": {
  ///   "12": [transaction,transaction,transaction],
  ///  "11": [transaction,transaction,transaction],
  /// "10": [transaction,transaction,transaction],}
  Future<Response> getSpendingPlansDetailHandler(
      Request request, String userId, String spendingPlan, String type) async {
    try {
      User? user = await userStorage.fetchById(userId);
      if (user == null) {
        return Response.notFound('User not found');
      }
      List<Transaction> transactions =
          await transactionStorage.fetchWhere('userId', userId);

      Map<String, Map<String, List<Transaction>>> result = {};
      for (var transaction in transactions) {
        String year = transaction.date.year.toString();
        String month = transaction.date.month.toString().padLeft(2, '0');
        result[year] ??= {};
        result[year]![month] ??= [];
        if (type == 'Income' && transaction.type == 'Income') {
          result[year]![month]!.add(transaction);
        } else if (type == 'Outcome' &&
            transaction.type == 'Outcome' &&
            transaction.spendingPlan == spendingPlan) {
          result[year]![month]!.add(transaction);
        } else if (type == 'Combined') {
          if (transaction.type == 'Income') {
            result[year]![month]!.add(transaction);
          } else if (transaction.type == 'Outcome' &&
              transaction.spendingPlan == spendingPlan) {
            result[year]![month]!.add(transaction);
          }
        }
      }
      // Sắp xếp theo năm, tháng giảm dần
      var sortedResult =
          SplayTreeMap<String, Map<String, List<Transaction>>>.from(
        result,
        (a, b) => b.compareTo(a),
      );

      sortedResult.forEach((year, months) {
        sortedResult[year] = SplayTreeMap<String, List<Transaction>>.from(
          months,
          (a, b) => b.compareTo(a),
        );

        sortedResult[year]!.forEach((month, transactions) {
          transactions.sort((a, b) => b.date.compareTo(a.date));
        });
      });

      return Response.ok(jsonEncode(sortedResult), headers: _headers);
    } catch (e) {
      return Response.internalServerError(body: 'Error: $e', headers: _headers);
    }
  }
}

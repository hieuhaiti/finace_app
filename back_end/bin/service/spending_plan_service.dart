import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../models/spending_plan.dart';
import '../data/json_storage.dart';
import 'service.dart';

/// SpendingPlanService handles all spending plan-related operations

class SpendingPlanJsonStorage extends JsonStorage<SpendingPlan> {
  SpendingPlanJsonStorage() : super('bin/data/json/spending_plans.json');

  @override
  SpendingPlan fromJson(Map<String, dynamic> json) =>
      SpendingPlan.fromJson(json);

  @override
  Map<String, dynamic> toJson(SpendingPlan object) => object.toJson();
}

class SpendingPlanService with Service {
  final SpendingPlanJsonStorage _spendingPlanStorage =
      SpendingPlanJsonStorage();
  final _headers = {'Content-Type': 'application/json'};

  /// Default spending plan
  static const Map<String, int> defaultSpendingPlan = {
    "saving": 20,
    "needs": 50,
    "wants": 30
  };

  /// Initialize default spending plan for a user
  Future<void> initializeDefaultSpendingPlan(String userId) async {
    final spendingPlan =
        SpendingPlan(userId: userId, categories: defaultSpendingPlan);
    await _spendingPlanStorage.save(userId, spendingPlan);
  }

  /// Get Spending Plan Handler
  Future<Response> getSpendingPlansHandler(
      Request request, String userId) async {
    try {
      final spendingPlan = await _spendingPlanStorage.fetchById(userId);
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

  /// Update Spending Plan Handler
  Future<Response> updateSpendingPlanHandler(
      Request request, String userId) async {
    try {
      final body = await parseRequestBody(request);
      final newCategories = Map<String, int>.from(body['categories']);

      if (newCategories.isEmpty) {
        return Response.badRequest(
            body: 'Spending plan must have at least one category.',
            headers: _headers);
      }

      final totalPercentage = newCategories.values.reduce((a, b) => a + b);
      if (totalPercentage != 100) {
        return Response.badRequest(
            body: 'Total percentage must equal 100%.', headers: _headers);
      }

      final updatedSpendingPlan =
          SpendingPlan(userId: userId, categories: newCategories);
      await _spendingPlanStorage.save(userId, updatedSpendingPlan);

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
      Request request, String userId, String category) async {
    try {
      final spendingPlan = await _spendingPlanStorage.fetchById(userId);
      if (spendingPlan == null) {
        return Response.notFound('Spending plan not found for userId: $userId',
            headers: _headers);
      }

      final updatedCategories = Map<String, int>.from(spendingPlan.categories);
      updatedCategories.remove(category);

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
      updatedCategories[remainingCategory] = 100;

      final updatedSpendingPlan =
          SpendingPlan(userId: userId, categories: updatedCategories);
      await _spendingPlanStorage.save(userId, updatedSpendingPlan);

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
}

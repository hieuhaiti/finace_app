import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../models/spending_plan.dart';
import '../data/localstore.dart';
import 'service.dart';

/// SpendingPlanService handles all spending plan-related operations
class SpendingPlanService with Service {
  final LocalstoreService<SpendingPlan> _spendingPlanStore;

  SpendingPlanService() : _spendingPlanStore = SpendingPlanLocalstoreService();

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
    await _spendingPlanStore.save(userId, spendingPlan);
  }

  /// Get Spending Plan Handler
  Future<Response> getSpendingPlansHandler(
      Request request, String userId) async {
    try {
      final spendingPlan = await _spendingPlanStore.fetchById(userId);
      if (spendingPlan == null) {
        await initializeDefaultSpendingPlan(userId);
        return Response.ok(jsonEncode({
          'message': 'Initialized default spending plan.',
          'spendingPlan': defaultSpendingPlan
        }));
      }
      return Response.ok(jsonEncode(spendingPlan.toJson()));
    } catch (e) {
      return Response.internalServerError(
          body: 'Error fetching spending plan: $e');
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
            body: 'Spending plan must have at least one category.');
      }

      final totalPercentage = newCategories.values.reduce((a, b) => a + b);
      if (totalPercentage != 100) {
        return Response.badRequest(body: 'Total percentage must equal 100%.');
      }

      final updatedSpendingPlan =
          SpendingPlan(userId: userId, categories: newCategories);
      await _spendingPlanStore.save(userId, updatedSpendingPlan);

      return Response.ok(
          jsonEncode({'message': 'Spending plan updated successfully'}));
    } catch (e) {
      return Response.internalServerError(
          body: 'Error updating spending plan: $e');
    }
  }

  /// Delete a Category in Spending Plan
  Future<Response> deleteCategoryHandler(
      Request request, String userId, String category) async {
    try {
      final spendingPlan = await _spendingPlanStore.fetchById(userId);
      if (spendingPlan == null) {
        return Response.notFound('Spending plan not found');
      }

      final updatedCategories = Map<String, int>.from(spendingPlan.categories);
      updatedCategories.remove(category);

      if (updatedCategories.isEmpty) {
        return Response.badRequest(
            body: 'At least one category must remain in the spending plan.');
      }

      final updatedSpendingPlan =
          SpendingPlan(userId: userId, categories: updatedCategories);
      await _spendingPlanStore.save(userId, updatedSpendingPlan);

      return Response.ok(
          jsonEncode({'message': 'Category deleted successfully'}));
    } catch (e) {
      return Response.internalServerError(body: 'Error deleting category: $e');
    }
  }
}

/// LocalstoreService implementation for SpendingPlan
class SpendingPlanLocalstoreService extends LocalstoreService<SpendingPlan> {
  @override
  String get collectionName => 'spending_plans';

  @override
  SpendingPlan fromJson(Map<String, dynamic> json) =>
      SpendingPlan.fromJson(json);

  @override
  Map<String, dynamic> toJson(SpendingPlan object) => object.toJson();
}

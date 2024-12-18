import 'dart:convert';
import 'package:test/test.dart';
import 'package:shelf/shelf.dart';
import 'package:localstore/localstore.dart';
import '../../bin/service/spending_plan_service.dart';
import '../../bin/models/spending_plan.dart';

void main() {
  final spendingPlanService = SpendingPlanService();
  final localstoreService = SpendingPlanLocalstoreService();

  setUp(() async {
    // Clear the database before each test
    await Localstore.instance.collection('spending_plans').delete();
  });

  group('SpendingPlanService Tests', () {
    test('Get Spending Plan Handler - Initialize Default', () async {
      final request = Request('GET', Uri.parse('http://localhost/spending-plans/user1'));
      final response = await spendingPlanService.getSpendingPlansHandler(request, 'user1');

      expect(response.statusCode, equals(200));
      final body = await response.readAsString();
      final json = jsonDecode(body);
      expect(json['message'], equals('Initialized default spending plan.'));
      expect(json['spendingPlan'], equals(SpendingPlanService.defaultSpendingPlan));
    });

    test('Get Spending Plan Handler - Existing Plan', () async {
      final spendingPlan = SpendingPlan(
        userId: 'user1',
        categories: {'saving': 20, 'needs': 50, 'wants': 30},
      );
      await localstoreService.save(spendingPlan.userId, spendingPlan);

      final request = Request('GET', Uri.parse('http://localhost/spending-plans/user1'));
      final response = await spendingPlanService.getSpendingPlansHandler(request, 'user1');

      expect(response.statusCode, equals(200));
      final body = await response.readAsString();
      final json = jsonDecode(body);
      expect(json['categories'], equals({'saving': 20, 'needs': 50, 'wants': 30}));
    });

    test('Update Spending Plan Handler', () async {
      final spendingPlan = SpendingPlan(
        userId: 'user1',
        categories: {'saving': 20, 'needs': 50, 'wants': 30},
      );
      await localstoreService.save(spendingPlan.userId, spendingPlan);

      final request = Request(
        'PUT',
        Uri.parse('http://localhost/spending-plans/user1'),
        body: jsonEncode({'categories': {'saving': 25, 'needs': 45, 'wants': 30}}),
      );
      final response = await spendingPlanService.updateSpendingPlanHandler(request, 'user1');

      expect(response.statusCode, equals(200));
      final body = await response.readAsString();
      final json = jsonDecode(body);
      expect(json['message'], equals('Spending plan updated successfully'));

      final updatedSpendingPlan = await localstoreService.fetchById('user1');
      expect(updatedSpendingPlan, isNotNull);
      expect(updatedSpendingPlan!.categories, equals({'saving': 25, 'needs': 45, 'wants': 30}));
    });

    test('Delete Category Handler', () async {
      final spendingPlan = SpendingPlan(
        userId: 'user1',
        categories: {'saving': 20, 'needs': 50, 'wants': 30},
      );
      await localstoreService.save(spendingPlan.userId, spendingPlan);

      final request = Request('DELETE', Uri.parse('http://localhost/spending-plans/user1/saving'));
      final response = await spendingPlanService.deleteCategoryHandler(request, 'user1', 'saving');

      expect(response.statusCode, equals(200));
      final body = await response.readAsString();
      final json = jsonDecode(body);
      expect(json['message'], equals('Category deleted successfully'));

      final updatedSpendingPlan = await localstoreService.fetchById('user1');
      expect(updatedSpendingPlan, isNotNull);
      expect(updatedSpendingPlan!.categories, equals({'needs': 50, 'wants': 30}));
    });

    test('Delete Category Handler - Last Category', () async {
      final spendingPlan = SpendingPlan(
        userId: 'user1',
        categories: {'saving': 100},
      );
      await localstoreService.save(spendingPlan.userId, spendingPlan);

      final request = Request('DELETE', Uri.parse('http://localhost/spending-plans/user1/saving'));
      final response = await spendingPlanService.deleteCategoryHandler(request, 'user1', 'saving');

      expect(response.statusCode, equals(400));
      final body = await response.readAsString();
      expect(body, equals('At least one category must remain in the spending plan.'));
    });
  });
}
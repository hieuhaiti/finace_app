import 'package:test/test.dart';
import '../../bin/models/spending_plan.dart';

void main() {
  group('SpendingPlan Model Tests', () {
    test('SpendingPlan creation', () {
      final spendingPlan = SpendingPlan(
        userId: 'user1',
        categories: {'saving': 20, 'needs': 50, 'wants': 30},
      );

      expect(spendingPlan.userId, equals('user1'));
      expect(spendingPlan.categories,
          equals({'saving': 20, 'needs': 50, 'wants': 30}));
    });

    test('SpendingPlan toJson', () {
      final spendingPlan = SpendingPlan(
        userId: 'user1',
        categories: {'saving': 20, 'needs': 50, 'wants': 30},
      );
      final json = spendingPlan.toJson();

      expect(json['userId'], equals('user1'));
      expect(
          json['categories'], equals({'saving': 20, 'needs': 50, 'wants': 30}));
    });

    test('SpendingPlan fromJson', () {
      final json = {
        'userId': 'user1',
        'categories': {'saving': 20, 'needs': 50, 'wants': 30},
      };
      final spendingPlan = SpendingPlan.fromJson(json);

      expect(spendingPlan.userId, equals('user1'));
      expect(spendingPlan.categories,
          equals({'saving': 20, 'needs': 50, 'wants': 30}));
    });

    test('SpendingPlan creation with validation', () {
      expect(
        () => SpendingPlan(
          userId: 'user1',
          categories: {},
        ),
        throwsArgumentError,
      );

      expect(
        () => SpendingPlan(
          userId: 'user1',
          categories: {'saving': -20, 'needs': 50, 'wants': 30},
        ),
        throwsArgumentError,
      );

      expect(
        () => SpendingPlan(
          userId: 'user1',
          categories: {'saving': 20, 'needs': 50, 'wants': 40},
        ),
        throwsArgumentError,
      );
    });

    test('SpendingPlan fromJson with missing fields', () {
      final json = {
        'userId': 'user1',
      };

      expect(() => SpendingPlan.fromJson(json), throwsArgumentError);
    });
  });
}

import 'package:test/test.dart';
import '../../bin/models/transaction.dart';
import '../../bin/models/spending_plan.dart';

void main() {
  group('Transaction Model Tests', () {
    test('should create a valid income transaction without spendingPlan', () {
      final transaction = Transaction(
        userId: 'user123',
        name: 'Salary',
        type: 'income',
        category: 'Work',
        amount: 5000.0,
        date: DateTime.now(),
      );

      expect(transaction.type, 'income');
      expect(transaction.spendingPlan, isNull);
    });

    test('should throw error if income transaction has a spendingPlan', () {
      expect(
        () => Transaction(
          userId: 'user123',
          name: 'Bonus',
          type: 'income',
          spendingPlan: 'saving',
          category: 'Bonus',
          amount: 1000.0,
          date: DateTime.now(),
        ),
        throwsArgumentError,
      );
    });

    test('should create a valid outcome transaction with spendingPlan', () {
      // ignore: unused_local_variable
      final spendingPlan = SpendingPlan(
        userId: 'user123',
        categories: {'saving': 20, 'needs': 50, 'wants': 30},
      );

      final transaction = Transaction(
        userId: 'user123',
        name: 'Groceries',
        type: 'outcome',
        spendingPlan: 'needs',
        category: 'Food',
        amount: 200.0,
        date: DateTime.now(),
      );

      expect(transaction.type, 'outcome');
      expect(transaction.spendingPlan, 'needs');
    });

    test('should throw error if outcome transaction has no spendingPlan', () {
      expect(
        () => Transaction(
          userId: 'user123',
          name: 'Shopping',
          type: 'outcome',
          category: 'Clothing',
          amount: 300.0,
          date: DateTime.now(),
        ),
        throwsArgumentError,
      );
    });

    test('should serialize to JSON correctly', () {
      final transaction = Transaction(
        userId: 'user123',
        name: 'Groceries',
        type: 'outcome',
        spendingPlan: 'needs',
        category: 'Food',
        amount: 200.0,
        date: DateTime.parse('2024-01-01T12:00:00Z'),
      );

      final json = transaction.toJson();

      expect(json['id'], isNotNull);
      expect(json['userId'], 'user123');
      expect(json['name'], 'Groceries');
      expect(json['type'], 'outcome');
      expect(json['spendingPlan'], 'needs');
      expect(json['category'], 'Food');
      expect(json['amount'], 200.0);
      expect(json['date'], '2024-01-01T12:00:00.000Z');
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': '12345',
        'userId': 'user123',
        'name': 'Groceries',
        'type': 'outcome',
        'spendingPlan': 'needs',
        'category': 'Food',
        'amount': 200.0,
        'date': '2024-01-01T12:00:00.000Z',
      };

      final transaction = Transaction.fromJson(json);

      expect(transaction.id, '12345');
      expect(transaction.userId, 'user123');
      expect(transaction.name, 'Groceries');
      expect(transaction.type, 'outcome');
      expect(transaction.spendingPlan, 'needs');
      expect(transaction.category, 'Food');
      expect(transaction.amount, 200.0);
      expect(transaction.date, DateTime.parse('2024-01-01T12:00:00Z'));
    });

    test('Transaction fromJson with missing fields', () {
      final json = {
        'id': '12345',
        'userId': 'user123',
        'name': 'Groceries',
        'type': 'outcome',
        'category': 'Food',
        'amount': 200.0,
      };

      expect(() => Transaction.fromJson(json), throwsArgumentError);
    });

    test('should copy transaction with new values', () {
      final transaction = Transaction(
        userId: 'user123',
        name: 'Groceries',
        type: 'outcome',
        spendingPlan: 'needs',
        category: 'Food',
        amount: 200.0,
        date: DateTime.now(),
      );

      final copiedTransaction = transaction.copyWith(
        name: 'Updated Groceries',
        amount: 250.0,
      );

      expect(copiedTransaction.id, equals(transaction.id));
      expect(copiedTransaction.userId, equals(transaction.userId));
      expect(copiedTransaction.name, equals('Updated Groceries'));
      expect(copiedTransaction.type, equals(transaction.type));
      expect(copiedTransaction.spendingPlan, equals(transaction.spendingPlan));
      expect(copiedTransaction.category, equals(transaction.category));
      expect(copiedTransaction.amount, equals(250.0));
      expect(copiedTransaction.date, equals(transaction.date));
    });
  });
}

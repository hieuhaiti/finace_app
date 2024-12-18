import 'dart:convert';
import 'package:test/test.dart';
import 'package:shelf/shelf.dart';
import 'package:localstore/localstore.dart';
import '../../bin/service/transactions_service.dart';
import '../../bin/models/transaction.dart';

void main() {
  final transactionsService = TransactionsService();
  final localstoreService = TransactionLocalstoreService();

  setUp(() async {
    // Clear the database before each test
    await Localstore.instance.collection('transactions').delete();
  });

  group('TransactionsService Tests', () {
    test('Create Transaction Handler', () async {
      final request = Request(
        'POST',
        Uri.parse('http://localhost/api/v1/transactions'),
        body: jsonEncode({
          'userId': 'user1',
          'name': 'Salary',
          'type': 'income',
          'category': 'Work',
          'amount': 5000.0,
          'date': DateTime.now().toIso8601String(),
        }),
      );
      final response =
          await transactionsService.createTransactionHandler(request);

      expect(response.statusCode, equals(200));
      final body = await response.readAsString();
      final json = jsonDecode(body);
      expect(json['message'], equals('Transaction created successfully'));

      final transactions = await localstoreService.fetchAll();
      expect(transactions.length, equals(1));
      expect(transactions.first.name, equals('Salary'));
    });

    test('Get All Transactions Handler', () async {
      final transaction = Transaction(
        userId: 'user1',
        name: 'Salary',
        type: 'income',
        category: 'Work',
        amount: 5000.0,
        date: DateTime.now(),
      );
      await localstoreService.save(transaction.id, transaction);

      final request = Request(
          'GET', Uri.parse('http://localhost/api/v1/transactions/user1'));
      final response =
          await transactionsService.getAllTransactionsHandler(request, 'user1');

      expect(response.statusCode, equals(200));
      final body = await response.readAsString();
      final json = jsonDecode(body);
      expect(json.length, equals(1));
      expect(json[0]['name'], equals('Salary'));
    });

    test('Update Transaction Handler', () async {
      final transaction = Transaction(
        id: 'trans1',
        userId: 'user1',
        name: 'Salary',
        type: 'income',
        category: 'Work',
        amount: 5000.0,
        date: DateTime.now(),
      );
      await localstoreService.save(transaction.id, transaction);

      final request = Request(
        'PUT',
        Uri.parse('http://localhost/api/v1/transactions/trans1'),
        body: jsonEncode({'name': 'Updated Salary', 'amount': 6000.0}),
      );
      final response =
          await transactionsService.updateTransactionHandler(request, 'trans1');

      expect(response.statusCode, equals(200));
      final body = await response.readAsString();
      final json = jsonDecode(body);
      expect(json['message'], equals('Transaction updated successfully'));

      final updatedTransaction = await localstoreService.fetchById('trans1');
      expect(updatedTransaction, isNotNull);
      expect(updatedTransaction!.name, equals('Updated Salary'));
      expect(updatedTransaction.amount, equals(6000.0));
    });

    test('Delete Transaction Handler', () async {
      final transaction = Transaction(
        id: 'trans1',
        userId: 'user1',
        name: 'Salary',
        type: 'income',
        category: 'Work',
        amount: 5000.0,
        date: DateTime.now(),
      );
      await localstoreService.save(transaction.id, transaction);

      final request = Request(
          'DELETE', Uri.parse('http://localhost/api/v1/transactions/trans1'));
      final response =
          await transactionsService.deleteTransactionHandler(request, 'trans1');

      expect(response.statusCode, equals(200));
      final body = await response.readAsString();
      final json = jsonDecode(body);
      expect(json['message'], equals('Transaction deleted successfully'));

      final deletedTransaction = await localstoreService.fetchById('trans1');
      expect(deletedTransaction, isNull);
    });

    test('Get Transactions Aggregated by Type', () async {
      final transaction1 = Transaction(
        userId: 'user1',
        name: 'Salary',
        type: 'income',
        category: 'Work',
        amount: 5000.0,
        date: DateTime.parse('2023-01-01'),
      );
      final transaction2 = Transaction(
        userId: 'user1',
        name: 'Groceries',
        type: 'outcome',
        category: 'Food',
        amount: 200.0,
        date: DateTime.parse('2023-01-01'),
      );
      await localstoreService.save(transaction1.id, transaction1);
      await localstoreService.save(transaction2.id, transaction2);

      final request = Request(
          'GET', Uri.parse('http://localhost/api/v1/transactions/user1/type'));
      final response = await transactionsService.getTransactionsAggregatedBy(
          request, 'user1', 'type');

      expect(response.statusCode, equals(200));
      final body = await response.readAsString();
      final json = jsonDecode(body);
      expect(json['totals']['income'], equals(5000.0));
      expect(json['totals']['outcome'], equals(200.0));
    });

    test('Get Transactions Aggregated by Category', () async {
      final transaction1 = Transaction(
        userId: 'user1',
        name: 'Salary',
        type: 'income',
        category: 'Work',
        amount: 5000.0,
        date: DateTime.parse('2023-01-01'),
      );
      final transaction2 = Transaction(
        userId: 'user1',
        name: 'Groceries',
        type: 'outcome',
        category: 'Food',
        amount: 200.0,
        date: DateTime.parse('2023-01-01'),
      );
      await localstoreService.save(transaction1.id, transaction1);
      await localstoreService.save(transaction2.id, transaction2);

      final request = Request('GET',
          Uri.parse('http://localhost/api/v1/transactions/user1/category'));
      final response = await transactionsService.getTransactionsAggregatedBy(
          request, 'user1', 'category');

      expect(response.statusCode, equals(200));
      final body = await response.readAsString();
      final json = jsonDecode(body);
      expect(json['totals']['Work'], equals(5000.0));
      expect(json['totals']['Food'], equals(200.0));
    });

    test('Get Transactions Aggregated by Spending Plan', () async {
      final transaction1 = Transaction(
        userId: 'user1',
        name: 'Salary',
        type: 'income',
        category: 'Work',
        amount: 5000.0,
        date: DateTime.parse('2023-01-01'),
      );
      final transaction2 = Transaction(
        userId: 'user1',
        name: 'Groceries',
        type: 'outcome',
        spendingPlan: 'needs',
        category: 'Food',
        amount: 200.0,
        date: DateTime.parse('2023-01-01'),
      );
      await localstoreService.save(transaction1.id, transaction1);
      await localstoreService.save(transaction2.id, transaction2);

      final request = Request('GET',
          Uri.parse('http://localhost/api/v1/transactions/user1/spendingPlan'));
      final response = await transactionsService.getTransactionsAggregatedBy(
          request, 'user1', 'spendingPlan');

      expect(response.statusCode, equals(200));
      final body = await response.readAsString();
      final json = jsonDecode(body);
      expect(json['totals']['needs'], equals(200.0));
    });
  });
}

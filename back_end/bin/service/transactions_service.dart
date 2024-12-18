import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../data/localstore.dart';
import '../models/transaction.dart';
import 'service.dart';

/// TransactionService handles CRUD operations and data aggregation for transactions
class TransactionsService with Service {
  final LocalstoreService<Transaction> _transactionStore;

  TransactionsService() : _transactionStore = TransactionLocalstoreService();

  /// Get all transactions by user ID
  Future<Response> getAllTransactionsHandler(Request request, String userId) async {
    try {
      final transactions = await _transactionStore.fetchWhere('userId', userId);
      return Response.ok(jsonEncode(transactions.map((t) => t.toJson()).toList()));
    } catch (e) {
      return Response.internalServerError(body: 'Error fetching transactions: $e');
    }
  }

  /// Aggregate transactions by a given key (category, spending plan, type)
  Future<Response> getTransactionsAggregatedBy(
      Request request, String userId, String key) async {
    try {
      final transactions = await _transactionStore.fetchWhere('userId', userId);
      final groupedByYear = <String, Map<String, dynamic>>{};

      for (var transaction in transactions) {
        final year = transaction.date.year.toString();
        final month = transaction.date.month.toString().padLeft(2, '0');
        final aggregationKey = key == 'category'
            ? transaction.category
            : key == 'spendingPlan'
                ? transaction.spendingPlan ?? 'Unassigned'
                : transaction.type;

        groupedByYear.putIfAbsent(year, () => {});
        final yearData = groupedByYear[year]!;

        yearData.putIfAbsent(month, () => {});
        final monthData = yearData[month]!;

        monthData.putIfAbsent(
            aggregationKey, () => {'transactions': [], 'totalSpending': 0.0});
        monthData[aggregationKey]['transactions'].add(transaction.toJson());
        monthData[aggregationKey]['totalSpending'] += transaction.amount;
      }

      final details = groupedByYear.entries
          .map((yearEntry) => {
                'year': yearEntry.key,
                'yearDetail': yearEntry.value.entries
                    .map((monthEntry) => {
                          'month': monthEntry.key,
                          'monthDetail': monthEntry.value.entries
                              .map((entry) => {
                                    key: entry.key,
                                    'totalSpending': entry.value['totalSpending'],
                                    'transactions': entry.value['transactions']
                                  })
                              .toList()
                        })
                    .toList()
              })
          .toList();

      final totals = transactions.fold(<String, double>{}, (map, t) {
        final aggregationKey = key == 'category'
            ? t.category
            : key == 'spendingPlan'
                ? t.spendingPlan ?? 'Unassigned'
                : t.type;
        map[aggregationKey] = (map[aggregationKey] ?? 0.0) + t.amount;
        return map;
      });

      final averages = totals.map((key, value) => MapEntry(key, value / groupedByYear.length));

      return Response.ok(jsonEncode({'totals': totals, 'averages': averages, 'details': details}));
    } catch (e) {
      return Response.internalServerError(body: 'Error fetching transactions aggregated by $key: $e');
    }
  }

  /// Create a new transaction
  Future<Response> createTransactionHandler(Request request) async {
    try {
      final body = await parseRequestBody(request);
      final transaction = Transaction.fromJson(body);
      await _transactionStore.save(transaction.id, transaction);
      return Response.ok(jsonEncode({'message': 'Transaction created successfully'}));
    } catch (e) {
      return Response.internalServerError(body: 'Error creating transaction: $e');
    }
  }

  /// Update a transaction
  Future<Response> updateTransactionHandler(Request request, String transactionId) async {
    try {
      final body = await parseRequestBody(request);
      await _transactionStore.update(transactionId, body);
      return Response.ok(jsonEncode({'message': 'Transaction updated successfully'}));
    } catch (e) {
      return Response.internalServerError(body: 'Error updating transaction: $e');
    }
  }

  /// Delete a transaction
  Future<Response> deleteTransactionHandler(Request request, String transactionId) async {
    try {
      await _transactionStore.delete(transactionId);
      return Response.ok(jsonEncode({'message': 'Transaction deleted successfully'}));
    } catch (e) {
      return Response.internalServerError(body: 'Error deleting transaction: $e');
    }
  }
}

/// LocalstoreService implementation for Transaction
class TransactionLocalstoreService extends LocalstoreService<Transaction> {
  @override
  String get collectionName => 'transactions';

  @override
  Transaction fromJson(Map<String, dynamic> json) => Transaction.fromJson(json);

  @override
  Map<String, dynamic> toJson(Transaction object) => object.toJson();
}

import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../data/json_storage.dart';
import '../models/transaction.dart';
import 'service.dart';

/// TransactionService handles CRUD operations and data aggregation for transactions
class TransactionJsonStorage extends JsonStorage<Transaction> {
  TransactionJsonStorage() : super('bin/data/json/transactions.json');

  @override
  Transaction fromJson(Map<String, dynamic> json) => Transaction.fromJson(json);

  @override
  Map<String, dynamic> toJson(Transaction object) => object.toJson();
}

class TransactionsService with Service {
  final TransactionJsonStorage _transactionStorage = TransactionJsonStorage();
  final _headers = {'Content-Type': 'application/json'};

  /// Get transactions with optional time range and limit parameters
  Future<Response> getAllTransactionsHandler(
      Request request, String userId) async {
    try {
      final queryParams = request.url.queryParameters;
      final limit = int.tryParse(queryParams['limit'] ?? '0') ?? 0;
      final startDate = queryParams['startDate'] != null
          ? DateTime.tryParse(queryParams['startDate']!)
          : null;
      final endDate = queryParams['endDate'] != null
          ? DateTime.tryParse(queryParams['endDate']!)
          : null;

      // Fetch all transactions for the user
      var transactions = await _transactionStorage.fetchWhere('userId', userId);

      // Lọc theo khoảng thời gian
      if (startDate != null || endDate != null) {
        transactions = transactions.where((t) {
          final date = t.date;
          return (startDate == null || date.isAfter(startDate)) &&
              (endDate == null || date.isBefore(endDate));
        }).toList();
      }

      // Sắp xếp từ mới nhất đến cũ nhất
      transactions.sort((a, b) => b.date.compareTo(a.date));

      // Áp dụng giới hạn số lượng (nếu có)
      if (limit > 0) {
        transactions = transactions.take(limit).toList();
      }

      return Response.ok(
          jsonEncode(transactions.map((t) => t.toJson()).toList()),
          headers: _headers);
    } catch (e) {
      return Response.internalServerError(
          body: jsonEncode({
            'error': 'Error fetching transactions',
            'details': e.toString(),
            'suggestion': 'Check query parameters and ensure they are valid.'
          }),
          headers: _headers);
    }
  }

  /// Create a new transaction with amount adjustment
  Future<Response> createTransactionHandler(Request request) async {
    try {
      final body = await parseRequestBody(request);

      // Tạo giao dịch từ dữ liệu request
      final transaction = Transaction.fromJson(body);

      // Nếu loại là outcome, chuyển amount thành số âm
      final adjustedTransaction = transaction.type == 'outcome'
          ? transaction.copyWith(amount: -transaction.amount.abs())
          : transaction;

      await _transactionStorage.save(
          adjustedTransaction.id, adjustedTransaction);
      return Response.ok(
          jsonEncode({'message': 'Transaction created successfully'}),
          headers: _headers);
    } catch (e) {
      return Response.internalServerError(
          body: jsonEncode({
            'error': 'Error creating transaction',
            'details': e.toString(),
            'suggestion': 'Ensure the request data is valid.'
          }),
          headers: _headers);
    }
  }

  /// Aggregate transactions by a given key (category, spending plan, type)
  /// descending order by time e.g 12/2024, 11/2024, 10/2024, ...
  Future<Response> getTransactionsAggregatedBy(
      Request request, String userId, String key) async {
    try {
      final transactions =
          await _transactionStorage.fetchWhere('userId', userId);
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

      // Sắp xếp details theo thứ tự giảm dần năm và tháng
      final sortedDetails = groupedByYear.entries.toList();
      sortedDetails
          .sort((a, b) => b.key.compareTo(a.key)); // Sắp xếp năm giảm dần

      final details = sortedDetails.map((yearEntry) {
        final sortedMonths = yearEntry.value.entries.toList();
        sortedMonths
            .sort((a, b) => b.key.compareTo(a.key)); // Sắp xếp tháng giảm dần

        return {
          'year': yearEntry.key,
          'yearDetail': sortedMonths.map((monthEntry) {
            return {
              'month': monthEntry.key,
              'monthDetail': monthEntry.value.entries.map((entry) {
                return {
                  key: entry.key,
                  'totalSpending': entry.value['totalSpending'],
                  'transactions': entry.value['transactions'],
                };
              }).toList(),
            };
          }).toList(),
        };
      }).toList();

      // Sắp xếp totals và averages theo giá trị giảm dần
      final totals = transactions.fold(<String, double>{}, (map, t) {
        final aggregationKey = key == 'category'
            ? t.category
            : key == 'spendingPlan'
                ? t.spendingPlan ?? 'Unassigned'
                : t.type;
        map[aggregationKey] = (map[aggregationKey] ?? 0.0) + t.amount;
        return map;
      });

      final sortedTotals = Map.fromEntries(
          totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value)));

      final averages = sortedTotals
          .map((key, value) => MapEntry(key, value / groupedByYear.length));

      return Response.ok(
          jsonEncode({
            'totals': sortedTotals,
            'averages': averages,
            'details': details
          }),
          headers: _headers);
    } catch (e) {
      return Response.internalServerError(
          body: 'Error fetching transactions aggregated by $key: $e',
          headers: _headers);
    }
  }

  /// Update a transaction
  Future<Response> updateTransactionHandler(
      Request request, String transactionId) async {
    try {
      // Đọc dữ liệu từ request
      final updates = await parseRequestBody(request);

      // Lấy giao dịch hiện có
      final existingTransaction =
          await _transactionStorage.fetchById(transactionId);
      if (existingTransaction == null) {
        return Response.notFound('Transaction not found', headers: _headers);
      }

      // Kết hợp dữ liệu cũ và mới
      final updatedTransaction = Transaction(
        id: transactionId,
        userId: updates['userId'] ?? existingTransaction.userId,
        name: updates['name'] ?? existingTransaction.name,
        type: updates['type'] ?? existingTransaction.type,
        spendingPlan:
            updates['spendingPlan'] ?? existingTransaction.spendingPlan,
        category: updates['category'] ?? existingTransaction.category,
        amount: updates['amount'] != null
            ? double.parse(updates['amount'].toString())
            : existingTransaction.amount,
        date: updates['date'] != null
            ? DateTime.parse(updates['date'])
            : existingTransaction.date,
      );

      // Lưu lại giao dịch đã cập nhật
      await _transactionStorage.save(transactionId, updatedTransaction);

      return Response.ok(
          jsonEncode({'message': 'Transaction updated successfully'}),
          headers: _headers);
    } catch (e) {
      return Response.internalServerError(
          body: 'Error updating transaction: $e', headers: _headers);
    }
  }

  /// Delete a transaction
  Future<Response> deleteTransactionHandler(
      Request request, String transactionId) async {
    try {
      await _transactionStorage.delete(transactionId);
      return Response.ok(
          jsonEncode({'message': 'Transaction deleted successfully'}),
          headers: _headers);
    } catch (e) {
      return Response.internalServerError(
          body: 'Error deleting transaction: $e', headers: _headers);
    }
  }
}

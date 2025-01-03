import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../models/transaction.dart';
import 'service.dart';
import '../data/category_storage.dart';
import '../data/transaction_storage.dart';
import '../service/spending_plan_service.dart';

final spendingPlanService = SpendingPlanService();

class TransactionsService with Service {
  final TransactionStorage transactionStorage =
      TransactionStorage('bin/data/json/transactions.json');
  final CategoryStorage categoryStorage =
      CategoryStorage('bin/data/json/categories.json');
  final _headers = {'Content-Type': 'application/json'};

  /// Get transactions with optional time range and limit parameters
  Future<Response> getAllTransactionsHandlerByUserId(
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
      var transactions = await transactionStorage.fetchWhere('userId', userId);

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

  Future<Response> getAllTransactionsHandlerByTransactionId(
      Request request, String transactionId) async {
    try {
      // Fetch the transaction by ID
      final transaction = await transactionStorage.fetchById(transactionId);

      // If no transaction is found, return a 404 response
      if (transaction == null) {
        return Response.notFound('Transaction not found', headers: _headers);
      }

      // Fetch the category details based on the transaction's category
      final category = await categoryStorage.fetchById(transaction.category);

      // Prepare the response object with enhanced details
      final transactionWithDetails = transaction.toJson();
      transactionWithDetails.remove('category');
      // If category exists, enrich the transaction with category details
      if (category != null) {
        transactionWithDetails['categoryDetails'] = {
          'id': category.id,
          'name': category.name,
          'icon': category.icon,
          'color': category.color,
        };
      }

      // Return the response with the enriched transaction data
      return Response.ok(jsonEncode(transactionWithDetails), headers: _headers);
    } catch (e) {
      // Handle errors gracefully with a 500 response
      return Response.internalServerError(
        body: 'Error fetching transaction: $e',
        headers: _headers,
      );
    }
  }

  /// add a new transaction
  /// if transaction type is outcome, amount should be negative
  /// and use subtractSpendingPlanAmountHandler to subtract spending plan amount
  /// if transaction type is income, amount should be positive
  /// and use addSpendingPlanAmountHandler to add spending plan amount
  Future<Response> createTransactionHandler(Request request) async {
    try {
      final body = await parseRequestBody(request);

      // Create transaction from request data
      final transaction = Transaction.fromJson(body);

      // if transaction type is outcome, amount should be negative
      final adjustedTransaction = transaction.type == 'Outcome'
          ? transaction.copyWith(amount: -transaction.amount.abs())
          : transaction;
// Update spending plan based on transaction type
      if (adjustedTransaction.type == 'Income') {
        await spendingPlanService.addSpendingPlanAmountHandler(
            request, adjustedTransaction.userId, adjustedTransaction.amount);
      } else if (adjustedTransaction.type == 'Outcome') {
        await spendingPlanService.subtractSpendingPlanAmountHandler(
            request,
            adjustedTransaction.userId,
            adjustedTransaction.spendingPlan ?? 'null',
            adjustedTransaction.amount);
      }
      await transactionStorage.save(
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

  Future<Response> getTransactionsAggregatedBy(
      Request request, String userId, String key) async {
    try {
      final transactions =
          await transactionStorage.fetchWhere('userId', userId);

      // Nhóm các giao dịch theo năm và tháng
      final groupedByYear = <String, Map<String, Map<String, dynamic>>>{};

      for (var transaction in transactions) {
        final year = transaction.date.year.toString();
        final month = transaction.date.month.toString().padLeft(2, '0');
        final aggregationKey = key == 'category'
            ? transaction.category
            : key == 'spendingPlan'
                ? transaction.spendingPlan ?? 'Income'
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

      // **Sắp xếp theo thứ tự giảm dần năm và tháng**
      final sortedDetails = groupedByYear.entries.toList();
      sortedDetails.sort((a, b) => b.key.compareTo(a.key));

      final details = sortedDetails.map((yearEntry) {
        final sortedMonths = yearEntry.value.entries.toList();
        sortedMonths
            .sort((a, b) => int.parse(b.key).compareTo(int.parse(a.key)));

        return {
          'year': yearEntry.key,
          'yearDetail': sortedMonths.map((monthEntry) {
            return {
              'month': monthEntry.key,
              'monthDetail': monthEntry.value.entries.map((entry) {
                return {
                  'key': entry.key,
                  'transactions': (entry.value['transactions'] as List<dynamic>)
                      .cast<Map<String, dynamic>>(),
                };
              }).toList(),
            };
          }).toList(),
        };
      }).toList();

      return Response.ok(
        jsonEncode({'details': details}),
        headers: _headers,
      );
    } catch (e) {
      return Response.internalServerError(
        body: 'Error fetching transactions aggregated by $key: $e',
        headers: _headers,
      );
    }
  }

  Future<Response> getTransactionsAggregatedByMonthYear(Request request,
      String userId, String key, String month, String year) async {
    try {
      // Call `getTransactionsAggregatedBy` and await the result
      final aggregatedResponse =
          await getTransactionsAggregatedBy(request, userId, key);

      // Decode the response from `getTransactionsAggregatedBy`
      final responseData = jsonDecode(await aggregatedResponse.readAsString());

      // Extract the `details` field from the response
      final details = responseData['details'] as List<dynamic>;

      // Find the specific year data
      final yearData = details.firstWhere(
        (d) => d['year'] == year.toString(),
        orElse: () => null,
      );

      if (yearData == null) {
        return Response.ok(
          jsonEncode({
            'month': month.toString().padLeft(2, '0'),
            'year': year.toString(),
            'aggregatedData': [],
          }),
          headers: _headers,
        );
      }

      // Find the specific month data
      final monthData = (yearData['yearDetail'] as List<dynamic>).firstWhere(
        (d) => d['month'] == month.toString().padLeft(2, '0'),
        orElse: () => null,
      );

      if (monthData == null) {
        return Response.ok(
          jsonEncode({
            'month': month.toString().padLeft(2, '0'),
            'year': year.toString(),
            'aggregatedData': [],
          }),
          headers: _headers,
        );
      }

      return Response.ok(
        jsonEncode(monthData),
        headers: _headers,
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({
          'error': 'Error fetching transactions aggregated by month/year',
          'details': e.toString(),
        }),
        headers: _headers,
      );
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
          await transactionStorage.fetchById(transactionId);
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
      await transactionStorage.save(transactionId, updatedTransaction);

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
      await transactionStorage.delete(transactionId);
      return Response.ok(
          jsonEncode({'message': 'Transaction deleted successfully'}),
          headers: _headers);
    } catch (e) {
      return Response.internalServerError(
          body: 'Error deleting transaction: $e', headers: _headers);
    }
  }
}

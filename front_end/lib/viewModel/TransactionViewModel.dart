import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/transaction.dart';
import 'package:http/http.dart' as http;

class TransactionViewModel with ChangeNotifier {
  String baseURL = "http://${dotenv.env['ip']}:${dotenv.env['port']}/api/v1";
  String path1 = "transactions";
  String path2 = "transaction";
  bool isLoading = false;

  Future<Map<String, dynamic>> getTransactions(String userId) async {
    isLoading = true;
    notifyListeners();

    final url = Uri.parse('$baseURL/$path1/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      isLoading = false;
      notifyListeners();
      return jsonData;
    } else {
      throw Exception('Failed to load transactions');
    }
  }

  Future<Map<String, dynamic>> getTransactionDetail(String transactionId) async {
    isLoading = true;
    notifyListeners();

    final url = Uri.parse('$baseURL/$path2/$transactionId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      isLoading = false;
      notifyListeners();
      return jsonData;
    } else {
      throw Exception('Failed to load transactions');
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    isLoading = true;
    notifyListeners();

    final url = Uri.parse('$baseURL/$path2');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(transaction.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add transaction');
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> deleteTransaction(String transactionId) async {
    isLoading = true;
    notifyListeners();

    final url = Uri.parse('$baseURL/$path2/$transactionId');
    final response = await http.delete(url);

    if (response.statusCode != 204) {
      throw Exception('Failed to delete transaction');
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    isLoading = true;
    notifyListeners();

    final url = Uri.parse('$baseURL/$path2/${transaction.id}');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(transaction.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update transaction');
    }

    isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> getTransactionsAggregate(
      String userId, String key) async {
    isLoading = true;
    notifyListeners();
    final url = Uri.parse('$baseURL/$path1/$userId/aggregate/$key');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      final Map<String, dynamic> data =
          jsonData.containsKey("details") ? jsonData["details"] : {};
      isLoading = false;
      notifyListeners();
      return data;
    } else {
      isLoading = false;
      notifyListeners();
      throw Exception('Failed to load aggregate data');
    }
  }

  Future<Map<String, dynamic>> getTransactionsAggregateByMonth(
      String userId, String key, String month, String year) async {
    isLoading = true;
    notifyListeners();
    final url =
        Uri.parse('$baseURL/$path1/$userId/aggregate/$key/$month/$year');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      isLoading = false;
      notifyListeners();
      return jsonData;
    } else {
      isLoading = false;
      notifyListeners();
      throw Exception('Failed to load aggregate data');
    }
  }
}

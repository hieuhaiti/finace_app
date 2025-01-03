import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front_end/viewModel/TransactionViewModel.dart';
import '../models/category.dart';

import 'package:http/http.dart' as http;

class CategoryViewModel with ChangeNotifier {
  String baseURL = "http://${dotenv.env['ip']}:${dotenv.env['port']}/api/v1";
  String path = "categories";
  bool isLoading = false;

  Future<List<Category>> fetchCategories(String userId) async {
    isLoading = true;
    notifyListeners();

    final response = await http.get(
      Uri.parse('$baseURL/$path/$userId'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      isLoading = false;
      notifyListeners();
      return data.map((e) => Category.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  // get category details
  Future<Category> getCategoryDetails(String userID, String categoryId) async {
    isLoading = true;
    notifyListeners();
    try {
      final categories = await fetchCategories(userID);
      isLoading = false;
      notifyListeners();
      final category = categories.firstWhere(
        (item) => item.id == categoryId,
        orElse: () => throw Exception('Category not found'),
      );

      return category;
    } catch (e) {
      throw Exception('Failed to fetch category details: $e');
    }
  }

  // add category
  Future<void> addCategory(Category category) async {
    isLoading = true;
    notifyListeners();

    final url = Uri.parse('$baseURL/$path');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(category.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add category');
    }

    isLoading = false;
    notifyListeners();
  }

  // update category
  Future<void> updateCategory(Category category) async {
    isLoading = true;
    notifyListeners();

    final url = Uri.parse('$baseURL/$path/${category.id}');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(category.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update category');
    }

    isLoading = false;
    notifyListeners();
  }

  // delete category
  Future<void> deleteCategory(String categoryId) async {
    isLoading = true;
    notifyListeners();

    final response = await http.delete(Uri.parse('$baseURL/$path/$categoryId'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete category');
    }

    isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> getTopCategoriesCurrent(
      String userId, int top, String month, String year) async {
    isLoading = true;
    notifyListeners();
    TransactionViewModel transactionViewModel = TransactionViewModel();
    final dataAll =
        await transactionViewModel.getTransactionsAggregate(userId, 'category');
    final dataByMonth = await transactionViewModel
        .getTransactionsAggregateByMonth(userId, 'category', month, year);

    final dataDetail = dataAll['details'];
    final averages = dataDetail['average'];
    final sortedTotals = averages.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final totals = dataByMonth['total'];

    // Get top categories
    final topCategories = sortedTotals.take(top).map((entry) {
      return {
        'categoryId': entry.key,
        'average': averages[entry.key],
        'totalInMonth': totals[entry.key] ?? 0.0,
      };
    }).toList();

    // Fetch category details
    final categoryDetails = [];
    for (var category in topCategories) {
      final categoryId = category['categoryId'];
      final categoryDetail = await getCategoryDetails(userId, categoryId);
      final categoryMap = categoryDetail.toJson();
      categoryMap['average'] = category['average'];
      categoryMap['totalInMonth'] = category['totalInMonth'];
      categoryDetails.add(categoryMap);
    }

    isLoading = false;
    notifyListeners();
    return {
      'year': year,
      'month': month,
      'details': categoryDetails,
    };
  }
}

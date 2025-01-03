import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GenerateViewmodel with ChangeNotifier {
  String baseURL = "http://${dotenv.env['ip']}:${dotenv.env['port']}/api/v1";
  String path = "dashBoard";
  bool isLoading = false;

  Future<Map<String, dynamic>> getNetWorthCurrent(String userId) async {
    isLoading = true;
    notifyListeners();

    final url = Uri.parse('$baseURL/$path/$userId/networth/current');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      isLoading = false;
      notifyListeners();
      return jsonData;
    } else {
      throw Exception('Failed to load networth current');
    }
  }

  Future<Map<String, dynamic>> getNetWorthDetail(String userId) async {
    isLoading = true;
    notifyListeners();

    final url = Uri.parse('$baseURL/$path/$userId/networth/detail');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      isLoading = false;
      notifyListeners();
      return jsonData;
    } else {
      throw Exception('Failed to load networth detail');
    }
  }

  Future<Map<String, dynamic>> getCategoryCurrent(
      String userId, String numberOfCategory) async {
    isLoading = true;
    notifyListeners();

    final url =
        Uri.parse('$baseURL/$path/$userId/category/current/$numberOfCategory');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      isLoading = false;
      notifyListeners();
      return jsonData;
    } else {
      throw Exception('Failed to load category current');
    }
  }

  Future<Map<String, dynamic>> getCategoryDetail(String userId) async {
    isLoading = true;
    notifyListeners();

    final url = Uri.parse('$baseURL/$path/$userId/category/detail');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      isLoading = false;
      notifyListeners();
      return jsonData;
    } else {
      throw Exception('Failed to load category detail');
    }
  }

  Future<Map<String, dynamic>> getSpendingPlantCurrent(String userId) async {
    isLoading = true;
    notifyListeners();

    final url = Uri.parse('$baseURL/$path/$userId/spending-plant/current');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      isLoading = false;
      notifyListeners();
      return jsonData;
    } else {
      throw Exception('Failed to load spending plant current');
    }
  }

  Future<Map<String, dynamic>> getSpendingPlantDetail(
      String userId, String spendingPlan) async {
    isLoading = true;
    notifyListeners();

    final url =
        Uri.parse('$baseURL/$path/$userId/spending-plant/detail/$spendingPlan');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = jsonDecode(response.body);
      isLoading = false;
      notifyListeners();
      return jsonData;
    } else {
      throw Exception('Failed to load spending plant detail');
    }
  }
}

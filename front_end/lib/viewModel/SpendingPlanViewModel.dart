import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/spending_plan.dart';
import 'package:http/http.dart' as http;

class SpendingPlanViewModel with ChangeNotifier {
  String baseURL = "http://${dotenv.env['ip']}:${dotenv.env['port']}/api/v1";
  String path = "spending-plans";
  bool isLoading = false;

  Future<SpendingPlan> fetchSpendingPlan(String userId) async {
    isLoading = true;
    notifyListeners();

    final url = Uri.parse('$baseURL/$path/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      isLoading = false;
      notifyListeners();
      return SpendingPlan.fromJson(data);
    } else {
      throw Exception('Failed to load spending plan');
    }
  }

  // put spending plan
  Future<void> putSpendingPlan(SpendingPlan spendingPlan) async {
    isLoading = true;
    notifyListeners();

    final url = Uri.parse('$baseURL/$path/${spendingPlan.userId}');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(spendingPlan.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update spending plan');
    }

    isLoading = false;
    notifyListeners();
  }

  //delete spending plan
  Future<void> deleteSpendingPlan(String userId, String categoryId) async {
    isLoading = true;
    notifyListeners();

    final url = Uri.parse('$baseURL/$path/$userId/$categoryId');
    final response = await http.delete(url);

    if (response.statusCode != 204) {
      throw Exception('Failed to delete spending plan');
    }

    isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> getSpendingPlantDetail(
      String userId, String spendingPlan, String type) async {
    isLoading = true;
    notifyListeners();

    final url = Uri.parse('$baseURL/$path/$userId/$spendingPlan/$type');
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

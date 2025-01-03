// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:front_end/common/color_extension.dart';
import 'package:front_end/views/dashboard/category_widget.dart';
import 'package:front_end/views/dashboard/spending_plant_widget.dart';
import 'package:front_end/views/dashboard/total_budget_widget.dart';

class DashboardPage extends StatefulWidget {
  final String userId;

  const DashboardPage({
    super.key,
    required this.userId,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: TColor.gray,
        body: SingleChildScrollView(
            child: Column(children: [
          Container(
            height: size.height * 0.1,
            width: size.width,
            decoration: BoxDecoration(
              color: TColor.gray70,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Welcome to Finance App",
                  style: TextStyle(
                    color: TColor.primaryText,
                    fontSize: 20,
                  ),
                ),
                Text(
                  "Manage your finance easily",
                  style: TextStyle(
                    color: TColor.primaryText,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          TotalBudgetWidget(
            size: size,
            userId: widget.userId,
          ),
          const SizedBox(height: 20),
          SpendingPlantWidget(size: size, userId: widget.userId),
          const SizedBox(height: 20),
          CategoryWidget(
            size: size,
            userId: widget.userId,
          ),
        ])));
  }
}

import 'package:flutter/material.dart';
import 'package:front_end/common/color_extension.dart';
import 'package:front_end/views/spending%20plan/spendingPlanChart.dart';
import 'package:front_end/views/spending%20plan/spendingPlanOverview.dart';
import 'package:front_end/views/spending%20plan/spendingPlanTransaction.dart';

class SpendingplanPage extends StatefulWidget {
  final String userId;

  const SpendingplanPage({super.key, required this.userId});

  @override
  State<SpendingplanPage> createState() => _SpendingplanPageState();
}

class _SpendingplanPageState extends State<SpendingplanPage> {
  final ValueNotifier<String> _selectedPlanName =
      ValueNotifier<String>("needs");
  final ValueNotifier<String> _selectedTypeName =
      ValueNotifier<String>("Combined");

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: TColor.gray,
      body: Padding(
        padding: const EdgeInsets.only(top: 15, right: 8, left: 8),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Spending Plan Overview
              SpendingplanOverview(
                size: size,
                userId: widget.userId,
                onPlanSelected: (planName) {
                  _selectedPlanName.value = planName;
                },
              ),
              const SizedBox(height: 10),

              // Spending Plan Chart
              ValueListenableBuilder<String>(
                valueListenable: _selectedPlanName,
                builder: (context, planName, _) {
                  return SpendingplanChart(
                    size: size,
                    userId: widget.userId,
                    spendingPlan: planName,
                    onTypeSelected: (typeName) {
                      _selectedTypeName.value = typeName;
                    },
                  );
                },
              ),
              const SizedBox(height: 5),

              // Spending Plan Transactions
              ValueListenableBuilder<String>(
                valueListenable: _selectedTypeName,
                builder: (context, typeName, _) {
                  return ValueListenableBuilder<String>(
                    valueListenable: _selectedPlanName,
                    builder: (context, planName, _) {
                      return SpendingplanTransaction(
                        size: size,
                        userId: widget.userId,
                        spendingPlan: planName,
                        typeOfTrans: typeName,
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

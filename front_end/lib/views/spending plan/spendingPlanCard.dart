import 'dart:math';
import 'package:flutter/material.dart';
import 'package:front_end/common/color_extension.dart';
import 'package:front_end/views/spending%20plan/modalContent.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class SpendingPlanCard extends StatelessWidget {
  final Size size;
  final String planName;
  final double totalAmount;
  final double income;
  final double outcome;
  final double remain;
  final List<ChartData>? chartData;

  const SpendingPlanCard(
      {super.key,
      required this.size,
      required this.planName,
      required this.totalAmount,
      required this.income,
      required this.outcome,
      required this.remain,
      required this.chartData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              showMaterialModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) => ModalContent(
                  planNameSelected: planName,
                  chartData: chartData!,
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: TColor.gray60,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    planName,
                    style: TextStyle(
                      color: TColor.primaryText,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Center(
                  child: Text(
                    "Total amount: ${totalAmount.toStringAsFixed(2)}",
                    style: TextStyle(
                      color: TColor.primaryText,
                      fontSize: 17,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Income: ${income.toStringAsFixed(2)}",
                      style: TextStyle(
                        color: TColor.lightGreen,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      "Outcome: ${outcome.toStringAsFixed(2)}",
                      style: TextStyle(
                        color: TColor.lightRed,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Progress bar
                Container(
                  height: 15,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: TColor.primaryText,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: min(
                      (income != 0) ? (outcome.abs() / income) : 0.0,
                      1.0, // Đảm bảo widthFactor không vượt quá 1.0
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: remain >= 0 ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 7),
                Center(
                  child: Text(
                    remain >= 0
                        ? "Remaining: ${remain.toStringAsFixed(2)}"
                        : "${remain.abs().toStringAsFixed(2)} over", // Hiển thị số dư hoặc vượt mức
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: remain >= 0 ? TColor.lightGreen : TColor.lightRed,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:front_end/common/color_extension.dart';

class SpendingPlanCard extends StatelessWidget {
  final Size size;
  final int height;
  final int width;
  final Color color;
  final String planName;
  final double totalAmount;
  final double income;
  final double outcome;
  final double remain;

  const SpendingPlanCard({
    Key? key,
    required this.size,
    required this.height,
    required this.width,
    required this.color,
    required this.planName,
    required this.totalAmount,
    required this.income,
    required this.outcome,
    required this.remain,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Stack(
        children: [
          Container(
            height: size.height * height,
            width: size.width * width,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          // Nội dung chi tiết
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      planName.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: TColor.primaryText,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      "Total: ${totalAmount.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: TColor.primaryText,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Income: ${income.toStringAsFixed(2)}",
                      style: TextStyle(
                        color: TColor.lightGreen,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      "Outcome: ${outcome.toStringAsFixed(2)}",
                      style: TextStyle(
                        color: TColor.lightRed,
                        fontSize: 12,
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
                      fontSize: 14,
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

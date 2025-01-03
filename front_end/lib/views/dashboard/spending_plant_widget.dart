import 'dart:math';

import 'package:flutter/material.dart';
import 'package:front_end/common/color_extension.dart';
import 'package:front_end/common_widget/error_widget.dart';
import 'package:front_end/common_widget/loading_widget.dart';
import 'package:front_end/common_widget/no_data_widget.dart';
import 'package:front_end/viewModel/GenerateViewmodel.dart';

class SpendingPlantWidget extends StatefulWidget {
  final Size size;
  final String userId;
  const SpendingPlantWidget(
      {super.key, required this.size, required this.userId});

  @override
  State<SpendingPlantWidget> createState() => _SpendingPlantWidgetState();
}

class _SpendingPlantWidgetState extends State<SpendingPlantWidget> {
  Map<String, dynamic>? _data;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data =
          await GenerateViewmodel().getSpendingPlantCurrent(widget.userId);
      setState(() {
        _data = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return LoadingWidget(
        height: widget.size.height * 0.18,
        width: widget.size.width,
      );
    }

    if (_error != null) {
      return ErrorWidgetCustom(
          height: widget.size.height * 0.18,
          width: widget.size.width,
          errorMessage: _error);
    }

    if (_data == null || _data!.isEmpty) {
      return NoDataWidget(
        height: widget.size.height * 0.18,
        width: widget.size.width,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Spending Plan",
                  style: TextStyle(
                    color: TColor.primaryText,
                    fontSize: 14,
                  )),
              Text("View All >",
                  style: TextStyle(
                    color: TColor.primary20,
                    fontSize: 14,
                  )),
            ],
          ),
          const SizedBox(height: 10),
          Stack(children: [
            // Nền tổng thể (bo góc)
            Container(
              height: widget.size.height * 0.18,
              width: widget.size.width,
              decoration: BoxDecoration(
                color: TColor.gray60,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: PageView.builder(
                  itemCount: _data!.keys.length,
                  itemBuilder: (context, index) {
                    String planName = _data!.keys.elementAt(index);
                    Map<String, dynamic> planDetails = _data![planName];
                    Map<String, dynamic> detail = planDetails['detail'];

                    return SpendingPlanCard(
                      size: widget.size,
                      planName: planName,
                      totalAmount: planDetails['amount'],
                      income: detail['Income'],
                      outcome: detail['Outcome'],
                      remain: detail['Remain'],
                    );
                  },
                ),
              ),
            ),
          ])
        ],
      ),
    );
  }
}

class SpendingPlanCard extends StatelessWidget {
  final Size size;
  final String planName;
  final double totalAmount;
  final double income;
  final double outcome;
  final double remain;

  const SpendingPlanCard({
    Key? key,
    required this.size,
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
            height: size.height * 0.15,
            width: size.width,
            decoration: BoxDecoration(
              color: TColor.gray70,
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
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "Total: ${totalAmount.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: TColor.primaryText,
                        fontSize: 16,
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
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      "Outcome: ${outcome.toStringAsFixed(2)}",
                      style: TextStyle(
                        color: TColor.lightRed,
                        fontSize: 13,
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
                      fontSize: 16,
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

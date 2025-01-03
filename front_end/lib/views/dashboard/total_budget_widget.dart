import 'package:flutter/material.dart';
import 'package:front_end/common/color_extension.dart';
import 'package:front_end/common_widget/error_widget.dart';
import 'package:front_end/common_widget/loading_widget.dart';
import 'package:front_end/common_widget/no_data_widget.dart';
import 'package:front_end/viewModel/GenerateViewmodel.dart';

class TotalBudgetWidget extends StatefulWidget {
  final Size size;
  final String userId;

  const TotalBudgetWidget({
    super.key,
    required this.size,
    required this.userId,
  });

  @override
  _TotalBudgetWidgetState createState() => _TotalBudgetWidgetState();
}

class _TotalBudgetWidgetState extends State<TotalBudgetWidget> {
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
      final data = await GenerateViewmodel().getNetWorthCurrent(widget.userId);
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
        height: widget.size.height * 0.15,
        width: widget.size.width,
      );
    }

    if (_error != null) {
      return ErrorWidgetCustom(
          height: widget.size.height * 0.15,
          width: widget.size.width,
          errorMessage: _error);
    }

    if (_data == null || _data!.isEmpty) {
      return NoDataWidget(
        height: widget.size.height * 0.15,
        width: widget.size.width,
      );
    }

    // Truy cập và xử lý dữ liệu
    final double income = (_data?['Income'] as num?)?.toDouble() ?? 0.0;
    final double outcome = (_data?['Outcome'] as num?)?.toDouble() ?? 0.0;
    final double remain = (_data?['Remain'] as num?)?.toDouble() ?? 0.0;

    // Trả về giao diện
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Budget",
                style: TextStyle(
                  color: TColor.primaryText,
                  fontSize: 16,
                ),
              ),
              Text(
                "View All >",
                style: TextStyle(
                  color: TColor.primary20,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Stack(
            children: [
              // Nền tổng thể (bo góc)
              Container(
                height: widget.size.height * 0.15,
                width: widget.size.width,
                decoration: BoxDecoration(
                  color: TColor.gray60,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // Nội dung
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: Column(
                  children: [
                    const SizedBox(height: 5),
                    Center(
                      child: Text(
                        "Remain: \$${remain.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: TColor.primaryText,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Stack(
                      children: [
                        FractionallySizedBox(
                          widthFactor: income / income,
                          child: Container(
                            height: 30,
                            decoration: BoxDecoration(
                              color: TColor.green,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: 1.0,
                          child: Container(
                            height: 30,
                            alignment: Alignment.centerRight,
                            child: FractionallySizedBox(
                              widthFactor: -outcome / income,
                              child: Container(
                                height: 30,
                                decoration: BoxDecoration(
                                  color: TColor.red,
                                  borderRadius: const BorderRadius.horizontal(
                                      right: Radius.circular(5)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Income:\n${income.toStringAsFixed(2)}",
                          style: TextStyle(
                            color: TColor.lightGreen,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "Outcome:\n${outcome.toStringAsFixed(2)}",
                          style: TextStyle(
                            color: TColor.lightRed,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:front_end/common_widget/loading_widget.dart';
import 'package:front_end/common_widget/no_data_widget.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:front_end/common/color_extension.dart';
import 'package:front_end/common_widget/error_widget.dart';
import 'package:front_end/viewModel/GenerateViewModel.dart';

class CategoryChart extends StatefulWidget {
  final Size size;
  final String userId;

  const CategoryChart({
    super.key,
    required this.size,
    required this.userId,
  });

  @override
  State<CategoryChart> createState() => _CategoryChartState();
}

class _CategoryChartState extends State<CategoryChart> {
  Map<String, dynamic>? _data;
  bool _isLoading = true;
  String? _error;
  late TooltipBehavior _tooltipBehavior;
  late double totalAmount;

  @override
  void initState() {
    super.initState();
    _tooltipBehavior = TooltipBehavior(enable: true);
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data =
          await GenerateViewmodel().getCategoryCurrent(widget.userId, '4');
      setState(() {
        _data = data;
        totalAmount = _calculateTotal(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  double _calculateTotal(Map<String, dynamic>? data) {
    if (data == null) return 0;
    return data.values.fold(0.0, (sum, item) {
      final amount = double.parse(item['amount'].toString());
      return sum + amount.abs();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return LoadingWidget(
        height: widget.size.height * 0.45,
        width: widget.size.width,
      );
    }

    if (_error != null) {
      return ErrorWidgetCustom(
          height: widget.size.height * 0.45,
          width: widget.size.width,
          errorMessage: _error);
    }

    if (_data == null || _data!.isEmpty) {
      return NoDataWidget(
        height: widget.size.height * 0.45,
        width: widget.size.width,
      );
    }

    final chartData = _data!.entries.map((entry) {
      final value = entry.value;
      return _ChartData(
        name: value['name'],
        amount: double.parse(value['amount'].toStringAsFixed(1)).abs(),
        icon: value['icon'],
        color: Color(
          int.parse(value['color'].substring(1), radix: 16) + 0xFF000000,
        ),
      );
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        height: widget.size.height * 0.45,
        width: widget.size.width,
        decoration: BoxDecoration(
          color: TColor.gray60,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Center(
                child: Text(
                  "Category Chart",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: TColor.primaryText,
                  ),
                ),
              ),
            ),
            Expanded(
              child: SfCircularChart(
                tooltipBehavior: _tooltipBehavior,
                series: <CircularSeries>[
                  PieSeries<_ChartData, String>(
                    dataSource: chartData,
                    xValueMapper: (_ChartData data, _) => data.name,
                    yValueMapper: (_ChartData data, _) => data.amount,
                    pointColorMapper: (_ChartData data, _) => data.color,
                    dataLabelMapper: (_ChartData data, int index) {
                      final percentage = (data.amount / totalAmount) * 100;
                      return '${data.icon}\n${percentage.toStringAsFixed(1)}%';
                    },
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      showZeroValue: false,
                      textStyle: TextStyle(fontSize: 14),
                    ),
                    enableTooltip: true,
                    radius: '88%',
                  ),
                ],
                onTooltipRender: (TooltipArgs args) {
                  final index = args.pointIndex!.toInt();
                  final data = chartData[index];
                  final percentage = (data.amount / totalAmount) * 100;

                  args.text = '${data.icon} ${data.name}: ${data.amount}\n'
                      'Tỉ lệ phần trăm: ${percentage.toStringAsFixed(1)}%\n'
                      '${data.amount} / $totalAmount';
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartData {
  final String name;
  final double amount;
  final String icon;
  final Color color;

  _ChartData({
    required this.name,
    required this.amount,
    required this.icon,
    required this.color,
  });
}

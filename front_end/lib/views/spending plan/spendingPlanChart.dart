import 'package:flutter/material.dart';
import 'package:front_end/common_widget/error_widget.dart';
import 'package:front_end/common_widget/loading_widget.dart';
import 'package:front_end/common_widget/no_data_widget.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:front_end/common/color_extension.dart';
import 'package:front_end/viewModel/GenerateViewmodel.dart';

class SpendingplanChart extends StatefulWidget {
  final Size size;
  final String userId;
  final String spendingPlan;
  final ValueChanged<String> onTypeSelected;

  const SpendingplanChart({
    super.key,
    required this.size,
    required this.userId,
    required this.spendingPlan,
    required this.onTypeSelected,
  });

  @override
  State<SpendingplanChart> createState() => _SpendingplanChartState();
}

class _SpendingplanChartState extends State<SpendingplanChart> {
  Map<String, dynamic>? _data;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void didUpdateWidget(covariant SpendingplanChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.spendingPlan != widget.spendingPlan) {
      _fetchData();
    }
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await GenerateViewmodel()
          .getSpendingPlantDetail(widget.userId, widget.spendingPlan);
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

  List<ChartData> _generateChartData(String type) {
    final chartData = <ChartData>[];

    _data!.forEach((year, months) {
      months.forEach((month, values) {
        chartData.add(
          ChartData(
            month: "$month/$year",
            income:
                type == "Income" ? (values['Income'] as double).toDouble() : 0,
            outcome: type == "Outcome"
                ? (values['Outcome'] as double).abs().toDouble()
                : 0,
          ),
        );
      });
    });

    chartData.sort((a, b) => a.month.compareTo(b.month));
    return chartData.reversed.take(12).toList();
  }

  List<ChartData> _generateCombinedData() {
    final combinedData = <ChartData>[];

    _data!.forEach((year, months) {
      months.forEach((month, values) {
        combinedData.add(
          ChartData(
            month: "$month/$year",
            income: (values['Income'] as double),
            outcome: (values['Outcome'] as double).abs(), // Convert to positive
          ),
        );
      });
    });

    // Sort and filter for 6 months
    combinedData.sort((a, b) => a.month.compareTo(b.month));
    return combinedData.reversed.take(6).toList();
  }

  double _calculateAverage(List<ChartData> data, String type) {
    final values = data.map((e) {
      switch (type) {
        case 'Income':
          return e.income;
        case 'Outcome':
          return e.outcome;
        default:
          return 0.0;
      }
    }).toList();

    return values.reduce((a, b) => a + b) / values.length;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return LoadingWidget(
        height: widget.size.height * 0.3,
        width: widget.size.width,
      );
    }

    if (_error != null) {
      return ErrorWidgetCustom(
          height: widget.size.height * 0.3,
          width: widget.size.width,
          errorMessage: _error);
    }

    if (_data == null || _data!.isEmpty) {
      return NoDataWidget(
        height: widget.size.height * 0.3,
        width: widget.size.width,
      );
    }

    final incomeData = _generateChartData("Income");
    final outcomeData = _generateChartData("Outcome");
    final combinedData = _generateCombinedData();

    final averageIncome = _calculateAverage(incomeData, 'Income');
    final averageOutcome = _calculateAverage(outcomeData, 'Outcome');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        height: widget.size.height * 0.3,
        width: widget.size.width,
        decoration: BoxDecoration(
          color: TColor.gray60,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: PageView(
            onPageChanged: (index) {
              // Map the index to a type name
              switch (index) {
                case 0:
                  widget.onTypeSelected("Combined");
                  break;
                case 1:
                  widget.onTypeSelected("Income");
                  break;
                case 2:
                  widget.onTypeSelected("Outcome");
                  break;
              }
            },
            children: [
              _buildCombinedChart(combinedData),
              _buildChart(incomeData, averageIncome, 'Income', TColor.green),
              _buildChart(outcomeData, averageOutcome, 'Outcome', TColor.red),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChart(
      List<ChartData> data, double average, String title, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$title Chart",
          style: TextStyle(
            color: TColor.primaryText,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(
              majorGridLines: const MajorGridLines(width: 0),
              labelStyle: TextStyle(
                color: TColor.primaryText,
                fontSize: 12,
              ),
              isInversed: true,
            ),
            primaryYAxis: NumericAxis(
              axisLine: const AxisLine(width: 0),
              majorTickLines: const MajorTickLines(size: 0),
              labelStyle: TextStyle(
                color: TColor.primaryText,
                fontSize: 12,
              ),
            ),
            tooltipBehavior: TooltipBehavior(
              enable: true,
              format: 'point.x : point.y',
              header: '',
            ),
            series: <ChartSeries>[
              ColumnSeries<ChartData, String>(
                dataSource: data,
                xValueMapper: (ChartData chart, _) => chart.month,
                yValueMapper: (ChartData chart, _) {
                  if (title == 'Income') return chart.income;
                  if (title == 'Outcome') return chart.outcome;
                  return null;
                },
                name: title,
                color: color,
                borderRadius: const BorderRadius.all(Radius.circular(5)),
              ),
              LineSeries<ChartData, String>(
                dataSource: data,
                xValueMapper: (ChartData chart, _) => chart.month,
                yValueMapper: (ChartData chart, _) => average,
                name: 'Average',
                dashArray: <double>[3, 3],
                color: TColor.white,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCombinedChart(List<ChartData> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Combined Chart",
          style: TextStyle(
            color: TColor.primaryText,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(
              majorGridLines: const MajorGridLines(width: 0),
              labelStyle: TextStyle(
                color: TColor.primaryText,
                fontSize: 12,
              ),
              isInversed: true,
            ),
            primaryYAxis: NumericAxis(
              axisLine: const AxisLine(width: 0),
              majorTickLines: const MajorTickLines(size: 0),
              labelStyle: TextStyle(
                color: TColor.primaryText,
                fontSize: 12,
              ),
            ),
            series: <ChartSeries>[
              ColumnSeries<ChartData, String>(
                dataSource: data,
                xValueMapper: (ChartData chart, _) => chart.month,
                yValueMapper: (ChartData chart, _) => chart.income,
                name: 'Income',
                color: TColor.green,
                borderRadius: const BorderRadius.all(Radius.circular(5)),
              ),
              ColumnSeries<ChartData, String>(
                dataSource: data,
                xValueMapper: (ChartData chart, _) => chart.month,
                yValueMapper: (ChartData chart, _) => chart.outcome,
                name: 'Outcome',
                color: TColor.red,
                borderRadius: const BorderRadius.all(Radius.circular(5)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ChartData {
  final String month;
  final double income;
  final double outcome;

  ChartData({
    required this.month,
    required this.income,
    required this.outcome,
  });
}

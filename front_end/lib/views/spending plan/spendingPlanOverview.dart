import 'package:flutter/material.dart';
import 'package:front_end/common/color_extension.dart';
import 'package:front_end/common_widget/error_widget.dart';
import 'package:front_end/common_widget/loading_widget.dart';
import 'package:front_end/common_widget/no_data_widget.dart';
import 'package:front_end/viewModel/GenerateViewmodel.dart';
import 'package:front_end/views/spending%20plan/modalContent.dart';
import 'package:front_end/views/spending%20plan/spendingPlanCard.dart';

class SpendingplanOverview extends StatefulWidget {
  final Size size;
  final String userId;
  final ValueChanged<String> onPlanSelected;

  const SpendingplanOverview({
    super.key,
    required this.size,
    required this.userId,
    required this.onPlanSelected,
  });

  @override
  State<SpendingplanOverview> createState() => _SpendingplanOverviewState();
}

class _SpendingplanOverviewState extends State<SpendingplanOverview> {
  Map<String, dynamic>? _data;
  List<ChartData>? _chartData;

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

        if (_data!.isNotEmpty) {
          widget.onPlanSelected(_data!.keys.first);
          _chartData = _getChartData(data);
        }
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<ChartData> _getChartData(Map<String, dynamic> data) {
    List<ChartData> chartData = [];
    for (var key in data.keys) {
      String planName = key;
      double ratio = data[key]['ratio'];
      chartData.add(ChartData(
          planName,
          ratio,
          chartData.isEmpty
              ? TColor.red
              : (chartData.length > 1 ? TColor.blue : Colors.green)));
    }

    return chartData;
  }

  @override
  Widget build(BuildContext context) {
   if (_isLoading) {
      return LoadingWidget(
        height: widget.size.height * 0.2,
        width: widget.size.width,
      );
    }

    if (_error != null) {
      return ErrorWidgetCustom(
          height: widget.size.height * 0.2,
          width: widget.size.width,
          errorMessage: _error);
    }

    if (_data == null || _data!.isEmpty) {
      return NoDataWidget(
        height: widget.size.height * 0.2,
        width: widget.size.width,
      );
    }
    return SizedBox(
      height: widget.size.height * 0.2,
      child: PageView.builder(
        itemCount: _data!.keys.length,
        onPageChanged: (index) {
          widget.onPlanSelected(_data!.keys.elementAt(index));
        },
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
              chartData: _chartData);
        },
      ),
    );
  }
}

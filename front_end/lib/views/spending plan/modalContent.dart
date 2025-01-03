import 'package:flutter/material.dart';
import 'package:front_end/common/color_extension.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ModalContent extends StatefulWidget {
  final String planNameSelected;
  final List<ChartData> chartData;

  const ModalContent({
    super.key,
    required this.planNameSelected,
    required this.chartData,
  });

  @override
  State<ModalContent> createState() => _ModalContentState();
}

class _ModalContentState extends State<ModalContent> {
  String? _selectedPlanName;
  String _selectedRatio = '';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    // Initialize selected plan and ratio based on provided planNameSelected
    final selectedData = widget.chartData.firstWhere(
      (data) => data.x == widget.planNameSelected,
      orElse: () => ChartData('', 0.0, Colors.transparent),
    );

    setState(() {
      _selectedPlanName =
          selectedData.x.isNotEmpty ? widget.planNameSelected : null;
      _selectedRatio = selectedData.x.isNotEmpty
          ? '${selectedData.y.toStringAsFixed(2)}%'
          : '';
    });
  }

  void _onChartSelectionChanged(SelectionArgs args) {
    final selectedData = widget.chartData[args.pointIndex];

    setState(() {
      if (_selectedPlanName == selectedData.x) {
        // Deselect if the same segment is clicked
        _selectedPlanName = null;
        _selectedRatio = '';
      } else {
        // Update selection to the newly clicked segment
        _selectedPlanName = selectedData.x;
        _selectedRatio = '${selectedData.y.toStringAsFixed(2)}%';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
        heightFactor: 0.5,
        child: Container(
          decoration: BoxDecoration(
            color: TColor.gray80,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 20),
                height: 5,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              _buildChart(),
              const SizedBox(height: 20),
              _buildSelectedRatio(),
              const SizedBox(height: 20),
              _buildSelectedPlanName(),
            ],
          ),
        ));
  }

  Widget _buildChart() {
    return SfCircularChart(
      title: ChartTitle(
        text: 'SPENDING PLAN ALLOCATION',
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      legend: Legend(isVisible: false),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <CircularSeries>[
        DoughnutSeries<ChartData, String>(
          dataSource: widget.chartData,
          xValueMapper: (ChartData data, _) => data.x,
          yValueMapper: (ChartData data, _) => data.y,
          pointColorMapper: (ChartData data, _) => _selectedPlanName == data.x
              ? data.color
              : data.color.withAlpha(128),
          explode: true,
          explodeIndex: widget.chartData
              .indexWhere((data) => data.x == _selectedPlanName),
          innerRadius: '60%',
          dataLabelSettings: const DataLabelSettings(isVisible: false),
          selectionBehavior: SelectionBehavior(enable: true),
        )
      ],
      onSelectionChanged: _onChartSelectionChanged,
    );
  }

  Widget _buildSelectedRatio() {
    return Text(
      _selectedRatio.isNotEmpty ? 'Ratio: $_selectedRatio' : '',
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildSelectedPlanName() {
    return Text(
      'Plan Name: ${_selectedPlanName ?? "None"}',
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}

class ChartData {
  final String x;
  final double y;
  final Color color;

  ChartData(this.x, this.y, this.color);
}

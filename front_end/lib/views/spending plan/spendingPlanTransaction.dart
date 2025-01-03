import 'package:flutter/material.dart';
import 'package:front_end/common/color_extension.dart';
import 'package:front_end/common_widget/error_widget.dart';
import 'package:front_end/common_widget/loading_widget.dart';
import 'package:front_end/common_widget/no_data_widget.dart';
import 'package:front_end/models/category.dart';
import 'package:front_end/viewModel/CategoryViewModel.dart';
import 'package:front_end/viewModel/SpendingPlanViewModel.dart';

class SpendingplanTransaction extends StatefulWidget {
  final Size size;
  final String userId;
  final String spendingPlan;
  final String typeOfTrans;
  const SpendingplanTransaction({
    super.key,
    required this.size,
    required this.userId,
    required this.spendingPlan,
    required this.typeOfTrans,
  });

  @override
  State<SpendingplanTransaction> createState() =>
      _SpendingplanTransactionState();
}

class _SpendingplanTransactionState extends State<SpendingplanTransaction> {
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
      final data = await SpendingPlanViewModel().getSpendingPlantDetail(
          widget.userId, widget.spendingPlan, widget.typeOfTrans);
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
  void didUpdateWidget(covariant SpendingplanTransaction oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.spendingPlan != widget.spendingPlan ||
        oldWidget.typeOfTrans != widget.typeOfTrans) {
      _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return LoadingWidget(
        height: widget.size.height * 0.35,
        width: widget.size.width,
      );
    }

    if (_error != null) {
      return ErrorWidgetCustom(
          height: widget.size.height * 0.35,
          width: widget.size.width,
          errorMessage: _error);
    }

    if (_data == null || _data!.isEmpty) {
      return NoDataWidget(
        height: widget.size.height * 0.35,
        width: widget.size.width,
      );
    }
    return _buildTransactionContainer();
  }

  Widget _buildTransactionContainer() {
    return _buildContainer(
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildTransactionList(),
          ),
        ),
      ),
    );
  }

  Widget _buildContainer(Widget child) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: widget.size.height * 0.35,
        width: widget.size.width,
        decoration: BoxDecoration(
          color: TColor.gray60,
          borderRadius: BorderRadius.circular(10),
        ),
        child: child,
      ),
    );
  }

  List<Widget> _buildTransactionList() {
    List<Widget> widgets = [];
    _data!.forEach((year, months) {
      widgets.add(_buildHeader("Year: $year"));

      (months as Map<String, dynamic>).forEach((month, transactions) {
        widgets.add(_buildSubHeader("Month: $month"));

        Map<String, List<Map<String, dynamic>>> groupedTransactions = {};
        for (var transaction in transactions) {
          String date = transaction['date'].substring(0, 10);
          if (!groupedTransactions.containsKey(date)) {
            groupedTransactions[date] = [];
          }
          groupedTransactions[date]!.add(transaction);
        }

        groupedTransactions.forEach((date, dailyTransactions) {
          widgets.add(_buildDateHeader(date));
          for (var transaction in dailyTransactions) {
            widgets.add(_buildTransactionItem(transaction));
          }
        });
      });
    });

    return widgets;
  }

  Widget _buildHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, top: 10),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: TColor.secondaryText,
              thickness: 2,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: TColor.primaryText,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: TColor.secondaryText,
              thickness: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, top: 10),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: TColor.secondaryText,
              thickness: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: TColor.secondaryText,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: TColor.secondaryText,
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateHeader(String date) {
    DateTime dateTime = DateTime.parse(date);
    final formattedDate =
        '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              formattedDate,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: TColor.primaryText,
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: TColor.primaryText,
              thickness: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 3,
            child: Row(
              children: [
                Text(
                  transaction['name'],
                  style: TextStyle(
                      color: TColor.secondaryText, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8.0),
                _buildCategoryItem(widget.userId, transaction['category']),
              ],
            ),
          ),
          Flexible(
            flex: 1,
            child: Text(
              "${transaction['amount']} \$",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: transaction['amount'] > 0 ? TColor.green : TColor.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String userId, String categoryId) {
    return FutureBuilder<Category?>(
      future: CategoryViewModel().getCategoryDetails(userId, categoryId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        }

        if (snapshot.hasError) {
          return const Text("Error");
        }

        final category = snapshot.data;
        if (category == null) {
          return const Text("N/A");
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: Color(int.parse(category.color.substring(1, 7), radix: 16) +
                    0xFF000000)
                .withAlpha(100),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text(category.icon),
              const SizedBox(width: 4.0),
              Text(category.name, style: TextStyle(color: TColor.primaryText)),
            ],
          ),
        );
      },
    );
  }
}

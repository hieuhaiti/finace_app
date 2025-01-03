import 'package:flutter/material.dart';
import 'package:front_end/common/color_extension.dart';
import 'package:front_end/common_widget/error_widget.dart';
import 'package:front_end/common_widget/loading_widget.dart';
import 'package:front_end/common_widget/no_data_widget.dart';
import 'package:front_end/viewModel/GenerateViewmodel.dart';

class CategoryWidget extends StatefulWidget {
  final Size size;
  final String userId;

  const CategoryWidget({
    super.key,
    required this.size,
    required this.userId,
  });

  @override
  State<CategoryWidget> createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends State<CategoryWidget> {
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
          await GenerateViewmodel().getCategoryCurrent(widget.userId, "5");
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Category Board",
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
          Container(
            height: widget.size.height * 0.2,
            width: widget.size.width,
            decoration: BoxDecoration(
              color: TColor.gray60,
              borderRadius: BorderRadius.circular(10),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    _data!.entries.take(_data!.entries.length - 1).map((entry) {
                  final category = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 7),
                    child: CategoryCard(
                      name: category['name'],
                      amount: category['amount'],
                      average: category['average'],
                      icon: category['icon'],
                      color: Color(
                          int.parse(category['color'].substring(1), radix: 16) +
                              0xFF000000),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final String name;
  final double amount;
  final double average;
  final String icon;
  final Color color;

  const CategoryCard({
    Key? key,
    required this.name,
    required this.amount,
    required this.average,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
      elevation: 5,
      child: Container(
        width: 120,
        height: 120,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: color.withAlpha((0.3 * 255).toInt()),
            borderRadius: BorderRadius.circular(19)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Text(
              icon,
              style: const TextStyle(fontSize: 30),
            ),
            const SizedBox(height: 8),
            // Name
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            // Amount
            Text(
              "\$${amount.toStringAsFixed(2)}", // Hiển thị số tiền
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: amount > average
                    ? Colors.red
                    : Colors.green, // Đổi màu dựa vào điều kiện
              ),
            ),
          ],
        ),
      ),
    );
  }
}

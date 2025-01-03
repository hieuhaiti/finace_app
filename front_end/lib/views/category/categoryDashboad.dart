import 'package:flutter/material.dart';
import 'package:front_end/common/color_extension.dart';
import 'package:front_end/common_widget/error_widget.dart';
import 'package:front_end/common_widget/loading_widget.dart';
import 'package:front_end/common_widget/no_data_widget.dart';
import 'package:front_end/viewModel/GenerateViewModel.dart';

class CategoryDashboad extends StatefulWidget {
  final Size size;
  final String userId;

  const CategoryDashboad({super.key, required this.size, required this.userId});

  @override
  State<CategoryDashboad> createState() => _CategoryDashboadState();
}

class _CategoryDashboadState extends State<CategoryDashboad> {
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
          await GenerateViewmodel().getCategoryCurrent(widget.userId, 'all');
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
        height: widget.size.height * 0.4,
        width: widget.size.width,
      );
    }

    if (_error != null) {
      return ErrorWidgetCustom(
        height: widget.size.height * 0.4,
        width: widget.size.width,
        errorMessage: _error,
      );
    }

    if (_data == null || _data!.isEmpty) {
      return NoDataWidget(
        height: widget.size.height * 0.4,
        width: widget.size.width,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        height: widget.size.height * 0.4,
        width: widget.size.width,
        decoration: BoxDecoration(
          color: TColor.gray60,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          'Category',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: TColor.primaryText,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 35),
                        child: Text(
                          'Amount',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: TColor.primaryText,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: -1,
                      child: Text(
                        'Average',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: TColor.primaryText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ListView.builder(
                    itemCount: _data!.length,
                    itemBuilder: (context, index) {
                      final key = _data!.keys.elementAt(index);
                      final category = _data![key];

                      final double progress =
                          (category['amount'] / category['average']).abs();
                      final bool isOverLimit =
                          category['average'] > category['amount'];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: Container(
                          height: 50,
                          width: widget.size.width,
                          decoration: BoxDecoration(
                            color: Color(int.parse(
                                    "0xFF" + category['color'].substring(1)))
                                .withAlpha(90),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        category['icon'],
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        category['name'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: TColor.primaryText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: LinearProgressIndicator(
                                          minHeight: 12,
                                          value:
                                              progress > 1.0 ? 1.0 : progress,
                                          backgroundColor: TColor.gray80,
                                          color: isOverLimit
                                              ? TColor.red
                                              : TColor.green,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            category['amount']
                                                .abs()
                                                .toStringAsFixed(2),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                              color: TColor.primaryText,
                                            ),
                                          ),
                                          Text(
                                            '${category['average'].abs().toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                              color: TColor.primaryText,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

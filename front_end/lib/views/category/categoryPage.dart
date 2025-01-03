import 'package:flutter/material.dart';
import 'package:front_end/common/color_extension.dart';
import 'package:front_end/views/category/categoryChart.dart';
import 'package:front_end/views/category/categoryDashboad.dart';

class CategoryPage extends StatefulWidget {
  final String userId;

  const CategoryPage({
    super.key,
    required this.userId,
  });

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: TColor.gray,
      body: Padding(
        padding: const EdgeInsets.only(top: 15, right: 8, left: 8),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CategoryChart(
                size: size,
                userId: widget.userId,
              ),
              const SizedBox(height: 10),
              CategoryDashboad(
                size: size,
                userId: widget.userId,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

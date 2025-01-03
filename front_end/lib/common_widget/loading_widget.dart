import 'package:flutter/material.dart';
import 'package:front_end/common/color_extension.dart';

class LoadingWidget extends StatelessWidget {
  final double height;
  final double width;

  const LoadingWidget({
    super.key,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: TColor.gray60,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

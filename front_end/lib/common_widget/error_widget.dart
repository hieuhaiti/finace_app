import 'package:flutter/material.dart';
import 'package:front_end/common/color_extension.dart';

class ErrorWidgetCustom extends StatelessWidget {
  final double height;
  final double width;
  final String? errorMessage;

  const ErrorWidgetCustom({
    super.key,
    required this.height,
    required this.width,
    required this.errorMessage,
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
        child: Center(
          child: Text(
            "Error: $errorMessage",
            style: TextStyle(color: TColor.primaryText),
          ),
        ),
      ),
    );
  }
}

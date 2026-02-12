import 'package:flutter/material.dart';

class FFButtonWidget extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final FFButtonOptions options;

  const FFButtonWidget({
    super.key,
    required this.onPressed,
    required this.text,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: options.height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: options.color,
          elevation: options.elevation,
          shape: RoundedRectangleBorder(
            borderRadius: options.borderRadius ?? BorderRadius.circular(12),
            side: options.borderSide ?? BorderSide.none,
          ),
          padding: options.padding,
        ),
        onPressed: onPressed,
        child: Text(text, style: options.textStyle),
      ),
    );
  }
}

class FFButtonOptions {
  final double height;
  final EdgeInsetsGeometry? padding;
  final Color color;
  final TextStyle? textStyle;
  final double elevation;
  final BorderSide? borderSide;
  final BorderRadius? borderRadius;

  FFButtonOptions({
    this.height = 40,
    this.padding,
    required this.color,
    this.textStyle,
    this.elevation = 0,
    this.borderSide,
    this.borderRadius,
  });
}

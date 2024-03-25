import 'package:flutter/material.dart';

class RoundedBadge extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final double padding;

  const RoundedBadge({
    required this.text,
    this.backgroundColor = const Color(0xFF424242),
    this.textColor = Colors.white,
    this.borderRadius = 8.0,
    this.padding = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      padding: EdgeInsets.all(padding),
      child: Text(
        text,
        style: TextStyle(color: textColor),
      ),
    );
  }
}
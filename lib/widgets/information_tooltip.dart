import 'package:flutter/material.dart';

class InformationTooltip extends StatelessWidget {
  final String message;
  final double iconSize;
  final EdgeInsetsGeometry padding;

  const InformationTooltip({
    super.key,
    required this.message,
    this.iconSize = 16,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Tooltip(
        message: message,
        textStyle: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade700,  // Consistent gray background
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Icon(
          Icons.info_outline,
          size: iconSize,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
}

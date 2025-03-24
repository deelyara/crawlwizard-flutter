import 'package:flutter/material.dart';

class InformationTooltip extends StatelessWidget {
  final String message;

  const InformationTooltip({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      preferBelow: true,
      showDuration: const Duration(seconds: 3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
        ),
      ),
      textStyle: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 12,
      ),
      child: Icon(
        Icons.info_outline,
        size: 16,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

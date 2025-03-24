import 'package:flutter/material.dart';

class ModernStepIndicator extends StatelessWidget {
  final int currentStep;
  final int stepCount;
  final List<String> stepTitles;
  final Function(int) onTap;

  const ModernStepIndicator({
    super.key,
    required this.currentStep,
    required this.stepCount,
    required this.stepTitles,
    required this.onTap,
  });

  // Get appropriate icon for each step
  IconData _getIconForStep(int step) {
    switch (step) {
      case 0: // Type
        return Icons.category_outlined;
      case 1: // Scope
        return Icons.language_outlined;
      case 2: // Restrictions
        return Icons.filter_list_outlined;
      case 3: // Origin Snapshots
        return Icons.history_outlined;
      case 4: // Fine-tune
        return Icons.tune_outlined;
      case 5: // Recurrence
        return Icons.calendar_month_outlined;
      case 6: // Review
        return Icons.assignment_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      height: 72,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(stepCount, (index) {
            final bool isActive = index == currentStep;
            final bool isPast = index < currentStep;
            final bool isClickable = isPast || isActive;
            
            return GestureDetector(
              onTap: isClickable ? () => onTap(index) : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    // Step Circle with Icon
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive 
                            ? theme.colorScheme.primary
                            : isPast 
                                ? theme.colorScheme.primary.withOpacity(0.15)
                                : theme.colorScheme.surfaceVariant.withOpacity(0.5),
                        border: isActive || isPast
                            ? Border.all(
                                color: isActive 
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.primary.withOpacity(0.5),
                                width: 2,
                              )
                            : Border.all(
                                color: theme.colorScheme.outlineVariant,
                                width: 1,
                              ),
                      ),
                      child: Center(
                        child: isPast
                            ? Icon(
                                Icons.check_rounded,
                                color: theme.colorScheme.primary,
                                size: 18,
                              )
                            : Icon(
                                _getIconForStep(index),
                                color: isActive
                                    ? Colors.white
                                    : theme.colorScheme.onSurfaceVariant,
                                size: 18,
                              ),
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Step Title
                    Text(
                      stepTitles[index],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                        color: isActive
                            ? theme.colorScheme.primary
                            : isPast
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    
                    // Connector line if not the last step
                    if (index < stepCount - 1)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        width: 24,
                        height: 1,
                        color: isPast && index + 1 <= currentStep
                            ? theme.colorScheme.primary.withOpacity(0.5)
                            : theme.colorScheme.outlineVariant,
                      ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

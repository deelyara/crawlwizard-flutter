import 'package:flutter/material.dart';

class ModernStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepTitles;
  final List<IconData> stepIcons;
  final Function(int) onStepTap;

  const ModernStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepTitles,
    required this.stepIcons,
    required this.onStepTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: ListView.builder(
        itemCount: totalSteps,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final bool isActive = index == currentStep;
          final bool isPast = index < currentStep;
          final bool canNavigate = isPast || index == currentStep;

          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 4.0,
              horizontal: 16.0,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: canNavigate ? () => onStepTap(index) : null,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 16.0,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isActive
                            ? primaryColor.withOpacity(0.1)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border:
                        isActive
                            ? Border.all(color: primaryColor, width: 1)
                            : null,
                  ),
                  child: Row(
                    children: [
                      // Step number with icon
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              isActive
                                  ? primaryColor
                                  : isPast
                                  ? primaryColor.withOpacity(0.7)
                                  : theme.colorScheme.surfaceVariant,
                        ),
                        child: Center(
                          child:
                              isPast
                                  ? Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 18,
                                  )
                                  : Icon(
                                    stepIcons[index],
                                    color:
                                        isActive
                                            ? Colors.white
                                            : theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                    size: 18,
                                  ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Step title
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Step number
                            Text(
                              'Step ${index + 1}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color:
                                    isActive
                                        ? primaryColor
                                        : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 2),
                            // Step title
                            Text(
                              stepTitles[index],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight:
                                    isActive
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                color:
                                    isActive
                                        ? theme.colorScheme.primary
                                        : isPast
                                        ? theme.colorScheme.onSurface
                                        : theme.colorScheme.onSurface
                                            .withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Status indicator
                      if (isActive)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primaryColor,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

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
    final backgroundColor = theme.colorScheme.background;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
      child: ListView.separated(
        itemCount: totalSteps,
        shrinkWrap: true,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final bool isActive = index == currentStep;
          final bool isPast = index < currentStep;
          final bool canNavigate = isPast || index == currentStep;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: canNavigate ? () => onStepTap(index) : null,
                borderRadius: BorderRadius.circular(12),
                hoverColor: primaryColor.withOpacity(0.05),
                splashColor: primaryColor.withOpacity(0.1),
                highlightColor: primaryColor.withOpacity(0.05),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 16.0,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isActive
                            ? primaryColor.withOpacity(0.08)
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
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              isActive
                                  ? primaryColor
                                  : isPast
                                  ? primaryColor.withOpacity(0.8)
                                  : theme.colorScheme.surfaceVariant
                                      .withOpacity(0.7),
                          boxShadow:
                              isActive || isPast
                                  ? [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                  : null,
                        ),
                        child: Center(
                          child:
                              isPast
                                  ? Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  )
                                  : Icon(
                                    stepIcons[index],
                                    color:
                                        isActive
                                            ? Colors.white
                                            : theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                    size: 20,
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
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color:
                                    isActive
                                        ? primaryColor
                                        : isPast
                                        ? theme.colorScheme.onSurface
                                            .withOpacity(0.8)
                                        : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Step title
                            Text(
                              stepTitles[index],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    isActive
                                        ? FontWeight.bold
                                        : FontWeight.w500,
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

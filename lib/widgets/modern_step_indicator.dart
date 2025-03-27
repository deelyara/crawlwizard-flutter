import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF37618E);
    final Color selectedTextColor = const Color(0xFF181C20);
    final Color lineColor = Colors.grey.shade300; // Consistent line color
    
    return Container(
      width: 200,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(stepCount, (index) {
          final bool isActive = index == currentStep;
          final bool isPast = index < currentStep;
          final bool isClickable = isPast || isActive;
          final bool isNotLast = index < stepCount - 1;
          
          return Column(
            children: [
              // Step with number and text
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Column for number and connecting line
                  SizedBox(
                    width: 32,
                    child: Column(
                      children: [
                        // Circle with number
                        GestureDetector(
                          onTap: isClickable ? () => onTap(index) : null,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isActive || isPast ? primaryColor : Colors.grey.shade200,
                              border: Border.all(
                                color: isActive || isPast ? primaryColor : Colors.grey.shade400,
                                width: 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: GoogleFonts.roboto(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: isActive || isPast ? Colors.white : Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        // Gap between circle and line
                        if (isNotLast) const SizedBox(height: 4),
                        
                        // Connector line (same color for all steps)
                        if (isNotLast)
                          Container(
                            width: 1,
                            height: 30, // Shorter line
                            color: lineColor,
                          ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Step Title
                  Expanded(
                    child: GestureDetector(
                      onTap: isClickable ? () => onTap(index) : null,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          stepTitles[index],
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: isActive 
                                ? selectedTextColor
                                : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              // Equal spacing after each step
              if (isNotLast)
                const SizedBox(height: 12),
            ],
          );
        }),
      ),
    );
  }
}

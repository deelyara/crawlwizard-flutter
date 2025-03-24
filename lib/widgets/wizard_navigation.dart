// File: lib/widgets/wizard_navigation.dart
import 'package:flutter/material.dart';

class WizardNavigation extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final bool isLastStep;
  final VoidCallback onComplete;

  const WizardNavigation({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.onNext,
    required this.onBack,
    required this.isLastStep,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Progress info
          Text(
            'Step ${currentStep + 1} of $totalSteps',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),

          // Buttons
          Row(
            children: [
              // Back button
              if (currentStep > 0)
                OutlinedButton.icon(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              if (currentStep > 0) const SizedBox(width: 12),

              // Next/Complete button
              ElevatedButton.icon(
                onPressed: isLastStep ? onComplete : onNext,
                icon: Icon(isLastStep ? Icons.play_arrow : Icons.arrow_forward),
                label: Text(isLastStep ? 'Start Crawl' : 'Next'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

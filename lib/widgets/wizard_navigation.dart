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
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          if (currentStep > 0)
            OutlinedButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back'),
            )
          else
            const SizedBox(width: 100), // Placeholder for alignment
          // Next/Start button
          ElevatedButton.icon(
            onPressed: isLastStep ? onComplete : onNext,
            icon: Icon(isLastStep ? Icons.play_arrow : Icons.arrow_forward),
            label: Text(isLastStep ? 'Start Crawl' : 'Next'),
          ),
        ],
      ),
    );
  }
}

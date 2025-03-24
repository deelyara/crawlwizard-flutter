// File: lib/widgets/wizard_navigation.dart
import 'package:flutter/material.dart';

class WizardNavigation extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final bool isLastStep;
  final VoidCallback onComplete;
  final bool isFromReviewStep;
  final VoidCallback? onBackToReview;

  const WizardNavigation({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.onNext,
    required this.onBack,
    required this.isLastStep,
    required this.onComplete,
    this.isFromReviewStep = false,
    this.onBackToReview,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side: Back button or empty space
          if (currentStep > 0)
            OutlinedButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back, size: 16),
              label: const Text('Back'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            )
          else
            // Empty container to maintain layout
            const SizedBox(width: 80),
            
          // Center: Back to Review button (if from review step)
          if (isFromReviewStep && onBackToReview != null)
            OutlinedButton.icon(
              onPressed: onBackToReview,
              icon: const Icon(Icons.visibility, size: 16),
              label: const Text('Back to Review'),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            
          // Right side: Next/Complete button
          ElevatedButton.icon(
            onPressed: isLastStep ? onComplete : onNext,
            icon: Icon(
              isLastStep ? Icons.play_arrow : Icons.arrow_forward,
              size: 16,
            ),
            label: Text(isLastStep ? 'Start Crawl' : 'Continue'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

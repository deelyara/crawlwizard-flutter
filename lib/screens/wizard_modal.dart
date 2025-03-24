import 'package:flutter/material.dart';
import '../models/crawl_config.dart';
import '../widgets/modern_step_indicator.dart';
import '../widgets/wizard_navigation.dart';
import 'type_screen.dart';
import 'scope_screen.dart';
import 'restrictions_screen.dart';
import 'snapshot_screen.dart';
import 'finetune_screen.dart';
import 'recurrence_screen.dart';
import 'review_screen.dart';

class WizardModal extends StatefulWidget {
  final VoidCallback? onClose;
  final VoidCallback? onComplete;

  const WizardModal({
    super.key,
    this.onClose,
    this.onComplete,
  });

  @override
  State<WizardModal> createState() => _WizardModalState();
}

class _WizardModalState extends State<WizardModal> {
  int _currentStep = 0;
  final CrawlConfig _config = CrawlConfig();
  bool _fromReviewStep = false;
  
  // Step titles
  final List<String> _stepTitles = [
    'Type',
    'Scope',
    'Restrictions',
    'Origin Snapshots',
    'Fine-tune',
    'Recurrence',
    'Review',
  ];

  void _navigateToStep(int step) {
    setState(() {
      if (_currentStep == 6) {
        // If coming from review step
        _fromReviewStep = true;
      }
      _currentStep = step;
    });
  }

  void _navigateToReview() {
    setState(() {
      _currentStep = 6;
      _fromReviewStep = false;
    });
  }

  void _nextStep() {
    if (_currentStep < _stepTitles.length - 1) {
      setState(() {
        _currentStep++;
        _fromReviewStep = false;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _fromReviewStep = false;
      });
    }
  }

  void _handleComplete() {
    if (widget.onComplete != null) {
      widget.onComplete!();
    } else {
      // Default implementation if no onComplete provided
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Crawl Started'),
            content: const Text(
              'Your crawl has been started. We\'ll notify you when it\'s completed.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Close wizard too
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 900,
          maxHeight: 700,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Modal header with title and close button
            Container(
              padding: const EdgeInsets.only(left: 24, right: 16, top: 16, bottom: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Modal title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.settings_outlined,
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Crawl Wizard: ${_stepTitles[_currentStep]}',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Close button
                  IconButton(
                    onPressed: widget.onClose ?? () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            
            // Step indicator
            ModernStepIndicator(
              currentStep: _currentStep,
              stepCount: _stepTitles.length,
              stepTitles: _stepTitles,
              onTap: (index) {
                // Only allow navigating to completed steps
                if (index <= _currentStep) {
                  _navigateToStep(index);
                }
              },
            ),
            
            // Main content area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _buildStepContent(),
              ),
            ),
            
            // Navigation footer
            WizardNavigation(
              currentStep: _currentStep,
              totalSteps: _stepTitles.length,
              onNext: _nextStep,
              onBack: _previousStep,
              isLastStep: _currentStep == _stepTitles.length - 1,
              onComplete: _handleComplete,
              isFromReviewStep: _fromReviewStep,
              onBackToReview: _fromReviewStep ? _navigateToReview : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return TypeScreen(
          config: _config,
          onConfigUpdate: () => setState(() {}),
        );
      case 1:
        return ScopeScreen(
          config: _config,
          onConfigUpdate: () => setState(() {}),
        );
      case 2:
        return RestrictionsScreen(
          config: _config,
          onConfigUpdate: () => setState(() {}),
        );
      case 3:
        return SnapshotScreen(
          config: _config,
          onConfigUpdate: () => setState(() {}),
        );
      case 4:
        return FinetuneScreen(
          config: _config,
          onConfigUpdate: () => setState(() {}),
        );
      case 5:
        return RecurrenceScreen(
          config: _config,
          onConfigUpdate: () => setState(() {}),
        );
      case 6:
        return ReviewScreen(
          config: _config,
          onConfigUpdate: () => setState(() {}),
          onEditStep: _navigateToStep,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  
  // Step titles - keeping the original titles
  final List<String> _stepTitles = [
    'Select type',
    'Set scope',
    'Set restrictions',
    'Snapshots',
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

  void _skipToReview() {
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

  void _switchToSimplifiedMode() {
    // Implement simplified mode logic here
    // For now, just show a dialog explaining the feature
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Simplified Mode'),
          content: const Text(
            'Simplified mode would provide a more streamlined experience with fewer options.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
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

  // Add a method to check if the current step is valid
  bool _isCurrentStepValid() {
    switch (_currentStep) {
      case 0: // Type screen
        return _config.crawlType != null;
      case 1: // Scope screen
        return _config.crawlScope != null;
      default:
        return true; // Other steps are optional
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF37618E);
    
    return Dialog(
      elevation: 0,
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 900,
          maxHeight: 700,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Modal header with title and close button
              Padding(
              padding: const EdgeInsets.only(left: 24, right: 16, top: 16, bottom: 16),
              child: Row(
                children: [
                  // Modal title
                  Expanded(
                      child: Text(
                        'Crawl wizard - ${_stepTitles[_currentStep]}',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
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
            
              // Divider
              const Divider(height: 1, thickness: 1),
              
              // Main content with step indicator on left side
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left sidebar with step indicator
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
                    
                    // Vertical divider
                    Container(
                      width: 1,
                      margin: const EdgeInsets.only(top: 1, bottom: 1),
                      color: Colors.grey.shade200,
            ),
            
            // Main content area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _buildStepContent(),
              ),
            ),
                  ],
                ),
              ),
              
              // Divider before navigation
              const Divider(height: 1, thickness: 1),
              
              // New full-width navigation bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left side with "Switch to simplified mode" button (only on first step)
                    Row(
                      children: [
                        if (_currentStep == 0)  // Only show on first step
                          TextButton(
                            onPressed: _switchToSimplifiedMode,
                            style: TextButton.styleFrom(
                              foregroundColor: primaryColor,
                            ),
                            child: Tooltip(
                              message: 'Switch to a more streamlined experience with fewer options',
                              child: Text(
                                'Switch to simplified mode',
                                style: GoogleFonts.roboto(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    // Right side with navigation buttons
                    Row(
                      children: [
                        // Back button (only if not on first step)
                        if (_currentStep > 0)
                          TextButton(
                            onPressed: _previousStep,
                            style: TextButton.styleFrom(
                              foregroundColor: primaryColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            child: Text(
                              'Back',
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        
                        // Skip to review button (from step 3 onwards, unless already in review)
                        if (_currentStep >= 2 && _currentStep < 6 && !_fromReviewStep)
                          TextButton(
                            onPressed: _skipToReview,
                            style: TextButton.styleFrom(
                              foregroundColor: primaryColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            child: Text(
                              'Skip to review',
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        
                        // Back to Review button (if editing from review)
                        if (_fromReviewStep)
                          TextButton(
                            onPressed: _navigateToReview,
                            style: TextButton.styleFrom(
                              foregroundColor: primaryColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            child: Text(
                              'Back to review',
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          
                        // Small spacing between buttons
                        const SizedBox(width: 8),
                        
                        // Next button
                        ElevatedButton(
                          onPressed: _currentStep == _stepTitles.length - 1 
                              ? _handleComplete 
                              : _isCurrentStepValid() 
                                  ? _nextStep 
                                  : null, // Disable if current step is invalid
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade300, // Add disabled color
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: Text(
                            _currentStep == _stepTitles.length - 1 ? 'Start crawl!' : 'Next',
                            style: GoogleFonts.roboto(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
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

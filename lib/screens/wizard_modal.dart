import 'package:flutter/material.dart';
import '../models/crawl_config.dart';
import 'type_screen.dart';
import 'scope_screen.dart';
import 'restrictions_screen.dart';
import 'snapshot_screen.dart';
import 'finetune_screen.dart';
import 'recurrence_screen.dart';
import 'review_screen.dart';
import '../widgets/modern_step_indicator.dart';
import '../widgets/wizard_navigation.dart';

class WizardModal extends StatefulWidget {
  const WizardModal({super.key});

  @override
  State<WizardModal> createState() => _WizardModalState();
}

class _WizardModalState extends State<WizardModal> {
  final CrawlConfig crawlConfig = CrawlConfig();
  int currentStep = 0;
  final int totalSteps = 7;

  final List<String> stepTitles = [
    'Select Type',
    'Set Scope',
    'Set Restrictions',
    'Origin Snapshot',
    'Fine-tune',
    'Recurrence',
    'Review',
  ];

  final List<IconData> stepIcons = [
    Icons.category_outlined,
    Icons.language_outlined,
    Icons.filter_alt_outlined,
    Icons.history_outlined,
    Icons.tune_outlined,
    Icons.repeat_outlined,
    Icons.checklist_outlined,
  ];

  void goToNextStep() {
    if (currentStep < totalSteps - 1) {
      setState(() {
        currentStep++;
      });
    }
  }

  void goToPreviousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step < totalSteps) {
      setState(() {
        currentStep = step;
      });
    }
  }

  Widget getStepContent() {
    switch (currentStep) {
      case 0:
        return TypeScreen(
          config: crawlConfig,
          onConfigUpdate: () => setState(() {}),
        );
      case 1:
        return ScopeScreen(
          config: crawlConfig,
          onConfigUpdate: () => setState(() {}),
        );
      case 2:
        return RestrictionsScreen(
          config: crawlConfig,
          onConfigUpdate: () => setState(() {}),
        );
      case 3:
        return SnapshotScreen(
          config: crawlConfig,
          onConfigUpdate: () => setState(() {}),
        );
      case 4:
        return FinetuneScreen(
          config: crawlConfig,
          onConfigUpdate: () => setState(() {}),
        );
      case 5:
        return RecurrenceScreen(
          config: crawlConfig,
          onConfigUpdate: () => setState(() {}),
        );
      case 6:
        return ReviewScreen(
          config: crawlConfig,
          onConfigUpdate: () => setState(() {}),
          onEditStep: goToStep,
        );
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.9,
        constraints: const BoxConstraints(maxWidth: 1200),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                stepTitles[currentStep],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              centerTitle: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
              elevation: 0,
            ),
            body: Row(
              children: [
                // Left sidebar with step indicator
                Container(
                  width: 240,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(1, 0),
                      ),
                    ],
                  ),
                  child: ModernStepIndicator(
                    currentStep: currentStep,
                    totalSteps: totalSteps,
                    stepTitles: stepTitles,
                    stepIcons: stepIcons,
                    onStepTap: goToStep,
                  ),
                ),
                // Main content area
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: getStepContent(),
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      WizardNavigation(
                        currentStep: currentStep,
                        totalSteps: totalSteps,
                        onNext: goToNextStep,
                        onBack: goToPreviousStep,
                        isLastStep: currentStep == totalSteps - 1,
                        onComplete: () {
                          // Handle crawl start
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Crawl Initiated'),
                                content: const Text(
                                  'Your crawl has been initiated. We will notify you when it is complete.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      Navigator.of(
                                        context,
                                      ).pop(); // Close the wizard too
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

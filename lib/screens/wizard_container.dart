import 'package:flutter/material.dart';
import '../models/crawl_config.dart';
import 'placeholders.dart';
import 'snapshot_screen.dart';
import 'finetune_screen.dart';
import 'recurrence_screen.dart';
import 'review_screen.dart';
import '../widgets/wizard_navigation.dart';
import '../widgets/step_indicator.dart';

class WizardContainer extends StatefulWidget {
  const WizardContainer({super.key});

  @override
  State<WizardContainer> createState() => _WizardContainerState();
}

class _WizardContainerState extends State<WizardContainer> {
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Crawl Wizard - ${stepTitles[currentStep]}',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          StepIndicator(
            currentStep: currentStep,
            totalSteps: totalSteps,
            stepTitles: stepTitles,
            onStepTap: goToStep,
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
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
    );
  }
}

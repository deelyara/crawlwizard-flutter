import 'package:flutter/material.dart';
import '../models/crawl_config.dart';
import 'placeholders.dart';
import 'snapshot_screen.dart';
import 'finetune_screen.dart';
import 'recurrence_screen.dart';
import 'review_screen.dart';
import '../widgets/wizard_navigation.dart';
import '../widgets/step_indicator.dart';
import 'package:google_fonts/google_fonts.dart';

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

  // Add method to check if the current step is valid
  bool isCurrentStepValid() {
    switch (currentStep) {
      case 0: // Type screen
        if (crawlConfig.crawlType == null) return false;
        
        // For TLS crawl type, ensure at least one language is selected
        if (crawlConfig.crawlType == CrawlType.tlsContentExtraction) {
          return crawlConfig.targetLanguages.isNotEmpty || crawlConfig.crawlWithoutTargetLanguage;
        }
        return true;
        
      case 1: // Scope screen
        if (crawlConfig.crawlScope == null) return false;
        
        // For specific pages or sitemap, require URLs to be provided
        if (crawlConfig.crawlScope == CrawlScope.specificPages || 
            crawlConfig.crawlScope == CrawlScope.sitemapPages) {
          return crawlConfig.specificUrls.isNotEmpty;
        }
        return true;
      default:
        return true; // Other steps are optional
    }
  }

  List<Step> getSteps() {
    // Don't show recurrence step for work packages or TLS crawl
    final bool canShowRecurrence = crawlConfig.crawlType != CrawlType.tlsContentExtraction && 
                                 !crawlConfig.generateWorkPackages;

    final steps = [
      Step(
        title: Text(
          'Type',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        content: TypeScreen(
          config: crawlConfig,
          onConfigUpdate: () => setState(() {}),
        ),
        isActive: currentStep >= 0,
        state: currentStep > 0 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: Text(
          'Scope',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        content: ScopeScreen(
          config: crawlConfig,
          onConfigUpdate: () => setState(() {}),
        ),
        isActive: currentStep >= 1,
        state: currentStep > 1 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: Text(
          'Restrictions',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        content: RestrictionsScreen(
          config: crawlConfig,
          onConfigUpdate: () => setState(() {}),
        ),
        isActive: currentStep >= 2,
        state: currentStep > 2 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: Text(
          'Snapshot',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        content: SnapshotScreen(
          config: crawlConfig,
          onConfigUpdate: () => setState(() {}),
        ),
        isActive: currentStep >= 3,
        state: currentStep > 3 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: Text(
          'Fine-tune',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        content: FinetuneScreen(
          config: crawlConfig,
          onConfigUpdate: () => setState(() {}),
        ),
        isActive: currentStep >= 4,
        state: currentStep > 4 ? StepState.complete : StepState.indexed,
      ),
    ];

    // Only add recurrence step if allowed
    if (canShowRecurrence) {
      steps.add(
        Step(
          title: Text(
            'Recurrence',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          content: RecurrenceScreen(
            config: crawlConfig,
            onConfigUpdate: () => setState(() {}),
            onEditStep: goToStep,
          ),
          isActive: currentStep >= 5,
          state: currentStep > 5 ? StepState.complete : StepState.indexed,
        ),
      );
    }

    // Always add review step as the last step
    steps.add(
      Step(
        title: Text(
          'Review',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        content: ReviewScreen(
          config: crawlConfig,
          onConfigUpdate: () => setState(() {}),
          onEditStep: goToStep,
        ),
        isActive: currentStep >= (canShowRecurrence ? 6 : 5),
        state: StepState.indexed,
      ),
    );

    return steps;
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
            canProceed: isCurrentStepValid(),
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
          onEditStep: goToStep,
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
}

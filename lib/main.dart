import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/wizard_container.dart';

void main() {
  runApp(const EasylingCrawlWizard());
}

class EasylingCrawlWizard extends StatelessWidget {
  const EasylingCrawlWizard({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Easyling Crawl Wizard',
      theme: AppTheme.lightTheme,
      home: const WizardContainer(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// File: lib/screens/type_screen.dart
import 'package:flutter/material.dart';
import '../models/crawl_config.dart';

class TypeScreen extends StatelessWidget {
  final CrawlConfig config;
  final VoidCallback onConfigUpdate;

  const TypeScreen({
    super.key,
    required this.config,
    required this.onConfigUpdate,
  });

  @override
  Widget build(BuildContext context) {
    // Placeholder for Type step
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Placeholder: Select Crawl Type',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'In the actual implementation, this step would allow selection of crawl type (Discovery, Content Extraction, etc.)',
            ),
            const SizedBox(height: 24),
            Text(
              'Currently Selected: ${config.crawlType.toString().split('.').last}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

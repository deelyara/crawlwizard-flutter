// File: lib/screens/restrictions_screen.dart
import 'package:flutter/material.dart';
import '../models/crawl_config.dart';

class RestrictionsScreen extends StatelessWidget {
  final CrawlConfig config;
  final VoidCallback onConfigUpdate;

  const RestrictionsScreen({
    super.key,
    required this.config,
    required this.onConfigUpdate,
  });

  @override
  Widget build(BuildContext context) {
    // Placeholder for Restrictions step
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Placeholder: Set Crawl Restrictions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'In the actual implementation, this step would allow setting URL path restrictions (includes, excludes)',
            ),
            const SizedBox(height: 24),
            const Text(
              'Currently Selected: No restrictions',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/crawl_config.dart';

class ScopeScreen extends StatelessWidget {
  final CrawlConfig config;
  final VoidCallback onConfigUpdate;

  const ScopeScreen({
    super.key,
    required this.config,
    required this.onConfigUpdate,
  });

  @override
  Widget build(BuildContext context) {
    // Placeholder for Scope step
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Set Crawl Scope',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Choose which pages to crawl:'),
            const SizedBox(height: 12),

            RadioListTile<CrawlScope>(
              title: const Text('Crawl entire website'),
              subtitle: const Text(
                'Re-visit current pagelist & find new pages',
              ),
              value: CrawlScope.entireSite,
              groupValue: config.crawlScope,
              onChanged: (value) {
                // In a real implementation, this would update the config
              },
            ),

            if (config.crawlScope == CrawlScope.entireSite)
              Padding(
                padding: const EdgeInsets.only(left: 48.0),
                child: Row(
                  children: [
                    const Text('Page limit: '),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 80,
                      child: TextFormField(
                        initialValue: config.pageLimit.toString(),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(isDense: true),
                        enabled: false,
                      ),
                    ),
                  ],
                ),
              ),

            RadioListTile<CrawlScope>(
              title: const Text('Current page list only'),
              subtitle: const Text('Only crawl pages already in your project'),
              value: CrawlScope.currentPages,
              groupValue: config.crawlScope,
              onChanged: (value) {
                // In a real implementation, this would update the config
              },
            ),

            RadioListTile<CrawlScope>(
              title: const Text('Specific pages only'),
              subtitle: const Text('Crawl only specified URLs or sitemaps'),
              value: CrawlScope.specificPages,
              groupValue: config.crawlScope,
              onChanged: (value) {
                // In a real implementation, this would update the config
              },
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'For this prototype, we are focusing on the later steps of the wizard. You can proceed to the next step.',
              style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

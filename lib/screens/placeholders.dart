import 'package:flutter/material.dart';
import '../models/crawl_config.dart';

// Type Screen (Step 1)
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
            Row(
              children: [
                Icon(
                  Icons.category,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Placeholder: Select Crawl Type',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'In the actual implementation, this step would allow selection of crawl type:',
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Wordcount (Discovery)'),
              subtitle: const Text(
                'Maps website structure without storing content',
              ),
              selected: config.crawlType == CrawlType.discovery,
            ),
            ListTile(
              leading: const Icon(Icons.content_copy),
              title: const Text('Content extraction (Scan)'),
              subtitle: const Text(
                'Extracts and stores source content for translation',
              ),
              selected: config.crawlType == CrawlType.contentExtraction,
            ),
            ListTile(
              leading: const Icon(Icons.compare_arrows),
              title: const Text('New content detection'),
              subtitle: const Text(
                'Analyzes site for new content since last crawl',
              ),
              selected: config.crawlType == CrawlType.newContentDetection,
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('TLS Content extraction (Scan)'),
              subtitle: const Text(
                'For sites with content that varies by target language',
              ),
              selected: config.crawlType == CrawlType.tlsContentExtraction,
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

// Scope Screen (Step 2)
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
            Row(
              children: [
                Icon(Icons.crop, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                const Text(
                  'Placeholder: Set Crawl Scope',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'In the actual implementation, this step would allow setting the scope of the crawl:',
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.public),
              title: const Text('Crawl entire website'),
              subtitle: const Text(
                'Re-visit current pagelist & find new pages',
              ),
              selected: config.crawlScope == CrawlScope.entireSite,
              trailing:
                  config.crawlScope == CrawlScope.entireSite
                      ? Text(
                        'Limit: ${config.pageLimit} pages',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      )
                      : null,
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Current page list only'),
              subtitle: const Text('Only crawl pages already in your project'),
              selected: config.crawlScope == CrawlScope.currentPages,
            ),
            ListTile(
              leading: const Icon(Icons.featured_play_list),
              title: const Text('Specific pages only'),
              subtitle: const Text('Crawl only specified URLs or sitemaps'),
              selected: config.crawlScope == CrawlScope.specificPages,
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

// Restrictions Screen (Step 3)
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
            Row(
              children: [
                Icon(Icons.block, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                const Text(
                  'Placeholder: Set Crawl Restrictions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'In the actual implementation, this step would allow setting URL path restrictions:',
            ),
            const SizedBox(height: 16),

            Card(
              color: Theme.of(
                context,
              ).colorScheme.surfaceVariant.withOpacity(0.5),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Existing project restrictions',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('No restrictions set.'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Temporary crawl restrictions',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Crawl pages starting with',
                        hintText: 'e.g., /blog/*, /en/*',
                        helperText:
                            'These restrictions will only apply to this crawl session',
                      ),
                      enabled: false,
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Don\'t crawl pages starting with',
                        hintText: 'e.g., /admin/*, /tmp/*',
                        helperText:
                            'These restrictions will only apply to this crawl session',
                      ),
                      enabled: false,
                    ),
                  ],
                ),
              ),
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

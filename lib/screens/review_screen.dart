import 'package:flutter/material.dart';
import '../models/crawl_config.dart';

class ReviewScreen extends StatelessWidget {
  final CrawlConfig config;
  final VoidCallback onConfigUpdate;
  final Function(int) onEditStep;

  const ReviewScreen({
    super.key,
    required this.config,
    required this.onConfigUpdate,
    required this.onEditStep,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and description
        Text(
          'Review and start crawl',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Review your configuration settings before starting the crawl.',
        ),
        const SizedBox(height: 24),

        // Type section
        _buildSection(
          context,
          title: 'Crawl type',
          content: _buildTypeContent(context),
          onEdit: () => onEditStep(0),
        ),

        const SizedBox(height: 16),

        // Scope section
        _buildSection(
          context,
          title: 'Scope',
          content: _buildScopeContent(context),
          onEdit: () => onEditStep(1),
        ),

        const SizedBox(height: 16),

        // Restrictions section
        _buildSection(
          context,
          title: 'Restrictions',
          content: _buildRestrictionsContent(context),
          onEdit: () => onEditStep(2),
        ),

        const SizedBox(height: 16),

        // Origin Snapshot section
        _buildSection(
          context,
          title: 'Origin Snapshot',
          content: _buildSnapshotContent(context),
          onEdit: () => onEditStep(3),
        ),

        const SizedBox(height: 16),

        // Fine-tune section
        _buildSection(
          context,
          title: 'Fine-tune',
          content: _buildFinetuneContent(context),
          onEdit: () => onEditStep(4),
        ),

        const SizedBox(height: 16),

        // Recurrence section
        _buildSection(
          context,
          title: 'Recurrence',
          content: _buildRecurrenceContent(context),
          onEdit: () => onEditStep(5),
        ),

        const SizedBox(height: 32),

        // Cost projection
        Card(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.euro_symbol,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Cost projection',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Estimated cost: €${config.getEstimatedCost().toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Note: Actual cost may vary based on content found during crawl.',
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required Widget content,
    required VoidCallback onEdit,
  }) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(padding: const EdgeInsets.all(16.0), child: content),
        ],
      ),
    );
  }

  Widget _buildTypeContent(BuildContext context) {
    String crawlTypeText = '';

    switch (config.crawlType) {
      case CrawlType.discovery:
        crawlTypeText = 'Discovery crawl';
        break;
      case CrawlType.contentExtraction:
        crawlTypeText = 'Content extraction (Scan)';
        break;
      case CrawlType.newContentDetection:
        crawlTypeText = 'New content detection';
        break;
      case CrawlType.tlsContentExtraction:
        crawlTypeText = 'TLS Content extraction (Scan)';
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(crawlTypeText),
        if (config.prerenderPages) ...[
          const SizedBox(height: 8),
          const Text('Prerender pages: Yes'),
        ],
      ],
    );
  }

  Widget _buildScopeContent(BuildContext context) {
    String scopeText = '';

    switch (config.crawlScope) {
      case CrawlScope.entireSite:
        scopeText = 'Crawl entire website';
        break;
      case CrawlScope.currentPages:
        scopeText = 'Crawl existing pages';
        break;
      case CrawlScope.specificPages:
        scopeText = 'Crawl specific pages';
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(scopeText),
        if (config.crawlScope == CrawlScope.entireSite) ...[
          const SizedBox(height: 8),
          Text('Page limit: ${config.pageLimit}'),
        ],
        if (config.crawlScope == CrawlScope.specificPages &&
            config.specificUrls.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('Number of specific URLs: ${config.specificUrls.length}'),
        ],
      ],
    );
  }

  Widget _buildRestrictionsContent(BuildContext context) {
    bool hasIncludes = config.includePrefixes.isNotEmpty;
    bool hasExcludes = config.excludePrefixes.isNotEmpty;

    if (!hasIncludes && !hasExcludes) {
      return const Text('No restrictions set.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasIncludes) ...[
          const Text(
            'Crawl pages starting with:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          ...config.includePrefixes.map((prefix) => Text('• $prefix')),
        ],
        if (hasIncludes && hasExcludes) const SizedBox(height: 8),
        if (hasExcludes) ...[
          const Text(
            'Don\'t crawl pages starting with:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          ...config.excludePrefixes.map((prefix) => Text('• $prefix')),
        ],
      ],
    );
  }

  Widget _buildSnapshotContent(BuildContext context) {
    String snapshotText = '';

    switch (config.snapshotOption) {
      case SnapshotOption.useExisting:
        snapshotText = 'Use existing snapshot';
        break;
      case SnapshotOption.compareContent:
        snapshotText = 'Compare content with previous crawl';
        break;
      case SnapshotOption.rebuildAll:
        snapshotText = 'Extract content from all pages';
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(snapshotText),
        if (config.snapshotOption != SnapshotOption.rebuildAll) ...[
          const SizedBox(height: 8),
          Text(
            config.storeNewPages
                ? 'New pages will be added to the snapshot'
                : 'New pages will be ignored',
          ),
        ],
        if (config.selectedSnapshot.isNotEmpty &&
            (config.snapshotOption == SnapshotOption.useExisting ||
                config.snapshotOption == SnapshotOption.compareContent)) ...[
          const SizedBox(height: 8),
          Text('Selected snapshot: ${config.selectedSnapshot}'),
        ],
      ],
    );
  }

  Widget _buildFinetuneContent(BuildContext context) {
    List<String> resourcesCollected = [];

    if (config.collectHtmlPages) resourcesCollected.add('HTML pages');
    if (config.collectJsCssResources)
      resourcesCollected.add('JS/CSS resources');
    if (config.collectImages) resourcesCollected.add('Images');
    if (config.collectBinaryResources)
      resourcesCollected.add('Binary resources');
    if (config.collectErrorPages) resourcesCollected.add('Error pages');
    if (config.collectExternalDomains)
      resourcesCollected.add('External domain resources');
    if (config.collectRedirectionPages)
      resourcesCollected.add('Redirection pages');
    if (config.collectShortLinks) resourcesCollected.add('Short links');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resources to collect:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        resourcesCollected.isEmpty
            ? const Text('No resources selected')
            : Wrap(
              spacing: 8,
              runSpacing: 4,
              children:
                  resourcesCollected.map((resource) {
                    return Chip(
                      label: Text(resource),
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceVariant,
                      visualDensity: VisualDensity.compact,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    );
                  }).toList(),
            ),

        const SizedBox(height: 8),
        Text('Simultaneous requests: ${config.simultaneousRequests}'),

        if (config.sessionCookie.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text('Session cookie: Set'),
        ],
      ],
    );
  }

  Widget _buildRecurrenceContent(BuildContext context) {
    if (config.recurrenceFrequency == RecurrenceFrequency.none) {
      return const Text('No recurring crawls scheduled');
    }

    String frequencyText = '';
    switch (config.recurrenceFrequency) {
      case RecurrenceFrequency.daily:
        frequencyText = 'Daily';
        break;
      case RecurrenceFrequency.weekly:
        String day = '';
        switch (config.recurrenceDayOfWeek) {
          case 1:
            day = 'Monday';
            break;
          case 2:
            day = 'Tuesday';
            break;
          case 3:
            day = 'Wednesday';
            break;
          case 4:
            day = 'Thursday';
            break;
          case 5:
            day = 'Friday';
            break;
          case 6:
            day = 'Saturday';
            break;
          case 7:
            day = 'Sunday';
            break;
          default:
            day = 'Monday';
        }
        frequencyText = 'Weekly on $day';
        break;
      case RecurrenceFrequency.monthly:
        String suffix = '';
        int dayOfMonth = config.recurrenceDayOfMonth;
        if (dayOfMonth == 1 || dayOfMonth == 21 || dayOfMonth == 31) {
          suffix = 'st';
        } else if (dayOfMonth == 2 || dayOfMonth == 22) {
          suffix = 'nd';
        } else if (dayOfMonth == 3 || dayOfMonth == 23) {
          suffix = 'rd';
        } else {
          suffix = 'th';
        }
        frequencyText = 'Monthly on the $dayOfMonth$suffix';
        break;
      case RecurrenceFrequency.custom:
        frequencyText = 'Custom schedule';
        break;
      case RecurrenceFrequency.none:
        frequencyText = 'No recurring crawls';
        break;
    }

    // Format time
    String formattedTime =
        '${config.recurrenceTime.hour.toString().padLeft(2, '0')}:${config.recurrenceTime.minute.toString().padLeft(2, '0')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$frequencyText at $formattedTime'),

        if (config.useRotatingSnapshots &&
            config.selectedRotatingSnapshots.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text(
            'Rotating snapshots:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          ...config.selectedRotatingSnapshots.map(
            (snapshot) => Text('• $snapshot'),
          ),
        ],
      ],
    );
  }
}

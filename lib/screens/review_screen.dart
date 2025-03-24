import 'package:flutter/material.dart';
import '../models/crawl_config.dart';

class ReviewScreen extends StatefulWidget {
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
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.config.userNote ?? '');
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and description
        Text(
          'Review and start crawl',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Review your configuration settings before starting the crawl.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),

        // Type section
        _buildSection(
          context,
          title: 'Crawl type',
          content: _buildTypeContent(context),
          onEdit: () => widget.onEditStep(0),
        ),

        const SizedBox(height: 16),

        // Scope section
        _buildSection(
          context,
          title: 'Scope',
          content: _buildScopeContent(context),
          onEdit: () => widget.onEditStep(1),
        ),

        const SizedBox(height: 16),

        // Restrictions section
        _buildSection(
          context,
          title: 'Restrictions',
          content: _buildRestrictionsContent(context),
          onEdit: () => widget.onEditStep(2),
        ),

        const SizedBox(height: 16),

        // Origin Snapshot section
        _buildSection(
          context,
          title: 'Origin Snapshot',
          content: _buildSnapshotContent(context),
          onEdit: () => widget.onEditStep(3),
        ),

        const SizedBox(height: 16),

        // Fine-tune section
        _buildSection(
          context,
          title: 'Fine-tune',
          content: _buildFinetuneContent(context),
          onEdit: () => widget.onEditStep(4),
        ),

        const SizedBox(height: 16),

        // Recurrence section
        _buildSection(
          context,
          title: 'Recurrence',
          content: _buildRecurrenceContent(context),
          onEdit: () => widget.onEditStep(5),
        ),

        const SizedBox(height: 24),
        
        // Note field for user comments
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: theme.colorScheme.outlineVariant,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.note_alt_outlined,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Notes',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _noteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Add any notes about this crawl (optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                  ),
                  onChanged: (value) {
                    // Save the note to the config
                    widget.config.userNote = value;
                    widget.onConfigUpdate();
                  },
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Important Note
        Card(
          color: theme.colorScheme.primary.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Important Note',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'The settings you selected determine what resources are collected during the crawl. To ensure optimal performance and accurate content extraction, these settings have been configured based on your selections.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Resources will be collected based on your website structure and the crawl type you\'ve selected.',
                  style: theme.textTheme.bodyMedium,
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
    final theme = Theme.of(context);
    
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
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
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.colorScheme.outlineVariant),
          Padding(
            padding: const EdgeInsets.all(16.0), 
            child: content
          ),
        ],
      ),
    );
  }

  Widget _buildTypeContent(BuildContext context) {
    String crawlTypeText = '';

    switch (widget.config.crawlType) {
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
        if (widget.config.prerenderPages) ...[
          const SizedBox(height: 8),
          const Text('Prerender pages: Yes'),
        ],
      ],
    );
  }

  Widget _buildScopeContent(BuildContext context) {
    String scopeText = '';

    switch (widget.config.crawlScope) {
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
        if (widget.config.crawlScope == CrawlScope.entireSite) ...[
          const SizedBox(height: 8),
          Text('Page limit: ${widget.config.pageLimit}'),
        ],
        if (widget.config.crawlScope == CrawlScope.specificPages &&
            widget.config.specificUrls.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('Number of specific URLs: ${widget.config.specificUrls.length}'),
        ],
      ],
    );
  }

  Widget _buildRestrictionsContent(BuildContext context) {
    bool hasIncludes = widget.config.includePrefixes.isNotEmpty;
    bool hasExcludes = widget.config.excludePrefixes.isNotEmpty;

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
          ...widget.config.includePrefixes.map((prefix) => Text('• $prefix')),
        ],
        if (hasIncludes && hasExcludes) const SizedBox(height: 8),
        if (hasExcludes) ...[
          const Text(
            'Don\'t crawl pages starting with:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          ...widget.config.excludePrefixes.map((prefix) => Text('• $prefix')),
        ],
      ],
    );
  }

  Widget _buildSnapshotContent(BuildContext context) {
    String snapshotText = '';

    switch (widget.config.snapshotOption) {
      case SnapshotOption.useExisting:
        snapshotText = 'Use existing snapshot';
        break;
      case SnapshotOption.compareContent:
        snapshotText = 'Compare content with previous crawl';
        break;
      case SnapshotOption.rebuildAll:
        snapshotText = 'Extract content from all pages';
        break;
      case SnapshotOption.createNew:
        snapshotText = 'Create new snapshot';
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(snapshotText),
        if (widget.config.snapshotOption != SnapshotOption.rebuildAll) ...[
          const SizedBox(height: 8),
          Text(
            widget.config.storeNewPages
                ? 'New pages will be added to the snapshot'
                : 'New pages will be ignored',
          ),
        ],
        if (widget.config.selectedSnapshot.isNotEmpty &&
            (widget.config.snapshotOption == SnapshotOption.useExisting ||
                widget.config.snapshotOption == SnapshotOption.compareContent)) ...[
          const SizedBox(height: 8),
          Text('Selected snapshot: ${widget.config.selectedSnapshot}'),
        ],
      ],
    );
  }

  Widget _buildFinetuneContent(BuildContext context) {
    List<String> resourcesCollected = [];

    if (widget.config.collectHtmlPages) resourcesCollected.add('HTML pages');
    if (widget.config.collectJsCssResources)
      resourcesCollected.add('JS/CSS resources');
    if (widget.config.collectImages) resourcesCollected.add('Images');
    if (widget.config.collectBinaryResources)
      resourcesCollected.add('Binary resources');
    if (widget.config.collectErrorPages) resourcesCollected.add('Error pages');
    if (widget.config.collectExternalDomains)
      resourcesCollected.add('External domain resources');
    if (widget.config.collectRedirectionPages)
      resourcesCollected.add('Redirection pages');
    if (widget.config.collectShortLinks) resourcesCollected.add('Short links');

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
        Text('Simultaneous requests: ${widget.config.simultaneousRequests}'),

        if (widget.config.sessionCookie.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text('Session cookie: Set'),
        ],
      ],
    );
  }

  Widget _buildRecurrenceContent(BuildContext context) {
    if (widget.config.recurrenceFrequency == RecurrenceFrequency.none) {
      return const Text('No recurring crawls scheduled');
    }

    String frequencyText = '';
    switch (widget.config.recurrenceFrequency) {
      case RecurrenceFrequency.daily:
        frequencyText = 'Daily';
        break;
      case RecurrenceFrequency.weekly:
        String day = '';
        switch (widget.config.recurrenceDayOfWeek) {
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
        int dayOfMonth = widget.config.recurrenceDayOfMonth;
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(frequencyText),

        if (widget.config.useRotatingSnapshots &&
            widget.config.selectedRotatingSnapshots.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text(
            'Rotating snapshots:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          ...widget.config.selectedRotatingSnapshots.map(
            (snapshot) => Text('• $snapshot'),
          ),
        ],
      ],
    );
  }
}

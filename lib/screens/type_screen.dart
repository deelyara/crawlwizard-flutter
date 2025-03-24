// File: lib/screens/type_screen.dart
import 'package:flutter/material.dart';
import '../models/crawl_config.dart';
import '../widgets/option_card.dart';
import '../widgets/information_tooltip.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title with tooltip
        Row(
          children: [
            Text(
              'Select Crawl Type',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            const InformationTooltip(
              message: 'Choose the type of crawl that best fits your needs.',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'The type of crawl determines what content is collected and how it is processed.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),

        // Type options
        SimpleOptionCard(
          isSelected: config.crawlType == CrawlType.discovery,
          title: 'Discovery',
          subtitle: 'Maps the structure of the site without storing content',
          icon: Icons.explore_outlined,
          onTap: () {
            config.crawlType = CrawlType.discovery;
            onConfigUpdate();
          },
        ),
        const SizedBox(height: 12),

        SimpleOptionCard(
          isSelected: config.crawlType == CrawlType.contentExtraction,
          title: 'Content Extraction',
          subtitle: 'Extracts and stores source content from pages',
          icon: Icons.download_outlined,
          onTap: () {
            config.crawlType = CrawlType.contentExtraction;
            onConfigUpdate();
          },
        ),
        const SizedBox(height: 12),

        SimpleOptionCard(
          isSelected: config.crawlType == CrawlType.newContentDetection,
          title: 'New Content Detection',
          subtitle: 'Analyzes pages for new content based on existing entries',
          icon: Icons.find_in_page_outlined,
          onTap: () {
            config.crawlType = CrawlType.newContentDetection;
            onConfigUpdate();
          },
        ),
        const SizedBox(height: 12),

        SimpleOptionCard(
          isSelected: config.crawlType == CrawlType.tlsContentExtraction,
          title: 'TLS Content Extraction',
          subtitle: 'For sites with varying content by target languages',
          icon: Icons.language_outlined,
          onTap: () {
            config.crawlType = CrawlType.tlsContentExtraction;
            onConfigUpdate();
          },
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../models/crawl_config.dart';
import '../widgets/option_card.dart';
import '../widgets/information_tooltip.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title with tooltip
        Row(
          children: [
            Text(
              'Choose What to Crawl',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            const InformationTooltip(
              message: 'Select which parts of the website to include.',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'How much of the website do you want to crawl?',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),

        // Scope options
        SimpleOptionCard(
          isSelected: config.crawlScope == CrawlScope.entireSite,
          title: 'Entire Website',
          subtitle: 'Crawl everything and discover new pages',
          icon: Icons.public_outlined,
          onTap: () {
            config.crawlScope = CrawlScope.entireSite;
            onConfigUpdate();
          },
        ),
        const SizedBox(height: 12),

        SimpleOptionCard(
          isSelected: config.crawlScope == CrawlScope.currentPages,
          title: 'Existing Pages Only',
          subtitle: 'Only crawl pages already in your project',
          icon: Icons.bookmark_border_outlined,
          onTap: () {
            config.crawlScope = CrawlScope.currentPages;
            onConfigUpdate();
          },
        ),
        const SizedBox(height: 12),

        SimpleOptionCard(
          isSelected: config.crawlScope == CrawlScope.specificPages,
          title: 'Custom Pages',
          subtitle: 'Specify exactly which pages to crawl',
          icon: Icons.list_alt_outlined,
          onTap: () {
            config.crawlScope = CrawlScope.specificPages;
            onConfigUpdate();
          },
        ),

        // Option to limit number of pages
        if (config.crawlScope == CrawlScope.entireSite) ...[
          const SizedBox(height: 24),
          Text(
            'How many pages?',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Limit the number of pages to keep costs under control.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Slider(
            value: config.pageLimit.toDouble(),
            min: 10,
            max: 1000,
            divisions: 99,
            label: '${config.pageLimit} pages',
            onChanged: (value) {
              config.pageLimit = value.round();
              onConfigUpdate();
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('10 pages'),
                Text(
                  '${config.pageLimit} pages',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Text('1000 pages'),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

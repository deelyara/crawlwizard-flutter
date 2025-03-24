import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/crawl_config.dart';
import '../widgets/option_card.dart';
import '../widgets/information_tooltip.dart';

class ScopeScreen extends StatefulWidget {
  final CrawlConfig config;
  final VoidCallback onConfigUpdate;

  const ScopeScreen({
    super.key,
    required this.config,
    required this.onConfigUpdate,
  });

  @override
  State<ScopeScreen> createState() => _ScopeScreenState();
}

class _ScopeScreenState extends State<ScopeScreen> {
  late TextEditingController _pageLimitController;

  @override
  void initState() {
    super.initState();
    _pageLimitController = TextEditingController(text: widget.config.pageLimit.toString());
  }

  @override
  void dispose() {
    _pageLimitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title with tooltip
        Row(
          children: [
            Text(
              'Choose What to Crawl',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
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
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),

        // Scope options
        SimpleOptionCard(
          isSelected: widget.config.crawlScope == CrawlScope.entireSite,
          title: 'Entire Website',
          subtitle: 'Crawl everything and discover new pages',
          icon: Icons.public_outlined,
          onTap: () {
            setState(() {
              widget.config.crawlScope = CrawlScope.entireSite;
              widget.onConfigUpdate();
            });
          },
        ),
        const SizedBox(height: 12),

        SimpleOptionCard(
          isSelected: widget.config.crawlScope == CrawlScope.currentPages,
          title: 'Existing Pages Only',
          subtitle: 'Only crawl pages already in your project',
          icon: Icons.bookmark_border_outlined,
          onTap: () {
            setState(() {
              widget.config.crawlScope = CrawlScope.currentPages;
              widget.onConfigUpdate();
            });
          },
        ),
        const SizedBox(height: 12),

        SimpleOptionCard(
          isSelected: widget.config.crawlScope == CrawlScope.specificPages,
          title: 'Custom Pages',
          subtitle: 'Specify exactly which pages to crawl',
          icon: Icons.list_alt_outlined,
          onTap: () {
            setState(() {
              widget.config.crawlScope = CrawlScope.specificPages;
              widget.onConfigUpdate();
            });
          },
        ),

        // Option to limit number of pages
        if (widget.config.crawlScope == CrawlScope.entireSite) ...[
          const SizedBox(height: 24),
          Text(
            'How many pages?',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Limit the number of pages to keep costs under control.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _pageLimitController,
                  decoration: InputDecoration(
                    labelText: 'Page limit',
                    hintText: 'Enter a number between 10-1000',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixText: 'pages',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      int newLimit = int.parse(value);
                      // Ensure the value is between 10 and 1000
                      if (newLimit < 10) newLimit = 10;
                      if (newLimit > 1000) newLimit = 1000;
                      
                      setState(() {
                        widget.config.pageLimit = newLimit;
                        if (newLimit.toString() != value) {
                          _pageLimitController.text = newLimit.toString();
                          _pageLimitController.selection = TextSelection.fromPosition(
                            TextPosition(offset: newLimit.toString().length),
                          );
                        }
                        widget.onConfigUpdate();
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Recommended: 100-500 pages for initial crawls',
            style: theme.textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

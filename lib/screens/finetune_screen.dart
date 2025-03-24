import 'package:flutter/material.dart';
import '../models/crawl_config.dart';
import '../widgets/information_tooltip.dart';

class FinetuneScreen extends StatefulWidget {
  final CrawlConfig config;
  final VoidCallback onConfigUpdate;

  const FinetuneScreen({
    super.key,
    required this.config,
    required this.onConfigUpdate,
  });

  @override
  State<FinetuneScreen> createState() => _FinetuneScreenState();
}

class _FinetuneScreenState extends State<FinetuneScreen> {
  // Expansion panel states
  bool _isResourcesExpanded = true;
  bool _isTweaksExpanded = false;
  bool _isSessionExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and description
        Text(
          'Fine-tune your crawl',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Configure advanced settings for your crawl including resource collection, request limits, and authentication options.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),

        // Resources to collect section
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: theme.colorScheme.outlineVariant,
            ),
          ),
          child: ExpansionPanelList(
            elevation: 0,
            expandedHeaderPadding: EdgeInsets.zero,
            expansionCallback: (panelIndex, isExpanded) {
              setState(() {
                if (panelIndex == 0)
                  _isResourcesExpanded = !_isResourcesExpanded;
                if (panelIndex == 1) _isTweaksExpanded = !_isTweaksExpanded;
                if (panelIndex == 2) _isSessionExpanded = !_isSessionExpanded;
              });
            },
            children: [
              // Resources to collect
              ExpansionPanel(
                headerBuilder: (context, isExpanded) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Resources to collect',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
                body: Padding(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    bottom: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Configure which resources to collect during the crawl',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),

                      // Common resources section
                      Text(
                        'Common resources',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // HTML pages
                      _buildCheckboxListTile(
                        title: 'HTML pages',
                        subtitle: 'Any pages found will be added to the page list',
                        tooltip: 'Collect new HTML pages found during crawl',
                        value: widget.config.collectHtmlPages,
                        onChanged: (value) {
                          setState(() {
                            widget.config.collectHtmlPages = value ?? false;
                            widget.onConfigUpdate();
                          });
                        },
                      ),

                      // JS, CSS resources
                      _buildCheckboxListTile(
                        title: 'JS, JSON, XML, CSS resources',
                        subtitle: 'Resources will be available for localization',
                        tooltip: 'Add script and style resources found during crawl',
                        value: widget.config.collectJsCssResources,
                        onChanged: (value) {
                          setState(() {
                            widget.config.collectJsCssResources = value ?? false;
                            widget.onConfigUpdate();
                          });
                        },
                      ),

                      // Images
                      _buildCheckboxListTile(
                        title: 'Images',
                        subtitle: 'Collect images for replacement during translation',
                        tooltip: 'Collect image resources (may increase crawl time significantly)',
                        value: widget.config.collectImages,
                        onChanged: (value) {
                          setState(() {
                            widget.config.collectImages = value ?? false;
                            widget.onConfigUpdate();
                          });
                        },
                      ),

                      // Binary resources
                      _buildCheckboxListTile(
                        title: 'Binary resources',
                        subtitle: 'Collect PDFs, downloads and other binary files',
                        tooltip: 'Collect other binary files like PDFs and downloads',
                        value: widget.config.collectBinaryResources,
                        onChanged: (value) {
                          setState(() {
                            widget.config.collectBinaryResources = value ?? false;
                            widget.onConfigUpdate();
                          });
                        },
                      ),

                      const Divider(),

                      // Additional resources section
                      Text(
                        'Additional resources',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Error pages
                      _buildCheckboxListTile(
                        title: 'Error pages (HTTP 4XX)',
                        subtitle: 'Include error pages in translation process',
                        tooltip: 'Collect error pages for localization',
                        value: widget.config.collectErrorPages,
                        onChanged: (value) {
                          setState(() {
                            widget.config.collectErrorPages = value ?? false;
                            widget.onConfigUpdate();
                          });
                        },
                      ),

                      // Resources from external domains
                      _buildCheckboxListTile(
                        title: 'Resources from external domains',
                        subtitle: 'Include resources hosted on different domains',
                        tooltip: 'Collect resources hosted on different domains',
                        value: widget.config.collectExternalDomains,
                        onChanged: (value) {
                          setState(() {
                            widget.config.collectExternalDomains = value ?? false;
                            widget.onConfigUpdate();
                          });
                        },
                      ),

                      // Redirection pages
                      _buildCheckboxListTile(
                        title: 'Redirection pages (HTTP 3XX)',
                        subtitle: 'Include redirect pages in translation',
                        tooltip: 'Collect redirect pages for localization',
                        value: widget.config.collectRedirectionPages,
                        onChanged: (value) {
                          setState(() {
                            widget.config.collectRedirectionPages = value ?? false;
                            widget.onConfigUpdate();
                          });
                        },
                      ),

                      // Short links
                      _buildCheckboxListTile(
                        title: 'Short links',
                        subtitle: 'Include shortened links (e.g., ?p=123)',
                        tooltip: 'Collect shortened links common in WordPress and similar CMS',
                        value: widget.config.collectShortLinks,
                        onChanged: (value) {
                          setState(() {
                            widget.config.collectShortLinks = value ?? false;
                            widget.onConfigUpdate();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                isExpanded: _isResourcesExpanded,
              ),

              // Additional tweaks
              ExpansionPanel(
                headerBuilder: (context, isExpanded) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Performance tweaks',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
                body: Padding(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    bottom: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Skip content-type check
                      _buildCheckboxListTile(
                        title: 'Skip content-type check if already determined',
                        subtitle: 'Speeds up crawl but may miss content type changes',
                        tooltip: 'Skip checking content types for pages that have been crawled before',
                        value: widget.config.skipContentTypeCheck,
                        onChanged: (value) {
                          setState(() {
                            widget.config.skipContentTypeCheck = value ?? false;
                            widget.onConfigUpdate();
                          });
                        },
                      ),

                      // Use ETags
                      _buildCheckboxListTile(
                        title: 'Use ETags from last crawl',
                        subtitle: 'Reduces server load but may miss minor changes',
                        tooltip: 'Use ETags to determine if content has changed since last crawl',
                        value: widget.config.useEtags,
                        onChanged: (value) {
                          setState(() {
                            widget.config.useEtags = value ?? false;
                            widget.onConfigUpdate();
                          });
                        },
                      ),

                      const Divider(),
                      const SizedBox(height: 8),

                      // Simultaneous requests
                      Text(
                        'Maximum simultaneous requests',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Limit the number of parallel requests to avoid overloading the website',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      Slider(
                        value: widget.config.simultaneousRequests.toDouble(),
                        min: 1,
                        max: 20,
                        divisions: 19,
                        label: widget.config.simultaneousRequests.toString(),
                        onChanged: (value) {
                          setState(() {
                            widget.config.simultaneousRequests = value.round();
                            widget.onConfigUpdate();
                          });
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('1 (gentler)', style: theme.textTheme.bodySmall),
                          Text(
                            widget.config.simultaneousRequests.toString(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          Text('20 (faster)', style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ],
                  ),
                ),
                isExpanded: _isTweaksExpanded,
              ),

              // Session options
              ExpansionPanel(
                headerBuilder: (context, isExpanded) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Session & authentication',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
                body: Padding(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    bottom: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Session cookie',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Use a session cookie to crawl authenticated content',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Paste session cookie here',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        maxLines: 4,
                        onChanged: (value) {
                          setState(() {
                            widget.config.sessionCookie = value;
                            widget.onConfigUpdate();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                isExpanded: _isSessionExpanded,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildCheckboxListTile({
    required String title,
    required String subtitle,
    required String tooltip,
    required bool value,
    required Function(bool?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InformationTooltip(message: tooltip),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

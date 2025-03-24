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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and description
        Text(
          'Fine-tune your crawl',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Configure advanced settings for your crawl including resource collection, request limits, and authentication options.',
        ),
        const SizedBox(height: 24),

        // Resources to collect section
        Card(
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
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Resources to collect',
                      style: TextStyle(
                        fontSize: 16,
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
                      const Text(
                        'Configure which resources to collect during the crawl',
                      ),
                      const SizedBox(height: 16),

                      // Common resources section
                      const Text(
                        'Common resources',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // HTML pages
                      SwitchListTile(
                        title: Row(
                          children: [
                            const Text('HTML pages'),
                            const SizedBox(width: 8),
                            InformationTooltip(
                              message:
                                  'Collect new HTML pages found during crawl',
                            ),
                          ],
                        ),
                        subtitle: const Text(
                          'Any pages found will be added to the page list',
                        ),
                        value: widget.config.collectHtmlPages,
                        onChanged: (value) {
                          setState(() {
                            widget.config.collectHtmlPages = value;
                            widget.onConfigUpdate();
                          });
                        },
                      ),

                      // JS, CSS resources
                      SwitchListTile(
                        title: Row(
                          children: [
                            const Text('JS, JSON, XML, CSS resources'),
                            const SizedBox(width: 8),
                            InformationTooltip(
                              message:
                                  'Add script and style resources found during crawl',
                            ),
                          ],
                        ),
                        subtitle: const Text(
                          'Resources will be available for localization',
                        ),
                        value: widget.config.collectJsCssResources,
                        onChanged: (value) {
                          setState(() {
                            widget.config.collectJsCssResources = value;
                            widget.onConfigUpdate();
                          });
                        },
                      ),

                      // Images
                      SwitchListTile(
                        title: Row(
                          children: [
                            const Text('Images'),
                            const SizedBox(width: 8),
                            InformationTooltip(
                              message:
                                  'Collect image resources (may increase crawl time significantly)',
                            ),
                          ],
                        ),
                        value: widget.config.collectImages,
                        onChanged: (value) {
                          setState(() {
                            widget.config.collectImages = value;
                            widget.onConfigUpdate();
                          });
                        },
                      ),

                      // Binary resources
                      SwitchListTile(
                        title: Row(
                          children: [
                            const Text('Binary resources'),
                            const SizedBox(width: 8),
                            InformationTooltip(
                              message:
                                  'Collect other binary files like PDFs and downloads',
                            ),
                          ],
                        ),
                        value: widget.config.collectBinaryResources,
                        onChanged: (value) {
                          setState(() {
                            widget.config.collectBinaryResources = value;
                            widget.onConfigUpdate();
                          });
                        },
                      ),

                      const Divider(),

                      // Additional resources section
                      const Text(
                        'Additional resources',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // Error pages
                      SwitchListTile(
                        title: Row(
                          children: [
                            const Text('Error pages (HTTP 4XX)'),
                            const SizedBox(width: 8),
                            InformationTooltip(
                              message: 'Collect error pages for localization',
                            ),
                          ],
                        ),
                        value: widget.config.collectErrorPages,
                        onChanged: (value) {
                          setState(() {
                            widget.config.collectErrorPages = value;
                            widget.onConfigUpdate();
                          });
                        },
                      ),

                      // Resources from external domains
                      SwitchListTile(
                        title: Row(
                          children: [
                            const Text('Resources from external domains'),
                            const SizedBox(width: 8),
                            InformationTooltip(
                              message:
                                  'Collect resources hosted on different domains',
                            ),
                          ],
                        ),
                        value: widget.config.collectExternalDomains,
                        onChanged: (value) {
                          setState(() {
                            widget.config.collectExternalDomains = value;
                            widget.onConfigUpdate();
                          });
                        },
                      ),

                      // Redirection pages
                      SwitchListTile(
                        title: Row(
                          children: [
                            const Text('Redirection pages (HTTP 3XX)'),
                            const SizedBox(width: 8),
                            InformationTooltip(
                              message:
                                  'Collect redirect pages for localization',
                            ),
                          ],
                        ),
                        value: widget.config.collectRedirectionPages,
                        onChanged: (value) {
                          setState(() {
                            widget.config.collectRedirectionPages = value;
                            widget.onConfigUpdate();
                          });
                        },
                      ),

                      // Short links
                      SwitchListTile(
                        title: Row(
                          children: [
                            const Text('Short links (e.g. ?p=123456)'),
                            const SizedBox(width: 8),
                            InformationTooltip(
                              message:
                                  'Collect short links commonly used by WordPress sites',
                            ),
                          ],
                        ),
                        subtitle: const Text(
                          'Often safe to ignore as they duplicate content',
                        ),
                        value: widget.config.collectShortLinks,
                        onChanged: (value) {
                          setState(() {
                            widget.config.collectShortLinks = value;
                            widget.onConfigUpdate();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                isExpanded: _isResourcesExpanded,
                canTapOnHeader: true,
              ),

              // Tweaks section
              ExpansionPanel(
                headerBuilder: (context, isExpanded) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Tweaks',
                      style: TextStyle(
                        fontSize: 16,
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
                      const Text(
                        'Fine-tune crawl behavior with these advanced options',
                      ),
                      const SizedBox(height: 16),

                      // Skip content-type check
                      SwitchListTile(
                        title: Row(
                          children: [
                            const Text(
                              'Skip content-type check if already determined',
                            ),
                            const SizedBox(width: 8),
                            InformationTooltip(
                              message:
                                  'Skip content-type checking for previously crawled pages',
                            ),
                          ],
                        ),
                        subtitle: const Text(
                          'Only applies to already crawled pages',
                        ),
                        value: widget.config.skipContentTypeCheck,
                        onChanged: (value) {
                          setState(() {
                            widget.config.skipContentTypeCheck = value;
                            widget.onConfigUpdate();
                          });
                        },
                      ),

                      // Use ETAGs
                      SwitchListTile(
                        title: Row(
                          children: [
                            const Text('Use ETAGs from last crawl'),
                            const SizedBox(width: 8),
                            InformationTooltip(
                              message:
                                  'Use ETAGs to reduce server load, may affect accuracy',
                            ),
                          ],
                        ),
                        subtitle: const Text(
                          'May reduce server load but could lead to invalid word counts',
                        ),
                        value: widget.config.useEtags,
                        onChanged: (value) {
                          setState(() {
                            widget.config.useEtags = value;
                            widget.onConfigUpdate();
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // Simultaneous requests limit
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Limit number of simultaneous requests: ${widget.config.simultaneousRequests}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          InformationTooltip(
                            message:
                                'Control the number of concurrent requests to prevent overwhelming the server',
                          ),
                        ],
                      ),
                      Slider(
                        value: widget.config.simultaneousRequests.toDouble(),
                        min: 1,
                        max: 20,
                        divisions: 19,
                        label: widget.config.simultaneousRequests.toString(),
                        onChanged: (value) {
                          setState(() {
                            widget.config.simultaneousRequests = value.toInt();
                            widget.onConfigUpdate();
                          });
                        },
                      ),
                      const Text(
                        'Use a lower value for smaller servers to prevent them from being overwhelmed',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Custom user agent
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Custom user agent',
                          hintText:
                              'e.g., Mozilla/5.0 (compatible; Easyling/1.0)',
                          helperText:
                              'Optionally override the crawler\'s default user agent',
                        ),
                      ),
                    ],
                  ),
                ),
                isExpanded: _isTweaksExpanded,
                canTapOnHeader: true,
              ),

              // Session Cookie section
              ExpansionPanel(
                headerBuilder: (context, isExpanded) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Session Cookie',
                      style: TextStyle(
                        fontSize: 16,
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
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Login areas on a site keep track of user sessions via cookies',
                            ),
                          ),
                          const SizedBox(width: 8),
                          InformationTooltip(
                            message:
                                'Use session cookies to crawl content behind login walls',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Session cookie
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Session Cookie',
                          hintText: 'Paste extracted session cookie here',
                        ),
                        maxLines: 4,
                        onChanged: (value) {
                          setState(() {
                            widget.config.sessionCookie = value;
                            widget.onConfigUpdate();
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // Bearer token
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Bearer Token',
                          hintText: 'Paste authorization token here',
                          helperText:
                              'Bearer tokens can be used to access protected resources',
                        ),
                      ),

                      const SizedBox(height: 16),
                      const Text(
                        'Note: Success depends on the implementation details of the site. IP checking or User-Agent verification might prevent this from working.',
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                isExpanded: _isSessionExpanded,
                canTapOnHeader: true,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Add a note (optional)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add a note (optional)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Add notes about this crawl configuration',
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

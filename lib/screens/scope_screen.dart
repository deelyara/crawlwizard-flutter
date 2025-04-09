import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/crawl_config.dart';

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
  late TextEditingController _maxDepthController;
  final TextEditingController _urlListController = TextEditingController(
    text: '''https://csega.hu/
https://csega.hu/intro/
https://csega.hu/muvek/
https://csega.hu/muvek/kotetek
https://csega.hu/muvek/rovid-prozak
https://csega.hu/muvek/rovid-prozak/a-tarsulat
https://csega.hu/muvek/rovid-prozak/gyogyulas
https://csega.hu/muvek/rovid-prozak/hiena'''
  );
  late TextEditingController _specificUrlsController;
  late TextEditingController _sitemapUrlsController;

  bool get canProceed {
    if (widget.config.crawlScope == null) return false;
    
    switch (widget.config.crawlScope) {
      case CrawlScope.specificPages:
        return widget.config.specificUrls.isNotEmpty;
      case CrawlScope.sitemapPages:
        return widget.config.specificUrls.isNotEmpty;
      default:
        return true;
    }
  }

  @override
  void initState() {
    super.initState();
    _pageLimitController = TextEditingController(text: widget.config.pageLimit.toString());
    _maxDepthController = TextEditingController();
    
    // Initialize specificUrlsController with existing URLs if available
    _specificUrlsController = TextEditingController(
      text: widget.config.crawlScope == CrawlScope.specificPages && widget.config.specificUrls.isNotEmpty
          ? widget.config.specificUrls.join('\n')
          : ''
    );
    
    // Initialize sitemapUrlsController with existing URLs if available
    _sitemapUrlsController = TextEditingController(
      text: widget.config.crawlScope == CrawlScope.sitemapPages && widget.config.specificUrls.isNotEmpty
          ? widget.config.specificUrls.join('\n')
          : ''
    );
  }

  @override
  void dispose() {
    _pageLimitController.dispose();
    _maxDepthController.dispose();
    _urlListController.dispose();
    _specificUrlsController.dispose();
    _sitemapUrlsController.dispose();
    super.dispose();
  }

  void validatePageLimit(String value) {
    if (value.isEmpty) {
      // Required field
      setState(() {
        widget.config.pageLimit = 100; // Default value
      });
      return;
    }

    final int? limit = int.tryParse(value);
    if (limit != null && limit > 0) {
      // Apply max limit based on user type (using 10,000 as default)
      final int maxLimit = 10000;
      
      setState(() {
        widget.config.pageLimit = limit > maxLimit ? maxLimit : limit;
        if (limit > maxLimit) {
          _pageLimitController.text = maxLimit.toString();
        }
      });
    } else {
      // Invalid input, reset to previous value
      _pageLimitController.text = widget.config.pageLimit.toString();
    }
    widget.onConfigUpdate();
  }

  void validateMaxDepth(String value) {
    if (value.isEmpty) {
      // Optional field
      setState(() {
        widget.config.maxDepth = null;
      });
      return;
    }

    final int? depth = int.tryParse(value);
    if (depth != null && depth >= 1) {
      setState(() {
        widget.config.maxDepth = depth;
      });
    } else {
      // Invalid input
      _maxDepthController.text = widget.config.maxDepth?.toString() ?? '';
    }
    widget.onConfigUpdate();
  }

  Widget _buildInfoTooltip(String message) {
    return Tooltip(
      message: message,
      textStyle: TextStyle(
        color: Theme.of(context).colorScheme.onInverseSurface,
        fontSize: 14
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.inverseSurface,
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Icon(
        Icons.info_outline,
        size: 16,
        color: Colors.grey.shade600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF37618E);
    final TextStyle helpTextStyle = GoogleFonts.notoSans(
      fontSize: 14,
      color: Colors.black87,
    );
    
    final TextStyle labelTextStyle = GoogleFonts.notoSans(
      fontSize: 14,
      color: Colors.black87,
    );
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
          'What do you want to crawl?',
          style: GoogleFonts.notoSans(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Define the scope of your crawl and set limits',
          style: helpTextStyle,
        ),
        const SizedBox(height: 32),

        // Crawl entire website option
        _buildRadioOption(
          title: 'Crawl entire website',
          subtitle: 'Crawl your existing pages and find new ones, within a page limit',
          value: CrawlScope.entireSite,
          groupValue: widget.config.crawlScope,
          onChanged: (value) {
            setState(() {
              widget.config.crawlScope = value;
              widget.onConfigUpdate();
            });
          },
          primaryColor: primaryColor,
        ),
        
        // Show page limit input for entire website option
        if (widget.config.crawlScope == CrawlScope.entireSite) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page limit field with tooltip
                Row(
                  children: [
                    Text(
                      'Page limit',
                      style: labelTextStyle,
                    ),
                    const SizedBox(width: 4),
                    _buildInfoTooltip(
                      'The maximum number of pages that will be crawled. Setting a lower limit is recommended for initial crawls.'
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 360,
                  child: TextField(
                    controller: _pageLimitController,
                    decoration: InputDecoration(
                      hintText: '100',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      alignLabelWithHint: true,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        validatePageLimit(value);
                      }
                    },
                    textAlignVertical: TextAlignVertical.top,
                  ),
                ),
                
                // Max crawl depth field with tooltip
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Max crawl depth limit (optional)',
                      style: labelTextStyle,
                    ),
                    const SizedBox(width: 4),
                    _buildInfoTooltip(
                      'Maximum number of link levels to follow. Lower values prevent crawling too deeply into the site structure.'
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 360,
                  child: TextField(
                    controller: _maxDepthController,
                    decoration: InputDecoration(
                      hintText: 'Enter crawl depth limit',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      alignLabelWithHint: true,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: validateMaxDepth,
                    textAlignVertical: TextAlignVertical.top,
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 16),
        
        // Crawl existing pages option
        _buildRadioOption(
          title: 'Crawl existing pages',
          subtitle: 'Crawl only existing pages without finding new ones',
          value: CrawlScope.currentPages,
          groupValue: widget.config.crawlScope,
          onChanged: (value) {
            setState(() {
              widget.config.crawlScope = value;
              
              // If currentPages is empty, populate with example URLs
              if (widget.config.currentPages.isEmpty) {
                widget.config.currentPages = [
                  'https://csega.hu/',
                  'https://csega.hu/intro/',
                  'https://csega.hu/muvek/',
                  'https://csega.hu/muvek/kotetek',
                  'https://csega.hu/muvek/rovid-prozak',
                  'https://csega.hu/muvek/rovid-prozak/a-tarsulat',
                  'https://csega.hu/muvek/rovid-prozak/gyogyulas',
                  'https://csega.hu/muvek/rovid-prozak/hiena'
                ];
              }
              
              widget.onConfigUpdate();
            });
          },
          primaryColor: primaryColor,
        ),
        
        // URL list field for existing pages (read-only)
        if (widget.config.crawlScope == CrawlScope.currentPages) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 40, right: 16),
            child: SizedBox(
              height: 200, // Fixed height for all containers
              child: TextField(
                controller: _urlListController,
                readOnly: true, // Make it non-editable
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                  alignLabelWithHint: true,
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
          ),
        ],

        const SizedBox(height: 16),
        
        // Crawl specific pages option
        _buildRadioOption(
          title: 'Crawl specific pages',
          subtitle: 'Crawl only the pages you specify',
          value: CrawlScope.specificPages,
          groupValue: widget.config.crawlScope,
          onChanged: (value) {
            setState(() {
              widget.config.crawlScope = value;
              
              // Set default options for specific pages
              widget.config.collectErrorPages = true;
              widget.config.collectRedirectionPages = true;
              widget.config.autoMarkTranslatable = true;
              
              // Remove the auto-population of URLs
              // If user selects this option, they need to explicitly add URLs
              widget.onConfigUpdate();
            });
          },
          primaryColor: primaryColor,
        ),
        
        // URL list field for specific pages
        if (widget.config.crawlScope == CrawlScope.specificPages) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 40, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 200,
                  child: TextField(
                    controller: _specificUrlsController,
                    decoration: InputDecoration(
                      hintText: 'Add URLs (one per line)\nyour/path\n/your/path\nhttp://example.com/path\nhttps://example.com/path',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                      alignLabelWithHint: true,
                    ),
                    maxLines: null,
                    expands: true,
                    onChanged: (value) {
                      setState(() {
                        widget.config.specificUrls = value.split('\n').where((url) => url.trim().isNotEmpty).toList();
                        widget.onConfigUpdate();
                      });
                    },
                    textAlignVertical: TextAlignVertical.top,
                  ),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  value: widget.config.addUnvisitedUrls,
                  onChanged: (value) {
                    setState(() {
                      widget.config.addUnvisitedUrls = value ?? false;
                      widget.onConfigUpdate();
                    });
                  },
                  title: Text(
                    'Also add new URLs not in the list above, if referred, but as "Unvisited"',
                    style: GoogleFonts.notoSans(fontSize: 14),
                  ),
                  subtitle: Text(
                    'Takes precedence over Page Freeze setting',
                    style: GoogleFonts.notoSans(fontSize: 12, color: Colors.grey[600]),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
                CheckboxListTile(
                  value: widget.config.collectErrorPages,
                  onChanged: (value) {
                    setState(() {
                      widget.config.collectErrorPages = value ?? true;
                      widget.onConfigUpdate();
                    });
                  },
                  title: Text(
                    'Collect error pages (HTTP 4XX)',
                    style: GoogleFonts.notoSans(fontSize: 14),
                  ),
                  subtitle: Text(
                    'Turning this option off will mean no indications of missing pages encountered during crawl are given!',
                    style: GoogleFonts.notoSans(fontSize: 12, color: Colors.grey[600]),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
                CheckboxListTile(
                  value: widget.config.collectRedirectionPages,
                  onChanged: (value) {
                    setState(() {
                      widget.config.collectRedirectionPages = value ?? true;
                      widget.onConfigUpdate();
                    });
                  },
                  title: Text(
                    'Collect redirection pages (HTTP 3XX)',
                    style: GoogleFonts.notoSans(fontSize: 14),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
                CheckboxListTile(
                  value: widget.config.autoMarkTranslatable,
                  onChanged: (value) {
                    setState(() {
                      widget.config.autoMarkTranslatable = value ?? true;
                      widget.onConfigUpdate();
                    });
                  },
                  title: Text(
                    'Automatically mark visited resources as translatable',
                    style: GoogleFonts.notoSans(fontSize: 14),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 16),
        
        // Crawl with sitemap option
        _buildRadioOption(
          title: 'Crawl with sitemap',
          subtitle: 'Crawl pages listed in your sitemaps or sitemap index',
          value: CrawlScope.sitemapPages,
          groupValue: widget.config.crawlScope,
          onChanged: (value) {
            setState(() {
              widget.config.crawlScope = CrawlScope.sitemapPages;
              
              // Set default options for sitemap pages
              widget.config.collectErrorPages = true;
              widget.config.collectRedirectionPages = true;
              widget.config.autoMarkTranslatable = true;
              
              widget.onConfigUpdate();
            });
          },
          primaryColor: primaryColor,
        ),
        
        // Sitemap URL field
        if (widget.config.crawlScope == CrawlScope.sitemapPages) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 40, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 200,
                  child: TextField(
                    controller: _sitemapUrlsController,
                    decoration: InputDecoration(
                      hintText: 'Paste a sitemap index URL, or multiple sitemaps:\nhttps://example.com/sitemap_index.xml\nhttps://example.com/post_sitemap1.xml\nhttps://example.com/page_sitemap2.xml',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                      alignLabelWithHint: true,
                    ),
                    maxLines: null,
                    expands: true,
                    onChanged: (value) {
                      setState(() {
                        widget.config.specificUrls = value.split('\n')
                            .where((url) => url.trim().isNotEmpty)
                            .toList();
                        widget.onConfigUpdate();
                      });
                    },
                    textAlignVertical: TextAlignVertical.top,
                  ),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  value: widget.config.addUnvisitedUrls,
                  onChanged: (value) {
                    setState(() {
                      widget.config.addUnvisitedUrls = value ?? false;
                      widget.onConfigUpdate();
                    });
                  },
                  title: Text(
                    'Also add new URLs not in the list above, if referred, but as "Unvisited"',
                    style: GoogleFonts.notoSans(fontSize: 14),
                  ),
                  subtitle: Text(
                    'Takes precedence over Page Freeze setting',
                    style: GoogleFonts.notoSans(fontSize: 12, color: Colors.grey[600]),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
                CheckboxListTile(
                  value: widget.config.collectErrorPages,
                  onChanged: (value) {
                    setState(() {
                      widget.config.collectErrorPages = value ?? true;
                      widget.onConfigUpdate();
                    });
                  },
                  title: Text(
                    'Collect error pages (HTTP 4XX)',
                    style: GoogleFonts.notoSans(fontSize: 14),
                  ),
                  subtitle: Text(
                    'Turning this option off will mean no indications of missing pages encountered during crawl are given!',
                    style: GoogleFonts.notoSans(fontSize: 12, color: Colors.grey[600]),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
                CheckboxListTile(
                  value: widget.config.collectRedirectionPages,
                  onChanged: (value) {
                    setState(() {
                      widget.config.collectRedirectionPages = value ?? true;
                      widget.onConfigUpdate();
                    });
                  },
                  title: Text(
                    'Collect redirection pages (HTTP 3XX)',
                    style: GoogleFonts.notoSans(fontSize: 14),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
                CheckboxListTile(
                  value: widget.config.autoMarkTranslatable,
                  onChanged: (value) {
                    setState(() {
                      widget.config.autoMarkTranslatable = value ?? true;
                      widget.onConfigUpdate();
                    });
                  },
                  title: Text(
                    'Automatically mark visited resources as translatable',
                    style: GoogleFonts.notoSans(fontSize: 14),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRadioOption({
    required String title,
    required String subtitle,
    required CrawlScope value,
    required CrawlScope? groupValue,
    required ValueChanged<CrawlScope?> onChanged,
    required Color primaryColor,
  }) {
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Radio<CrawlScope>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: primaryColor,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.notoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

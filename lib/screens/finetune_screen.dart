import 'package:flutter/material.dart';
import '../models/crawl_config.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

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
  bool _isTweaksExpanded = true;
  bool _isMiscExpanded = true;
  bool _isAdditionalPagesExpanded = true;
  
  // Simultaneous requests value
  final TextEditingController _requestsController = TextEditingController();
  
  // Custom user agent controller
  final TextEditingController _userAgentController = TextEditingController();
  
  // Session cookie controller
  final TextEditingController _sessionCookieController = TextEditingController();
  
  // Bearer token controller
  final TextEditingController _bearerTokenController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the controller with the default value from the config
    _requestsController.text = widget.config.simultaneousRequests.toString(); 
    _userAgentController.text = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0";
    _sessionCookieController.text = widget.config.sessionCookie;
    
    // Use post-frame callback to safely set defaults after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resetToDefaults();
      widget.onConfigUpdate();
    });
  }
  
  @override
  void didUpdateWidget(FinetuneScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // If crawl type or scope has changed, reset the defaults
    if (oldWidget.config.crawlType != widget.config.crawlType || 
        oldWidget.config.crawlScope != widget.config.crawlScope) {
      _resetToDefaults();
      widget.onConfigUpdate();
    }
  }
  
  // Method to set default selections based on crawl type and scope
  void _resetToDefaults() {
    // Different defaults based on crawl type and scope combinations
    if (widget.config.crawlType == CrawlType.discovery) {
      // Common defaults for all Discovery crawl scopes
      widget.config.skipContentTypeCheck = true;
      widget.config.doNotReloadExistingResources = true;
      
      if (widget.config.crawlScope == CrawlScope.entireSite) {
        // Discovery - Entire website
        widget.config.collectHtmlPages = true;  // ONLY set for Entire website
        widget.config.collectErrorPages = true;
      } 
      else if (widget.config.crawlScope == CrawlScope.currentPages) {
        // Discovery - Existing pages
        widget.config.collectHtmlPages = false; // Explicitly NOT selected
        widget.config.collectErrorPages = true;
      } 
      else if (widget.config.crawlScope == CrawlScope.specificPages || 
               widget.config.crawlScope == CrawlScope.sitemapPages) {
        // Discovery - Specific pages or Sitemaps
        widget.config.collectHtmlPages = false; // Explicitly NOT selected
        widget.config.collectErrorPages = true;
        widget.config.collectRedirectionPages = true;
      }
    } 
    else if (widget.config.crawlType == CrawlType.contentExtraction || 
             widget.config.crawlType == CrawlType.tlsContentExtraction ||
             widget.config.crawlType == CrawlType.newContentDetection) {
      
      // Common defaults for all content extraction types
      widget.config.useEtags = true;
      
      if (widget.config.crawlScope == CrawlScope.entireSite) {
        // Content extraction - Entire website
        widget.config.collectHtmlPages = true;
        widget.config.collectErrorPages = true;
      }
      else if (widget.config.crawlScope == CrawlScope.currentPages) {
        // Content extraction - Existing pages
        widget.config.collectHtmlPages = false;
        widget.config.collectErrorPages = true;
      }
      else if (widget.config.crawlScope == CrawlScope.specificPages || 
               widget.config.crawlScope == CrawlScope.sitemapPages) {
        // Content extraction - Specific pages or Sitemaps
        widget.config.collectHtmlPages = false;
        widget.config.collectErrorPages = true;
        widget.config.collectRedirectionPages = true;
      }
    }
    
    // Make sure the scope screen sets auto-mark translatable for specific pages
    // This is handled in the scope screen, not here
  }
  
  @override
  void dispose() {
    _requestsController.dispose();
    _userAgentController.dispose();
    _sessionCookieController.dispose();
    _bearerTokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF37618E);
    final containerWidth = MediaQuery.of(context).size.width - 48; // Accounting for padding
    
    // Check if scan option is selected
    final bool isScanSelected = widget.config.crawlType == CrawlType.contentExtraction || 
                                widget.config.crawlType == CrawlType.tlsContentExtraction;
    
    // Check if different scope modes are selected
    final bool isExistingPagesSelected = widget.config.crawlScope == CrawlScope.currentPages;
    final bool isSpecificPagesSelected = widget.config.crawlScope == CrawlScope.specificPages;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and description
        Text(
          'Fine-tune your crawl',
          style: GoogleFonts.notoSans(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Configure advanced settings for your crawl',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 24),

        // Resources to collect section
        _buildExpandableSection(
          title: 'Collect selected resource types',
          subtitle: 'Choose which types of resources the crawler should collect',
          isExpanded: _isResourcesExpanded,
          onToggle: () => setState(() => _isResourcesExpanded = !_isResourcesExpanded),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main resource types
              _buildCheckboxOption(
                title: 'New HTML pages',
                value: widget.config.collectHtmlPages,
                onChanged: (value) {
                  _handleResourceDependencies('html', value);
                },
              ),
              _buildCheckboxOption(
                title: 'New JS, JSON, XML, CSS resources',
                value: widget.config.collectJsCssResources,
                onChanged: (value) {
                  _handleResourceDependencies('js_css', value);
                },
              ),
              _buildCheckboxOption(
                title: 'New images, binary resources',
                value: widget.config.collectImages,
                onChanged: (value) {
                  _handleResourceDependencies('images_binary', value);
                },
              ),
              _buildCheckboxOption(
                title: 'Resources from external domains',
                value: widget.config.collectExternalDomains,
                onChanged: (value) {
                  _handleResourceDependencies('external', value);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Additional pages to process section
        _buildExpandableSection(
          title: 'Collection of non-standard pages',
          subtitle: 'Choose what non-standard pages like error pages and redirects should be collected during the crawl.',
          isExpanded: _isAdditionalPagesExpanded,
          onToggle: () => setState(() => _isAdditionalPagesExpanded = !_isAdditionalPagesExpanded),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCheckboxOption(
                title: 'Error pages (HTTP 4XX)',
                subtitle: 'Turning this option off will mean no indications of missing pages encountered during crawl are given!',
                value: widget.config.collectErrorPages,
                onChanged: (value) {
                  _handleResourceDependencies('error', value);
                },
              ),
              _buildCheckboxOption(
                title: 'Redirection pages (HTTP 3XX)',
                value: widget.config.collectRedirectionPages,
                onChanged: (value) {
                  _handleResourceDependencies('redirection', value);
                },
              ),
              _buildCheckboxOption(
                title: 'Short links (e.g. https://www.example.com/?p=123456)',
                value: widget.config.collectShortLinks,
                onChanged: (value) {
                  _handleResourceDependencies('short_links', value);
                },
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Tweaks section
        _buildExpandableSection(
          title: 'Tweaks',
          subtitle: 'Configure how the crawler processes and handles content',
          isExpanded: _isTweaksExpanded,
          onToggle: () => setState(() => _isTweaksExpanded = !_isTweaksExpanded),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Skip content type check
              _buildCheckboxOption(
                title: 'Skip content type check if already determined',
                value: widget.config.skipContentTypeCheck,
                onChanged: (value) {
                  setState(() {
                    widget.config.skipContentTypeCheck = value ?? false;
                    widget.onConfigUpdate();
                  });
                },
              ),

              // Don't reload existing resources - now a completely independent option
              _buildCheckboxOption(
                title: 'Do not reload existing resources',
                value: widget.config.doNotReloadExistingResources,
                onChanged: (value) {
                  setState(() {
                    widget.config.doNotReloadExistingResources = value ?? false;
                    widget.onConfigUpdate();
                  });
                },
              ),
              
              // Use ETags from last crawl
              _buildCheckboxOption(
                title: 'Use ETags from last crawl',
                value: widget.config.useEtags,
                onChanged: (value) {
                  setState(() {
                    widget.config.useEtags = value ?? false;
                    widget.onConfigUpdate();
                  });
                },
              ),

              const SizedBox(height: 24),

              // Limit number of simultaneous requests
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Limit number of simultaneous requests (1-8)',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 60,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _requestsController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                            ),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            errorStyle: GoogleFonts.notoSans(
                              fontSize: 0,
                              height: 0,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (value) {
                            setState(() {
                              _handleRequestsInput(value);
                            });
                          },
                        ),
                        if (!_validateRequestsInput(_requestsController.text) && _requestsController.text.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Maximum value is 8',
                              style: GoogleFonts.notoSans(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Miscellaneous section
        _buildExpandableSection(
          title: 'Miscellaneous',
          subtitle: 'Configure authentication and custom request settings for the crawl',
          isExpanded: _isMiscExpanded,
          onToggle: () => setState(() => _isMiscExpanded = !_isMiscExpanded),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom user agent
              Text(
                'Custom user agent',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Optionally override the crawler\'s default user agent with one of your choice',
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _userAgentController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Session Cookie
              Text(
                'Session cookie',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Login to the site and copy-paste the token of your session cookie',
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _sessionCookieController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    widget.config.sessionCookie = value;
                    widget.onConfigUpdate();
                  });
                },
              ),
              
              const SizedBox(height: 24),
              
              // Bearer Token
              Text(
                'Bearer token',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Bearer tokens can be used to access protected resources',
                style: GoogleFonts.notoSans(
                  fontSize: 12,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _bearerTokenController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildExpandableSection({
    required String title,
    required String subtitle,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width - 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          InkWell(
            onTap: onToggle,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
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
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.black87,
                  ),
                ],
              ),
            ),
          ),
          
          // Content
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                bottom: 16.0,
              ),
              child: child,
            ),
        ],
      ),
    );
  }
  
  Widget _buildCheckboxOption({
    required String title,
    required bool value,
    required Function(bool?) onChanged,
    bool isDisabled = false,
    String? subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: value,
              onChanged: isDisabled ? null : onChanged,
              activeColor: const Color(0xFF37618E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: isDisabled ? Colors.black45 : Colors.black87,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Resources collection section
  void _handleResourceDependencies(String resourceType, bool? value) {
    setState(() {
      if (resourceType == 'images_binary') {
        final newValue = value ?? false;
        
        // When images are selected, JS/JSON/XML/CSS must also be selected
        widget.config.collectImages = newValue;
        widget.config.collectBinaryResources = newValue;
        
        if (newValue) {
          // Force JS/JSON/XML/CSS to be selected when images are selected
          widget.config.collectJsCssResources = true;
        }
        // If turning off, don't change the JS/CSS resources state
      } else if (resourceType == 'js_css') {
        widget.config.collectJsCssResources = value ?? false;
        
        // If turning off JS/CSS but images are on, don't allow it
        if (widget.config.collectImages && !widget.config.collectJsCssResources) {
          widget.config.collectJsCssResources = true;
        }
      } else if (resourceType == 'html') {
        widget.config.collectHtmlPages = value ?? false;
      } else if (resourceType == 'external') {
        widget.config.collectExternalDomains = value ?? false;
      } else if (resourceType == 'error') {
        widget.config.collectErrorPages = value ?? false;
      } else if (resourceType == 'redirection') {
        widget.config.collectRedirectionPages = value ?? false;
      } else if (resourceType == 'short_links') {
        widget.config.collectShortLinks = value ?? false;
      }
      
      widget.onConfigUpdate();
    });
  }

  bool _validateRequestsInput(String value) {
    if (value.isEmpty) return true;
    try {
      final intValue = int.parse(value);
      return intValue >= 1 && intValue <= 8;
    } catch (e) {
      return false;
    }
  }

  void _handleRequestsInput(String value) {
    setState(() {
      if (value.isEmpty) {
        widget.config.simultaneousRequests = 5; // Default value
      } else if (_validateRequestsInput(value)) {
        widget.config.simultaneousRequests = int.parse(value);
      }
      widget.onConfigUpdate();
    });
  }
}

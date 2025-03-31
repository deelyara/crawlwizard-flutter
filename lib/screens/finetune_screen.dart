import 'package:flutter/material.dart';
import '../models/crawl_config.dart';
import 'package:google_fonts/google_fonts.dart';

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
  bool _isWorkPackageExpanded = true;
  bool _isMiscExpanded = true;
  
  // Simultaneous requests value
  final TextEditingController _requestsController = TextEditingController();
  
  // Work package entries
  final TextEditingController _entriesController = TextEditingController();
  
  // Custom user agent controller
  final TextEditingController _userAgentController = TextEditingController();
  
  // Session cookie controller
  final TextEditingController _sessionCookieController = TextEditingController();
  
  // Bearer token controller
  final TextEditingController _bearerTokenController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _requestsController.text = widget.config.simultaneousRequests.toString();
    _userAgentController.text = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0";
    _sessionCookieController.text = widget.config.sessionCookie;
    
    // Setting the defaults for the options
    widget.config.skipContentTypeCheck = true; // Enabled by default
    widget.config.useEtags = false; // Disabled by default
  }
  
  @override
  void dispose() {
    _requestsController.dispose();
    _entriesController.dispose();
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
          style: GoogleFonts.roboto(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Configure advanced settings for your crawl',
          style: GoogleFonts.roboto(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 24),

        // Resources to collect section
        _buildExpandableSection(
          title: 'Resources to collect',
          subtitle: 'Configure which resources to collect during the crawl',
          isExpanded: _isResourcesExpanded,
          onToggle: () => setState(() => _isResourcesExpanded = !_isResourcesExpanded),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Common resources',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

                      // Scope-specific options that appear at the top of the list
                      if (isExistingPagesSelected)
                        _buildCheckboxOption(
                          title: 'Also crawl new URLs not in the list',
                          value: widget.config.crawlNewUrlsNotInList,
                        onChanged: (value) {
                          setState(() {
                              widget.config.crawlNewUrlsNotInList = value ?? false;
                            widget.onConfigUpdate();
                          });
                        },
                      ),

                      if (isSpecificPagesSelected)
                        _buildCheckboxOption(
                          title: 'Also add new URLs not in the list above, if referred, but as "Unvisited"',
                          value: widget.config.includeNewUrls,
                        onChanged: (value) {
                          setState(() {
                              widget.config.includeNewUrls = value ?? false;
                            widget.onConfigUpdate();
                          });
                        },
                      ),

                      // HTML pages
              _buildCheckboxOption(
                title: 'Collect new HTML pages',
                        value: widget.config.collectHtmlPages,
                onChanged: (value) => _handleResourceDependencies('html', value),
                      ),

                      // JS, CSS resources
              _buildCheckboxOption(
                title: 'Collect new JS, JSON, XML, CSS resources',
                        value: widget.config.collectJsCssResources,
                onChanged: (value) => _handleResourceDependencies('js_css', value),
                isDisabled: widget.config.collectImages || widget.config.collectBinaryResources,
              ),
              
              // Images and binary resources combined
              _buildCheckboxOption(
                title: 'Collect new images, binary resources',
                value: widget.config.collectImages || widget.config.collectBinaryResources,
                onChanged: (value) => _handleResourceDependencies('images_binary', value),
              ),
              
              // Resources from external domains
              _buildCheckboxOption(
                title: 'Collect resources from external domains too',
                value: widget.config.collectExternalDomains,
                onChanged: (value) => _handleResourceDependencies('external', value),
              ),

                      // Error pages
              _buildCheckboxOption(
                title: 'Collect error pages (HTTP 4XX) - Missing pages will not be reported if off',
                        value: widget.config.collectErrorPages,
                onChanged: (value) => _handleResourceDependencies('error', value),
                      ),

                      // Redirection pages
              _buildCheckboxOption(
                title: 'Collect redirection pages (HTTP 3XX)',
                        value: widget.config.collectRedirectionPages,
                onChanged: (value) => _handleResourceDependencies('redirection', value),
                      ),

                      // Short links
              _buildCheckboxOption(
                title: 'Collect short links (e.g. https://www.example.com/?p=123456)',
                        value: widget.config.collectShortLinks,
                onChanged: (value) => _handleResourceDependencies('short_links', value),
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
              Text(
                'Common resources',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              
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
                    'Limit number of simultaneous requests',
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 60,
                    child: TextField(
                      controller: _requestsController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                        onChanged: (value) {
                        final intValue = int.tryParse(value);
                        if (intValue != null && intValue > 0 && intValue <= 8) {
                          setState(() {
                            widget.config.simultaneousRequests = intValue;
                            widget.onConfigUpdate();
                          });
                        }
                      },
                    ),
                  ),
                        ],
                      ),
                    ],
                  ),
                ),
        
        // Work package section (only show when scan is selected)
        if (isScanSelected) ...[
          const SizedBox(height: 32),
          
          _buildExpandableSection(
            title: 'Work package',
            subtitle: 'The Work package will contain every entry, not just the new ones',
            isExpanded: _isWorkPackageExpanded,
            onToggle: () => setState(() => _isWorkPackageExpanded = !_isWorkPackageExpanded),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Generate Work package for the crawl
                _buildCheckboxOption(
                  title: 'Generate Work package for the crawl',
                  value: false, // Not selected by default
                  onChanged: (value) {
                    // Now we allow changes
                    setState(() {
                      // Update any work package related configuration
                      widget.onConfigUpdate();
                    });
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Split package by every X entries
                Row(
                  children: [
                    Text(
                      'Split package by every',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 60,
                      child: TextField(
                        controller: _entriesController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'entries',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        
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
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
                      Text(
                'Optionally override the crawler\'s default user agent with one of your choice',
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  color: Colors.black54,
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
                'Session Cookie',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
                      Text(
                'Login to the site and copy-paste the token of your session cookie',
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  color: Colors.black54,
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
                'Bearer Token',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Bearer tokens can be used to access protected resources',
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  color: Colors.black54,
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
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: Colors.black54,
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
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
            child: Text(
                      title,
              style: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: isDisabled ? Colors.black45 : Colors.black87,
              ),
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
}

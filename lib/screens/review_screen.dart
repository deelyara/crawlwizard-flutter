import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/crawl_config.dart';
import '../widgets/information_tooltip.dart';

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
  bool _showPreview = false;
  bool _isNoteFocused = false;

  // Sample data for testing restrictions display
  final List<String> _projectIncludePrefixes = ['/blog', '/news'];
  final List<String> _projectExcludePrefixes = ['/about', '/contact'];
  final List<String> _tempIncludePrefixes = ['/product', '/category'];
  final List<String> _tempExcludePrefixes = ['/admin', '/login'];

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.config.userNote ?? '');
    
    // Add sample data to config if empty (for testing purposes)
    if (widget.config.includePrefixes.isEmpty) {
      widget.config.includePrefixes = [..._projectIncludePrefixes, ..._tempIncludePrefixes];
    }
    if (widget.config.excludePrefixes.isEmpty) {
      widget.config.excludePrefixes = [..._projectExcludePrefixes, ..._tempExcludePrefixes];
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = const Color(0xFF37618E);
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and description
          Text(
            'Review and start crawl',
            style: GoogleFonts.notoSans(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Review your configuration settings before starting the crawl.',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          
          // Note field with markdown preview
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  _buildSectionHeader(context, 'Notes', hideEditButton: true),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _showPreview = !_showPreview;
                      });
                    },
                    icon: Icon(
                      _showPreview ? Icons.edit : Icons.preview,
                      size: 16,
                      color: primaryColor,
                    ),
                    label: Text(
                      _showPreview ? 'Edit' : 'Preview',
                      style: GoogleFonts.notoSans(
                        color: primaryColor,
                        fontSize: 14,
                      ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              // Fixed outline for notes section
              _showPreview 
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        width: 1.0,
                      ),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _showPreview = false;
                        });
                      },
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 150),
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        child: _noteController.text.isEmpty
                            ? Text(
                                'No notes added',
                                style: GoogleFonts.notoSans(
                                  fontSize: 14,
                                  color: Colors.black38,
                                ),
                              )
                            : Markdown(
                                data: _noteController.text,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                              ),
                      ),
                    ),
                  )
                : TextField(
                    controller: _noteController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: 'Add notes about this crawl (supports markdown)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: primaryColor, width: 2),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                    onChanged: (value) {
                      widget.config.userNote = value;
                      widget.onConfigUpdate();
                    },
                  ),
            ],
          ),
          
          Divider(color: Colors.grey.shade300, height: 32),

          // Type section
          _buildSectionHeader(context, 'Crawl type'),
          _buildTypeContent(context),
          
          Divider(color: Colors.grey.shade300, height: 32),

          // Scope section
          _buildSectionHeader(context, 'Scope'),
          _buildScopeContent(context),
          
          Divider(color: Colors.grey.shade300, height: 32),

          // Restrictions section
          _buildSectionHeader(context, 'Restrictions'),
          _buildRestrictionsContent(context),
          
          Divider(color: Colors.grey.shade300, height: 32),

          // Origin Snapshot section
          _buildSectionHeader(context, 'Snapshot'),
          _buildSnapshotContent(context),
          
          Divider(color: Colors.grey.shade300, height: 32),

          // Fine-tune section
          _buildSectionHeader(context, 'Fine-tune'),
          _buildFinetuneContent(context),
          
          Divider(color: Colors.grey.shade300, height: 32),

          // Recurrence section
          _buildSectionHeader(context, 'Recurrence'),
          _buildRecurrenceContent(context),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, 
    String title, 
    {bool hideEditButton = false}
  ) {
    final primaryColor = const Color(0xFF37618E);
    final int stepIndex = _getStepIndex(title);
    
    return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
          style: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        if (!hideEditButton && stepIndex >= 0)
          IconButton(
            onPressed: () => widget.onEditStep(stepIndex),
                  icon: const Icon(Icons.edit, size: 16),
            color: primaryColor,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Edit',
          ),
      ],
    );
  }

  int _getStepIndex(String title) {
    switch (title) {
      case 'Crawl type': return 0;
      case 'Scope': return 1;
      case 'Restrictions': return 2;
      case 'Snapshot': return 3;
      case 'Fine-tune': return 4;
      case 'Recurrence': return 5;
      default: return -1;
    }
  }

  Widget _buildTypeContent(BuildContext context) {
    String crawlTypeText = '';

    if (widget.config.crawlType == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          'No crawl type selected',
          style: GoogleFonts.notoSans(fontSize: 14, color: Colors.red),
        ),
      );
    }

    switch (widget.config.crawlType) {
      case CrawlType.discovery:
        crawlTypeText = 'Discovery crawl';
        break;
      case CrawlType.contentExtraction:
        crawlTypeText = 'Content extraction';
        break;
      case CrawlType.newContentDetection:
        crawlTypeText = 'New content detection';
        break;
      case CrawlType.tlsContentExtraction:
        crawlTypeText = 'Target language specific (TLS) content extraction';
        break;
      case null: // This should never be reached due to the if check above
        crawlTypeText = 'No type selected';
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          Text(
            crawlTypeText,
            style: GoogleFonts.notoSans(fontSize: 14, color: Colors.black87),
          ),
        if (widget.config.prerenderPages) ...[
          const SizedBox(height: 8),
            Text(
              'Prerender pages: Yes',
              style: GoogleFonts.notoSans(fontSize: 14, color: Colors.black87),
            ),
          ],
        ],
      ),
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
      case CrawlScope.sitemapPages:
        scopeText = 'Crawl with sitemap';
        break;
      case CrawlScope.targetLanguageSpecific:
        scopeText = 'Crawl target language specific content';
        break;
      default:
        scopeText = 'No scope selected';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            scopeText,
            style: GoogleFonts.notoSans(fontSize: 14, color: Colors.black87),
          ),
          if (widget.config.crawlScope == CrawlScope.targetLanguageSpecific && widget.config.targetLanguages.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Target languages:',
              style: GoogleFonts.notoSans(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...widget.config.targetLanguages.map((lang) => Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        lang,
                        style: GoogleFonts.notoSans(fontSize: 14, color: Colors.black87),
                      ),
                    )).toList(),
                    if (widget.config.crawlWithoutTargetLanguage) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Also crawl with no target language specified',
                        style: GoogleFonts.notoSans(fontSize: 14, color: Colors.black87, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
          if (widget.config.crawlScope == CrawlScope.currentPages) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.config.currentPages.isNotEmpty 
                      ? widget.config.currentPages.map((page) => Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            page,
                            style: GoogleFonts.notoSans(fontSize: 14, color: Colors.black87),
                          ),
                        )).toList()
                      : [
                          Text(
                            'No pages specified',
                            style: GoogleFonts.notoSans(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                  ),
                ),
              ),
            ),
          ],
          if (widget.config.crawlScope == CrawlScope.specificPages) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.config.specificUrls.isNotEmpty 
                      ? widget.config.specificUrls.map((page) => Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            page,
                            style: GoogleFonts.notoSans(fontSize: 14, color: Colors.black87),
                          ),
                        )).toList()
                      : [
                          Text(
                            'No pages specified',
                            style: GoogleFonts.notoSans(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                  ),
                ),
              ),
            ),
            if (widget.config.addUnvisitedUrls) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.check,
                    size: 16,
                    color: Color(0xFF37618E),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Also add new URLs not in the list above, if referred, but as "Unvisited"',
                    style: GoogleFonts.notoSans(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ],
          ],
          if (widget.config.crawlScope == CrawlScope.sitemapPages) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.config.specificUrls.isNotEmpty 
                      ? widget.config.specificUrls.map((page) => Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            page,
                            style: GoogleFonts.notoSans(fontSize: 14, color: Colors.black87),
                          ),
                        )).toList()
                      : [
                          Text(
                            'No sitemaps specified',
                            style: GoogleFonts.notoSans(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                  ),
                ),
              ),
            ),
            if (widget.config.addUnvisitedUrls) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.check,
                    size: 16,
                    color: Color(0xFF37618E),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Also add new URLs not in the list above, if referred, but as "Unvisited"',
                    style: GoogleFonts.notoSans(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ],
          ],
          if (widget.config.crawlScope == CrawlScope.entireSite) ...[
            const SizedBox(height: 8),
            Text(
              'Page limit: ${widget.config.pageLimit}',
              style: GoogleFonts.notoSans(fontSize: 14, color: Colors.black87),
            ),
            if (widget.config.maxDepth != null) ...[
              const SizedBox(height: 8),
              Text(
                'Max crawl depth: ${widget.config.maxDepth}',
                style: GoogleFonts.notoSans(fontSize: 14, color: Colors.black87),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildRestrictionsContent(BuildContext context) {
    // Get restrictions from the actual config
    List<String> includePrefixes = widget.config.includePrefixes;
    List<String> excludePrefixes = widget.config.excludePrefixes;
    List<String> regexRestrictions = widget.config.regexRestrictions;
    
    bool hasIncludes = includePrefixes.isNotEmpty;
    bool hasExcludes = excludePrefixes.isNotEmpty;
    bool hasRegexRestrictions = regexRestrictions.isNotEmpty;

    if (!hasIncludes && !hasExcludes && !hasRegexRestrictions) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          'No restrictions set.',
          style: GoogleFonts.notoSans(fontSize: 14, color: Colors.black87),
        ),
      );
    }

    // Filter the config's prefixes into existing and temporary
    // In a real implementation, there would be a way to distinguish these
    // For now we'll simulate this with a split of the existing lists
    final List<String> existingIncludePrefixes = includePrefixes.take(includePrefixes.length ~/ 2).toList();
    final List<String> tempIncludePrefixes = includePrefixes.skip(includePrefixes.length ~/ 2).toList();
    
    final List<String> existingExcludePrefixes = excludePrefixes.take(excludePrefixes.length ~/ 2).toList();
    final List<String> tempExcludePrefixes = excludePrefixes.skip(excludePrefixes.length ~/ 2).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Existing restrictions container
          if (existingIncludePrefixes.isNotEmpty || existingExcludePrefixes.isNotEmpty) ...[
            _buildPathRestrictionsSubContainer(
              context,
              "Existing project restrictions",
              existingIncludePrefixes,
              existingExcludePrefixes,
              includeDeDePrefix: true
            ),
            const SizedBox(height: 16),
          ],
          
          // Temporary restrictions container
          if (tempIncludePrefixes.isNotEmpty || tempExcludePrefixes.isNotEmpty) ...[
            _buildPathRestrictionsSubContainer(
              context,
              "Temporary restrictions for this crawl",
              tempIncludePrefixes,
              tempExcludePrefixes
            ),
            const SizedBox(height: 16),
          ],
          
          // Regex restrictions container
          if (hasRegexRestrictions) ...[
            _buildRegexRestrictionsContainer(
              context,
              'Regular expression restrictions',
              regexRestrictions
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildPathRestrictionsSubContainer(
    BuildContext context,
    String title,
    List<String> includePrefixes,
    List<String> excludePrefixes,
    {bool includeDeDePrefix = false}
  ) {
    bool hasIncludes = includePrefixes.isNotEmpty;
    bool hasExcludes = excludePrefixes.isNotEmpty;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          // Container title
          Text(
            title,
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          
          // Include prefixes
          if (hasIncludes) ...[
            Text(
              'Crawl pages starting with:',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: includePrefixes.map((prefix) {
                final displayText = '$prefix*';
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12, 
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBDCF6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check,
                        size: 16,
                        color: Color(0xFF191C20),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        displayText,
                        style: GoogleFonts.notoSans(
                          color: const Color(0xFF191C20),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
          
          if (hasIncludes && hasExcludes) const SizedBox(height: 16),
          
          // Exclude prefixes
          if (hasExcludes || includeDeDePrefix) ...[
            Text(
              'Don\'t crawl pages starting with:',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (includeDeDePrefix)
                  _buildLockedDeDeChip(),
                ...excludePrefixes.map((prefix) {
                  final displayText = '$prefix*';
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12, 
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBDCF6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check,
                          size: 16,
                          color: Color(0xFF191C20),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          displayText,
                          style: GoogleFonts.notoSans(
                            color: const Color(0xFF191C20),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildRegexRestrictionsContainer(
    BuildContext context,
    String title,
    List<String> regexRestrictions
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Container title
          Text(
            title,
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          
          // Regex patterns
          ...regexRestrictions.map((regex) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(
                horizontal: 12, 
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFCBDCF6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check,
                    size: 16,
                    color: Color(0xFF191C20),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    regex,
                    style: GoogleFonts.notoSansMono(
                      color: const Color(0xFF191C20),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // Special widget for the locked /de_de/* restriction
  Widget _buildLockedDeDeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12, 
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFCBDCF6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.lock,
            size: 16,
            color: Color(0xFF191C20),
          ),
          const SizedBox(width: 6),
          Text(
            '/de_de*',
            style: GoogleFonts.notoSans(
              color: const Color(0xFF191C20),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSnapshotContent(BuildContext context) {
    String snapshotText = '';
    bool useSnapshot = widget.config.snapshotOption != SnapshotOption.rebuildAll;

    // Use the original option titles from the snapshot screen based on the selected option and storeNewPages value
    if (useSnapshot) {
      // Option 1 or 2 was selected
      if (widget.config.storeNewPages) {
        snapshotText = 'Reuse existing pages and store new pages';
      } else {
        snapshotText = 'Reuse existing pages and don\'t store new pages';
      }
    } else {
      // Option 3 was selected
      snapshotText = 'Don\'t reuse existing pages, update/store all encountered pages';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            snapshotText,
            style: GoogleFonts.notoSans(fontSize: 14, color: Colors.black87),
          ),
          if (widget.config.selectedSnapshot.isNotEmpty && useSnapshot) ...[
            const SizedBox(height: 8),
            Text(
              'Selected snapshot: ${widget.config.selectedSnapshot}',
              style: GoogleFonts.notoSans(fontSize: 14, color: Colors.black87),
            ),
          ],
          if (widget.config.buildLocalCache) ...[
            const SizedBox(height: 8),
            Text(
              'Build local cache: Yes',
              style: GoogleFonts.notoSans(fontSize: 14, color: Colors.black87),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFinetuneContent(BuildContext context) {
    List<String> resources = [];
    if (widget.config.collectHtmlPages) resources.add('HTML pages');
    if (widget.config.collectJsCssResources) resources.add('JS/CSS resources');
    if (widget.config.collectImages) resources.add('Images');
    if (widget.config.collectBinaryResources) resources.add('Binary resources');
    
    // Non-standard pages
    List<String> nonStandardPages = [];
    if (widget.config.collectErrorPages) nonStandardPages.add('Error pages');
    if (widget.config.collectRedirectionPages) nonStandardPages.add('Redirection pages');
    if (widget.config.collectShortLinks) nonStandardPages.add('Short links');
    if (widget.config.collectExternalDomains) resources.add('External domain resources');

    // Additional crawl settings
    List<String> additionalSettings = [];
    if (widget.config.skipContentTypeCheck) additionalSettings.add('Skip content-type check');
    if (widget.config.doNotReloadExistingResources) additionalSettings.add('Do not reload existing resources');
    if (widget.config.useEtags) additionalSettings.add('Use ETags');
    if (widget.config.crawlNewUrlsNotInList) additionalSettings.add('Crawl new URLs not in list');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          // Resources to collect
          if (resources.isNotEmpty) ...[
            Text(
          'Resources to collect:',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            ...resources.map((resource) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.check,
                    size: 16,
                    color: Color(0xFF37618E),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    resource,
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ] else ...[
            Text(
              'No resources selected',
              style: GoogleFonts.notoSans(fontSize: 14, color: Colors.black87),
            ),
          ],

          // Non-standard pages
          if (nonStandardPages.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Collection of non-standard pages:',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            ...nonStandardPages.map((page) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.check,
                    size: 16,
                    color: Color(0xFF37618E),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    page,
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],

          // Additional settings
          if (additionalSettings.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Tweaks:',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            ...additionalSettings.map((setting) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.check,
                    size: 16,
                    color: Color(0xFF37618E),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    setting,
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],

          const SizedBox(height: 12),
          Text(
            'Simultaneous requests: ${widget.config.simultaneousRequests}',
            style: GoogleFonts.notoSans(fontSize: 14, color: Colors.black87),
          ),

        if (widget.config.sessionCookie.isNotEmpty) ...[
          const SizedBox(height: 8),
            Text(
              'Session cookie: Set',
              style: GoogleFonts.notoSans(fontSize: 14, color: Colors.black87),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecurrenceContent(BuildContext context) {
    if (widget.config.recurrenceFrequency == RecurrenceFrequency.none) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          'No recurring crawls scheduled',
          style: GoogleFonts.notoSans(fontSize: 14, color: Colors.black87),
        ),
      );
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
        frequencyText = 'Every ${widget.config.recurrenceCustomDays} days';
        break;
      case RecurrenceFrequency.none:
        frequencyText = 'No recurring crawls';
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          Text(
            frequencyText,
            style: GoogleFonts.notoSans(fontSize: 14, color: Colors.black87),
          ),
          
          if (widget.config.firstScheduledCrawlDate != null) ...[
            const SizedBox(height: 8),
            Text(
              'First scheduled crawl: ${_formatDate(widget.config.firstScheduledCrawlDate!)}',
              style: GoogleFonts.notoSans(fontSize: 14, color: Colors.black87),
            ),
          ],

        if (widget.config.useRotatingSnapshots &&
            widget.config.selectedRotatingSnapshots.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
            'Rotating snapshots:',
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
          ),
          const SizedBox(height: 4),
          ...widget.config.selectedRotatingSnapshots.map(
              (snapshot) => Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  '• $snapshot',
                  style: GoogleFonts.notoSans(fontSize: 14, color: Colors.black87),
                ),
              ),
          ),
        ],
      ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

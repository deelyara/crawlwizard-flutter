// File: lib/screens/type_screen.dart
import 'package:flutter/material.dart';
import '../models/crawl_config.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

class TypeScreen extends StatefulWidget {
  final CrawlConfig config;
  final VoidCallback onConfigUpdate;

  const TypeScreen({
    super.key,
    required this.config,
    required this.onConfigUpdate,
  });

  @override
  State<TypeScreen> createState() => _TypeScreenState();
}

class _TypeScreenState extends State<TypeScreen> {
  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF266DAF);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What do you need to do with your content?',
          style: GoogleFonts.roboto(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose based on where you are in your translation process',
          style: GoogleFonts.roboto(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 32),

        // Radio options
        _buildRadioOption(
          title: 'Discovery crawl',
          subtitle: 'Maps site structure and count words without storing content',
          value: CrawlType.discovery,
          groupValue: widget.config.crawlType,
          onChanged: (value) {
            setState(() {
              widget.config.crawlType = value;
              widget.onConfigUpdate();
            });
          },
          primaryColor: primaryColor,
        ),
        const SizedBox(height: 16),

        _buildRadioOption(
          title: 'Content extraction',
          subtitle: 'Extracts and stores content for translation. Uses your subscription word quota',
          value: CrawlType.contentExtraction,
          groupValue: widget.config.crawlType,
          onChanged: (value) {
            setState(() {
              widget.config.crawlType = value;
              widget.onConfigUpdate();
            });
          },
          primaryColor: primaryColor,
        ),
        if (widget.config.crawlType == CrawlType.contentExtraction) ...[
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: widget.config.generateWorkPackages,
                        onChanged: (value) {
                          setState(() {
                            widget.config.generateWorkPackages = value ?? false;
                            widget.onConfigUpdate();
                          });
                        },
                        activeColor: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Generate work package for this crawl',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                if (widget.config.generateWorkPackages) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const SizedBox(width: 32),
                      Text(
                        'Split package by every',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: '100',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            isDense: true,
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (value) {
                            final entries = int.tryParse(value);
                            if (entries != null && entries > 0) {
                              setState(() {
                                widget.config.entriesPerPackage = entries;
                                widget.onConfigUpdate();
                              });
                            }
                          },
                          controller: TextEditingController(
                            text: widget.config.entriesPerPackage.toString(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'entries',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),

        _buildRadioOption(
          title: 'New content detection',
          subtitle: 'Counts words in new content without storing translatable content',
          value: CrawlType.newContentDetection,
          groupValue: widget.config.crawlType,
          onChanged: (value) {
            setState(() {
              widget.config.crawlType = value;
              widget.onConfigUpdate();
            });
          },
          primaryColor: primaryColor,
        ),
        const SizedBox(height: 16),

        _buildRadioOption(
          title: 'Target language specific (TLS) content extraction',
          subtitle: 'Crawls the website multiple times, once for each target language',
          value: CrawlType.tlsContentExtraction,
          groupValue: widget.config.crawlType,
          onChanged: (value) {
            setState(() {
              widget.config.crawlType = value;
              widget.onConfigUpdate();
            });
          },
          primaryColor: primaryColor,
        ),
        if (widget.config.crawlType == CrawlType.tlsContentExtraction) ...[
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                
                // Language selection group
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header inside container
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                        child: Text(
                          'Crawl separately for the following target languages:',
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    
                      // Language dropdown
                      Container(
                        width: 360,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                            listTileTheme: const ListTileThemeData(
                              dense: true,
                              visualDensity: VisualDensity(horizontal: 0, vertical: -2),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                            ),
                          ),
                          child: ExpansionTile(
                            title: Text(
                              'Select language(s)',
                              style: GoogleFonts.roboto(fontSize: 14),
                            ),
                            childrenPadding: const EdgeInsets.only(bottom: 8),
                            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                            expandedCrossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Search...',
                                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      borderSide: BorderSide(color: Colors.grey.shade300),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    isDense: true,
                                  ),
                                ),
                              ),
                              const Divider(height: 1, thickness: 1, indent: 16, endIndent: 16),
                              const SizedBox(height: 4),
                              // Language list items with improved spacing
                              ...['af-ZA', 'ar-AE', 'ar-BH'].map((lang) {
                                final Map<String, dynamic> langData = {
                                  'af-ZA': {
                                    'name': 'Afrikaans (South Africa)',
                                    'flag': 'https://flagcdn.com/w40/za.png'
                                  },
                                  'ar-AE': {
                                    'name': 'Arabic (United Arab Emirates)',
                                    'flag': 'https://flagcdn.com/w40/ae.png'
                                  },
                                  'ar-BH': {
                                    'name': 'Arabic (Bahrain)',
                                    'flag': 'https://flagcdn.com/w40/bh.png'
                                  },
                                };
                                
                                return CheckboxListTile(
                                  title: Row(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage(langData[lang]['flag']),
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          '${langData[lang]['name']} | $lang',
                                          style: GoogleFonts.roboto(fontSize: 14),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  value: widget.config.targetLanguages.contains(lang),
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value ?? false) {
                                        widget.config.targetLanguages.add(lang);
                                      } else {
                                        widget.config.targetLanguages.remove(lang);
                                      }
                                      widget.onConfigUpdate();
                                    });
                                  },
                                  dense: true,
                                  visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                  controlAffinity: ListTileControlAffinity.leading,
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),
                      
                      // No target language option
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: CheckboxListTile(
                          title: Text(
                            'Also crawl with no target language specified',
                            style: GoogleFonts.roboto(fontSize: 14),
                          ),
                          value: widget.config.crawlWithoutTargetLanguage,
                          onChanged: (bool? value) {
                            setState(() {
                              widget.config.crawlWithoutTargetLanguage = value ?? false;
                              widget.onConfigUpdate();
                            });
                          },
                          dense: true,
                          visualDensity: const VisualDensity(horizontal: -4, vertical: -2),
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ),
                      
                      // Info banner inside the language container - only show if languages are selected
                      if (widget.config.targetLanguages.isNotEmpty || widget.config.crawlWithoutTargetLanguage) ...[
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F7FF),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFFCBE2FF)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: const Color(0xFF37618E),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    widget.config.targetLanguages.length > 0
                                      ? 'Multiple languages will start multiple crawls. Will be crawled ${widget.config.targetLanguages.length + (widget.config.crawlWithoutTargetLanguage ? 1 : 0)} times.'
                                      : 'Will be crawled once with no target language specified.',
                                    style: GoogleFonts.roboto(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Work package option
                const SizedBox(height: 16),
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: widget.config.generateWorkPackages,
                        onChanged: (value) {
                          setState(() {
                            widget.config.generateWorkPackages = value ?? false;
                            widget.onConfigUpdate();
                          });
                        },
                        activeColor: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Generate work package for this crawl',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                if (widget.config.generateWorkPackages) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const SizedBox(width: 32),
                      Text(
                        'Split package by every',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: '100',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            isDense: true,
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (value) {
                            final entries = int.tryParse(value);
                            if (entries != null && entries > 0) {
                              setState(() {
                                widget.config.entriesPerPackage = entries;
                                widget.onConfigUpdate();
                              });
                            }
                          },
                          controller: TextEditingController(
                            text: widget.config.entriesPerPackage.toString(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'entries',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: 40),

        // Prerender option
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FF),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.scale(
                scale: 1.1,
                child: Checkbox(
                  value: widget.config.prerenderPages,
                  onChanged: (value) {
                    setState(() {
                      widget.config.prerenderPages = value!;
                      // If prerender is unchecked, also uncheck "Use Crest"
                      if (!value && widget.config.useCrest) {
                        widget.config.useCrest = false;
                      }
                      widget.onConfigUpdate();
                    });
                  },
                  activeColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prerender pages for more accurate wordcount',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Great to detect JS-generated content',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Use Crest option (admin only)
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.scale(
                scale: 1.1,
                child: Checkbox(
                  value: widget.config.useCrest,
                  onChanged: widget.config.prerenderPages 
                    ? (value) {
                        setState(() {
                          widget.config.useCrest = value!;
                          widget.onConfigUpdate();
                        });
                      }
                    : null, // Disable checkbox if prerender is not selected
                  activeColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      'Use Crest - Use Crest for content extraction (requires prerender)',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: widget.config.prerenderPages ? Colors.black87 : Colors.black45,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Admin only feature',
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRadioOption({
    required String title,
    required String subtitle,
    required CrawlType value,
    required CrawlType? groupValue,
    required ValueChanged<CrawlType?> onChanged,
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
            Radio<CrawlType>(
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

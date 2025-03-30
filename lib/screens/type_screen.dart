// File: lib/screens/type_screen.dart
import 'package:flutter/material.dart';
import '../models/crawl_config.dart';
import 'package:google_fonts/google_fonts.dart';

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
                  value: false, // This would be controlled by a config value
                  onChanged: null, // Disabled for non-admin users
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
                        color: Colors.black45,
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

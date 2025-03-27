import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/crawl_config.dart';
import '../widgets/information_tooltip.dart';
import 'snapshot_configuration_screen.dart';

class SnapshotScreen extends StatefulWidget {
  final CrawlConfig config;
  final VoidCallback onConfigUpdate;

  const SnapshotScreen({
    super.key,
    required this.config,
    required this.onConfigUpdate,
  });

  @override
  State<SnapshotScreen> createState() => _SnapshotScreenState();
}

class _SnapshotScreenState extends State<SnapshotScreen> {
  // Sample data for available snapshots
  final List<String> availableSnapshots = [
    'Latest crawl',
  ];
  
  // Selected radio option for how pages should be handled
  int _selectedOption = 0;
  
  // Whether to use snapshot from previous crawl
  bool _useSnapshot = false;
  
  // For admin only translation target snapshot
  bool _useTranslationTarget = false;
  bool _buildLocalCache = false;
  
  // Whether the current user is an admin
  final bool _isAdmin = true;
  
  // Whether to show update resource settings message
  bool _showUpdateResourceMessage = false;

  @override
  void initState() {
    super.initState();
    // Initialize config values based on default toggle state (off)
    _useSnapshot = false;
    widget.config.snapshotOption = SnapshotOption.rebuildAll;
    
    // Store selected option for when toggle is turned on
    if (widget.config.snapshotOption == SnapshotOption.rebuildAll) {
      _selectedOption = 2;
    } else {
      _selectedOption = widget.config.storeNewPages ? 0 : 1;
    }
  }

  void _updateConfig() {
    if (_useSnapshot) {
      if (_selectedOption == 2) {
        widget.config.snapshotOption = SnapshotOption.rebuildAll;
      } else {
        widget.config.snapshotOption = SnapshotOption.useExisting;
        widget.config.storeNewPages = _selectedOption == 0;
      }
    } else {
      widget.config.snapshotOption = SnapshotOption.rebuildAll;
    }
    
    // Show resource settings message only when toggle is on and options 0 or 2 are selected
    setState(() {
      _showUpdateResourceMessage = _useSnapshot && (_selectedOption == 0 || _selectedOption == 2);
    });
    
    widget.onConfigUpdate();
  }

  // Update resource collection settings
  void _updateResourceSettings() {
    setState(() {
      widget.config.collectHtmlPages = true;
      widget.config.collectJsCssResources = true;
      _showUpdateResourceMessage = false;
    });
    widget.onConfigUpdate();
  }

  void _openSnapshotConfiguration() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SnapshotConfigurationScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF37618E);
    final containerWidth = MediaQuery.of(context).size.width - 48; // Accounting for padding
    
    final headerStyle = GoogleFonts.roboto(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.black87,
    );
    
    // Check if scan option is selected
    final bool isScanSelected = widget.config.crawlType == CrawlType.contentExtraction || 
                                widget.config.crawlType == CrawlType.tlsContentExtraction;
    
    // When toggle is off, don't show any radio as selected
    final displayedSelectedOption = _useSnapshot ? _selectedOption : -1;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and description
        Text(
          'Origin snapshots',
          style: GoogleFonts.roboto(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Configure how to handle content changes since the last crawl',
          style: GoogleFonts.roboto(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 32),
        
        // Main container with snapshot options
        Container(
          width: containerWidth,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Use snapshot from previous crawl option with switch
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          'Use snapshot from previous crawl',
                          style: headerStyle,
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                  Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: _useSnapshot,
                      onChanged: (value) {
                        setState(() {
                          _useSnapshot = value;
                          _updateConfig();
                        });
                      },
                      activeColor: primaryColor,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 4),
              
              // Description text
              Text(
                'Compare content with a previous crawl to detect changes',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              
              // Snapshot selection dropdown - always visible but grayed out when toggle is off
              const SizedBox(height: 16),
              Text(
                'Select snapshot to use:',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _useSnapshot ? Colors.black87 : Colors.black38,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: containerWidth,
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    enabled: _useSnapshot,
                  ),
                  value: availableSnapshots.first,
                  items: availableSnapshots.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: _useSnapshot 
                    ? (newValue) {
                        if (newValue != null) {
                          setState(() {
                            widget.config.selectedSnapshot = newValue;
                            _updateConfig();
                          });
                        }
                      }
                    : null,
                  style: GoogleFonts.roboto(
                    color: _useSnapshot ? Colors.black87 : Colors.black38,
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // How should new pages be handled section
              Text(
                'How should new pages be handled?',
                style: headerStyle.copyWith(
                  color: _useSnapshot ? Colors.black87 : Colors.black38,
                ),
              ),
              const SizedBox(height: 16),
              
              // Option 1: Reuse existing pages and store new pages
              _buildRadioOption(
                value: 0,
                groupValue: displayedSelectedOption,
                title: 'Reuse existing pages and store new pages',
                description: 'For every visited page, the crawler checks whether it is in the Snapshot already. If it isn\'t, it adds it. This option doesn\'t update existing pages in the Snapshot.',
                onChanged: (value) {
                  if (value != null && _useSnapshot) {
                    setState(() {
                      _selectedOption = value;
                      _updateConfig();
                    });
                  }
                },
                isEnabled: _useSnapshot,
              ),
              
              const SizedBox(height: 8),
              
              // Option 2: Reuse existing pages but don't store new ones
              _buildRadioOption(
                value: 1,
                groupValue: displayedSelectedOption,
                title: 'Reuse existing pages and don\'t store new pages',
                description: 'For every visited page, the crawler checks whether it is in the Snapshot already. If it is, content is Scanned from the stored page. If it isn\'t, the page is Scanned from the remote.',
                onChanged: (value) {
                  if (value != null && _useSnapshot) {
                    setState(() {
                      _selectedOption = value;
                      _updateConfig();
                    });
                  }
                },
                isEnabled: _useSnapshot,
              ),
              
              const SizedBox(height: 8),
              
              // Option 3: Don't reuse existing pages
              _buildRadioOption(
                value: 2,
                groupValue: displayedSelectedOption,
                title: 'Don\'t reuse existing pages, update/store all encountered pages',
                description: 'For every visited page, the crawler checks whether it is in the Snapshot already. If it is, the page is updated. If it isn\'t, the new page is added. This option doesn\'t affect pages that aren\'t visited during the crawl.',
                onChanged: (value) {
                  if (value != null && _useSnapshot) {
                    setState(() {
                      _selectedOption = value;
                      _updateConfig();
                    });
                  }
                },
                isEnabled: _useSnapshot,
              ),
              
              // Message for updating resource collection settings
              if (_showUpdateResourceMessage) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F7FF),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFFCBE2FF)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFF37618E),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Would you like to update resource collection settings to match the selected snapshot?',
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _updateResourceSettings,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF37618E),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Update',
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        
        // Admin only - Translation target snapshot container
        if (_isAdmin && isScanSelected) ...[
          const SizedBox(height: 24),
          Container(
            width: containerWidth,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Translation target snapshot',
                      style: headerStyle,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDF2F7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Admin only feature',
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Build local cache checkbox
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _buildLocalCache,
                        onChanged: (value) {
                          setState(() {
                            _buildLocalCache = value!;
                            _updateConfig();
                          });
                        },
                        activeColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Build local cache',
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
      ],
    );
  }
  
  Widget _buildRadioOption({
    required int value,
    required int groupValue,
    required String title,
    required String description,
    required ValueChanged<int?> onChanged,
    required bool isEnabled,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Radio<int>(
          value: value,
          groupValue: groupValue,
          onChanged: isEnabled ? onChanged : null,
          activeColor: const Color(0xFF37618E),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isEnabled ? Colors.black87 : Colors.black38,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: isEnabled ? Colors.black54 : Colors.black26,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/crawl_config.dart';
import '../widgets/information_tooltip.dart';
import 'snapshot_configuration_screen.dart';
import '../theme/button_styles.dart';

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
    // Empty list for the "No snapshots available" state
  ];
  
  // Selected radio option for how pages should be handled
  int _selectedOption = -1;
  
  // Whether to use snapshot from previous crawl
  bool _useSnapshot = false;
  
  // For translation target snapshot
  bool _useTranslationTarget = false;
  
  // Track policy and language selections
  String? _selectedPolicy;
  String? _selectedLanguage;
  
  // Whether the current user is an admin
  final bool _isAdmin = true;
  
  // Whether to show update resource settings message
  bool _showUpdateResourceMessage = false;

  bool get _hasSnapshots => availableSnapshots.isNotEmpty;

  @override
  void initState() {
    super.initState();
    // Initialize with snapshots turned off by default
    _useSnapshot = false;
    _selectedOption = -1; // No option selected by default
    
    // Set default policy
    _selectedPolicy = 'Always overwrite';
    
    // If there's only one language, select it by default
    if (_getAvailableLanguages().length == 1) {
      _selectedLanguage = _getAvailableLanguages().first;
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
      widget.config.storeNewPages = false;
      _selectedOption = -1; // Reset selected option when turned off
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
    
    final headerStyle = GoogleFonts.notoSans(
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Snapshots',
              style: GoogleFonts.notoSans(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Snapshots store and serve source website content exactly as captured during crawling, unchanged until you run a new crawl to update it.',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        
        // Main container with snapshot options
        Container(
          width: containerWidth,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
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
                          'Origin snapshot',
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
                          if (value) {
                            // When turned on, ensure no option is selected initially
                            _selectedOption = -1;
                          } else {
                            // When turned off, reset all related settings
                            widget.config.snapshotOption = SnapshotOption.rebuildAll;
                            widget.config.storeNewPages = false;
                            _selectedOption = -1;
                          }
                          _updateConfig();
                        });
                      },
                      activeColor: primaryColor,
                    ),
                  ),
                ],
              ),
              
              // Only show description and options when toggle is ON
              if (_useSnapshot) ...[
                const SizedBox(height: 4),
                
                // Snapshot selection dropdown
                const SizedBox(height: 16),
                Text(
                  'Select snapshot to use:',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: containerWidth,
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      hintText: 'No snapshots available',
                    ),
                    value: _hasSnapshots ? availableSnapshots.first : null,
                    items: _hasSnapshots 
                      ? availableSnapshots.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: GoogleFonts.notoSans(
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          );
                        }).toList()
                      : [],
                    onChanged: _hasSnapshots 
                      ? (newValue) {
                          if (newValue != null) {
                            setState(() {
                              widget.config.selectedSnapshot = newValue;
                              _updateConfig();
                            });
                          }
                        }
                      : null,
                  ),
                ),
                
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: _openSnapshotConfiguration,
                      style: AppButtonStyles.textButton,
                      child: AppButtonStyles.buttonWithIcon(
                        text: _hasSnapshots 
                          ? 'Origin snapshot is disabled. Change settings'
                          : 'Origin snapshot is not available. Create a snapshot',
                        icon: Icons.launch,
                        iconLeading: false,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Reload snapshots logic
                        setState(() {
                          // Refresh the snapshot list while keeping toggle on
                          // Just reset the options and make radio options available
                          _selectedOption = -1;
                          widget.config.snapshotOption = SnapshotOption.rebuildAll;
                          widget.config.storeNewPages = false;
                          _updateConfig();
                          
                          // Here we would fetch new snapshots data if implemented
                          // Simulate having snapshots available for now
                          availableSnapshots.clear();
                          availableSnapshots.add("Snapshot 1");
                        });
                      },
                      style: AppButtonStyles.textButton,
                      child: AppButtonStyles.buttonWithIcon(
                        text: 'Reload snapshots',
                        icon: Icons.refresh,
                        iconLeading: true,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Add back radio options with modern Material Design 3 styling
                _buildRadioOption(
                  value: 0,
                  groupValue: _selectedOption,
                  title: 'Reuse existing pages and store new pages',
                  description: 'Keeps existing pages in the Snapshot unchanged and adds any new pages found during the crawl.',
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedOption = value;
                        _updateConfig();
                      });
                    }
                  },
                  isEnabled: _hasSnapshots,
                ),
                
                const SizedBox(height: 8),
                
                _buildRadioOption(
                  value: 1,
                  groupValue: _selectedOption,
                  title: 'Reuse existing pages and don\'t store new pages',
                  description: 'Uses existing pages from the Snapshot without adding new pages. Pages not in the Snapshot are crawled but not stored.',
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedOption = value;
                        _updateConfig();
                      });
                    }
                  },
                  isEnabled: _hasSnapshots,
                ),
                
                const SizedBox(height: 8),
                
                _buildRadioOption(
                  value: 2,
                  groupValue: _selectedOption,
                  title: 'Don\'t reuse existing pages, update/store all encountered pages',
                  description: 'Updates all existing pages and adds new ones. Best for initial snapshots or to capture the current state of the site.',
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedOption = value;
                        _updateConfig();
                      });
                    }
                  },
                  isEnabled: _hasSnapshots,
                ),
                
                // Message for updating resource collection settings
                if (_showUpdateResourceMessage) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F7FF),
                      borderRadius: BorderRadius.circular(20),
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
                            style: GoogleFonts.notoSans(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _updateResourceSettings,
                          style: AppButtonStyles.primaryFilledButton,
                          child: AppButtonStyles.buttonText('Update'),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
        
        // Translation target snapshot container (formerly admin-only)
        if (isScanSelected) ...[
          const SizedBox(height: 24),
          Container(
            width: containerWidth,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Translation (target) snapshot',
                      style: headerStyle,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDF2F7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Admin only feature',
                        style: GoogleFonts.notoSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Add the Build local cache label with toggle switch
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Build local cache',
                      style: GoogleFonts.notoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: widget.config.buildLocalCache,
                        onChanged: (value) {
                          setState(() {
                            widget.config.buildLocalCache = value;
                            _updateConfig();
                          });
                        },
                        activeColor: primaryColor,
                      ),
                    ),
                  ],
                ),
                
                // Show policy selector and language dropdown when toggle is on
                if (widget.config.buildLocalCache) ...[
                  const SizedBox(height: 16),
                  
                  // Target language header
                  Text(
                    'Select target language',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Language selection dropdown (example with Hungarian)
                  Container(
                    width: containerWidth,
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        hintText: 'Select target language',
                      ),
                      value: _getDefaultLanguage(),
                      items: _getAvailableLanguages().map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  border: Border(
                                    top: BorderSide(color: Colors.white, width: 1),
                                    bottom: BorderSide(color: Colors.green, width: 1),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                value,
                                style: GoogleFonts.notoSans(
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      // Restored to original active state
                      onChanged: (newValue) {
                        // Handle language selection
                        setState(() {
                          _selectedLanguage = newValue;
                        });
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: _openSnapshotConfiguration,
                        style: AppButtonStyles.textButton,
                        child: AppButtonStyles.buttonWithIcon(
                          text: 'Translation snapshot is disabled. Change settings',
                          icon: Icons.launch,
                          iconLeading: false,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Reload snapshots logic
                          setState(() {
                            // Refresh the snapshot list while keeping toggle on
                            // Just reset the selections to prompt user to choose again
                            _selectedLanguage = null;
                            _selectedPolicy = null;
                            _updateConfig();
                            
                            // Here we would fetch new languages and policies if implemented
                          });
                        },
                        style: AppButtonStyles.textButton,
                        child: AppButtonStyles.buttonWithIcon(
                          text: 'Reload snapshots',
                          icon: Icons.refresh,
                          iconLeading: true,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Policy selection dropdown
                  Text(
                    'Select policy',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: containerWidth,
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        hintText: 'Select a policy',
                      ),
                      value: _selectedPolicy,
                      items: [
                        'Never overwrite',
                        'Overwrite if better',
                        'Always overwrite'
                      ].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: GoogleFonts.notoSans(
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                      // Restored to original active state
                      onChanged: (newValue) {
                        // Handle policy selection
                        setState(() {
                          _selectedPolicy = newValue;
                        });
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Warning message as an informational help text - show only if selections are incomplete
                  if (_selectedPolicy == null || _selectedLanguage == null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED), // Warning background color
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFFECD1)), // Warning border color
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded, // Triangle warning icon
                          color: Color(0xFFDC6803), // Warning icon color
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Select both a target language and a policy to enable local cache building.',
                            style: GoogleFonts.notoSans(
                              fontSize: 14,
                              color: Colors.black87,
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
    return GestureDetector(
      onTap: isEnabled ? () => onChanged(value) : null,
      child: Row(
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
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isEnabled ? Colors.black87 : Colors.black38,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: isEnabled ? Colors.black54 : Colors.black26,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Add these helper methods for language handling
  List<String> _getAvailableLanguages() {
    // Restore to original implementation with multiple languages
    return ['Hungarian (Hungary) [hu-HU]', 'German (Germany) [de-DE]', 'French (France) [fr-FR]'];
  }
  
  String? _getDefaultLanguage() {
    final languages = _getAvailableLanguages();
    
    // If a language is already selected, use that
    if (_selectedLanguage != null) {
      return _selectedLanguage;
    }
    
    // If there's only one language, use it as default
    if (languages.length == 1) {
      return languages.first;
    }
    
    // Otherwise, don't select a default for multiple languages
    return null;
  }
}

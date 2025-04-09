import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/crawl_config.dart';
import '../widgets/information_tooltip.dart';

class RestrictionsScreen extends StatefulWidget {
  final CrawlConfig config;
  final VoidCallback onConfigUpdate;

  const RestrictionsScreen({
    super.key,
    required this.config,
    required this.onConfigUpdate,
  });

  @override
  State<RestrictionsScreen> createState() => _RestrictionsScreenState();
}

class _RestrictionsScreenState extends State<RestrictionsScreen> {
  // Current state for the restriction type (include or exclude)
  bool? _isExcludeMode = null;
  
  // Controller for the new restriction input field
  final _restrictionController = TextEditingController();
  
  // Error messages for validation
  String? _prefixError;
  String? _regexError;
  
  // Toggle for making temporary restrictions permanent
  bool _makePermanent = false;
  
  // Sample existing project restrictions (in a real app, these would come from a backend)
  final List<String> _existingIncludePrefixes = ['/blog', '/news', '/asdf', '/aaaaa', '/bbbbb'];
  final List<String> _existingExcludePrefixes = ['/about', '/qwertz', '/ccc', '/ddd', '/eee'];
  
  // Temporary restrictions for this crawl
  List<String> _tempIncludePrefixes = [];
  List<String> _tempExcludePrefixes = [];
  
  // Set of disabled existing restrictions (won't be applied to this crawl)
  final Set<String> _disabledExistingPrefixes = {};
  
  // Regular expression restrictions
  final List<String> _regexRestrictions = [];
  final _regexController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // In a real app, load the config's include and exclude prefixes here
    _tempIncludePrefixes = ['/blog', '/news'];
    _tempExcludePrefixes = ['/about', '/contact'];
    
    // Load regex restrictions from config
    if (widget.config.regexRestrictions.isNotEmpty) {
      _regexRestrictions.addAll(widget.config.regexRestrictions);
    }
  }

  @override
  void dispose() {
    _restrictionController.dispose();
    _regexController.dispose();
    super.dispose();
  }

  // Validate and format the path prefix
  String? _validatePrefix(String value) {
    if (value.isEmpty) {
      return null;
    }
    
    if (!value.startsWith('/')) {
      return "Invalid prefix. Must start with '/'";
    }
    
    if (value.trim() == '/') {
      return "Single slash not allowed. Please enter a more specific path.";
    }
    
    // Extract path component if full URL is entered
    if (value.startsWith('http')) {
      try {
        final uri = Uri.parse(value);
        value = uri.path;
      } catch (e) {
        return "Invalid URL format.";
      }
    }
    
    // Convert double slashes to single slash
    value = value.replaceAll('//', '/');
    
    return null;
  }

  // Add a new restriction based on the current mode
  void _addRestriction() {
    final value = _restrictionController.text.trim();
    if (value.isEmpty) return;
    
    final error = _validatePrefix(value);
    if (error != null) {
      setState(() {
        _prefixError = error;
      });
      return;
    }
    
    setState(() {
      _prefixError = null;
      // Handle comma-separated values
      final prefixes = value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      
      if (_isExcludeMode == true) {
        _tempExcludePrefixes.addAll(prefixes);
      } else if (_isExcludeMode == false) {
        _tempIncludePrefixes.addAll(prefixes);
      }
      
      _restrictionController.clear();
    });
    
    // Update the config
    widget.onConfigUpdate();
  }

  // Remove a temporary restriction
  void _removeTemporaryRestriction(String prefix, bool isExclude) {
    setState(() {
      if (isExclude) {
        _tempExcludePrefixes.remove(prefix);
      } else {
        _tempIncludePrefixes.remove(prefix);
      }
    });
    widget.onConfigUpdate();
  }

  // Toggle an existing restriction (enable/disable)
  void _toggleExistingRestriction(String prefix) {
    setState(() {
      if (_disabledExistingPrefixes.contains(prefix)) {
        _disabledExistingPrefixes.remove(prefix);
      } else {
        _disabledExistingPrefixes.add(prefix);
      }
    });
    widget.onConfigUpdate();
  }

  // Add a regex restriction
  void _addRegexRestriction() {
    final value = _regexController.text.trim();
    if (value.isEmpty) return;
    
    // Basic regex validation
    try {
      RegExp(value);
      setState(() {
        _regexError = null;
        _regexRestrictions.add(value);
        // Add to config for tracking in the review screen
        widget.config.regexRestrictions.add(value);
        _regexController.clear();
      });
    } catch (e) {
      setState(() {
        _regexError = "Invalid regular expression pattern";
      });
      return;
    }
    
    widget.onConfigUpdate();
  }

  // Remove a regex restriction
  void _removeRegexRestriction(int index) {
    setState(() {
      final removedRegex = _regexRestrictions.removeAt(index);
      // Also remove from config
      widget.config.regexRestrictions.remove(removedRegex);
    });
    widget.onConfigUpdate();
  }

  // Build a restriction chip with asterisk suffix
  Widget _buildRestrictionChip({
    required String prefix,
    required bool isTemporary,
    required bool isExclude,
    required bool isDisabled,
    required VoidCallback onRemove,
    bool isRegex = false,
  }) {
    // Display with asterisk suffix for UI purposes
    final displayText = isRegex ? prefix : '$prefix*';
    final primaryColor = const Color(0xFF37618E);
    final chipTextColor = const Color(0xFF191C20);
    final chipColor = const Color(0xFFCBDCF6);
    
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Builder(
        builder: (context) {
          bool isHovering = false;
          
          return StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                child: GestureDetector(
                  onTap: isTemporary && isHovering 
                      ? onRemove 
                      : (isTemporary ? null : () => _toggleExistingRestriction(prefix)),
                  child: MouseRegion(
                    onEnter: (_) => setState(() => isHovering = true),
                    onExit: (_) => setState(() => isHovering = false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDisabled ? Colors.grey.shade200 : chipColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Fixed-width container for icons to prevent layout shift
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Check Icon (default state or non-temporary chip)
                                Positioned(
                                  child: Opacity(
                                    opacity: isTemporary && isHovering ? 0.0 : 1.0, // Hide when close icon should show
                                    child: Icon(
                                      Icons.check,
                                      size: 16,
                                      color: isDisabled
                                          ? Colors.grey.shade600
                                          : chipTextColor,
                                    ),
                                  ),
                                ),
                                // Close Icon (only for temporary chips on hover)
                                Positioned(
                                  child: Opacity(
                                    opacity: isTemporary && isHovering ? 1.0 : 0.0, // Show only when hovering temporary
                                    child: Icon(
                                      Icons.close,
                                      size: 16,
                                      color: chipTextColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            displayText,
                            style: isRegex 
                              ? GoogleFonts.notoSansMono( // Changed from robotoMono
                                  color: isDisabled ? Colors.grey.shade600 : chipTextColor,
                                  fontSize: 14,
                                )
                              : TextStyle( // Regular style for other restrictions
                                  color: isDisabled ? Colors.grey.shade600 : chipTextColor,
                                  fontSize: 14,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF37618E);
    final headerStyle = GoogleFonts.notoSans(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.black87,
    );
    
    // Consistent container width
    final containerWidth = MediaQuery.of(context).size.width - 48; // Accounting for padding
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Manage restrictions for this crawl',
          style: GoogleFonts.notoSans(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Define which content to include and exclude during this crawl session',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 32),
        
        // Existing project restrictions section (if present)
        if (_existingIncludePrefixes.isNotEmpty || _existingExcludePrefixes.isNotEmpty) ...[
          // Container for existing restrictions with title inside
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
                Text(
                  'Existing project restrictions',
                  style: headerStyle,
                ),
                const SizedBox(height: 8),
                Text(
                  'Click on a restriction to disable it for this crawl. Disabled restrictions will not be applied.',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Crawl pages starting with section
                if (_existingIncludePrefixes.isNotEmpty) ...[
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
                    children: _existingIncludePrefixes.map((prefix) {
                      final isDisabled = _disabledExistingPrefixes.contains(prefix);
                      return _buildRestrictionChip(
                        prefix: prefix,
                        isTemporary: false,
                        isExclude: false,
                        isDisabled: isDisabled,
                        onRemove: () {}, // Not applicable for existing
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Don't crawl pages starting with section
                if (_existingExcludePrefixes.isNotEmpty) ...[
                  Text(
                    "Don't crawl pages starting with:",
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    children: [
                      // Add the special non-clickable /de_de/* chip at the beginning
                      Tooltip(
                        message: 'The custom subdirectory prefix is always excluded by the crawl',
                        child: MouseRegion(
                          cursor: SystemMouseCursors.forbidden,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            margin: const EdgeInsets.only(right: 8, bottom: 8),
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
                                const Text(
                                  '/de_de/*',
                                  style: TextStyle(
                                    color: Color(0xFF191C20),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Then add all the regular exclude prefixes
                      ..._existingExcludePrefixes.map((prefix) {
                        final isDisabled = _disabledExistingPrefixes.contains(prefix);
                        return _buildRestrictionChip(
                          prefix: prefix,
                          isTemporary: false,
                          isExclude: true,
                          isDisabled: isDisabled,
                          onRemove: () {}, // Not applicable for existing
                        );
                      }).toList(),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
        
        // Combined container for add temporary restrictions and temporary restrictions display
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
              // Add temporary restrictions section
              Text(
                'Add temporary restrictions for this crawl',
                style: headerStyle,
              ),
              const SizedBox(height: 8),
              Text(
                "Path prefixes control which pages to include or exclude.",
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              
              // Radio buttons for include/exclude mode
              Row(
                children: [
                  Radio<bool>(
                    value: false,
                    groupValue: _isExcludeMode,
                    onChanged: (value) {
                      setState(() {
                        _isExcludeMode = value;
                        _prefixError = null; // Clear error on mode change
                      });
                    },
                    activeColor: primaryColor,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const Text('Crawl pages starting with'),
                  const SizedBox(width: 24),
                  Radio<bool>(
                    value: true,
                    groupValue: _isExcludeMode,
                    onChanged: (value) {
                      setState(() {
                        _isExcludeMode = value;
                        _prefixError = null; // Clear error on mode change
                      });
                    },
                    activeColor: primaryColor,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const Text("Don't crawl pages starting with"),
                ],
              ),
              const SizedBox(height: 16),
              
              // Restriction input field with validation
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 40,
                          child: TextField(
                            controller: _restrictionController,
                            decoration: InputDecoration(
                              hintText: 'Path prefix rule, e.g., /blog, /news/, /fr/',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: BorderSide(
                                  color: _prefixError != null ? Colors.red : Colors.grey.shade400,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: BorderSide(
                                  color: _prefixError != null ? Colors.red : primaryColor,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                            onChanged: (value) {
                              // Clear error when user types
                              if (_prefixError != null) {
                                setState(() {
                                  _prefixError = null;
                                });
                              }
                            },
                            onSubmitted: (_) => _addRestriction(),
                          ),
                        ),
                        if (_prefixError != null) 
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 4),
                            child: Text(
                              _prefixError!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isExcludeMode != null ? _addRestriction : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      disabledBackgroundColor: Colors.grey.shade300, // Disabled color
                    ),
                    child: const Text('Add'),
                  ),
                ],
              ),
              
              // Temporary restrictions section (only show if there are temporary restrictions)
              if (_tempIncludePrefixes.isNotEmpty || _tempExcludePrefixes.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Divider(height: 1),
                const SizedBox(height: 24),
                
                Text(
                  _makePermanent ? 'New project restrictions' : 'Temporary crawl restrictions',
                  style: headerStyle,
                ),
                const SizedBox(height: 8),
                Text(
                  _makePermanent 
                      ? 'These restrictions will be added to your project settings permanently' 
                      : 'These restrictions will only apply to this crawl session',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Temporary crawl pages starting with
                if (_tempIncludePrefixes.isNotEmpty) ...[
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
                    children: _tempIncludePrefixes.map((prefix) {
                      return _buildRestrictionChip(
                        prefix: prefix,
                        isTemporary: true,
                        isExclude: false,
                        isDisabled: false,
                        onRemove: () => _removeTemporaryRestriction(prefix, false),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Temporary don't crawl pages starting with
                if (_tempExcludePrefixes.isNotEmpty) ...[
                  Text(
                    "Don't crawl pages starting with:",
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    children: _tempExcludePrefixes.map((prefix) {
                      return _buildRestrictionChip(
                        prefix: prefix,
                        isTemporary: true,
                        isExclude: true,
                        isDisabled: false,
                        onRemove: () => _removeTemporaryRestriction(prefix, true),
                      );
                    }).toList(),
                  ),
                  
                  // Add spacing before the toggle
                  const SizedBox(height: 24),
                ],
                
                // Switch to make temporary restrictions permanent - moved below the chip lists
                Row(
                  children: [
                    SizedBox(
                      height: 24, // Smaller height
                      width: 40, // Smaller width
                      child: Transform.scale(
                        scale: 0.8, // Scale down the switch
                        child: Switch(
                          value: _makePermanent,
                          onChanged: (value) {
                            setState(() {
                              _makePermanent = value;
                            });
                          },
                          activeColor: primaryColor,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Add these temporary restrictions to the project settings permanently',
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        
        // Regular expression restrictions section
        const SizedBox(height: 32),
        
        // Container for regex with title inside
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
              Text(
                'Add regular expression restrictions',
                style: headerStyle,
              ),
              const SizedBox(height: 8),
              Text(
                'Exclude the pages matching the following regular expression during this crawl',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              
              // Regex input field
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 40,
                          child: TextField(
                            controller: _regexController,
                            decoration: InputDecoration(
                              hintText: 'e.g /_el/dashboard/project/.*/crawl-wizard',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: BorderSide(
                                  color: _regexError != null ? Colors.red : Colors.grey.shade400,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                                borderSide: BorderSide(
                                  color: _regexError != null ? Colors.red : primaryColor,
                                  width: 2,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                            onChanged: (value) {
                              // Clear error when user types
                              if (_regexError != null) {
                                setState(() {
                                  _regexError = null;
                                });
                              }
                            },
                            onSubmitted: (_) => _addRegexRestriction(),
                          ),
                        ),
                        if (_regexError != null) 
                          Padding(
                            padding: const EdgeInsets.only(top: 4, left: 4),
                            child: Text(
                              _regexError!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _addRegexRestriction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Add'),
                  ),
                ],
              ),

              // Regular expression restrictions list
              if (_regexRestrictions.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Regular expression restrictions',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'These restrictions will only apply to this crawl session',
                  style: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                
                // List of regex patterns with delete buttons
                ...List.generate(_regexRestrictions.length, (index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBDCF6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _regexRestrictions[index],
                            style: GoogleFonts.notoSansMono(
                              color: const Color(0xFF191C20),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => _removeRegexRestriction(index),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
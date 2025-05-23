// File: lib/screens/restrictions_screen.dart
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
  bool _isExcludeMode = true;
  
  // Controller for the new restriction input field
  final _restrictionController = TextEditingController();
  
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

  // Class-level tracking variable for hover state
  bool _isDeDeChipHovered = false;

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

  // Update the validation method to be more specific
  bool _validatePrefixInput(String value) {
    if (value.isEmpty) return true;
    return value.startsWith('/');
  }

  // Update the add restriction method to use the validation
  void _addRestriction() {
    final value = _restrictionController.text.trim();
    if (value.isEmpty) return;
    
    if (!_validatePrefixInput(value)) {
      setState(() {}); // Show error state
      return;
    }
    
    setState(() {
      // Handle comma-separated values
      final prefixes = value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      
      if (_isExcludeMode) {
        _tempExcludePrefixes.addAll(prefixes);
      } else {
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
    
    setState(() {
      _regexRestrictions.add(value);
      // Add to config for tracking in the review screen
      widget.config.regexRestrictions.add(value);
      _regexController.clear();
    });
    
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
              // Calculate the extra padding needed for the close icon
              final EdgeInsets contentPadding = isTemporary
                  ? EdgeInsets.symmetric(
                      horizontal: isHovering ? 12 : 16, 
                      vertical: 8
                    )
                  : const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
              
              return Padding(
                padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                child: GestureDetector(
                  onTap: isTemporary && isHovering 
                      ? onRemove 
                      : (isTemporary ? null : () => _toggleExistingRestriction(prefix)),
                  child: MouseRegion(
                    onEnter: (_) => setState(() => isHovering = true),
                    onExit: (_) => setState(() => isHovering = false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: contentPadding,
                      decoration: BoxDecoration(
                        color: isDisabled ? Colors.transparent : chipColor,
                        border: isDisabled 
                          ? Border.all(color: Theme.of(context).colorScheme.outline) 
                          : null,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isDisabled) 
                            Icon(
                              Icons.check,
                              size: 16,
                              color: chipTextColor,
                            ),
                          SizedBox(width: isDisabled ? 0 : 6),
                          Text(
                            displayText,
                            style: isRegex 
                              ? GoogleFonts.robotoMono( // Monospace for regex
                                  color: isDisabled ? Theme.of(context).colorScheme.onSurface : chipTextColor,
                                  fontSize: 14,
                                )
                              : TextStyle( // Regular style for other restrictions
                                  color: isDisabled ? Theme.of(context).colorScheme.onSurface : chipTextColor,
                                  fontSize: 14,
                                ),
                          ),
                          // Always maintain space for the close icon for temporary chips but only show on hover
                          if (isTemporary && isHovering) ...[
                            const SizedBox(width: 6),
                            Icon(
                              Icons.close,
                              size: 16,
                              color: chipTextColor,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
          );
        }
      ),
    );
  }

  // Build a special locked restriction chip
  Widget _buildLockedRestrictionChip(String prefix) {
    final displayText = '$prefix*';
    final chipColor = const Color(0xFFCBDCF6);
    final chipTextColor = const Color(0xFF191C20);
    
    return MouseRegion(
      onEnter: (_) => setState(() => _isDeDeChipHovered = true),
      onExit: (_) => setState(() => _isDeDeChipHovered = false),
      child: Tooltip(
        message: "Published subdirectories are always excluded from crawling",
        verticalOffset: 20,
        preferBelow: true,
        child: Padding(
          padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: chipColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _isDeDeChipHovered ? Icons.lock : Icons.check,
                  size: 16,
                  color: chipTextColor,
                ),
                const SizedBox(width: 6),
                Text(
                  displayText,
                  style: TextStyle(
                    color: chipTextColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
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
              borderRadius: BorderRadius.circular(16),
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
                      _buildLockedRestrictionChip('/de_de'),
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
            borderRadius: BorderRadius.circular(16),
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
                        _isExcludeMode = value!;
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
                        _isExcludeMode = value!;
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 40,
                          child: TextField(
                            controller: _restrictionController,
                            decoration: InputDecoration(
                              hintText: 'Path prefix rule, e.g., /blog, /news/, /fr/',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              isDense: true,
                              errorText: _validatePrefixInput(_restrictionController.text) ? null : 'Must start with /',
                              errorStyle: GoogleFonts.notoSans(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.error,
                                height: 1,
                              ),
                            ),
                            onSubmitted: (_) => _addRestriction(),
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: _addRestriction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(88, 40),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'Add',
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              // Temporary restrictions section (only show if there are temporary restrictions)
              if (_tempIncludePrefixes.isNotEmpty || _tempExcludePrefixes.isNotEmpty) ...[
                const SizedBox(height: 24),
                Divider(color: Colors.grey.shade300, height: 1),
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
                ],
                
                // Move the toggle switch here - after the chips display
                const SizedBox(height: 24),
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
            borderRadius: BorderRadius.circular(16),
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 40,
                          child: TextField(
                            controller: _regexController,
                            decoration: InputDecoration(
                              hintText: 'e.g /_el/dashboard/project/.*/crawl-wizard',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              isDense: true,
                            ),
                            onSubmitted: (_) => _addRegexRestriction(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: _addRegexRestriction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(88, 40),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'Add',
                        style: GoogleFonts.notoSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
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
                Wrap(
                  children: List.generate(_regexRestrictions.length, (index) {
                    return _buildRestrictionChip(
                      prefix: _regexRestrictions[index],
                      isTemporary: true,
                      isExclude: true,
                      isDisabled: false,
                      onRemove: () => _removeRegexRestriction(index),
                      isRegex: true,
                    );
                  }),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../models/crawl_config.dart';
import '../widgets/information_tooltip.dart';

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
  // Sample data for available snapshots - this would be empty if no snapshots exist
  final List<String> availableSnapshots = [
    'Latest Crawl (2023-03-22)',
    'Production Snapshot (2023-03-15)',
    'Translation Snapshot (2023-03-10)',
  ];

  // Simulate no snapshots for testing
  final bool hasSnapshots = true; // Set to false to test no snapshots message

  // Track selected handling option for new pages
  late int _selectedHandlingOption;
  // Track if we want to use a snapshot (separate from selected option)
  late bool _useExistingSnapshot;

  @override
  void initState() {
    super.initState();
    // Initialize based on the current config
    _useExistingSnapshot = widget.config.snapshotOption == SnapshotOption.useExisting;
    
    if (widget.config.snapshotOption == SnapshotOption.rebuildAll) {
      _selectedHandlingOption = 2; // The "Don't reuse existing pages" option
    } else {
      _selectedHandlingOption = widget.config.storeNewPages ? 0 : 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and description
        Text(
          'Origin Snapshots',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Configure how to handle content changes since the last crawl',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        
        // No snapshots warning if applicable
        if (!hasSnapshots)
          _buildNoSnapshotsWarning(theme),
          
        // Main snapshot configuration card
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: theme.colorScheme.outlineVariant,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
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
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(width: 8),
                          InformationTooltip(
                            message: 'Compare the current content with a previous crawl to detect changes',
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _useExistingSnapshot,
                      onChanged: (value) {
                        setState(() {
                          _useExistingSnapshot = value;
                          if (value) {
                            // If we turn on the toggle, set the snapshot option
                            widget.config.snapshotOption = SnapshotOption.useExisting;
                            // Restore the previous option or default to store new pages
                            widget.config.storeNewPages = _selectedHandlingOption == 0;
                          } else {
                            // If we turn off the toggle, set to rebuild all
                            widget.config.snapshotOption = SnapshotOption.rebuildAll;
                            // But keep the handling option for when we toggle back on
                          }
                          widget.onConfigUpdate();
                        });
                      },
                      activeColor: theme.colorScheme.primary,
                    ),
                  ],
                ),
                
                const SizedBox(height: 4),
                
                // Subtitle with better visual separation
                Text(
                  'Compare content with a previous crawl to detect changes',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                
                // Snapshot dropdown if enabled with improved styling
                if (_useExistingSnapshot)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, right: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Label above the dropdown with better visibility
                        Text(
                          'Select snapshot to use:',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Improved dropdown styling
                        DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: theme.colorScheme.outline),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.7)),
                            ),
                          ),
                          icon: Icon(Icons.arrow_drop_down, color: theme.colorScheme.primary),
                          dropdownColor: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          value: availableSnapshots.first,
                          items: availableSnapshots
                              .map((snapshot) => DropdownMenuItem<String>(
                                    value: snapshot,
                                    child: Text(
                                      snapshot,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              widget.config.selectedSnapshot = value!;
                              widget.onConfigUpdate();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                
                // Divider to separate sections visually
                if (_useExistingSnapshot) ...[
                  const SizedBox(height: 24),
                  Divider(color: theme.colorScheme.outlineVariant),
                  const SizedBox(height: 16),
                  
                  Text(
                    'How should new pages be handled?',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Option 1: Reuse existing pages and store new pages
                  _buildRadioOption(
                    value: 0,
                    title: 'Reuse existing pages and store new pages',
                    subtitle: 'For every visited page, the crawler checks whether it is in the Snapshot already. If it isn\'t, it adds it. This option doesn\'t update existing pages in the Snapshot',
                    theme: theme,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Option 2: Reuse existing pages and don't store new pages
                  _buildRadioOption(
                    value: 1,
                    title: 'Reuse existing pages and don\'t store new pages',
                    subtitle: 'For every visited page, the crawler checks whether it is in the Snapshot already. If it is, content is Scanned from the stored page. If if it isn\'t, the page is Scanned from the remote',
                    theme: theme,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Option 3: Don't reuse existing pages, update/store all
                  _buildRadioOption(
                    value: 2,
                    title: 'Don\'t reuse existing pages, update/store all encountered pages',
                    subtitle: 'For every visited page, the crawler checks whether it is in the Snapshot already. If it is, the page is updated. If it isn\'t, the new page is added. This option doesn\'t affect pages that aren\'t visited during the crawl.',
                    theme: theme,
                  ),
                ],
                
                // If toggle is off, show the rebuild all explanation
                if (!_useExistingSnapshot) ...[
                  const SizedBox(height: 16),
                  Card(
                    elevation: 0,
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.refresh,
                                color: theme.colorScheme.primary,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Rebuild All Pages',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'All pages will be extracted from the source site. This ignores existing snapshot content completely.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
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
        ),
      ],
    );
  }
  
  Widget _buildRadioOption({
    required int value,
    required String title,
    required String subtitle,
    required ThemeData theme,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: _selectedHandlingOption == value 
              ? theme.colorScheme.primary.withOpacity(0.5)
              : theme.colorScheme.outlineVariant.withOpacity(0.5),
          width: _selectedHandlingOption == value ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: RadioListTile(
          title: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          value: value,
          groupValue: _selectedHandlingOption,
          onChanged: (newValue) {
            setState(() {
              _selectedHandlingOption = newValue!;
              
              if (newValue == 2) {
                // For the "Don't reuse existing pages" option
                // Still use existing snapshot toggle but change the behavior
                widget.config.snapshotOption = SnapshotOption.rebuildAll;
              } else {
                // For options 0 and 1, set the proper snapshot option
                widget.config.snapshotOption = SnapshotOption.useExisting;
                // And update the storeNewPages flag based on selection
                widget.config.storeNewPages = newValue == 0;
              }
              
              widget.onConfigUpdate();
            });
          },
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          activeColor: theme.colorScheme.primary,
          selected: _selectedHandlingOption == value,
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ),
    );
  }
  
  Widget _buildNoSnapshotsWarning(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'No snapshots available',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'You need to create a snapshot first before you can use this feature. Snapshots help track changes to your website content over time.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              // Action to open new tab for snapshot creation
            },
            icon: const Icon(Icons.add),
            label: const Text('Create New Snapshot'),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}

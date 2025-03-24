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
  // Sample data for available snapshots
  final List<String> availableSnapshots = [
    'Latest Crawl (2025-03-22)',
    'Production Snapshot (2025-03-15)',
    'Translation Snapshot (2025-03-10)',
  ];

  // Track the expanded state of the advanced section
  bool _isAdvancedExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and description
        Text(
          'Origin snapshot',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Select how to handle origin (source) content for this crawl.',
        ),
        const SizedBox(height: 24),

        // Snapshot options card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Snapshot options',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Use existing snapshot option
                RadioListTile<SnapshotOption>(
                  title: Row(
                    children: [
                      const Text('Use existing snapshot'),
                      const SizedBox(width: 8),
                      InformationTooltip(
                        message: 'Use content from existing snapshot as origin',
                      ),
                    ],
                  ),
                  subtitle: const Text(
                    'Only update changed content, use same origin source',
                  ),
                  value: SnapshotOption.useExisting,
                  groupValue: widget.config.snapshotOption,
                  onChanged: (value) {
                    setState(() {
                      widget.config.snapshotOption = value!;
                      widget.onConfigUpdate();
                    });
                  },
                ),

                // Snapshot dropdown if use existing selected
                if (widget.config.snapshotOption == SnapshotOption.useExisting)
                  Padding(
                    padding: const EdgeInsets.only(left: 48.0, right: 16.0),
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Select snapshot',
                        isDense: true,
                      ),
                      value: availableSnapshots[0],
                      items:
                          availableSnapshots.map((snapshot) {
                            return DropdownMenuItem<String>(
                              value: snapshot,
                              child: Text(
                                snapshot,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          widget.config.selectedSnapshot = value!;
                          widget.onConfigUpdate();
                        });
                      },
                    ),
                  ),

                // Compare content option
                RadioListTile<SnapshotOption>(
                  title: Row(
                    children: [
                      const Text('Compare content with previous crawl'),
                      const SizedBox(width: 8),
                      InformationTooltip(
                        message:
                            'Identify changed content by comparing with a previous snapshot',
                      ),
                    ],
                  ),
                  subtitle: const Text(
                    'Store only pages where content has changed',
                  ),
                  value: SnapshotOption.compareContent,
                  groupValue: widget.config.snapshotOption,
                  onChanged: (value) {
                    setState(() {
                      widget.config.snapshotOption = value!;
                      widget.onConfigUpdate();
                    });
                  },
                ),

                // Comparison snapshot dropdown if compare content selected
                if (widget.config.snapshotOption ==
                    SnapshotOption.compareContent)
                  Padding(
                    padding: const EdgeInsets.only(left: 48.0, right: 16.0),
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Compare against',
                        isDense: true,
                      ),
                      value: availableSnapshots[0],
                      items:
                          availableSnapshots.map((snapshot) {
                            return DropdownMenuItem<String>(
                              value: snapshot,
                              child: Text(
                                snapshot,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          widget.config.selectedSnapshot = value!;
                          widget.onConfigUpdate();
                        });
                      },
                    ),
                  ),

                // Extract all content option
                RadioListTile<SnapshotOption>(
                  title: Row(
                    children: [
                      const Text('Extract content from all pages'),
                      const SizedBox(width: 8),
                      InformationTooltip(
                        message: 'Create a new snapshot with all content',
                      ),
                    ],
                  ),
                  subtitle: const Text(
                    'Ignore previous snapshots and collect everything',
                  ),
                  value: SnapshotOption.rebuildAll,
                  groupValue: widget.config.snapshotOption,
                  onChanged: (value) {
                    setState(() {
                      widget.config.snapshotOption = value!;
                      widget.onConfigUpdate();
                    });
                  },
                ),

                // Additional options
                if (widget.config.snapshotOption !=
                    SnapshotOption.rebuildAll) ...[
                  const Divider(height: 32),
                  const Text(
                    'New pages:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Store content from new pages'),
                    subtitle: const Text(
                      'Pages not in the existing snapshot will be included',
                    ),
                    value: widget.config.storeNewPages,
                    onChanged: (value) {
                      setState(() {
                        widget.config.storeNewPages = value;
                        widget.onConfigUpdate();
                      });
                    },
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Snapshot configuration details (Advanced section)
        ExpansionPanelList(
          elevation: 0,
          expandedHeaderPadding: EdgeInsets.zero,
          expansionCallback: (panelIndex, isExpanded) {
            setState(() {
              _isAdvancedExpanded = !_isAdvancedExpanded;
            });
          },
          children: [
            ExpansionPanel(
              headerBuilder: (context, isExpanded) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Snapshot configuration details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                );
              },
              body: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Snapshot name
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Snapshot name',
                        hintText: 'e.g., March 2025 Production',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Content types to cache
                    const Text(
                      'Content types to cache',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Control what types of content are stored in the snapshot',
                    ),

                    CheckboxListTile(
                      title: const Text('HTML content'),
                      value: true,
                      onChanged: (value) {},
                    ),
                    CheckboxListTile(
                      title: const Text('JavaScript and CSS'),
                      value: true,
                      onChanged: (value) {},
                    ),
                    CheckboxListTile(
                      title: const Text('Images'),
                      value: false,
                      onChanged: (value) {},
                    ),

                    const SizedBox(height: 16),

                    // Content path patterns
                    const Text(
                      'Content path patterns',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Define which content should be included in or excluded from the snapshot using URL patterns',
                    ),

                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Include content matching',
                        hintText: 'e.g., /en/*, /blog/*',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Exclude content matching',
                        hintText: 'e.g., /admin/*, /tmp/*',
                      ),
                    ),
                  ],
                ),
              ),
              isExpanded: _isAdvancedExpanded,
              canTapOnHeader: true,
            ),
          ],
        ),
      ],
    );
  }
}

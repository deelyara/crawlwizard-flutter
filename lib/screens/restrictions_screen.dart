// File: lib/screens/restrictions_screen.dart
import 'package:flutter/material.dart';
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
  final _includeController = TextEditingController();
  final _excludeController = TextEditingController();

  @override
  void dispose() {
    _includeController.dispose();
    _excludeController.dispose();
    super.dispose();
  }

  void _addIncludePrefix() {
    if (_includeController.text.isNotEmpty) {
      setState(() {
        widget.config.includePrefixes.add(_includeController.text);
        _includeController.clear();
      });
      widget.onConfigUpdate();
    }
  }

  void _addExcludePrefix() {
    if (_excludeController.text.isNotEmpty) {
      setState(() {
        widget.config.excludePrefixes.add(_excludeController.text);
        _excludeController.clear();
      });
      widget.onConfigUpdate();
    }
  }

  void _removeIncludePrefix(int index) {
    setState(() {
      widget.config.includePrefixes.removeAt(index);
    });
    widget.onConfigUpdate();
  }

  void _removeExcludePrefix(int index) {
    setState(() {
      widget.config.excludePrefixes.removeAt(index);
    });
    widget.onConfigUpdate();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title with tooltip
        Row(
          children: [
            Text(
              'Set URL Filters',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            const InformationTooltip(
              message: 'Include or exclude specific parts of the website.',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Focus your crawl on specific website sections and avoid unnecessary content.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),

        // Include prefixes section
        Text(
          'Include These Sections',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'The crawler will only process URLs containing these paths:',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),

        // Include prefixes card
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Input field
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _includeController,
                        decoration: InputDecoration(
                          hintText: 'Example: /blog or /products',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _addIncludePrefix,
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                    ),
                  ],
                ),

                // List of include rules as chips
                if (widget.config.includePrefixes.isEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'No filters added. The entire site will be crawled.',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(
                      widget.config.includePrefixes.length,
                      (index) => Chip(
                        label: Text(widget.config.includePrefixes[index]),
                        deleteIcon: const Icon(Icons.cancel, size: 18),
                        onDeleted: () => _removeIncludePrefix(index),
                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        side: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                        deleteIconColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Exclude prefixes section
        Text(
          'Skip These Sections',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'The crawler will ignore URLs containing these paths:',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),

        // Exclude prefixes card
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Input field
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _excludeController,
                        decoration: InputDecoration(
                          hintText: 'Example: /admin or /tmp',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _addExcludePrefix,
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
                    ),
                  ],
                ),

                // List of exclude rules as chips
                if (widget.config.excludePrefixes.isEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'No exclusions added. Nothing will be skipped.',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(
                      widget.config.excludePrefixes.length,
                      (index) => Chip(
                        label: Text(widget.config.excludePrefixes[index]),
                        deleteIcon: const Icon(Icons.cancel, size: 18),
                        onDeleted: () => _removeExcludePrefix(index),
                        backgroundColor: Theme.of(context).colorScheme.error.withOpacity(0.1),
                        side: BorderSide(color: Theme.of(context).colorScheme.error.withOpacity(0.3)),
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w500,
                        ),
                        deleteIconColor: Theme.of(context).colorScheme.error,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Make permanent option
        SwitchListTile(
          title: const Text('Save these filters for future crawls'),
          subtitle: const Text('Apply the same settings to all your crawls'),
          value: widget.config.makePermanent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          onChanged: (value) {
            setState(() {
              widget.config.makePermanent = value;
            });
            widget.onConfigUpdate();
          },
        ),
      ],
    );
  }
}

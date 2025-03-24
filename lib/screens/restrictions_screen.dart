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
              'Set URL Restrictions',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            const InformationTooltip(
              message:
                  'Define which URLs should be included or excluded from the crawl.',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Restrict the crawl to only include certain URL patterns and exclude others.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),

        // Include prefixes section
        Text(
          'Include Rules',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Only crawl URLs matching these prefixes:',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),

        // Include prefixes list
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
              children: [
                // Input field
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _includeController,
                        decoration: InputDecoration(
                          hintText: 'e.g., /blog/, /products/',
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

                // List of include rules
                if (widget.config.includePrefixes.isEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'No include rules added. If left empty, all URLs will be crawled.',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.config.includePrefixes.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(widget.config.includePrefixes[index]),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _removeIncludePrefix(index),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Exclude prefixes section
        Text(
          'Exclude Rules',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Skip URLs matching these prefixes:',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),

        // Exclude prefixes list
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
              children: [
                // Input field
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _excludeController,
                        decoration: InputDecoration(
                          hintText: 'e.g., /admin/, /tmp/',
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

                // List of exclude rules
                if (widget.config.excludePrefixes.isEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'No exclude rules added. If left empty, no URLs will be excluded.',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.config.excludePrefixes.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(widget.config.excludePrefixes[index]),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => _removeExcludePrefix(index),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Make permanent option
        SwitchListTile(
          title: const Text('Make Restrictions Permanent'),
          subtitle: const Text('Apply these restrictions to all future crawls'),
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

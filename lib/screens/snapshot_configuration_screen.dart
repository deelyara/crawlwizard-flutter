import 'package:flutter/material.dart';

class SnapshotConfigurationScreen extends StatefulWidget {
  const SnapshotConfigurationScreen({super.key});

  @override
  State<SnapshotConfigurationScreen> createState() => _SnapshotConfigurationScreenState();
}

class _SnapshotConfigurationScreenState extends State<SnapshotConfigurationScreen> {
  bool _snapshotsEnabled = false;
  int _selectedRetentionDays = 30;
  bool _autoCleanup = true;
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Snapshot Configuration'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Text(
              'Configure Snapshots',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enable and configure snapshot settings to track content changes over time',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Main configuration card
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
                    // Enable snapshots switch
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Enable Snapshots',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Store and track content changes across crawls',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _snapshotsEnabled,
                          onChanged: (value) {
                            setState(() {
                              _snapshotsEnabled = value;
                            });
                          },
                        ),
                      ],
                    ),

                    if (_snapshotsEnabled) ...[
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 24),

                      // Snapshot name field
                      Text(
                        'Default Snapshot Name Format',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: 'e.g., {date}_snapshot_{type}',
                          helperText: 'Use {date}, {type}, and {count} as placeholders',
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Retention period
                      Text(
                        'Retention Period',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: _selectedRetentionDays,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: [
                          DropdownMenuItem(value: 7, child: Text('7 days')),
                          DropdownMenuItem(value: 30, child: Text('30 days')),
                          DropdownMenuItem(value: 90, child: Text('90 days')),
                          DropdownMenuItem(value: 180, child: Text('180 days')),
                          DropdownMenuItem(value: 365, child: Text('1 year')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedRetentionDays = value!;
                          });
                        },
                      ),

                      const SizedBox(height: 24),

                      // Auto cleanup switch
                      SwitchListTile(
                        title: Text(
                          'Automatic Cleanup',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Automatically remove snapshots older than the retention period',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        value: _autoCleanup,
                        onChanged: (value) {
                          setState(() {
                            _autoCleanup = value;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _snapshotsEnabled
                    ? () {
                        // Save configuration and close
                        Navigator.of(context).pop();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  disabledBackgroundColor: theme.colorScheme.surfaceVariant,
                  disabledForegroundColor: theme.colorScheme.onSurfaceVariant,
                ),
                child: const Text('Save Configuration'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
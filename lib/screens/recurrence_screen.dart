import 'package:flutter/material.dart';
import '../models/crawl_config.dart';
import '../widgets/information_tooltip.dart';

class RecurrenceScreen extends StatefulWidget {
  final CrawlConfig config;
  final VoidCallback onConfigUpdate;

  const RecurrenceScreen({
    super.key,
    required this.config,
    required this.onConfigUpdate,
  });

  @override
  State<RecurrenceScreen> createState() => _RecurrenceScreenState();
}

class _RecurrenceScreenState extends State<RecurrenceScreen> {
  // Sample data for available snapshots
  final List<String> availableSnapshots = [
    'Latest Crawl (2023-03-22)',
    'Production Snapshot (2023-03-15)',
    'Translation Snapshot (2023-03-10)',
  ];

  // Selected snapshots for rotation
  List<String> _selectedRotatingSnapshots = [];

  @override
  void initState() {
    super.initState();
    // Initialize selected snapshots from the config
    _selectedRotatingSnapshots = List.from(
      widget.config.selectedRotatingSnapshots,
    );
  }

  // Calculate next run date based on settings (simplified to not include time)
  String _getNextRunDate() {
    DateTime now = DateTime.now();
    DateTime nextRun;

    switch (widget.config.recurrenceFrequency) {
      case RecurrenceFrequency.daily:
        // Next run tomorrow if it's after current time
        nextRun = DateTime(now.year, now.month, now.day + 1);
        break;

      case RecurrenceFrequency.weekly:
        // Next run on the specified day of week
        int currentWeekday = now.weekday; // 1 = Monday, 7 = Sunday
        int daysUntilTarget = widget.config.recurrenceDayOfWeek - currentWeekday;
        if (daysUntilTarget <= 0) daysUntilTarget += 7;
        nextRun = DateTime(now.year, now.month, now.day).add(Duration(days: daysUntilTarget));
        break;

      case RecurrenceFrequency.monthly:
        // Next run on the specified day of month
        int targetDay = widget.config.recurrenceDayOfMonth;
        
        // Create date for this month's target day
        DateTime thisMonthTarget = DateTime(now.year, now.month, targetDay);
        
        // If this month's target is in the past, go to next month
        if (thisMonthTarget.isBefore(now)) {
          thisMonthTarget = DateTime(now.year, now.month + 1, targetDay);
        }
        
        nextRun = thisMonthTarget;
        break;

      case RecurrenceFrequency.custom:
        // For custom, just show 3 days in the future as an example
        nextRun = now.add(const Duration(days: 3));
        break;

      default:
        // For no recurrence, return empty string
        return 'Not scheduled';
    }

    // Format the date nicely
    String formattedDate = '${nextRun.year}-${nextRun.month.toString().padLeft(2, '0')}-${nextRun.day.toString().padLeft(2, '0')}';
    return formattedDate;
  }

  // Day of week names
  final List<String> _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  // Day of month options
  final List<int> _daysOfMonth = List.generate(31, (index) => index + 1);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isRecurringEnabled = widget.config.recurrenceFrequency != RecurrenceFrequency.none;
    final String nextRunDate = _getNextRunDate();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and description
        Text(
          'Set recurring crawl',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Configure recurring crawls to automatically extract new content at specified intervals.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),

        // Crawl frequency card
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
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Crawl frequency',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InformationTooltip(
                      message: 'How often should the crawl run automatically?',
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // None option
                _buildRadioOption(
                  value: RecurrenceFrequency.none,
                  title: 'No recurring crawls',
                  subtitle: 'Run crawls manually only',
                  theme: theme,
                ),
                
                const SizedBox(height: 8),

                // Daily option
                _buildRadioOption(
                  value: RecurrenceFrequency.daily,
                  title: 'Daily',
                  subtitle: 'Run crawl every day',
                  theme: theme,
                ),
                
                const SizedBox(height: 8),

                // Weekly option
                _buildRadioOption(
                  value: RecurrenceFrequency.weekly,
                  title: 'Weekly',
                  subtitle: 'Run crawl once a week on specified day',
                  theme: theme,
                ),
                
                // Day of week selection for weekly option
                if (widget.config.recurrenceFrequency == RecurrenceFrequency.weekly)
                  _buildFrequencyOptionContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select day of week:',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
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
                          value: widget.config.recurrenceDayOfWeek,
                          items: List.generate(7, (index) {
                            return DropdownMenuItem<int>(
                              value: index + 1,
                              child: Text(_daysOfWeek[index]),
                            );
                          }),
                          onChanged: (value) {
                            setState(() {
                              widget.config.recurrenceDayOfWeek = value!;
                              widget.onConfigUpdate();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 8),

                // Monthly option
                _buildRadioOption(
                  value: RecurrenceFrequency.monthly,
                  title: 'Monthly',
                  subtitle: 'Run crawl once a month on specified day',
                  theme: theme,
                ),
                
                // Day of month selection for monthly option
                if (widget.config.recurrenceFrequency == RecurrenceFrequency.monthly)
                  _buildFrequencyOptionContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select day of month:',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
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
                          value: widget.config.recurrenceDayOfMonth,
                          items: _daysOfMonth.map((day) {
                            return DropdownMenuItem<int>(
                              value: day,
                              child: Text('$day'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              widget.config.recurrenceDayOfMonth = value!;
                              widget.onConfigUpdate();
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                if (isRecurringEnabled) ...[
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // Next run date
                  Row(
                    children: [
                      Icon(
                        Icons.event,
                        size: 20, 
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Next scheduled run: ',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        nextRunDate,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),

        // Snapshot rotation section
        if (isRecurringEnabled) ...[
          const SizedBox(height: 24),
          
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
                  Row(
                    children: [
                      Icon(
                        Icons.autorenew_rounded,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Snapshot rotation',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      InformationTooltip(
                        message: 'This will cycle through selected snapshots with each crawl run',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Use rotating snapshots switch
                  SwitchListTile(
                    title: Text(
                      'Enable snapshot rotation',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      'Automatically cycle through selected snapshots when running recurring crawls',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    value: widget.config.useRotatingSnapshots,
                    onChanged: (value) {
                      setState(() {
                        widget.config.useRotatingSnapshots = value;
                        widget.onConfigUpdate();
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  
                  // Snapshot selection list
                  if (widget.config.useRotatingSnapshots) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Select snapshots to rotate through:',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    ...availableSnapshots.map((snapshot) {
                      final bool isSelected = _selectedRotatingSnapshots.contains(snapshot);
                      
                      return CheckboxListTile(
                        title: Text(snapshot),
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value != null && value) {
                              if (!_selectedRotatingSnapshots.contains(snapshot)) {
                                _selectedRotatingSnapshots.add(snapshot);
                              }
                            } else {
                              _selectedRotatingSnapshots.remove(snapshot);
                            }
                            
                            widget.config.selectedRotatingSnapshots = List.from(_selectedRotatingSnapshots);
                            widget.onConfigUpdate();
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildRadioOption({
    required RecurrenceFrequency value,
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
          color: widget.config.recurrenceFrequency == value 
              ? theme.colorScheme.primary.withOpacity(0.5)
              : theme.colorScheme.outlineVariant.withOpacity(0.5),
          width: widget.config.recurrenceFrequency == value ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: RadioListTile<RecurrenceFrequency>(
          title: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          value: value,
          groupValue: widget.config.recurrenceFrequency,
          onChanged: (newValue) {
            setState(() {
              widget.config.recurrenceFrequency = newValue!;
              widget.onConfigUpdate();
            });
          },
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          activeColor: theme.colorScheme.primary,
          selected: widget.config.recurrenceFrequency == value,
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ),
    );
  }
  
  Widget _buildFrequencyOptionContainer({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: child,
    );
  }
}

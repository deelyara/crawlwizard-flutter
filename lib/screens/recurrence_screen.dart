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
    'Latest Crawl (2025-03-22)',
    'Production Snapshot (2025-03-15)',
    'Translation Snapshot (2025-03-10)',
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

  // Calculate next run date based on settings
  String _getNextRunDate() {
    DateTime now = DateTime.now();
    DateTime nextRun;

    switch (widget.config.recurrenceFrequency) {
      case RecurrenceFrequency.daily:
        // Next run today at specified time if it's in the future, otherwise tomorrow
        TimeOfDay time = widget.config.recurrenceTime;
        DateTime todayWithTime = DateTime(
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        );
        nextRun =
            todayWithTime.isAfter(now)
                ? todayWithTime
                : todayWithTime.add(const Duration(days: 1));
        break;

      case RecurrenceFrequency.weekly:
        // Next run on the specified day of week at specified time
        int currentWeekday = now.weekday; // 1 = Monday, 7 = Sunday
        int daysUntilTarget =
            widget.config.recurrenceDayOfWeek - currentWeekday;
        if (daysUntilTarget < 0) daysUntilTarget += 7;

        TimeOfDay time = widget.config.recurrenceTime;
        DateTime targetDay = DateTime(
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        ).add(Duration(days: daysUntilTarget));

        // If it's the same day and time is earlier, add a week
        if (daysUntilTarget == 0 && targetDay.isBefore(now)) {
          targetDay = targetDay.add(const Duration(days: 7));
        }

        nextRun = targetDay;
        break;

      case RecurrenceFrequency.monthly:
        // Next run on the specified day of month at specified time
        int targetDay = widget.config.recurrenceDayOfMonth;
        TimeOfDay time = widget.config.recurrenceTime;

        // Create date for this month's target day
        DateTime thisMonthTarget = DateTime(
          now.year,
          now.month,
          targetDay,
          time.hour,
          time.minute,
        );

        // If this month's target is in the past, go to next month
        if (thisMonthTarget.isBefore(now)) {
          thisMonthTarget = DateTime(
            now.year,
            now.month + 1,
            targetDay,
            time.hour,
            time.minute,
          );
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
    String formattedDate =
        '${nextRun.year}-${nextRun.month.toString().padLeft(2, '0')}-${nextRun.day.toString().padLeft(2, '0')} ';
    String formattedTime =
        '${widget.config.recurrenceTime.hour.toString().padLeft(2, '0')}:${widget.config.recurrenceTime.minute.toString().padLeft(2, '0')}:00';

    return '$formattedDate$formattedTime';
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
    bool isRecurringEnabled =
        widget.config.recurrenceFrequency != RecurrenceFrequency.none;
    String nextRunDate = _getNextRunDate();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and description
        Text(
          'Set recurring crawl',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Configure recurring crawls to automatically extract new content at specified intervals.',
        ),
        const SizedBox(height: 24),

        // Crawl frequency card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Crawl frequency',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // None option
                RadioListTile<RecurrenceFrequency>(
                  title: const Text('No recurring crawls'),
                  subtitle: const Text('Run crawls manually only'),
                  value: RecurrenceFrequency.none,
                  groupValue: widget.config.recurrenceFrequency,
                  onChanged: (value) {
                    setState(() {
                      widget.config.recurrenceFrequency = value!;
                      widget.onConfigUpdate();
                    });
                  },
                ),

                // Daily option
                RadioListTile<RecurrenceFrequency>(
                  title: const Text('Daily'),
                  subtitle: const Text('Run crawl every day at specified time'),
                  value: RecurrenceFrequency.daily,
                  groupValue: widget.config.recurrenceFrequency,
                  onChanged: (value) {
                    setState(() {
                      widget.config.recurrenceFrequency = value!;
                      widget.onConfigUpdate();
                    });
                  },
                ),

                // Weekly option
                RadioListTile<RecurrenceFrequency>(
                  title: const Text('Weekly'),
                  subtitle: const Text(
                    'Run crawl once a week on specified day',
                  ),
                  value: RecurrenceFrequency.weekly,
                  groupValue: widget.config.recurrenceFrequency,
                  onChanged: (value) {
                    setState(() {
                      widget.config.recurrenceFrequency = value!;
                      widget.onConfigUpdate();
                    });
                  },
                ),

                // Monthly option
                RadioListTile<RecurrenceFrequency>(
                  title: const Text('Monthly'),
                  subtitle: const Text(
                    'Run crawl once a month on specified day',
                  ),
                  value: RecurrenceFrequency.monthly,
                  groupValue: widget.config.recurrenceFrequency,
                  onChanged: (value) {
                    setState(() {
                      widget.config.recurrenceFrequency = value!;
                      widget.onConfigUpdate();
                    });
                  },
                ),

                // Custom option
                RadioListTile<RecurrenceFrequency>(
                  title: const Text('Custom...'),
                  subtitle: const Text('Set a custom schedule'),
                  value: RecurrenceFrequency.custom,
                  groupValue: widget.config.recurrenceFrequency,
                  onChanged: (value) {
                    setState(() {
                      widget.config.recurrenceFrequency = value!;
                      widget.onConfigUpdate();
                    });
                  },
                ),

                // Divider before additional options
                if (isRecurringEnabled) const Divider(height: 32),

                // Additional options based on frequency
                if (isRecurringEnabled) ...[
                  // Time picker for all frequencies
                  InkWell(
                    onTap: () async {
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: widget.config.recurrenceTime,
                      );
                      if (pickedTime != null) {
                        setState(() {
                          widget.config.recurrenceTime = pickedTime;
                          widget.onConfigUpdate();
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Time of day',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${widget.config.recurrenceTime.hour.toString().padLeft(2, '0')}:${widget.config.recurrenceTime.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Day selector for weekly
                  if (widget.config.recurrenceFrequency ==
                      RecurrenceFrequency.weekly)
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Day of week',
                        isDense: true,
                      ),
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

                  // Day selector for monthly
                  if (widget.config.recurrenceFrequency ==
                      RecurrenceFrequency.monthly)
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Day of month',
                        isDense: true,
                      ),
                      value: widget.config.recurrenceDayOfMonth,
                      items:
                          _daysOfMonth.map((day) {
                            String suffix = '';
                            if (day == 1 || day == 21 || day == 31) {
                              suffix = 'st';
                            } else if (day == 2 || day == 22) {
                              suffix = 'nd';
                            } else if (day == 3 || day == 23) {
                              suffix = 'rd';
                            } else {
                              suffix = 'th';
                            }

                            return DropdownMenuItem<int>(
                              value: day,
                              child: Text('$day$suffix'),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          widget.config.recurrenceDayOfMonth = value!;
                          widget.onConfigUpdate();
                        });
                      },
                    ),

                  // Custom schedule UI would go here
                  if (widget.config.recurrenceFrequency ==
                      RecurrenceFrequency.custom)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        'Custom scheduling options will be implemented in a future version.',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                ],

                // Next run indicator
                if (isRecurringEnabled) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.schedule),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Next scheduled run:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            nextRunDate,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),

        // Rotating snapshots option (only visible for recurring crawls)
        if (isRecurringEnabled) ...[
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Use a different origin (source) snapshot for every crawl',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      InformationTooltip(
                        message:
                            'Rotate between snapshots to continuously update content while keeping production stable',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This creates a round-robin crawl pattern where content is written to different snapshots in sequence',
                  ),

                  Switch(
                    value: widget.config.useRotatingSnapshots,
                    onChanged: (value) {
                      setState(() {
                        widget.config.useRotatingSnapshots = value;
                        widget.onConfigUpdate();
                      });
                    },
                  ),

                  // Snapshot selection (only visible when rotation is enabled)
                  if (widget.config.useRotatingSnapshots) ...[
                    const Divider(),
                    const Text(
                      'Select snapshots to rotate between:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    ...availableSnapshots.map((snapshot) {
                      bool isSelected = _selectedRotatingSnapshots.contains(
                        snapshot,
                      );
                      return CheckboxListTile(
                        title: Text(snapshot),
                        value: isSelected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedRotatingSnapshots.add(snapshot);
                            } else {
                              _selectedRotatingSnapshots.remove(snapshot);
                            }
                            widget.config.selectedRotatingSnapshots = List.from(
                              _selectedRotatingSnapshots,
                            );
                            widget.onConfigUpdate();
                          });
                        },
                      );
                    }).toList(),

                    if (_selectedRotatingSnapshots.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Please select at least one snapshot for rotation',
                          style: TextStyle(
                            color: Colors.red,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),

                    if (_selectedRotatingSnapshots.length == 1)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'For effective rotation, select at least two snapshots',
                          style: TextStyle(
                            color: Colors.orange,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),

                    if (_selectedRotatingSnapshots.length > 1) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Rotation sequence: ${_selectedRotatingSnapshots.join(" → ")} → ${_selectedRotatingSnapshots.first}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

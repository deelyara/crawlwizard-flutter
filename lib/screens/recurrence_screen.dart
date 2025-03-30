import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/crawl_config.dart';

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
  // Whether the current user is an admin
  final bool _isAdmin = true;
  
  // Text controller for custom days
  final TextEditingController _customDaysController = TextEditingController(text: "100");
  
  // Selected date for first scheduled crawl
  DateTime? _selectedDate;
  
  @override
  void initState() {
    super.initState();
    _selectedDate = widget.config.firstScheduledCrawlDate;
  }
  
  @override
  void dispose() {
    _customDaysController.dispose();
    super.dispose();
  }

  // Calculate next run date based on settings
  String _getNextRunDate() {
    if (_selectedDate != null) {
      return '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
    }
    
    DateTime now = DateTime.now();
    DateTime nextRun;

    switch (widget.config.recurrenceFrequency) {
      case RecurrenceFrequency.daily:
        // Next run tomorrow
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
        DateTime thisMonthTarget = DateTime(now.year, now.month, targetDay);
        if (thisMonthTarget.isBefore(now)) {
          thisMonthTarget = DateTime(now.year, now.month + 1, targetDay);
        }
        nextRun = thisMonthTarget;
        break;

      case RecurrenceFrequency.custom:
        // For custom, use the value from the text field
        int days = int.tryParse(_customDaysController.text) ?? 100;
        nextRun = now.add(Duration(days: days));
        break;

      default:
        // For no recurrence, return empty string
        return 'Not scheduled';
    }

    // Format the date nicely
    String formattedDate = '${nextRun.year}-${nextRun.month.toString().padLeft(2, '0')}-${nextRun.day.toString().padLeft(2, '0')}';
    return formattedDate;
  }

  // Open date picker for selecting first scheduled crawl date
  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        widget.config.firstScheduledCrawlDate = picked;
        widget.onConfigUpdate();
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF37618E);
    final containerWidth = MediaQuery.of(context).size.width - 48; // Accounting for padding
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and description
        Text(
          'Set recurring crawl',
          style: GoogleFonts.roboto(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Configure recurring crawls to automatically extract new content at specified intervals',
          style: GoogleFonts.roboto(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 32),
        
        // Crawl frequency options without container
        Text(
          'Crawl frequency',
          style: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        
        // No recurring crawls option
        _buildRadioOption(
          value: RecurrenceFrequency.none,
          title: 'No recurring crawls',
        ),
        
        // Daily option
        _buildRadioOption(
          value: RecurrenceFrequency.daily,
          title: 'Daily',
        ),
        
        // Weekly option
        _buildRadioOption(
          value: RecurrenceFrequency.weekly,
          title: 'Weekly',
        ),
        
        // Monthly option
        _buildRadioOption(
          value: RecurrenceFrequency.monthly,
          title: 'Monthly',
        ),
        
        // Custom option with text field
        Row(
          children: [
            Radio<RecurrenceFrequency>(
              value: RecurrenceFrequency.custom,
              groupValue: widget.config.recurrenceFrequency,
              onChanged: (value) {
                setState(() {
                  widget.config.recurrenceFrequency = value!;
                  widget.onConfigUpdate();
                });
              },
              activeColor: primaryColor,
            ),
            Text(
              'Custom...',
              style: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 60,
              child: TextField(
                controller: _customDaysController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  enabled: widget.config.recurrenceFrequency == RecurrenceFrequency.custom,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  if (widget.config.recurrenceFrequency == RecurrenceFrequency.custom) {
                    widget.onConfigUpdate();
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'days',
              style: GoogleFonts.roboto(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        
        // Display next run date
        if (widget.config.recurrenceFrequency != RecurrenceFrequency.none) ...[
          const SizedBox(height: 24),
          Text(
            'The crawl is going to start ~${_getNextRunDate()} 00:00:00',
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Colors.black87,
            ),
          ),
        ],
        
        // Admin-only first scheduled crawl date selection without container
        if (_isAdmin && widget.config.recurrenceFrequency != RecurrenceFrequency.none) ...[
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'First scheduled crawl',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF2F7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Admin only feature',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: () => _selectDate(context),
                icon: const Icon(Icons.calendar_today, size: 16),
                label: Text(
                  _selectedDate != null 
                      ? '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}'
                      : 'Select date',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ],
          ),
        ],
        
        // Option to use different origin snapshot without container
        if (widget.config.recurrenceFrequency != RecurrenceFrequency.none) ...[
          const SizedBox(height: 24),
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: widget.config.useRotatingSnapshots,
                  onChanged: (value) {
                    setState(() {
                      widget.config.useRotatingSnapshots = value ?? false;
                      widget.onConfigUpdate();
                    });
                  },
                  activeColor: primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Use a different origin (source) snapshot for every crawl',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
  
  Widget _buildRadioOption({
    required RecurrenceFrequency value,
    required String title,
  }) {
    final primaryColor = const Color(0xFF37618E);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Radio<RecurrenceFrequency>(
            value: value,
            groupValue: widget.config.recurrenceFrequency,
            onChanged: (value) {
              setState(() {
                widget.config.recurrenceFrequency = value!;
                widget.onConfigUpdate();
              });
            },
            activeColor: primaryColor,
          ),
          Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

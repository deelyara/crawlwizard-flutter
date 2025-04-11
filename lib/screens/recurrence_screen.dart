import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/crawl_config.dart';
import '../theme/button_styles.dart';

class RecurrenceScreen extends StatefulWidget {
  final CrawlConfig config;
  final VoidCallback onConfigUpdate;
  final Function(int)? onEditStep;

  const RecurrenceScreen({
    super.key,
    required this.config,
    required this.onConfigUpdate,
    this.onEditStep,
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
    final DateTime now = DateTime.now();
    final DateTime twoDaysLater = DateTime(now.year, now.month, now.day + 2);
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: widget.config.recurrenceFrequency == RecurrenceFrequency.daily ? twoDaysLater : now.add(const Duration(days: 1)),
      firstDate: widget.config.recurrenceFrequency == RecurrenceFrequency.daily ? twoDaysLater : now.add(const Duration(days: 1)),
      lastDate: DateTime(2100),
      selectableDayPredicate: (DateTime date) {
        if (widget.config.recurrenceFrequency == RecurrenceFrequency.daily) {
          return date.isAfter(now.add(const Duration(days: 1)));
        }
        return date.isAfter(now);
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        widget.config.firstScheduledCrawlDate = picked;
        widget.onConfigUpdate();
      });
    }
  }
  
  void _updateRecurrenceFrequency(RecurrenceFrequency? value) {
    if (value == null) return;
    
    setState(() {
      widget.config.recurrenceFrequency = value;
      
      // Set first scheduled crawl date based on frequency
      final now = DateTime.now();
      if (value == RecurrenceFrequency.daily) {
        // For daily recurrence, set start date to 2 days later
        widget.config.firstScheduledCrawlDate = DateTime(
          now.year,
          now.month,
          now.day + 2,
          widget.config.recurrenceTime.hour,
          widget.config.recurrenceTime.minute,
        );
      } else {
        // For other frequencies, set to next day
        widget.config.firstScheduledCrawlDate = DateTime(
          now.year,
          now.month,
          now.day + 1,
          widget.config.recurrenceTime.hour,
          widget.config.recurrenceTime.minute,
        );
      }
      
      widget.onConfigUpdate();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF37618E);
    
    // Check if recurrence is allowed for the current configuration
    if (!widget.config.isRecurrenceAllowed()) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recurrence',
            style: GoogleFonts.notoSans(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFFECD1)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: const Color(0xFFDC6803),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.config.crawlType == CrawlType.tlsContentExtraction && widget.config.generateWorkPackages
                        ? 'Recurrence can\'t be set for TLS content extraction and work package generation'
                        : widget.config.crawlType == CrawlType.tlsContentExtraction
                            ? 'Recurrence can\'t be set for TLS content extraction'
                            : 'Recurrence can\'t be set for work package generation',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final containerWidth = MediaQuery.of(context).size.width - 48; // Accounting for padding
    
    // Check if TLS or work package is selected
    final bool isTlsSelected = widget.config.crawlType == CrawlType.tlsContentExtraction;
    final bool hasWorkPackage = widget.config.generateWorkPackages;
    
    if (isTlsSelected || hasWorkPackage) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and description
          Text(
            'Set recurrence for this crawl',
            style: GoogleFonts.notoSans(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Configure recurring crawls to automatically extract new content at specified intervals',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 32),
          
          // Warning message
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFFECD1)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: const Color(0xFFDC6803),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isTlsSelected && hasWorkPackage
                        ? 'Recurrence can\'t be set for TLS content extraction and work package generation'
                        : isTlsSelected
                            ? 'Recurrence can\'t be set for TLS content extraction'
                            : 'Recurrence can\'t be set for work package generation',
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title and description
        Text(
          'Set recurrence for this crawl',
          style: GoogleFonts.notoSans(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Configure recurring crawls to automatically extract new content at specified intervals',
          style: GoogleFonts.notoSans(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 32),
        
        // Crawl frequency options without container
        Text(
          'Crawl frequency',
          style: GoogleFonts.notoSans(
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
              onChanged: _updateRecurrenceFrequency,
              activeColor: primaryColor,
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  widget.config.recurrenceFrequency = RecurrenceFrequency.custom;
                  widget.onConfigUpdate();
                });
              },
              child: Text(
                'Every...',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 60,
              child: TextField(
                controller: _customDaysController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
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
              style: GoogleFonts.notoSans(
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
            'The crawl is going to start ~${_getNextRunDate()}',
            style: GoogleFonts.notoSans(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Colors.black87,
            ),
          ),
        ],
        
        // First scheduled crawl date selection without container
        if (widget.config.recurrenceFrequency != RecurrenceFrequency.none) ...[
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'First scheduled crawl',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: () => _selectDate(context),
                style: AppButtonStyles.outlinedButton,
                child: AppButtonStyles.buttonWithIcon(
                  text: _selectedDate != null 
                      ? '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}'
                      : 'Select date',
                  icon: Icons.calendar_today,
                  iconLeading: true,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDF2F7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Admin only feature',
                  style: GoogleFonts.notoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
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
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          if (widget.config.useRotatingSnapshots) ...[
            Padding(
              padding: const EdgeInsets.only(left: 36, top: 8),
              child: Row(
                children: [
                  Text(
                    "Don't forget to ",
                    style: GoogleFonts.notoSans(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (widget.onEditStep != null) {
                        widget.onEditStep!(3);
                      }
                    },
                    child: Row(
                      children: [
                        Text(
                          "set snapshots",
                          style: GoogleFonts.notoSans(
                            fontSize: 12,
                            color: primaryColor,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.edit,
                          size: 12,
                          color: primaryColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
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
      child: GestureDetector(
        onTap: () {
          setState(() {
            widget.config.recurrenceFrequency = value;
            widget.onConfigUpdate();
          });
        },
        child: Row(
          children: [
            Radio<RecurrenceFrequency>(
              value: value,
              groupValue: widget.config.recurrenceFrequency,
              onChanged: _updateRecurrenceFrequency,
              activeColor: primaryColor,
            ),
            Text(
              title,
              style: GoogleFonts.notoSans(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

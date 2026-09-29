import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dhabayih_lmamlaka/generated/l10n.dart';
import 'package:dhabayih_lmamlaka/core/theme/colors.dart';

class DeliveryCalendarWidget extends StatefulWidget {
  final Function(DateTime selectedDate, String timeSlot) onScheduleChanged;

  const DeliveryCalendarWidget({super.key, required this.onScheduleChanged});

  @override
  State<DeliveryCalendarWidget> createState() => _DeliveryCalendarWidgetState();
}

class _DeliveryCalendarWidgetState extends State<DeliveryCalendarWidget> {
  int _selectedDateIndex = 0; // 0 = Today, 1 = Tomorrow, 2 = Custom
  DateTime _selectedDate = DateTime.now();
  int _selectedTimeSlotIndex = 0; // 0 = Morning, 1 = Afternoon, 2 = Evening

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyChange();
    });
  }

  void _notifyChange() {
    String timeSlot;
    final s = S.of(context);
    if (_selectedTimeSlotIndex == 0) {
      timeSlot = s.time_slot_morning;
    } else if (_selectedTimeSlotIndex == 1) {
      timeSlot = s.time_slot_afternoon;
    } else {
      timeSlot = s.time_slot_evening;
    }
    widget.onScheduleChanged(_selectedDate, timeSlot);
  }

  Future<void> _pickCustomDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDate.isBefore(DateTime.now().add(const Duration(days: 2)))
          ? DateTime.now().add(const Duration(days: 2))
          : _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedDateIndex = 2;
      });
      _notifyChange();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final s = S.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final timeSlots = [
      s.time_slot_morning,
      s.time_slot_afternoon,
      s.time_slot_evening,
    ];

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDark
            ? cs.surfaceContainerHighest.withOpacity(0.4)
            : cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? cs.outline.withOpacity(0.3)
              : cs.outline.withOpacity(0.5),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month_rounded, color: cs.primary, size: 24),
              const SizedBox(width: 10),
              Text(
                s.delivery_schedule,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            s.select_delivery_date,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurface.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildDateChip(
                  context,
                  index: 0,
                  label: s.today,
                  date: DateTime.now(),
                  onTap: () {
                    setState(() {
                      _selectedDateIndex = 0;
                      _selectedDate = DateTime.now();
                    });
                    _notifyChange();
                  },
                ),
                const SizedBox(width: 8),
                _buildDateChip(
                  context,
                  index: 1,
                  label: s.tomorrow,
                  date: DateTime.now().add(const Duration(days: 1)),
                  onTap: () {
                    setState(() {
                      _selectedDateIndex = 1;
                      _selectedDate = DateTime.now().add(
                        const Duration(days: 1),
                      );
                    });
                    _notifyChange();
                  },
                ),
                const SizedBox(width: 8),
                _buildDateChip(
                  context,
                  index: 2,
                  label: _selectedDateIndex == 2
                      ? DateFormat(
                          'dd/MM/yyyy',
                          Localizations.localeOf(context).languageCode,
                        ).format(_selectedDate)
                      : s.custom_date,
                  icon: Icons.date_range_rounded,
                  onTap: () => _pickCustomDate(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            s.select_delivery_time,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurface.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 10),
          Column(
            children: List.generate(timeSlots.length, (index) {
              final isSelected = _selectedTimeSlotIndex == index;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedTimeSlotIndex = index;
                    });
                    _notifyChange();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? cs.primary.withOpacity(0.15)
                          : (isDark
                                ? cs.surfaceContainerHighest.withOpacity(0.3)
                                : cs.surfaceContainerHighest.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? cs.primary
                            : cs.outline.withOpacity(0.3),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: isSelected ? cs.primary : cs.onSurfaceVariant,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            timeSlots[index],
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isSelected ? cs.primary : cs.onSurface,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDateChip(
    BuildContext context, {
    required int index,
    required String label,
    DateTime? date,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isSelected = _selectedDateIndex == index;

    String dateSubText = '';
    if (date != null) {
      dateSubText = DateFormat(
        'dd/MM',
        Localizations.localeOf(context).languageCode,
      ).format(date);
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? cs.primary
              : (theme.brightness == Brightness.dark
                    ? cs.surfaceContainerHighest.withOpacity(0.3)
                    : cs.surfaceContainerHighest.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? cs.primary : cs.outline.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
            ],
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isSelected ? cs.onPrimary : cs.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
                if (dateSubText.isNotEmpty)
                  Text(
                    dateSubText,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isSelected
                          ? cs.onPrimary.withOpacity(0.9)
                          : cs.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

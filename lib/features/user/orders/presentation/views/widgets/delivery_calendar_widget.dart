import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dhabayih_lmamlaka/generated/l10n.dart';
import 'package:dhabayih_lmamlaka/core/theme/colors.dart';

class DeliveryCalendarWidget extends StatefulWidget {
  final Function(DateTime selectedDate, String timeSlot) onScheduleChanged;

  const DeliveryCalendarWidget({super.key, required this.onScheduleChanged});

  /// Authoritative Saudi Arabia business time (Asia/Riyadh = UTC+3)
  static DateTime get riyadhNow =>
      DateTime.now().toUtc().add(const Duration(hours: 3));

  static DateTime get riyadhToday {
    final now = riyadhNow;
    return DateTime(now.year, now.month, now.day);
  }

  /// End hour (24h) for each of the 3 slaughter/preparation slots in Riyadh time
  static const List<int> slotEndHours = [12, 16, 20];

  static bool isSlotAvailableOnDate(DateTime date, int slotIndex) {
    final today = riyadhToday;
    final normalized = DateTime(date.year, date.month, date.day);
    if (normalized.isBefore(today)) return false;
    if (normalized.isAfter(today)) return true;
    final endHour = slotEndHours[slotIndex.clamp(0, slotEndHours.length - 1)];
    return riyadhNow.hour < endHour;
  }

  static bool get hasAnySlotToday =>
      isSlotAvailableOnDate(riyadhToday, 0) ||
      isSlotAvailableOnDate(riyadhToday, 1) ||
      isSlotAvailableOnDate(riyadhToday, 2);

  static bool isScheduleValid(
    String? dateIso,
    String? timeSlot, {
    DateTime? nowOverride,
  }) {
    if (dateIso == null || dateIso.trim().isEmpty) return false;
    if (timeSlot == null || timeSlot.trim().isEmpty) return false;
    final parsed = DateTime.tryParse(dateIso.trim());
    if (parsed == null) return false;
    final now =
        nowOverride ?? DateTime.now().toUtc().add(const Duration(hours: 3));
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(parsed.year, parsed.month, parsed.day);
    if (selectedDay.isBefore(today)) return false;
    if (selectedDay.isAtSameMomentAs(today)) {
      final t = timeSlot.trim();
      int? endHour;
      if (t.contains('صباح') || t.toLowerCase().contains('morning') || t.contains('8:00')) {
        endHour = 12;
      } else if (t.contains('ظهر') || t.toLowerCase().contains('afternoon') || t.contains('12:00')) {
        endHour = 16;
      } else if (t.contains('مسا') || t.toLowerCase().contains('evening') || t.contains('4:00')) {
        endHour = 20;
      }
      if (endHour != null && now.hour >= endHour) {
        return false;
      }
    }
    return true;
  }

  @override
  State<DeliveryCalendarWidget> createState() => _DeliveryCalendarWidgetState();
}

class _DeliveryCalendarWidgetState extends State<DeliveryCalendarWidget> {
  int _selectedDateIndex = 0; // 0 = Today, 1 = Tomorrow, 2 = Custom
  late DateTime _selectedDate;
  int _selectedTimeSlotIndex = 0; // 0 = Morning, 1 = Afternoon, 2 = Evening

  @override
  void initState() {
    super.initState();
    final today = DeliveryCalendarWidget.riyadhToday;
    if (DeliveryCalendarWidget.hasAnySlotToday) {
      _selectedDateIndex = 0;
      _selectedDate = today;
      _selectedTimeSlotIndex = _firstAvailableSlotForDate(today);
    } else {
      _selectedDateIndex = 1;
      _selectedDate = today.add(const Duration(days: 1));
      _selectedTimeSlotIndex = 0;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _notifyChange();
    });
  }

  int _firstAvailableSlotForDate(DateTime date) {
    for (int i = 0; i < 3; i++) {
      if (DeliveryCalendarWidget.isSlotAvailableOnDate(date, i)) {
        return i;
      }
    }
    return 0;
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
    final today = DeliveryCalendarWidget.riyadhToday;
    final minCustom = today.add(const Duration(days: 2));
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(minCustom) ? minCustom : _selectedDate,
      firstDate: DeliveryCalendarWidget.hasAnySlotToday
          ? today
          : today.add(const Duration(days: 1)),
      lastDate: today.add(const Duration(days: 30)),
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
        _selectedDate = DateTime(picked.year, picked.month, picked.day);
        if (_selectedDate.isAtSameMomentAs(today)) {
          _selectedDateIndex = 0;
        } else if (_selectedDate.isAtSameMomentAs(today.add(const Duration(days: 1)))) {
          _selectedDateIndex = 1;
        } else {
          _selectedDateIndex = 2;
        }
        if (!DeliveryCalendarWidget.isSlotAvailableOnDate(
          _selectedDate,
          _selectedTimeSlotIndex,
        )) {
          _selectedTimeSlotIndex = _firstAvailableSlotForDate(_selectedDate);
        }
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
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final today = DeliveryCalendarWidget.riyadhToday;
    final todayAvailable = DeliveryCalendarWidget.hasAnySlotToday;

    final timeSlots = [
      s.time_slot_morning,
      s.time_slot_afternoon,
      s.time_slot_evening,
    ];

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDark
            ? cs.surfaceContainerHighest.withValues(alpha: 0.4)
            : cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? cs.outline.withValues(alpha: 0.3)
              : cs.outline.withValues(alpha: 0.5),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
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
              Expanded(
                child: Text(
                  isAr
                      ? 'موعد الذبح والتجهيز (توقيت الرياض)'
                      : 'Slaughter & Preparation Schedule',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            isAr ? 'اختر تاريخ الذبح' : s.select_delivery_date,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurface.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                if (todayAvailable) ...[
                  _buildDateChip(
                    context,
                    index: 0,
                    label: s.today,
                    date: today,
                    onTap: () {
                      setState(() {
                        _selectedDateIndex = 0;
                        _selectedDate = today;
                        if (!DeliveryCalendarWidget.isSlotAvailableOnDate(
                          today,
                          _selectedTimeSlotIndex,
                        )) {
                          _selectedTimeSlotIndex = _firstAvailableSlotForDate(
                            today,
                          );
                        }
                      });
                      _notifyChange();
                    },
                  ),
                  const SizedBox(width: 8),
                ],
                _buildDateChip(
                  context,
                  index: 1,
                  label: s.tomorrow,
                  date: today.add(const Duration(days: 1)),
                  onTap: () {
                    setState(() {
                      _selectedDateIndex = 1;
                      _selectedDate = today.add(const Duration(days: 1));
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
            isAr ? 'اختر فترة الذبح والتجهيز' : s.select_delivery_time,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: cs.onSurface.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 10),
          Column(
            children: List.generate(timeSlots.length, (index) {
              final isAvailable = DeliveryCalendarWidget.isSlotAvailableOnDate(
                _selectedDate,
                index,
              );
              final isSelected = _selectedTimeSlotIndex == index && isAvailable;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Opacity(
                  opacity: isAvailable ? 1.0 : 0.45,
                  child: InkWell(
                    onTap: isAvailable
                        ? () {
                            setState(() {
                              _selectedTimeSlotIndex = index;
                            });
                            _notifyChange();
                          }
                        : null,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? cs.primary.withValues(alpha: 0.15)
                            : (isDark
                                  ? cs.surfaceContainerHighest.withValues(
                                      alpha: 0.3,
                                    )
                                  : cs.surfaceContainerHighest.withValues(
                                      alpha: 0.5,
                                    )),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? cs.primary
                              : cs.outline.withValues(alpha: 0.3),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: isSelected
                                ? cs.primary
                                : cs.onSurfaceVariant,
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
                          if (!isAvailable)
                            Text(
                              isAr ? 'انتهت الفترة' : 'Passed',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: cs.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
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

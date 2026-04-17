import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/core/utils/time_formatter.dart';
import 'package:intl/intl.dart';

class SlotSelectionDateHeader extends StatelessWidget {
  final DateTime date;
  final bool isToday;
  final DateTime now;

  const SlotSelectionDateHeader({
    required this.date,
    required this.isToday,
    required this.now,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.elevatedBgColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.elevatedBgColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, color: AppColors.elevatedBgColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, MMMM dd, yyyy').format(date),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.elevatedBgColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isToday) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Today • Current time: ${formatTimeTo12Hour(DateFormat('HH:mm').format(now))}',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.lightTextColor2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/data/models/notification_item_model.dart';
import 'package:idoc_user/presentation/screens/notification/widgets/notifications_card.dart';
import 'package:intl/intl.dart';

class NotificationList extends StatelessWidget {
  final List<NotificationItemModel> notifications;
  final String userId;

  const NotificationList({
    required this.notifications,
    required this.userId,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    // Group by date label.
    final grouped = <String, List<NotificationItemModel>>{};
    for (final n in notifications) {
      grouped.putIfAbsent(_dateLabel(n.timestamp), () => []).add(n);
    }
    final keys = grouped.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      physics: const BouncingScrollPhysics(),
      itemCount: keys.length,
      itemBuilder: (context, sectionIndex) {
        final dateLabel = keys[sectionIndex];
        final items = grouped[dateLabel]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
              child: Text(
                dateLabel,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            ...items.map(
              (n) => NotificationCard(notification: n, userId: userId),
            ),
          ],
        );
      },
    );
  }

  String _dateLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dt.year, dt.month, dt.day);

    if (date == today) return 'Today';
    if (date == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return DateFormat('d MMM yyyy').format(dt);
  }
}
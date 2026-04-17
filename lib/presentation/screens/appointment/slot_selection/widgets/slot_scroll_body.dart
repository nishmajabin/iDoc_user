import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/presentation/screens/appointment/slot_selection/widgets/slot_organizer.dart';
import 'package:idoc_user/presentation/screens/appointment/slot_selection/widgets/slot_scroll_period_config.dart';
import 'package:idoc_user/presentation/screens/appointment/slot_selection/widgets/slot_selection_date_header.dart';
import 'package:idoc_user/presentation/screens/appointment/slot_selection/widgets/slot_selection_legend.dart';
import 'package:idoc_user/presentation/screens/appointment/slot_selection/widgets/slot_selection_section.dart';
import 'package:idoc_user/presentation/screens/appointment/slot_selection/widgets/slot_selection_today_notice.dart';
import 'package:idoc_user/presentation/screens/appointment/slot_selection/widgets/slot_time_helper.dart';

class SlotScrollBody extends StatelessWidget {
  const SlotScrollBody({
    required this.selectedDate,
    required this.isToday,
    required this.now,
    required this.groups,
    required this.selectedSlotId,
    super.key,
  });

  final DateTime selectedDate;
  final bool isToday;
  final DateTime now;
  final SlotGroups groups;
  final String? selectedSlotId;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SlotSelectionDateHeader(
            date: selectedDate,
            isToday: isToday,
            now: now,
          ),
          if (isToday) ...[
            const SizedBox(height: 8),
            SlotSelectionTodayNotice(),
          ],
          const SizedBox(height: 8),
          SlotSelectionLegend(),
          const SizedBox(height: 16),
          ..._buildPeriodSections(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // ── Period section builders ──────────────────────────────────────────────

  List<Widget> _buildPeriodSections() {
    final sections =
        <SlotScrollPeriodConfig>[
          SlotScrollPeriodConfig(
            title: 'Morning Slots',
            slots: groups.morning,
            icon: Icons.wb_sunny,
            color: AppColors.morningSlotColor,
          ),
          SlotScrollPeriodConfig(
            title: 'Afternoon Slots',
            slots: groups.afternoon,
            icon: Icons.wb_sunny_outlined,
            color: AppColors.afternoonSlotColor,
          ),
          SlotScrollPeriodConfig(
            title: 'Evening Slots',
            slots: groups.evening,
            icon: Icons.nights_stay,
            color: AppColors.eveningSlotColor,
          ),
        ].where((c) => c.slots.isNotEmpty).toList();

    final widgets = <Widget>[];

    for (var i = 0; i < sections.length; i++) {
      if (i > 0) widgets.add(const SizedBox(height: 24));
      widgets.add(_buildSection(sections[i]));
    }

    return widgets;
  }

  Widget _buildSection(SlotScrollPeriodConfig config) {
    return SlotSelectionSection(
      title: config.title,
      slots: config.slots,
      selectedSlotId: selectedSlotId,
      icon: config.icon,
      color: config.color,
      isToday: isToday,
      selectedDate: selectedDate,
      isSlotInPast: SlotTimeHelper.isSlotInPast,
    );
  }
}


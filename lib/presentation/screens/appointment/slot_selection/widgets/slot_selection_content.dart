import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/logic/blocs/auth/auth_bloc.dart';
import 'package:idoc_user/logic/blocs/auth/auth_state.dart';
import 'package:idoc_user/logic/blocs/appointment/appointment_state.dart';
import 'package:idoc_user/presentation/screens/appointment/slot_selection/widgets/slot_empty_date_view.dart';
import 'package:idoc_user/presentation/screens/appointment/slot_selection/widgets/slot_organizer.dart';
import 'package:idoc_user/presentation/screens/appointment/slot_selection/widgets/slot_selection_bottom_bar.dart';
import 'package:idoc_user/presentation/screens/appointment/slot_selection/widgets/slot_selection_date_picker_row.dart';
import 'package:idoc_user/presentation/screens/appointment/slot_selection/widgets/slot_scroll_body.dart';

class SlotSelectionContent extends StatelessWidget {
  const SlotSelectionContent({
    required this.state,
    required this.doctorId,
    required this.consultationFee,
    this.doctorName,
    this.doctorSpecialist,
    this.doctorProfileImageUrl,
    super.key,
  });

  final SlotsFetched state;
  final String doctorId;
  final String? doctorName;
  final String? doctorSpecialist;
  final String? doctorProfileImageUrl;
  final double consultationFee;

  // ── Date helpers ─────────────────────────────────────────────────────────

  static DateTime _normalise(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context) {
    // ── Auth ──────────────────────────────────────────────────────────────
    final authState = context.read<AuthBloc>().state;
    final String? userId =
        authState is AuthAuthenticated ? authState.user.uid : null;

    // ── Date setup ────────────────────────────────────────────────────────
    final now = DateTime.now();
    final today = _normalise(now);
    final normalizedSelectedDate = _normalise(state.selectedDate);
    final isSelectedDateToday =
        normalizedSelectedDate.isAtSameMomentAs(today);

    // ── Data preparation (pure — no Flutter context needed) ───────────────
    final availableDates = SlotOrganizer.buildAvailableDates(state.slots);
    final slotsForSelectedDate =
        SlotOrganizer.slotsForDate(state.slots, normalizedSelectedDate);
    final groups = SlotOrganizer.groupByPeriod(slotsForSelectedDate);

    return Column(
      children: [
        // Date picker row
        SlotSelectionDatePickerRow(
          availableDates: availableDates,
          selectedDate: normalizedSelectedDate,
        ),

        // Slot content area
        Expanded(
          child: slotsForSelectedDate.isEmpty
              ? const SlotEmptyDateView()
              : SlotScrollBody(
                  selectedDate: normalizedSelectedDate,
                  isToday: isSelectedDateToday,
                  now: now,
                  groups: groups,
                  selectedSlotId: state.selectedSlotId,
                ),
        ),

        // Bottom booking bar
        SlotSelectionBottomBar(
          state: state,
          userId: userId,
          consultationFee: consultationFee,
          doctorId: doctorId,
          doctorName: doctorName,
          doctorSpecialist: doctorSpecialist,
          doctorProfileImageUrl: doctorProfileImageUrl,
        ),
      ],
    );
  }
}
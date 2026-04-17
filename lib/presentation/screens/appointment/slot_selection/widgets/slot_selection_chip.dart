import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/core/constants/slot_status.dart';
import 'package:idoc_user/core/utils/time_formatter.dart';
import 'package:idoc_user/logic/blocs/appointment/appointment_bloc.dart';
import 'package:idoc_user/logic/blocs/appointment/appointment_event.dart';
import 'package:idoc_user/presentation/screens/appointment/slot_selection/widgets/chip_styling.dart';
import 'package:idoc_user/presentation/screens/appointment/slot_selection/widgets/slot_selection_time_label.dart';

class SlotSelectionChip extends StatelessWidget {
  const SlotSelectionChip({
    required this.slotId,
    required this.rawStart,
    required this.rawEnd,
    required this.status,
    required this.isSelected,
    super.key,
  });
 
  final String slotId;
  final String rawStart;
  final String rawEnd;
  final SlotStatus status;
  final bool isSelected;
 
  bool get _isInteractive => status == SlotStatus.available;
 
  double get _opacity => switch (status) {
    SlotStatus.past => 0.5,
    SlotStatus.booked => 0.85,
    _ => 1.0,
  };
 
  @override
  Widget build(BuildContext context) {
    final displayStart = formatTimeTo12Hour(rawStart);
    final displayEnd = formatTimeTo12Hour(rawEnd);
    final badge = badgeLabel(status);
 
    return GestureDetector(
      onTap:
          _isInteractive
              ? () => context.read<AppointmentBloc>().add(
                SelectSlotEvent(
                  slotId: slotId,
                  startTime: rawStart,
                  endTime: rawEnd,
                ),
              )
              : null,
      child: Opacity(
        opacity: _opacity,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: chipBackground(status, isSelected),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: chipBorder(status, isSelected),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: chipShadow(status, isSelected),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                leadingIcon(status, isSelected),
                size: 16,
                color: iconColor(status, isSelected),
              ),
              const SizedBox(width: 6),
              SlotSelectionTimeLabel(
                displayStart: displayStart,
                displayEnd: displayEnd,
                status: status,
              ),
              if (badge.isNotEmpty) ...[
                const SizedBox(width: 6),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
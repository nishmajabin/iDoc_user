import 'package:flutter/material.dart';
import 'package:idoc_user/core/constants/slot_status.dart';
import 'package:idoc_user/presentation/screens/appointment/slot_selection/widgets/chip_styling.dart';

class SlotSelectionTimeLabel extends StatelessWidget {
  const SlotSelectionTimeLabel({
    required this.displayStart,
    required this.displayEnd,
    required this.status,
    super.key
  });
 
  final String displayStart;
  final String displayEnd;
  final SlotStatus status;
 
  @override
  Widget build(BuildContext context) {
    return Text(
      '$displayStart – $displayEnd',
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: labelColor(status, false),
        decoration:
            status == SlotStatus.past ? TextDecoration.lineThrough : null,
      ),
      maxLines: 1,
    );
  }
}
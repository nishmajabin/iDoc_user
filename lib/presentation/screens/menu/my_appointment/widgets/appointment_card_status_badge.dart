import 'package:flutter/material.dart';
import 'package:idoc_user/presentation/screens/menu/my_appointment/widgets/status_style.dart';

class AppointmentCardStatusBadge extends StatelessWidget {
  final StatusStyle style;
  const AppointmentCardStatusBadge(this.style, {super.key});
 
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: style.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(style.icon, size: 12, color: style.color),
            const SizedBox(width: 4),
            Text(style.label,
                style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700, color: style.color)),
          ],
        ),
      );
}
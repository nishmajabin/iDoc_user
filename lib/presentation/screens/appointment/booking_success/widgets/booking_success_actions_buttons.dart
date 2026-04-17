import 'package:flutter/material.dart';
import 'package:idoc_user/presentation/screens/appointment/booking_success/widgets/custom_box_decoration.dart';

class BookingSuccessActionsButtons extends StatelessWidget {
  const BookingSuccessActionsButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () =>
                Navigator.of(context).popUntil((r) => r.isFirst),
            style: primaryButtonStyle(),
            child: const Text('Done'),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () =>
                Navigator.of(context).popUntil((r) => r.isFirst),
            style: outlineButtonStyle(),
            child: const Text('View My Appointments'),
          ),
        ),
      ],
    );
  }
}
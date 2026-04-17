import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/presentation/screens/appointment/booking_success/widgets/booking_success_detail_row.dart';
import 'package:idoc_user/presentation/screens/appointment/booking_success/widgets/booking_success_payment_box.dart';
import 'package:idoc_user/presentation/screens/appointment/booking_success/widgets/custom_box_decoration.dart';
import 'package:intl/intl.dart';

class BookingSuccessDetailsCard extends StatelessWidget {
  final String doctorName;
  final DateTime appointmentDate;
  final String startTime;
  final String endTime;
  final String? paymentId;

  const BookingSuccessDetailsCard({
    required this.doctorName,
    required this.appointmentDate,
    required this.startTime,
    required this.endTime,
    this.paymentId,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: cardDecoration(),
      child: Column(
        children: [
          BookingSuccessDetailRow(
            icon: Icons.person_outline,
            label: 'Doctor',
            value: 'Dr. $doctorName',
          ),
          const SizedBox(height: 16),

          BookingSuccessDetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'Date',
            value: DateFormat('EEEE, MMMM dd, yyyy')
                .format(appointmentDate),
          ),
          const SizedBox(height: 16),

          BookingSuccessDetailRow(
            icon: Icons.access_time_outlined,
            label: 'Time',
            value: '$startTime - $endTime',
          ),

          if (paymentId != null) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            BookingSuccessDetailRow(
              icon: Icons.payment_outlined,
              label: 'Payment Status',
              value: 'Paid',
              valueColor: AppColors.successBgColor,
            ),

            const SizedBox(height: 12),
            BookingSuccessPaymentBox(paymentId: paymentId!),
          ],
        ],
      ),
    );
  }
}
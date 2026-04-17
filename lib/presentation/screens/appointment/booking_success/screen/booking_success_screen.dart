import 'package:flutter/material.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/presentation/screens/appointment/booking_success/widgets/booking_success_actions_buttons.dart';
import 'package:idoc_user/presentation/screens/appointment/booking_success/widgets/booking_success_appbar.dart';
import 'package:idoc_user/presentation/screens/appointment/booking_success/widgets/booking_success_details_card.dart';
import 'package:idoc_user/presentation/screens/appointment/booking_success/widgets/booking_success_header.dart';
import 'package:idoc_user/presentation/screens/appointment/booking_success/widgets/booking_success_icon.dart';
import 'package:idoc_user/presentation/screens/appointment/booking_success/widgets/booking_success_info_card.dart';

class BookingSuccessScreen extends StatelessWidget {
  final String doctorName;
  final DateTime appointmentDate;
  final String startTime;
  final String endTime;
  final String? paymentId;

  const BookingSuccessScreen({
    super.key,
    required this.doctorName,
    required this.appointmentDate,
    required this.startTime,
    required this.endTime,
    this.paymentId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar:  BookingSuccessAppBar(),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const BookingSuccessIcon(),
              const SizedBox(height: 32),

              const BookingSuccessHeader(),
              const SizedBox(height: 32),

               BookingSuccessDetailsCard(
                doctorName: doctorName,
                appointmentDate: appointmentDate,
                startTime: startTime,
                endTime: endTime,
                paymentId: paymentId,
              ),

              const SizedBox(height: 24),
              const BookingSuccessInfoCard(),

              const SizedBox(height: 32),
              const BookingSuccessActionsButtons(),
            ],
          ),
        ),
      ),
    );
  }
}

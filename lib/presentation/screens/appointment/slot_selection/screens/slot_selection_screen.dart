import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/core/utils/time_formatter.dart';
import 'package:idoc_user/logic/blocs/appointment/appointment_bloc.dart';
import 'package:idoc_user/logic/blocs/appointment/appointment_state.dart';
import 'package:idoc_user/logic/blocs/payment/payment_bloc.dart';
import 'package:idoc_user/logic/blocs/payment/payment_state.dart';
import 'package:idoc_user/presentation/screens/appointment/booking_success/screen/booking_success_screen.dart';
import 'package:idoc_user/presentation/screens/appointment/slot_selection/widgets/no_slots_available_view.dart';
import 'package:idoc_user/presentation/screens/appointment/slot_selection/widgets/slot_selection_content.dart';


class SlotSelectionScreen extends StatelessWidget {
  final String doctorId;
  final String? doctorName;
  final String? doctorSpecialist;
  final String? doctorProfileImageUrl;
  final double consultationFee;

  const SlotSelectionScreen({
    super.key,
    required this.doctorId,
    this.doctorName,
    this.doctorSpecialist,
    this.doctorProfileImageUrl,
    required this.consultationFee,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        title: const Text('Select Time Slot'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.backgroundColor,
        foregroundColor: AppColors.shadowDark,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<PaymentBloc, PaymentState>(
            listener: (context, state) {
              if (state is PaymentAndBookingSuccess) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => BookingSuccessScreen(
                          doctorName: state.doctorName,
                          appointmentDate: state.appointmentDate,
                          startTime: formatTimeTo12Hour(state.startTime),
                          endTime: formatTimeTo12Hour(state.endTime),
                          paymentId: state.paymentId,
                        ),
                  ),
                );
              } else if (state is PaymentFailed) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Payment Failed: ${state.message}'),
                    backgroundColor: AppColors.errorBgColor,
                    duration: const Duration(seconds: 5),
                    action: SnackBarAction(
                      label: 'OK',
                      textColor: AppColors.bgColor,
                      onPressed:
                          () =>
                              ScaffoldMessenger.of(
                                context,
                              ).hideCurrentSnackBar(),
                    ),
                  ),
                );
              } else if (state is PaymentCancelled) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Payment cancelled by user'),
                    backgroundColor: AppColors.cancelledColor,
                    duration: Duration(seconds: 3),
                  ),
                );
              } else if (state is PaymentError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.errorBgColor,
                    duration: const Duration(seconds: 5),
                  ),
                );
              }
            },
          ),
          BlocListener<AppointmentBloc, AppointmentState>(
            listener: (context, state) {
              if (state is AppointmentError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.errorBgColor,
                    duration: const Duration(seconds: 5),
                  ),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<AppointmentBloc, AppointmentState>(
          builder: (context, state) {
            if (state is AppointmentLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is SlotsFetched) {
              // "No slots" means no available + no booked — truly empty.
              if (state.slots.isEmpty) {
                return NoSlotsAvailableView(
                  doctorName: doctorName,
                );
              }
              return SlotSelectionContent(
                state: state,
                doctorId: doctorId,
                doctorName: doctorName,
                doctorSpecialist: doctorSpecialist,
                doctorProfileImageUrl: doctorProfileImageUrl,
                consultationFee: consultationFee,
              );
            }
            return const Center(child: Text('Loading slots...'));
          },
        ),
      ),
    );
  }
}

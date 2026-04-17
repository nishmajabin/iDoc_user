import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/core/utils/time_formatter.dart';
import 'package:idoc_user/logic/blocs/appointment/appointment_state.dart';
import 'package:idoc_user/logic/blocs/payment/payment_bloc.dart';
import 'package:idoc_user/logic/blocs/payment/payment_event.dart';
import 'package:idoc_user/logic/blocs/payment/payment_state.dart';

class SlotSelectionBottomBar extends StatelessWidget {
  final SlotsFetched state;
  final String? userId;
  final double consultationFee;
  final String doctorId;
  final String? doctorName;
  final String? doctorSpecialist;
  final String? doctorProfileImageUrl;

  const SlotSelectionBottomBar({
    required this.state,
    required this.userId,
    required this.consultationFee,
    required this.doctorId,
    this.doctorName,
    this.doctorSpecialist,
    this.doctorProfileImageUrl,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowDark.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Selected slot summary chip
            if (state.selectedSlotId != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.elevatedBgColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.elevatedBgColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Selected: ${formatTimeTo12Hour(state.selectedStartTime!)} – ${formatTimeTo12Hour(state.selectedEndTime!)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.elevatedBgColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Consultation Fee:',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.lightTextColor2,
                          ),
                        ),
                        Text(
                          '₹${consultationFee.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.elevatedBgColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            // Pay & Confirm button
            BlocBuilder<PaymentBloc, PaymentState>(
              builder: (context, paymentState) {
                final isProcessing =
                    paymentState is PaymentProcessing ||
                    paymentState is PaymentUIOpened ||
                    paymentState is PaymentSuccessProcessing;

                return SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed:
                        state.selectedSlotId != null &&
                                userId != null &&
                                !isProcessing
                            ? () {
                              if (state.patientName == null ||
                                  state.contactNumber == null ||
                                  state.description == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Patient details are missing. Please go back and fill the form.',
                                    ),
                                    backgroundColor: AppColors.errorBgColor,
                                  ),
                                );
                                return;
                              }

                              context.read<PaymentBloc>().add(
                                InitiatePaymentEvent(
                                  doctorId: doctorId,
                                  userId: userId!,
                                  slotId: state.selectedSlotId!,
                                  patientName: state.patientName!,
                                  contactNumber: state.contactNumber!,
                                  description: state.description!,
                                  appointmentDate: state.selectedDate,
                                  startTime: state.selectedStartTime!,
                                  endTime: state.selectedEndTime!,
                                  consultationFee: consultationFee,
                                  doctorName: doctorName,
                                  doctorSpecialist: doctorSpecialist,
                                  doctorProfileImageUrl: doctorProfileImageUrl,
                                ),
                              );
                            }
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.elevatedBgColor,
                      foregroundColor: AppColors.backgroundColor,
                      elevation: 0,
                      disabledBackgroundColor: AppColors.lightText,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child:
                        isProcessing
                            ?  SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.backgroundColor,
                                ),
                              ),
                            )
                            : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.payment, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  userId == null
                                      ? 'Please Login'
                                      : state.selectedSlotId == null
                                      ? 'Select a Time Slot'
                                      : 'Pay ₹${consultationFee.toStringAsFixed(0)} & Confirm',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

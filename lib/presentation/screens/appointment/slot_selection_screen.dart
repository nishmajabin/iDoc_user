import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/logic/blocs/appointment/appointment_bloc.dart';
import 'package:idoc_user/logic/blocs/appointment/appointment_event.dart';
import 'package:idoc_user/logic/blocs/appointment/appointment_state.dart';
import 'package:idoc_user/logic/blocs/auth/auth_bloc.dart';
import 'package:idoc_user/logic/blocs/auth/auth_state.dart';
import 'package:idoc_user/logic/blocs/payment/payment_bloc.dart';
import 'package:idoc_user/logic/blocs/payment/payment_event.dart';
import 'package:idoc_user/logic/blocs/payment/payment_state.dart';
import 'package:idoc_user/presentation/screens/appointment/booking_success_screen.dart';
import 'package:intl/intl.dart';

class SlotSelectionScreen extends StatefulWidget {
  final String doctorId;
  final String? doctorName;
  final String? doctorSpecialist;
  final String? doctorProfileImageUrl;
  final double consultationFee;

  const SlotSelectionScreen({
    Key? key,
    required this.doctorId,
    this.doctorName,
    this.doctorSpecialist,
    this.doctorProfileImageUrl,
    required this.consultationFee,
  }) : super(key: key);

  @override
  State<SlotSelectionScreen> createState() => _SlotSelectionScreenState();
}

class _SlotSelectionScreenState extends State<SlotSelectionScreen> {
  // ✅ Store reference to PaymentBloc to avoid context access during dispose
  late final PaymentBloc _paymentBloc;

  @override
  void initState() {
    super.initState();
    
    context.read<AppointmentBloc>().add(
      FetchAllAvailableSlotsEvent(
        doctorId: widget.doctorId,
      ),
    );

    // ✅ Store the PaymentBloc reference
    _paymentBloc = context.read<PaymentBloc>();
    
    // ✅ Initialize Razorpay with callbacks that dispatch events to PaymentBloc
    _paymentBloc.paymentService.initializeRazorpay(
      onSuccess: (response) {
        print('🎉 Razorpay success callback triggered');
        _paymentBloc.add(
          PaymentSuccessEvent(
            paymentId: response.paymentId ?? '',
            orderId: response.orderId ?? '',
            signature: response.signature ?? '',
          ),
        );
      },
      onFailure: (response) {
        print('❌ Razorpay failure callback triggered');
        _paymentBloc.add(
          PaymentFailureEvent(
            code: response.code ?? 0,
            message: response.message ?? 'Payment failed',
          ),
        );
      },
      onCancel: () {
        print('🚫 Razorpay cancel callback triggered');
        _paymentBloc.add(const PaymentCancelledEvent());
      },
    );
  }

  @override
  void dispose() {
    // ✅ Clean up Razorpay instance using stored reference instead of context
    // This is safe because we stored the reference in initState
    _paymentBloc.paymentService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Select Time Slot'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: MultiBlocListener(
        listeners: [
          // Listen to payment state
          BlocListener<PaymentBloc, PaymentState>(
            listener: (context, state) {
              if (state is PaymentAndBookingSuccess) {
                print('✅ Payment and booking successful, navigating to success screen');
                
                // Navigate to success screen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingSuccessScreen(
                      doctorName: state.doctorName,
                      appointmentDate: state.appointmentDate,
                      startTime: state.startTime,
                      endTime: state.endTime,
                      paymentId: state.paymentId,
                    ),
                  ),
                );
              } else if (state is PaymentFailed) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Payment Failed: ${state.message}'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 5),
                    action: SnackBarAction(
                      label: 'OK',
                      textColor: Colors.white,
                      onPressed: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      },
                    ),
                  ),
                );
              } else if (state is PaymentCancelled) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Payment cancelled by user'),
                    backgroundColor: Colors.orange,
                    duration: Duration(seconds: 3),
                  ),
                );
              } else if (state is PaymentError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 5),
                  ),
                );
              }
            },
          ),
          // Listen to appointment state for errors
          BlocListener<AppointmentBloc, AppointmentState>(
            listener: (context, state) {
              if (state is AppointmentError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
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
              if (state.slots.isEmpty) {
                return _buildNoSlotsAvailable(context);
              }

              return _SlotSelectionContent(
                state: state,
                doctorId: widget.doctorId,
                doctorName: widget.doctorName,
                doctorSpecialist: widget.doctorSpecialist,
                doctorProfileImageUrl: widget.doctorProfileImageUrl,
                consultationFee: widget.consultationFee,
              );
            }

            return const Center(child: Text('Loading slots...'));
          },
        ),
      ),
    );
  }

  Widget _buildNoSlotsAvailable(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_busy,
                size: 60,
                color: Colors.orange[700],
              ),
            ),
            
            const SizedBox(height: 24),

            Text(
              'No Slots Available',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            Text(
              'Dr. ${widget.doctorName ?? "This doctor"} has no available appointment slots. Please check back later or contact the doctor directly.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D4FF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'Go Back',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlotSelectionContent extends StatelessWidget {
  final SlotsFetched state;
  final String doctorId;
  final String? doctorName;
  final String? doctorSpecialist;
  final String? doctorProfileImageUrl;
  final double consultationFee;

  const _SlotSelectionContent({
    required this.state,
    required this.doctorId,
    this.doctorName,
    this.doctorSpecialist,
    this.doctorProfileImageUrl,
    required this.consultationFee,
  });

  /// Helper method to check if a slot is in the past
  bool _isSlotInPast(DateTime slotDate, String startTime) {
    try {
      final now = DateTime.now();
      
      final timeParts = startTime.replaceAll(RegExp(r'[AP]M'), '').trim().split(':');
      int hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      
      if (startTime.contains('PM') && hour != 12) {
        hour += 12;
      } else if (startTime.contains('AM') && hour == 12) {
        hour = 0;
      }
      
      final slotDateTime = DateTime(
        slotDate.year,
        slotDate.month,
        slotDate.day,
        hour,
        minute,
      );
      
      final bufferTime = now.add(const Duration(minutes: 5));
      
      return slotDateTime.isBefore(bufferTime);
    } catch (e) {
      print('Error parsing time in UI: $e');
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    String? userId;
    
    if (authState is AuthAuthenticated) {
      userId = authState.user.uid;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Extract unique dates from slots
    final Set<DateTime> uniqueDatesSet = {};
    for (var slot in state.slots) {
      final slotDate = slot['date'] as DateTime;
      final normalizedDate = DateTime(slotDate.year, slotDate.month, slotDate.day);
      uniqueDatesSet.add(normalizedDate);
    }

    final List<DateTime> availableDates = uniqueDatesSet.toList()
      ..sort((a, b) => a.compareTo(b));

    final normalizedSelectedDate = DateTime(
      state.selectedDate.year,
      state.selectedDate.month,
      state.selectedDate.day,
    );

    final slotsForSelectedDate = state.slots.where((slot) {
      final slotDate = slot['date'] as DateTime;
      final normalizedSlotDate = DateTime(
        slotDate.year,
        slotDate.month,
        slotDate.day,
      );
      return normalizedSlotDate.isAtSameMomentAs(normalizedSelectedDate);
    }).toList();

    final isSelectedDateToday = normalizedSelectedDate.isAtSameMomentAs(today);

    // Group slots by time period
    final morningSlots = <Map<String, dynamic>>[];
    final afternoonSlots = <Map<String, dynamic>>[];
    final eveningSlots = <Map<String, dynamic>>[];

    for (var slot in slotsForSelectedDate) {
      final startTime = slot['startTime'] as String;
      final hour = int.parse(startTime.split(':')[0]);

      if (hour < 12) {
        morningSlots.add(slot);
      } else if (hour < 17) {
        afternoonSlots.add(slot);
      } else {
        eveningSlots.add(slot);
      }
    }

    return Column(
      children: [
        // Date selection horizontal list
        Container(
          height: 110,
          padding: const EdgeInsets.symmetric(vertical: 12),
          color: Colors.white,
          child: availableDates.isEmpty
              ? Center(
                  child: Text(
                    'No available dates',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: availableDates.length,
                  itemBuilder: (context, index) {
                    final date = availableDates[index];
                    final isSelected = date.isAtSameMomentAs(normalizedSelectedDate);
                    
                    return GestureDetector(
                      onTap: () {
                        context.read<AppointmentBloc>().add(
                          SelectDateEvent(date),
                        );
                      },
                      child: Container(
                        width: 66,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF00D4FF)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF00D4FF)
                                : Colors.grey[300]!,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF00D4FF).withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('EEE').format(date),
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('dd').format(date),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                              maxLines: 1,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat('MMM').format(date),
                              style: TextStyle(
                                fontSize: 10,
                                color: isSelected
                                    ? Colors.white.withOpacity(0.8)
                                    : Colors.grey[500],
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
        ),

        // Time Slots
        Expanded(
          child: slotsForSelectedDate.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_busy,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No available slots for this date',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Date Header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00D4FF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF00D4FF).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: Color(0xFF00D4FF),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat('EEEE, MMMM dd, yyyy').format(normalizedSelectedDate),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF00D4FF),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (isSelectedDateToday) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Today • Current time: ${DateFormat('hh:mm a').format(now)}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (isSelectedDateToday) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.orange[800],
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Only future time slots are available for booking',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange[900],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      if (morningSlots.isNotEmpty)
                        _buildSlotSection(
                          context,
                          'Morning Slots',
                          morningSlots,
                          state.selectedSlotId,
                          Icons.wb_sunny,
                          Colors.orange,
                          isSelectedDateToday,
                          normalizedSelectedDate,
                        ),
                      if (afternoonSlots.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _buildSlotSection(
                          context,
                          'Afternoon Slots',
                          afternoonSlots,
                          state.selectedSlotId,
                          Icons.wb_sunny_outlined,
                          Colors.amber,
                          isSelectedDateToday,
                          normalizedSelectedDate,
                        ),
                      ],
                      if (eveningSlots.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _buildSlotSection(
                          context,
                          'Evening Slots',
                          eveningSlots,
                          state.selectedSlotId,
                          Icons.nights_stay,
                          Colors.indigo,
                          isSelectedDateToday,
                          normalizedSelectedDate,
                        ),
                      ],
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
        ),

        // Payment Summary and Pay & Confirm Button
        SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state.selectedSlotId != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D4FF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Color(0xFF00D4FF),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Selected: ${state.selectedStartTime} - ${state.selectedEndTime}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF00D4FF),
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
                                color: Colors.grey[700],
                              ),
                            ),
                            Text(
                              '₹${consultationFee.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF00D4FF),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                BlocBuilder<PaymentBloc, PaymentState>(
                  builder: (context, paymentState) {
                    final isProcessing = paymentState is PaymentProcessing ||
                        paymentState is PaymentUIOpened ||
                        paymentState is PaymentSuccessProcessing;

                    return SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: state.selectedSlotId != null &&
                                userId != null &&
                                !isProcessing
                            ? () {
                                print('=== PAY & CONFIRM BUTTON PRESSED ===');
                                
                                if (userId == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please login to book appointment'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                if (state.patientName == null || state.contactNumber == null || state.description == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Patient details are missing. Please go back and fill the form.'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
                                
                                // Initiate payment
                                context.read<PaymentBloc>().add(
                                  InitiatePaymentEvent(
                                    doctorId: doctorId,
                                    userId: userId,
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
                          backgroundColor: const Color(0xFF00D4FF),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          disabledBackgroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: isProcessing
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
        ),
      ],
    );
  }

  Widget _buildSlotSection(
    BuildContext context,
    String title,
    List<Map<String, dynamic>> slots,
    String? selectedSlotId,
    IconData icon,
    Color color,
    bool isToday,
    DateTime selectedDate,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${slots.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: slots.map((slot) {
            final slotId = slot['slotId'] as String;
            final startTime = slot['startTime'] as String;
            final endTime = slot['endTime'] as String;
            final isSelected = slotId == selectedSlotId;
            
            final isPast = isToday && _isSlotInPast(selectedDate, startTime);

            return GestureDetector(
              onTap: isPast 
                  ? null 
                  : () {
                      context.read<AppointmentBloc>().add(
                            SelectSlotEvent(
                              slotId: slotId,
                              startTime: startTime,
                              endTime: endTime,
                            ),
                          );
                    },
              child: Opacity(
                opacity: isPast ? 0.4 : 1.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isPast 
                        ? Colors.grey[200]
                        : isSelected 
                            ? const Color(0xFF00D4FF) 
                            : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isPast
                          ? Colors.grey[400]!
                          : isSelected
                              ? const Color(0xFF00D4FF)
                              : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected && !isPast
                        ? [
                            BoxShadow(
                              color: const Color(0xFF00D4FF).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPast ? Icons.block : Icons.access_time,
                        size: 16,
                        color: isPast
                            ? Colors.grey[600]
                            : isSelected 
                                ? Colors.white 
                                : Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$startTime - $endTime',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isPast
                              ? Colors.grey[600]
                              : isSelected 
                                  ? Colors.white 
                                  : Colors.black87,
                          decoration: isPast ? TextDecoration.lineThrough : null,
                        ),
                        maxLines: 1,
                      ),
                      if (isPast) ...[
                        const SizedBox(width: 4),
                        Text(
                          'Past',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
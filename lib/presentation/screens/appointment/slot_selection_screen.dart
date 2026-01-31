import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/logic/blocs/appointment/appointment_bloc.dart';
import 'package:idoc_user/logic/blocs/appointment/appointment_event.dart';
import 'package:idoc_user/logic/blocs/appointment/appointment_state.dart';
import 'package:idoc_user/logic/blocs/auth/auth_bloc.dart';
import 'package:idoc_user/logic/blocs/auth/auth_state.dart';
import 'package:idoc_user/presentation/screens/appointment/booking_success_screen.dart';
import 'package:intl/intl.dart';

class SlotSelectionScreen extends StatelessWidget {
  final String doctorId;
  final String? doctorName;
  final String? doctorSpecialist;
  final String? doctorProfileImageUrl;

  const SlotSelectionScreen({
    Key? key,
    required this.doctorId,
    this.doctorName,
    this.doctorSpecialist,
    this.doctorProfileImageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Fetch ALL available slots for this doctor (no date restriction)
    context.read<AppointmentBloc>().add(
      FetchAllAvailableSlotsEvent(
        doctorId: doctorId,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Appointment'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: BlocConsumer<AppointmentBloc, AppointmentState>(
        listener: (context, state) {
          if (state is AppointmentBooked) {
            print('AppointmentBooked state received, navigating to success screen');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => BookingSuccessScreen(
                  doctorName: state.doctorName,
                  appointmentDate: state.appointmentDate,
                  startTime: state.startTime,
                  endTime: state.endTime,
                ),
              ),
            );
          } else if (state is AppointmentError) {
            print('AppointmentError state received: ${state.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        },
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
              doctorId: doctorId,
              doctorName: doctorName,
              doctorSpecialist: doctorSpecialist,
              doctorProfileImageUrl: doctorProfileImageUrl,
            );
          }

          return const Center(child: Text('Loading slots...'));
        },
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
              'Dr. ${doctorName ?? "This doctor"} has not set up any appointment slots yet. Please check back later or contact the doctor directly.',
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

  const _SlotSelectionContent({
    required this.state,
    required this.doctorId,
    this.doctorName,
    this.doctorSpecialist,
    this.doctorProfileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    String? userId;
    
    if (authState is AuthAuthenticated) {
      userId = authState.user.uid;
      print('User ID from auth: $userId');
    } else {
      print('WARNING: User not authenticated!');
    }

    // Extract unique dates from slots
    final Set<DateTime> uniqueDatesSet = {};
    for (var slot in state.slots) {
      final slotDate = slot['date'] as DateTime;
      final normalizedDate = DateTime(slotDate.year, slotDate.month, slotDate.day);
      uniqueDatesSet.add(normalizedDate);
    }

    final List<DateTime> availableDates = uniqueDatesSet.toList()
      ..sort((a, b) => a.compareTo(b));

    print('=== AVAILABLE DATES ===');
    print('Total unique dates with slots: ${availableDates.length}');
    for (var date in availableDates) {
      print('- ${DateFormat('MMM dd, yyyy').format(date)}');
    }
    print('=====================');

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
        // Date Selector - Fixed height with horizontal scroll
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

        // Time Slots - Expandable area
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
                      // Date Header - FIXED: Proper responsive container
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
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
                              child: Text(
                                DateFormat('EEEE, MMMM dd, yyyy').format(normalizedSelectedDate),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF00D4FF),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (morningSlots.isNotEmpty)
                        _buildSlotSection(
                          context,
                          'Morning Slots',
                          morningSlots,
                          state.selectedSlotId,
                          Icons.wb_sunny,
                          Colors.orange,
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
                        ),
                      ],
                      const SizedBox(height: 100), // Extra space for bottom button
                    ],
                  ),
                ),
        ),

        // Confirm Button - Fixed at bottom
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
                // Show selected slot info if any
                if (state.selectedSlotId != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D4FF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
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
                  ),
                ],

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: state.selectedSlotId != null && userId != null
                        ? () {
                            print('=== CONFIRM BUTTON PRESSED ===');
                            print('User ID: $userId');
                            print('Selected slot ID: ${state.selectedSlotId}');
                            print('Patient Name: ${state.patientName}');
                            print('Contact Number: ${state.contactNumber}');
                            print('Description: ${state.description}');
                            print('============================');
                            
                            if (userId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please login to book appointment'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                            
                            context.read<AppointmentBloc>().add(
                                  BookAppointmentEvent(
                                    doctorId: doctorId,
                                    userId: userId,
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
                    child: Text(
                      userId == null 
                          ? 'Please Login' 
                          : state.selectedSlotId == null 
                              ? 'Select a Time Slot'
                              : 'Confirm Appointment',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
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

            return GestureDetector(
              onTap: () {
                print('Slot selected: $slotId ($startTime - $endTime)');
                context.read<AppointmentBloc>().add(
                      SelectSlotEvent(
                        slotId: slotId,
                        startTime: startTime,
                        endTime: endTime,
                      ),
                    );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF00D4FF) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: isSelected ? Colors.white : Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$startTime - $endTime',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
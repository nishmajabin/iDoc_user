import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/core/utils/time_formatter.dart';
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

// ─────────────────────────────────────────────────────────────────────────────
// Slot status enum
// ─────────────────────────────────────────────────────────────────────────────

/// Represents the three mutually exclusive visual/interactive states a slot
/// chip can be in.  Calculated once per slot in [_SlotSection._resolveStatus]
/// and used to drive both the appearance and the tap behaviour.
enum _SlotStatus {
  /// Slot is free and in the future — the user can select it.
  available,

  /// Slot is already booked by someone else — visible but non-interactive.
  booked,

  /// Slot is available in Firestore but the time has already passed today —
  /// shown as dimmed with a "Past" label.
  past,
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

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
  late final PaymentBloc _paymentBloc;

  @override
  void initState() {
    super.initState();

    // FetchAllAvailableSlotsEvent now resolves to the inclusive fetchSlots()
    // method in AppointmentService, so the BLoC receives both available +
    // booked slots in one go.
    context
        .read<AppointmentBloc>()
        .add(FetchAllAvailableSlotsEvent(doctorId: widget.doctorId));

    _paymentBloc = context.read<PaymentBloc>();
    _paymentBloc.paymentService.initializeRazorpay(
      onSuccess: (response) {
        _paymentBloc.add(PaymentSuccessEvent(
          paymentId: response.paymentId ?? '',
          orderId: response.orderId ?? '',
          signature: response.signature ?? '',
        ));
      },
      onFailure: (response) {
        _paymentBloc.add(PaymentFailureEvent(
          code: response.code ?? 0,
          message: response.message ?? 'Payment failed',
        ));
      },
      onCancel: () => _paymentBloc.add(const PaymentCancelledEvent()),
    );
  }

  @override
  void dispose() {
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
          BlocListener<PaymentBloc, PaymentState>(
            listener: (context, state) {
              if (state is PaymentAndBookingSuccess) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BookingSuccessScreen(
                      doctorName: state.doctorName,
                      appointmentDate: state.appointmentDate,
                      startTime: formatTimeTo12Hour(state.startTime),
                      endTime: formatTimeTo12Hour(state.endTime),
                      paymentId: state.paymentId,
                    ),
                  ),
                );
              } else if (state is PaymentFailed) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Payment Failed: ${state.message}'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 5),
                  action: SnackBarAction(
                    label: 'OK',
                    textColor: Colors.white,
                    onPressed: () =>
                        ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                  ),
                ));
              } else if (state is PaymentCancelled) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Payment cancelled by user'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 3),
                ));
              } else if (state is PaymentError) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 5),
                ));
              }
            },
          ),
          BlocListener<AppointmentBloc, AppointmentState>(
            listener: (context, state) {
              if (state is AppointmentError) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 5),
                ));
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
              child: Icon(Icons.event_busy,
                  size: 60, color: Colors.orange[700]),
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
              'Dr. ${widget.doctorName ?? "This doctor"} has no available appointment slots. '
              'Please check back later or contact the doctor directly.',
              style: TextStyle(
                  fontSize: 16, color: Colors.grey[600], height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D4FF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text('Go Back',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Slot selection content
// ─────────────────────────────────────────────────────────────────────────────

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

  bool _isSlotInPast(DateTime slotDate, String startTime) {
    try {
      final now = DateTime.now();
      final parts =
          startTime.replaceAll(RegExp(r'[AP]M'), '').trim().split(':');
      int hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      if (startTime.contains('PM') && hour != 12) hour += 12;
      if (startTime.contains('AM') && hour == 12) hour = 0;

      final slotDateTime =
          DateTime(slotDate.year, slotDate.month, slotDate.day, hour, minute);
      return slotDateTime.isBefore(now.add(const Duration(minutes: 5)));
    } catch (_) {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final String? userId =
        authState is AuthAuthenticated ? authState.user.uid : null;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // ── Sorted unique date list ────────────────────────────────────────────
    final Set<DateTime> uniqueDatesSet = {};
    for (final slot in state.slots) {
      final d = slot['date'] as DateTime;
      uniqueDatesSet.add(DateTime(d.year, d.month, d.day));
    }
    final List<DateTime> availableDates = uniqueDatesSet.toList()
      ..sort((a, b) => a.compareTo(b));

    final normalizedSelectedDate = DateTime(
      state.selectedDate.year,
      state.selectedDate.month,
      state.selectedDate.day,
    );

    // ── Slots for the selected date (available + booked) ──────────────────
    final slotsForSelectedDate = state.slots.where((slot) {
      final d = slot['date'] as DateTime;
      return DateTime(d.year, d.month, d.day)
          .isAtSameMomentAs(normalizedSelectedDate);
    }).toList();

    final isSelectedDateToday =
        normalizedSelectedDate.isAtSameMomentAs(today);

    // ── Group by time period ──────────────────────────────────────────────
    final morningSlots = <Map<String, dynamic>>[];
    final afternoonSlots = <Map<String, dynamic>>[];
    final eveningSlots = <Map<String, dynamic>>[];

    for (final slot in slotsForSelectedDate) {
      final hour = int.parse((slot['startTime'] as String).split(':')[0]);
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
        // ── Date picker row ────────────────────────────────────────────
        _DatePickerRow(
          availableDates: availableDates,
          selectedDate: normalizedSelectedDate,
        ),

        // ── Slot list ──────────────────────────────────────────────────
        Expanded(
          child: slotsForSelectedDate.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy,
                          size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'No slots for this date',
                        style: TextStyle(
                            color: Colors.grey[600], fontSize: 16),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DateHeader(
                        date: normalizedSelectedDate,
                        isToday: isSelectedDateToday,
                        now: now,
                      ),
                      if (isSelectedDateToday) ...[
                        const SizedBox(height: 8),
                        _TodayNotice(),
                      ],
                      // ── Slot legend ──────────────────────────────────
                      const SizedBox(height: 8),
                      _SlotLegend(),
                      const SizedBox(height: 16),
                      if (morningSlots.isNotEmpty)
                        _SlotSection(
                          title: 'Morning Slots',
                          slots: morningSlots,
                          selectedSlotId: state.selectedSlotId,
                          icon: Icons.wb_sunny,
                          color: Colors.orange,
                          isToday: isSelectedDateToday,
                          selectedDate: normalizedSelectedDate,
                          isSlotInPast: _isSlotInPast,
                        ),
                      if (afternoonSlots.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _SlotSection(
                          title: 'Afternoon Slots',
                          slots: afternoonSlots,
                          selectedSlotId: state.selectedSlotId,
                          icon: Icons.wb_sunny_outlined,
                          color: Colors.amber,
                          isToday: isSelectedDateToday,
                          selectedDate: normalizedSelectedDate,
                          isSlotInPast: _isSlotInPast,
                        ),
                      ],
                      if (eveningSlots.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        _SlotSection(
                          title: 'Evening Slots',
                          slots: eveningSlots,
                          selectedSlotId: state.selectedSlotId,
                          icon: Icons.nights_stay,
                          color: Colors.indigo,
                          isToday: isSelectedDateToday,
                          selectedDate: normalizedSelectedDate,
                          isSlotInPast: _isSlotInPast,
                        ),
                      ],
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
        ),

        // ── Bottom bar ─────────────────────────────────────────────────
        _BottomBar(
          state: state,
          userId: userId,
          consultationFee: consultationFee,
          doctorId: doctorId,
          doctorName: doctorName,
          doctorSpecialist: doctorSpecialist,
          doctorProfileImageUrl: doctorProfileImageUrl,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Slot legend
// ─────────────────────────────────────────────────────────────────────────────

/// A compact row of coloured badges explaining what each chip colour means.
/// Placed once per date view, directly above the slot sections.
class _SlotLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: const [
        _LegendItem(
          color: Colors.white,
          borderColor: Color(0xFFBDBDBD),
          label: 'Available',
          icon: Icons.check_circle_outline,
          iconColor: Color(0xFF00D4FF),
        ),
        _LegendItem(
          color: Color(0xFFFFF3E0),
          borderColor: Color(0xFFFFB74D),
          label: 'Booked',
          icon: Icons.lock_outline,
          iconColor: Color(0xFFE65100),
        ),
        _LegendItem(
          color: Color(0xFFF5F5F5),
          borderColor: Color(0xFFBDBDBD),
          label: 'Past',
          icon: Icons.block,
          iconColor: Color(0xFF9E9E9E),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final Color borderColor;
  final String label;
  final IconData icon;
  final Color iconColor;

  const _LegendItem({
    required this.color,
    required this.borderColor,
    required this.label,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Date picker row
// ─────────────────────────────────────────────────────────────────────────────

class _DatePickerRow extends StatelessWidget {
  final List<DateTime> availableDates;
  final DateTime selectedDate;

  const _DatePickerRow({
    required this.availableDates,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: Colors.white,
      child: availableDates.isEmpty
          ? Center(
              child: Text('No available dates',
                  style:
                      TextStyle(color: Colors.grey[600], fontSize: 14)))
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: availableDates.length,
              itemBuilder: (context, index) {
                final date = availableDates[index];
                final isSelected = date.isAtSameMomentAs(selectedDate);
                return GestureDetector(
                  onTap: () => context
                      .read<AppointmentBloc>()
                      .add(SelectDateEvent(date)),
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
                                color: const Color(0xFF00D4FF)
                                    .withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
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
                            color:
                                isSelected ? Colors.white : Colors.black,
                          ),
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Date header banner
// ─────────────────────────────────────────────────────────────────────────────

class _DateHeader extends StatelessWidget {
  final DateTime date;
  final bool isToday;
  final DateTime now;

  const _DateHeader({
    required this.date,
    required this.isToday,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF00D4FF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00D4FF).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today,
              color: Color(0xFF00D4FF), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, MMMM dd, yyyy').format(date),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF00D4FF),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isToday) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Today • Current time: ${formatTimeTo12Hour(DateFormat('HH:mm').format(now))}',
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Today notice
// ─────────────────────────────────────────────────────────────────────────────

class _TodayNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange[800], size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Only future time slots are available for booking',
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange[900],
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Slot section (Morning / Afternoon / Evening)
// ─────────────────────────────────────────────────────────────────────────────

class _SlotSection extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> slots;
  final String? selectedSlotId;
  final IconData icon;
  final Color color;
  final bool isToday;
  final DateTime selectedDate;
  final bool Function(DateTime, String) isSlotInPast;

  const _SlotSection({
    required this.title,
    required this.slots,
    required this.selectedSlotId,
    required this.icon,
    required this.color,
    required this.isToday,
    required this.selectedDate,
    required this.isSlotInPast,
  });

  // ── Status resolution ─────────────────────────────────────────────────────

  /// Derives the [_SlotStatus] for a single slot map.
  ///
  /// Priority: booked (from Firestore) > past (time-based) > available.
  _SlotStatus _resolveStatus(Map<String, dynamic> slot) {
    final firestoreStatus = slot['status'] as String? ?? 'available';

    // Firestore says this slot is taken — always treat as booked regardless
    // of whether the time has passed.
    if (firestoreStatus == 'booked') return _SlotStatus.booked;

    // Available in Firestore but today and time has passed.
    if (isToday && isSlotInPast(selectedDate, slot['startTime'] as String)) {
      return _SlotStatus.past;
    }

    return _SlotStatus.available;
  }

  // ── Chip styling per status ───────────────────────────────────────────────

  Color _chipBackground(_SlotStatus status, bool isSelected) {
    switch (status) {
      case _SlotStatus.booked:
        return const Color(0xFFFFF3E0); // warm amber tint
      case _SlotStatus.past:
        return Colors.grey[200]!;
      case _SlotStatus.available:
        return isSelected ? const Color(0xFF00D4FF) : Colors.white;
    }
  }

  Color _chipBorder(_SlotStatus status, bool isSelected) {
    switch (status) {
      case _SlotStatus.booked:
        return const Color(0xFFFFB74D); // amber border
      case _SlotStatus.past:
        return Colors.grey[400]!;
      case _SlotStatus.available:
        return isSelected ? const Color(0xFF00D4FF) : Colors.grey[300]!;
    }
  }

  Color _labelColor(_SlotStatus status, bool isSelected) {
    switch (status) {
      case _SlotStatus.booked:
        return const Color(0xFFE65100); // deep orange
      case _SlotStatus.past:
        return Colors.grey[600]!;
      case _SlotStatus.available:
        return isSelected ? Colors.white : Colors.black87;
    }
  }

  Color _iconColor(_SlotStatus status, bool isSelected) {
    switch (status) {
      case _SlotStatus.booked:
        return const Color(0xFFE65100);
      case _SlotStatus.past:
        return Colors.grey[600]!;
      case _SlotStatus.available:
        return isSelected ? Colors.white : Colors.grey[600]!;
    }
  }

  IconData _leadingIcon(_SlotStatus status, bool isSelected) {
    switch (status) {
      case _SlotStatus.booked:
        return Icons.lock_outline;
      case _SlotStatus.past:
        return Icons.block;
      case _SlotStatus.available:
        return isSelected ? Icons.check_circle : Icons.access_time;
    }
  }

  String _badgeLabel(_SlotStatus status) {
    switch (status) {
      case _SlotStatus.booked:
        return 'Booked';
      case _SlotStatus.past:
        return 'Past';
      case _SlotStatus.available:
        return '';
    }
  }

  List<BoxShadow>? _chipShadow(_SlotStatus status, bool isSelected) {
    if (status == _SlotStatus.available && isSelected) {
      return [
        BoxShadow(
          color: const Color(0xFF00D4FF).withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
    }
    return null;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Count only available (bookable) slots for the badge.
    final bookableCount =
        slots.where((s) => _resolveStatus(s) == _SlotStatus.available).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title row
        Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            // Total slots badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${slots.length}',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color),
              ),
            ),
            // Available slots badge (shown only when some are booked)
            if (bookableCount < slots.length) ...[
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D4FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$bookableCount free',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF00D4FF)),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),

        // Slot chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: slots.map((slot) {
            final slotId = slot['slotId'] as String;
            final rawStart = slot['startTime'] as String;
            final rawEnd = slot['endTime'] as String;
            final isSelected = slotId == selectedSlotId;

            final status = _resolveStatus(slot);
            final isInteractive = status == _SlotStatus.available;

            final displayStart = formatTimeTo12Hour(rawStart);
            final displayEnd = formatTimeTo12Hour(rawEnd);
            final badge = _badgeLabel(status);

            return GestureDetector(
              onTap: isInteractive
                  ? () => context.read<AppointmentBloc>().add(
                        SelectSlotEvent(
                          slotId: slotId,
                          startTime: rawStart,
                          endTime: rawEnd,
                        ),
                      )
                  : null,
              child: Opacity(
                // Slightly dim past & booked chips but keep booked more
                // visible (0.75) than pure past (0.5) so users understand
                // the distinction.
                opacity: status == _SlotStatus.past
                    ? 0.5
                    : status == _SlotStatus.booked
                        ? 0.85
                        : 1.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: _chipBackground(status, isSelected),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _chipBorder(status, isSelected),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: _chipShadow(status, isSelected),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _leadingIcon(status, isSelected),
                        size: 16,
                        color: _iconColor(status, isSelected),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$displayStart – $displayEnd',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _labelColor(status, isSelected),
                          decoration: status == _SlotStatus.past
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        maxLines: 1,
                      ),
                      if (badge.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: status == _SlotStatus.booked
                                ? const Color(0xFFE65100).withOpacity(0.12)
                                : Colors.grey[400]!.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: status == _SlotStatus.booked
                                  ? const Color(0xFFE65100)
                                  : Colors.grey[700],
                            ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Bottom bar
// ─────────────────────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final SlotsFetched state;
  final String? userId;
  final double consultationFee;
  final String doctorId;
  final String? doctorName;
  final String? doctorSpecialist;
  final String? doctorProfileImageUrl;

  const _BottomBar({
    required this.state,
    required this.userId,
    required this.consultationFee,
    required this.doctorId,
    this.doctorName,
    this.doctorSpecialist,
    this.doctorProfileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
            // Selected slot summary chip
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
                        const Icon(Icons.check_circle,
                            color: Color(0xFF00D4FF), size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Selected: ${formatTimeTo12Hour(state.selectedStartTime!)} – ${formatTimeTo12Hour(state.selectedEndTime!)}',
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
                        Text('Consultation Fee:',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[700])),
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

            // Pay & Confirm button
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
                            if (state.patientName == null ||
                                state.contactNumber == null ||
                                state.description == null) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text(
                                    'Patient details are missing. Please go back and fill the form.'),
                                backgroundColor: Colors.red,
                              ));
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
                                    doctorProfileImageUrl:
                                        doctorProfileImageUrl,
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
                          borderRadius: BorderRadius.circular(15)),
                    ),
                    child: isProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
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
                                    fontWeight: FontWeight.w600),
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
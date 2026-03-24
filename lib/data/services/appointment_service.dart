
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:idoc_user/data/models/appointment_model.dart';

class AppointmentService {
  final FirebaseFirestore _firestore;
  AppointmentService(this._firestore);

  // ── Internal helpers ──────────────────────────────────────────────────────

  bool _isSlotInPast(DateTime slotDate, String startTime) {
    try {
      final timeParts = startTime
          .replaceAll(RegExp(r'[AP]M'), '')
          .trim()
          .split(':');
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
      return slotDateTime.isBefore(
        DateTime.now().add(const Duration(minutes: 5)),
      );
    } catch (_) {
      return true;
    }
  }

  Map<String, dynamic> _mapSlot(doc) => {
        'slotId': doc.id,
        'startTime': doc['startTime'] as String,
        'endTime': doc['endTime'] as String,
        'date': (doc['date'] as Timestamp).toDate(),
        'status': doc['status'] as String,
      };


  bool _isSlotVisible(
    Map<String, dynamic> data,
    DateTime? from,
    DateTime? to,
    DateTime today, {
    required bool availableOnly,
  }) {
    final status = data['status'] as String;

    if (availableOnly) {
      if (status != 'available') return false;
    } else {
      // Slot-selection view: show available + booked; skip anything else
      // (e.g. 'cancelled') so it never appears in the picker.
      if (status != 'available' && status != 'booked') return false;
    }

    final slotDate = (data['date'] as Timestamp).toDate();
    final normalized = DateTime(slotDate.year, slotDate.month, slotDate.day);

    if (from != null && normalized.isBefore(from)) return false;
    if (to != null && normalized.isAfter(to)) return false;

    // For today: hide past *available* slots but keep past *booked* slots so
    // the user can see the full schedule without gaps.
    if (normalized.isAtSameMomentAs(today) &&
        status == 'available' &&
        _isSlotInPast(slotDate, data['startTime'] as String)) {
      return false;
    }

    return true;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> _fetchDoctorSlots(
          String doctorId) =>
      _firestore
          .collection('slots')
          .where('doctorId', isEqualTo: doctorId)
          .get();

  void _sortByDateAndTime(List<Map<String, dynamic>> slots) {
    slots.sort((a, b) {
      final d = (a['date'] as DateTime).compareTo(b['date'] as DateTime);
      return d != 0
          ? d
          : (a['startTime'] as String).compareTo(b['startTime'] as String);
    });
  }

  // ── Inclusive fetch (available + booked) — used by slot-selection screen ──

  /// All visible slots (available + booked) for a specific [date].
  Future<List<Map<String, dynamic>>> fetchSlotsForDate({
    required String doctorId,
    required DateTime date,
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final snapshot = await _fetchDoctorSlots(doctorId);

    final slots = snapshot.docs
        .where((doc) {
          final data = doc.data();
          final status = data['status'] as String;
          if (status != 'available' && status != 'booked') return false;

          final slotDate = (data['date'] as Timestamp).toDate();
          if (slotDate.isBefore(startOfDay) || !slotDate.isBefore(endOfDay)) {
            return false;
          }
          if (startOfDay.isAtSameMomentAs(today) &&
              status == 'available' &&
              _isSlotInPast(slotDate, data['startTime'] as String)) {
            return false;
          }
          return true;
        })
        .map(_mapSlot)
        .toList();

    slots.sort(
        (a, b) => (a['startTime'] as String).compareTo(b['startTime'] as String));
    return slots;
  }

  /// All visible slots (available + booked) within [startDate]…[endDate].
  Future<List<Map<String, dynamic>>> fetchSlotsForRange({
    required String doctorId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final from = DateTime(startDate.year, startDate.month, startDate.day);
    final to = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
    final snapshot = await _fetchDoctorSlots(doctorId);

    final slots = snapshot.docs
        .where((doc) => _isSlotVisible(doc.data(), from, to, today,
            availableOnly: false))
        .map(_mapSlot)
        .toList();

    _sortByDateAndTime(slots);
    return slots;
  }

  /// All future slots (available + booked) from today onwards.
  Future<List<Map<String, dynamic>>> fetchSlots({
    required String doctorId,
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final snapshot = await _fetchDoctorSlots(doctorId);

    final slots = snapshot.docs
        .where((doc) =>
            _isSlotVisible(doc.data(), today, null, today, availableOnly: false))
        .map(_mapSlot)
        .toList();

    _sortByDateAndTime(slots);
    return slots;
  }

  // ── Available-only fetch (legacy — kept for other callers) ────────────────

  Future<List<Map<String, dynamic>>> fetchAvailableSlots({
    required String doctorId,
    required DateTime date,
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    final snapshot = await _fetchDoctorSlots(doctorId);

    final slots = snapshot.docs
        .where((doc) {
          final data = doc.data();
          final slotDate = (data['date'] as Timestamp).toDate();
          if (data['status'] != 'available') return false;
          if (slotDate.isBefore(startOfDay) || !slotDate.isBefore(endOfDay)) {
            return false;
          }
          if (startOfDay.isAtSameMomentAs(today) &&
              _isSlotInPast(slotDate, data['startTime'] as String)) {
            return false;
          }
          return true;
        })
        .map(_mapSlot)
        .toList();

    slots.sort(
        (a, b) => (a['startTime'] as String).compareTo(b['startTime'] as String));
    return slots;
  }

  Future<List<Map<String, dynamic>>> fetchAvailableSlotsForRange({
    required String doctorId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final from = DateTime(startDate.year, startDate.month, startDate.day);
    final to = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
    final snapshot = await _fetchDoctorSlots(doctorId);

    final slots = snapshot.docs
        .where((doc) => _isSlotVisible(doc.data(), from, to, today,
            availableOnly: true))
        .map(_mapSlot)
        .toList();

    _sortByDateAndTime(slots);
    return slots;
  }

  Future<List<Map<String, dynamic>>> fetchAllAvailableSlots({
    required String doctorId,
  }) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final snapshot = await _fetchDoctorSlots(doctorId);

    final slots = snapshot.docs
        .where((doc) =>
            _isSlotVisible(doc.data(), today, null, today, availableOnly: true))
        .map(_mapSlot)
        .toList();

    _sortByDateAndTime(slots);
    return slots;
  }

  // ── User profile ──────────────────────────────────────────────────────────

  /// Fetches the display name of a user from Firestore.
  Future<String?> getUserName(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data()?['name'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<String?> getUserProfileImage(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data()?['profileImageUrl'] as String?;
    } catch (_) {
      return null;
    }
  }

  // ── Appointment operations ────────────────────────────────────────────────

  Future<String> bookAppointment({
    required AppointmentModel appointment,
  }) async {
    try {
      String? profileImageUrl;
      try {
        final userDoc =
            await _firestore.collection('users').doc(appointment.userId).get();
        profileImageUrl = userDoc.data()?['profileImageUrl'] as String?;
      } catch (_) {}

      final today =
          DateTime.now().let((n) => DateTime(n.year, n.month, n.day));
      final apptDay = DateTime(
        appointment.appointmentDate.year,
        appointment.appointmentDate.month,
        appointment.appointmentDate.day,
      );

      if (apptDay.isAtSameMomentAs(today) &&
          _isSlotInPast(appointment.appointmentDate, appointment.startTime)) {
        throw Exception(
          'Cannot book a time slot that has already passed. Please select a future time slot.',
        );
      }

      final slotDoc =
          await _firestore.collection('slots').doc(appointment.slotId).get();
      if (!slotDoc.exists) throw Exception('Slot not found');

      final slotData = slotDoc.data()!;
      if (slotData['doctorId'] != appointment.doctorId)
        throw Exception('Slot does not belong to this doctor');
      if (slotData['status'] != 'available')
        throw Exception('This slot is no longer available');

      final slotDate = (slotData['date'] as Timestamp).toDate();
      final slotDateOnly =
          DateTime(slotDate.year, slotDate.month, slotDate.day);

      if (!apptDay.isAtSameMomentAs(slotDateOnly) ||
          slotData['startTime'] != appointment.startTime) {
        throw Exception('Slot details do not match the appointment details');
      }

      final batch = _firestore.batch();
      final appointmentRef = _firestore.collection('appointments').doc();
      batch.set(
        appointmentRef,
        appointment
            .copyWith(
              appointmentId: appointmentRef.id,
              profileImageUrl: profileImageUrl,
            )
            .toFirestore(),
      );
      batch.update(_firestore.collection('slots').doc(appointment.slotId), {
        'status': 'booked',
        'bookedBy': appointment.userId,
        'bookedAt': FieldValue.serverTimestamp(),
        'appointmentId': appointmentRef.id,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      return appointmentRef.id;
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('already passed')) rethrow;
      if (msg.contains('not found')) {
        throw Exception(
          'The selected time slot was not found. Please try selecting another slot.',
        );
      }
      if (msg.contains('no longer available')) {
        throw Exception(
          'This time slot was just booked by someone else. Please select another slot.',
        );
      }
      if (msg.contains('does not belong'))
        throw Exception('Invalid slot selection. Please try again.');
      if (msg.contains('do not match'))
        throw Exception(
          'Slot validation failed. Please select a different slot.',
        );
      throw Exception('Failed to book appointment. Please try again.');
    }
  }

  Future<List<AppointmentModel>> getUserAppointments(String userId) async {
    final snapshot = await _firestore
        .collection('appointments')
        .where('userId', isEqualTo: userId)
        .get();
    final appointments = snapshot.docs.expand((doc) {
      try {
        return [AppointmentModel.fromFirestore(doc)];
      } catch (_) {
        return <AppointmentModel>[];
      }
    }).toList();
    appointments.sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
    return appointments;
  }

  Future<void> cancelAppointment({
    required String appointmentId,
    required String doctorId,
    required String slotId,
  }) async {
    final batch = _firestore.batch();
    batch.update(_firestore.collection('appointments').doc(appointmentId), {
      'status': 'cancelled',
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.update(_firestore.collection('slots').doc(slotId), {
      'status': 'available',
      'bookedBy': FieldValue.delete(),
      'bookedAt': FieldValue.delete(),
      'appointmentId': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }
}

extension _Let<T> on T {
  R let<R>(R Function(T) block) => block(this);
}
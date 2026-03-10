import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:idoc_user/data/models/appointment_model.dart';
import 'package:intl/intl.dart';

class AppointmentService {
  final FirebaseFirestore _firestore;

  AppointmentService(this._firestore);

  bool _isSlotInPast(DateTime slotDate, String startTime) {
    try {
      final now = DateTime.now();

      // Parse the start time (format: "HH:mm" or "HH:mm AM/PM")
      final timeParts = startTime
          .replaceAll(RegExp(r'[AP]M'), '')
          .trim()
          .split(':');
      int hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      // Handle AM/PM format
      if (startTime.contains('PM') && hour != 12) {
        hour += 12;
      } else if (startTime.contains('AM') && hour == 12) {
        hour = 0;
      }

      // Create the full slot datetime
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
      return true; // If parsing fails, consider it past to be safe
    }
  }


  Future<List<Map<String, dynamic>>> fetchAvailableSlots({
    required String doctorId,
    required DateTime date,
  }) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final isToday = DateTime(
        date.year,
        date.month,
        date.day,
      ).isAtSameMomentAs(today);

      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Query from Firestore
      final snapshot =
          await _firestore
              .collection('slots')
              .where('doctorId', isEqualTo: doctorId)
              .get();


      // Filter slots
      final slots =
          snapshot.docs
              .where((doc) {
                final data = doc.data();
                final status = data['status'] as String?;
                final slotDate = (data['date'] as Timestamp).toDate();
                final startTime = data['startTime'] as String;

                // Must be available and on the correct date
                if (status != 'available') return false;
                if (slotDate.isBefore(startOfDay) ||
                    !slotDate.isBefore(endOfDay)) {
                  return false;
                }

                // If it's today, filter out past slots
                if (isToday && _isSlotInPast(slotDate, startTime)) {
                  return false;
                }

                return true;
              })
              .map(
                (doc) => {
                  'slotId': doc.id,
                  'startTime': doc['startTime'] as String,
                  'endTime': doc['endTime'] as String,
                  'date': (doc['date'] as Timestamp).toDate(),
                  'status': doc['status'] as String,
                },
              )
              .toList();

      // Sort by start time
      slots.sort(
        (a, b) =>
            (a['startTime'] as String).compareTo(b['startTime'] as String),
      );

      return slots;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchAvailableSlotsForRange({
    required String doctorId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final normalizedStart = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
      );
      final normalizedEnd = DateTime(
        endDate.year,
        endDate.month,
        endDate.day,
        23,
        59,
        59,
      );
      final snapshot =
          await _firestore
              .collection('slots')
              .where('doctorId', isEqualTo: doctorId)
              .get();

     
      // Filter slots
      final availableSlots =
          snapshot.docs
              .where((doc) {
                final data = doc.data();
                final status = data['status'] as String?;
                final slotDate = (data['date'] as Timestamp).toDate();
                final normalizedSlotDate = DateTime(
                  slotDate.year,
                  slotDate.month,
                  slotDate.day,
                );
                final startTime = data['startTime'] as String;

                // Must be available and in date range
                if (status != 'available') return false;
                if (normalizedSlotDate.isBefore(normalizedStart) ||
                    normalizedSlotDate.isAfter(normalizedEnd)) {
                  return false;
                }

                // If slot is today, filter out past times
                if (normalizedSlotDate.isAtSameMomentAs(today) &&
                    _isSlotInPast(slotDate, startTime)) {
                  print(
                    'Filtering out past slot: ${DateFormat('HH:mm').format(slotDate)} $startTime',
                  );
                  return false;
                }

                return true;
              })
              .map(
                (doc) => {
                  'slotId': doc.id,
                  'startTime': doc['startTime'] as String,
                  'endTime': doc['endTime'] as String,
                  'date': (doc['date'] as Timestamp).toDate(),
                  'status': doc['status'] as String,
                },
              )
              .toList();

      print(
        'Found ${availableSlots.length} available slots in range after filtering',
      );

      // Sort by date and time
      availableSlots.sort((a, b) {
        final dateCompare = (a['date'] as DateTime).compareTo(
          b['date'] as DateTime,
        );
        if (dateCompare != 0) return dateCompare;
        return (a['startTime'] as String).compareTo(b['startTime'] as String);
      });

      return availableSlots;
    } catch (e) {
      print('Error fetching available slots for range: $e');
      rethrow;
    }
  }

  /// Fetch all available slots for a doctor (no date restriction)
  /// Filters out past slots for today
  Future<List<Map<String, dynamic>>> fetchAllAvailableSlots({
    required String doctorId,
  }) async {
    try {
      print('Fetching all available slots for doctor: $doctorId');

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final snapshot =
          await _firestore
              .collection('slots')
              .where('doctorId', isEqualTo: doctorId)
              .get();

      print('Found ${snapshot.docs.length} total slots for doctor');

      // Filter slots
      final availableSlots =
          snapshot.docs
              .where((doc) {
                final data = doc.data();
                final status = data['status'] as String?;
                final slotDate = (data['date'] as Timestamp).toDate();
                final normalizedSlotDate = DateTime(
                  slotDate.year,
                  slotDate.month,
                  slotDate.day,
                );
                final startTime = data['startTime'] as String;

                // Must be available and not before today
                if (status != 'available') return false;
                if (normalizedSlotDate.isBefore(today)) return false;

                // If slot is today, filter out past times
                if (normalizedSlotDate.isAtSameMomentAs(today) &&
                    _isSlotInPast(slotDate, startTime)) {
                  print(
                    'Filtering out past slot: ${DateFormat('HH:mm').format(slotDate)} $startTime',
                  );
                  return false;
                }

                return true;
              })
              .map(
                (doc) => {
                  'slotId': doc.id,
                  'startTime': doc['startTime'] as String,
                  'endTime': doc['endTime'] as String,
                  'date': (doc['date'] as Timestamp).toDate(),
                  'status': doc['status'] as String,
                },
              )
              .toList();

      print(
        'Found ${availableSlots.length} available slots from today onwards after filtering',
      );

      // Sort by date and time
      availableSlots.sort((a, b) {
        final dateCompare = (a['date'] as DateTime).compareTo(
          b['date'] as DateTime,
        );
        if (dateCompare != 0) return dateCompare;
        return (a['startTime'] as String).compareTo(b['startTime'] as String);
      });

      return availableSlots;
    } catch (e) {
      print('Error fetching all available slots: $e');
      rethrow;
    }
  }

  /// Book an appointment with additional validation
  /// ✨ NEW: Fetches user's profile image and includes it in appointment
  Future<String> bookAppointment({
    required AppointmentModel appointment,
  }) async {
    try {
      // ✨ FETCH USER'S PROFILE IMAGE
      String? profileImageUrl;
      try {
        final userDoc =
            await _firestore.collection('users').doc(appointment.userId).get();

        if (userDoc.exists) {
          final userData = userDoc.data();
          profileImageUrl = userData?['profileImageUrl'] as String?;
          print('User profile image URL: $profileImageUrl');
        } else {
          print(
            '⚠️ Warning: User document not found for userId: ${appointment.userId}',
          );
        }
      } catch (e) {
        print('⚠️ Warning: Failed to fetch user profile image: $e');
        // Continue with booking even if profile fetch fails
      }

      // CRITICAL: Verify the slot is not in the past
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final appointmentDay = DateTime(
        appointment.appointmentDate.year,
        appointment.appointmentDate.month,
        appointment.appointmentDate.day,
      );

      if (appointmentDay.isAtSameMomentAs(today)) {
        if (_isSlotInPast(appointment.appointmentDate, appointment.startTime)) {
          throw Exception(
            'Cannot book a time slot that has already passed. Please select a future time slot.',
          );
        }
      }

      // Verify the slot exists and is available
      final slotDoc =
          await _firestore.collection('slots').doc(appointment.slotId).get();

      if (!slotDoc.exists) {
        throw Exception('Slot not found');
      }

      final slotData = slotDoc.data();
      final slotDoctorId = slotData?['doctorId'] as String?;

      // Verify the slot belongs to the correct doctor
      if (slotDoctorId != appointment.doctorId) {
        throw Exception('Slot does not belong to this doctor');
      }

      final slotStatus = slotData?['status'] as String?;
      if (slotStatus != 'available') {
        throw Exception('This slot is no longer available');
      }

      // Double-check the slot date and time match
      final slotDate = (slotData?['date'] as Timestamp).toDate();
      final slotStartTime = slotData?['startTime'] as String;

      final appointmentDateOnly = DateTime(
        appointment.appointmentDate.year,
        appointment.appointmentDate.month,
        appointment.appointmentDate.day,
      );
      final slotDateOnly = DateTime(
        slotDate.year,
        slotDate.month,
        slotDate.day,
      );

      if (!appointmentDateOnly.isAtSameMomentAs(slotDateOnly) ||
          slotStartTime != appointment.startTime) {
        throw Exception('Slot details do not match the appointment details');
      }

      // Start a batch write
      final batch = _firestore.batch();

      // 1. Create appointment document WITH profile image
      final appointmentRef = _firestore.collection('appointments').doc();

      // ✨ Add profile image to appointment
      final appointmentWithId = appointment.copyWith(
        appointmentId: appointmentRef.id,
        profileImageUrl: profileImageUrl, // ← ADD PROFILE IMAGE HERE
      );

      print('Creating appointment with ID: ${appointmentRef.id}');
      print(
        'Profile image included: ${profileImageUrl != null ? "✅ Yes" : "❌ No"}',
      );

      batch.set(appointmentRef, appointmentWithId.toFirestore());

      // 2. Update slot status to booked
      final slotRef = _firestore.collection('slots').doc(appointment.slotId);

      print('Updating slot: ${appointment.slotId} to booked status');

      batch.update(slotRef, {
        'status': 'booked',
        'bookedBy': appointment.userId,
        'bookedAt': FieldValue.serverTimestamp(),
        'appointmentId': appointmentRef.id,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 3. Commit the batch
      print('Committing batch write...');
      await batch.commit();

      print('✅ Appointment booked successfully with profile image!');
      return appointmentRef.id;
    } catch (e, stackTrace) {
      print('❌ ERROR in bookAppointment: $e');
      print('Stack trace: $stackTrace');

      // Provide more specific error messages
      if (e.toString().contains('already passed')) {
        rethrow; // Keep our specific message
      } else if (e.toString().contains('not found')) {
        throw Exception(
          'The selected time slot was not found. Please try selecting another slot.',
        );
      } else if (e.toString().contains('no longer available')) {
        throw Exception(
          'This time slot was just booked by someone else. Please select another slot.',
        );
      } else if (e.toString().contains('does not belong')) {
        throw Exception('Invalid slot selection. Please try again.');
      } else if (e.toString().contains('do not match')) {
        throw Exception(
          'Slot validation failed. Please select a different slot.',
        );
      } else {
        throw Exception('Failed to book appointment. Please try again.');
      }
    }
  }

  /// Get user appointments
  Future<List<AppointmentModel>> getUserAppointments(String userId) async {
    try {
      print('=== FETCHING APPOINTMENTS FROM FIREBASE ===');
      print('User ID: $userId');

      final snapshot =
          await _firestore
              .collection('appointments')
              .where('userId', isEqualTo: userId)
              .get();

      print('Documents found: ${snapshot.docs.length}');

      final appointments = <AppointmentModel>[];

      for (var doc in snapshot.docs) {
        try {
          print('---');
          print('Document ID: ${doc.id}');

          final appointment = AppointmentModel.fromFirestore(doc);
          appointments.add(appointment);

          print(
            'Parsed: ${appointment.appointmentId} - ${appointment.appointmentDate}',
          );
        } catch (e) {
          print('❌ Error parsing document ${doc.id}: $e');
        }
      }

      // Sort in Dart instead of in Firestore query
      appointments.sort(
        (a, b) => a.appointmentDate.compareTo(b.appointmentDate),
      );

      print('=== APPOINTMENTS LOADED ===');
      print('Total: ${appointments.length}');
      print('=========================');

      return appointments;
    } catch (e, stackTrace) {
      print('❌ Error fetching user appointments: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Cancel appointment
  Future<void> cancelAppointment({
    required String appointmentId,
    required String doctorId,
    required String slotId,
  }) async {
    try {
      final batch = _firestore.batch();

      // 1. Update appointment status
      final appointmentRef = _firestore
          .collection('appointments')
          .doc(appointmentId);
      batch.update(appointmentRef, {
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 2. Release the slot
      final slotRef = _firestore.collection('slots').doc(slotId);

      batch.update(slotRef, {
        'status': 'available',
        'bookedBy': FieldValue.delete(),
        'bookedAt': FieldValue.delete(),
        'appointmentId': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      print('Appointment cancelled successfully');
    } catch (e) {
      print('Error cancelling appointment: $e');
      rethrow;
    }
  }

  Future<String?> getUserProfileImage(String userId) async {
    try {
      print('Fetching profile image for user: $userId');

      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        final profileImageUrl = userData?['profileImageUrl'] as String?;

        print('✅ Profile image URL: ${profileImageUrl ?? "No image"}');
        return profileImageUrl;
      }

      print('⚠️ User document does not exist');
      return null;
    } catch (e) {
      print('❌ Error fetching user profile image: $e');
      return null;
    }
  }
}

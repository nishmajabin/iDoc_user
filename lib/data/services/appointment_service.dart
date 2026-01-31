import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:idoc_user/data/models/appointment_model.dart';

class AppointmentService {
  final FirebaseFirestore _firestore;

  AppointmentService(this._firestore);

  /// Fetch available slots for a doctor on a specific date
  /// SIMPLIFIED: Query only by doctorId, filter in Dart to avoid composite index
  Future<List<Map<String, dynamic>>> fetchAvailableSlots({
    required String doctorId,
    required DateTime date,
  }) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      print('Fetching slots for doctor: $doctorId on date: $date');

      // SIMPLIFIED QUERY: Only filter by doctorId
      final snapshot = await _firestore
          .collection('slots')
          .where('doctorId', isEqualTo: doctorId)
          .get();

      print('Found ${snapshot.docs.length} total slots for doctor');

      // Filter in Dart: available status and specific date
      final slots = snapshot.docs
          .where((doc) {
            final data = doc.data();
            final status = data['status'] as String?;
            final slotDate = (data['date'] as Timestamp).toDate();
            
            return status == 'available' && 
                   !slotDate.isBefore(startOfDay) && 
                   slotDate.isBefore(endOfDay);
          })
          .map((doc) => {
                'slotId': doc.id,
                'startTime': doc['startTime'] as String,
                'endTime': doc['endTime'] as String,
                'date': (doc['date'] as Timestamp).toDate(),
                'status': doc['status'] as String,
              })
          .toList();

      print('Found ${slots.length} available slots for the date');

      // Sort by start time
      slots.sort((a, b) => (a['startTime'] as String).compareTo(b['startTime'] as String));

      return slots;
    } catch (e) {
      print('Error fetching available slots: $e');
      rethrow;
    }
  }

  /// Fetch available slots for a date range
  /// SIMPLIFIED: Query only by doctorId, filter rest in Dart to avoid composite index
  Future<List<Map<String, dynamic>>> fetchAvailableSlotsForRange({
    required String doctorId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final normalizedStart = DateTime(startDate.year, startDate.month, startDate.day);
      final normalizedEnd = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);

      print('Fetching slots for doctor: $doctorId from $normalizedStart to $normalizedEnd');

      // SIMPLIFIED QUERY: Only filter by doctorId
      final snapshot = await _firestore
          .collection('slots')
          .where('doctorId', isEqualTo: doctorId)
          .get();

      print('Found ${snapshot.docs.length} total slots for doctor');

      // Filter in Dart: available status and date range
      final availableSlots = snapshot.docs
          .where((doc) {
            final data = doc.data();
            final status = data['status'] as String?;
            final date = (data['date'] as Timestamp).toDate();
            
            return status == 'available' && 
                   !date.isBefore(normalizedStart) && 
                   !date.isAfter(normalizedEnd);
          })
          .map((doc) => {
                'slotId': doc.id,
                'startTime': doc['startTime'] as String,
                'endTime': doc['endTime'] as String,
                'date': (doc['date'] as Timestamp).toDate(),
                'status': doc['status'] as String,
              })
          .toList();

      print('Found ${availableSlots.length} available slots in range');

      // Sort by date and time
      availableSlots.sort((a, b) {
        final dateCompare = (a['date'] as DateTime).compareTo(b['date'] as DateTime);
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
  /// This helps us know which dates have slots
  /// SIMPLIFIED: Uses only doctorId filter to avoid composite index
  Future<List<Map<String, dynamic>>> fetchAllAvailableSlots({
    required String doctorId,
  }) async {
    try {
      print('Fetching all available slots for doctor: $doctorId');

      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day);

      // SIMPLIFIED QUERY: Only filter by doctorId to avoid composite index
      // Filter the rest in Dart
      final snapshot = await _firestore
          .collection('slots')
          .where('doctorId', isEqualTo: doctorId)
          .get();

      print('Found ${snapshot.docs.length} total slots for doctor');

      // Filter in Dart: only available slots from today onwards
      final availableSlots = snapshot.docs
          .where((doc) {
            final data = doc.data();
            final status = data['status'] as String?;
            final date = (data['date'] as Timestamp).toDate();
            final normalizedDate = DateTime(date.year, date.month, date.day);
            
            return status == 'available' && 
                   !normalizedDate.isBefore(startOfToday);
          })
          .map((doc) => {
                'slotId': doc.id,
                'startTime': doc['startTime'] as String,
                'endTime': doc['endTime'] as String,
                'date': (doc['date'] as Timestamp).toDate(),
                'status': doc['status'] as String,
              })
          .toList();

      print('Found ${availableSlots.length} available slots from today onwards');

      // Sort by date and time
      availableSlots.sort((a, b) {
        final dateCompare = (a['date'] as DateTime).compareTo(b['date'] as DateTime);
        if (dateCompare != 0) return dateCompare;
        return (a['startTime'] as String).compareTo(b['startTime'] as String);
      });

      return availableSlots;
    } catch (e) {
      print('Error fetching all available slots: $e');
      rethrow;
    }
  }

  /// Book an appointment
  Future<String> bookAppointment({
    required AppointmentModel appointment,
  }) async {
    try {
      print('=== BOOKING APPOINTMENT SERVICE ===');
      print('Doctor ID: ${appointment.doctorId}');
      print('Slot ID: ${appointment.slotId}');
      print('Patient: ${appointment.patientName}');
      print('Description: ${appointment.description}');
      print('Date: ${appointment.appointmentDate}');
      print('Time: ${appointment.startTime} - ${appointment.endTime}');
      print('===================================');

      // First, verify the slot is still available
      // FIXED: Query from main 'slots' collection
      final slotDoc = await _firestore
          .collection('slots')
          .doc(appointment.slotId)
          .get();

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

      // Start a batch write
      final batch = _firestore.batch();

      // 1. Create appointment document
      final appointmentRef = _firestore.collection('appointments').doc();
      final appointmentWithId = appointment.copyWith(
        appointmentId: appointmentRef.id,
      );
      
      print('Creating appointment with ID: ${appointmentRef.id}');
      batch.set(appointmentRef, appointmentWithId.toFirestore());

      // 2. Update slot status to booked
      // FIXED: Update in main 'slots' collection
      final slotRef = _firestore
          .collection('slots')
          .doc(appointment.slotId);

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
      
      print('✅ Appointment booked successfully!');
      return appointmentRef.id;
    } catch (e, stackTrace) {
      print('❌ ERROR in bookAppointment: $e');
      print('Stack trace: $stackTrace');
      
      // Provide more specific error messages
      if (e.toString().contains('not found')) {
        throw Exception('The selected time slot was not found. Please try selecting another slot.');
      } else if (e.toString().contains('no longer available')) {
        throw Exception('This time slot was just booked by someone else. Please select another slot.');
      } else if (e.toString().contains('does not belong')) {
        throw Exception('Invalid slot selection. Please try again.');
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
      
      // Query without orderBy to avoid needing a composite index
      final snapshot = await _firestore
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
          
          print('Parsed: ${appointment.appointmentId} - ${appointment.appointmentDate}');
        } catch (e) {
          print('❌ Error parsing document ${doc.id}: $e');
          // Continue with other documents even if one fails
        }
      }

      // Sort in Dart instead of in Firestore query
      appointments.sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));

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
      final appointmentRef = _firestore.collection('appointments').doc(appointmentId);
      batch.update(appointmentRef, {
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 2. Release the slot
      // FIXED: Update in main 'slots' collection
      final slotRef = _firestore
          .collection('slots')
          .doc(slotId);

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
}
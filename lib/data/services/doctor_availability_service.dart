// lib/data/services/doctor_availability_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorAvailabilityService {
  final FirebaseFirestore _firestore;

  DoctorAvailabilityService(this._firestore);

  /// Check if doctor has available slots today
  Future<bool> hasAvailabilityToday(String doctorId) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final endOfDay = today.add(const Duration(days: 1));

      final snapshot = await _firestore
          .collection('slots')
          .where('doctorId', isEqualTo: doctorId)
          .where('status', isEqualTo: 'available')
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return false;

      // Check if any slot is today and not in the past
      for (var doc in snapshot.docs) {
        final slotDate = (doc['date'] as Timestamp).toDate();
        final normalizedSlotDate = DateTime(
          slotDate.year,
          slotDate.month,
          slotDate.day,
        );

        if (normalizedSlotDate.isAtSameMomentAs(today)) {
          final startTime = doc['startTime'] as String;
          if (!_isSlotInPast(slotDate, startTime)) {
            return true;
          }
        }
      }

      return false;
    } catch (e) {
      print('Error checking today availability: $e');
      return false;
    }
  }

  /// Check if doctor has available slots this week
  Future<bool> hasAvailabilityThisWeek(String doctorId) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final endOfWeek = today.add(const Duration(days: 7));

      final snapshot = await _firestore
          .collection('slots')
          .where('doctorId', isEqualTo: doctorId)
          .where('status', isEqualTo: 'available')
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return false;

      // Check if any slot is within this week
      for (var doc in snapshot.docs) {
        final slotDate = (doc['date'] as Timestamp).toDate();
        final normalizedSlotDate = DateTime(
          slotDate.year,
          slotDate.month,
          slotDate.day,
        );

        if (!normalizedSlotDate.isBefore(today) &&
            normalizedSlotDate.isBefore(endOfWeek)) {
          return true;
        }
      }

      return false;
    } catch (e) {
      print('Error checking week availability: $e');
      return false;
    }
  }

  /// Helper to check if slot is in the past
  bool _isSlotInPast(DateTime slotDate, String startTime) {
    try {
      final now = DateTime.now();

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

      final bufferTime = now.add(const Duration(minutes: 5));

      return slotDateTime.isBefore(bufferTime);
    } catch (e) {
      print('Error parsing time: $e');
      return true;
    }
  }

  /// Batch check availability for multiple doctors (optimized)
  Future<Map<String, bool>> checkTodayAvailabilityBatch(
    List<String> doctorIds,
  ) async {
    final results = <String, bool>{};

    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Fetch all available slots for these doctors
      final snapshot = await _firestore
          .collection('slots')
          .where('doctorId', whereIn: doctorIds)
          .where('status', isEqualTo: 'available')
          .get();

      // Initialize all as false
      for (var id in doctorIds) {
        results[id] = false;
      }

      // Check each slot
      for (var doc in snapshot.docs) {
        final doctorId = doc['doctorId'] as String;
        if (!results.containsKey(doctorId)) continue;
        if (results[doctorId]!) continue; // Already found availability

        final slotDate = (doc['date'] as Timestamp).toDate();
        final normalizedSlotDate = DateTime(
          slotDate.year,
          slotDate.month,
          slotDate.day,
        );

        if (normalizedSlotDate.isAtSameMomentAs(today)) {
          final startTime = doc['startTime'] as String;
          if (!_isSlotInPast(slotDate, startTime)) {
            results[doctorId] = true;
          }
        }
      }

      return results;
    } catch (e) {
      print('Error in batch availability check: $e');
      return results;
    }
  }

  /// Batch check availability for this week
  Future<Map<String, bool>> checkWeekAvailabilityBatch(
    List<String> doctorIds,
  ) async {
    final results = <String, bool>{};

    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final endOfWeek = today.add(const Duration(days: 7));

      final snapshot = await _firestore
          .collection('slots')
          .where('doctorId', whereIn: doctorIds)
          .where('status', isEqualTo: 'available')
          .get();

      for (var id in doctorIds) {
        results[id] = false;
      }

      for (var doc in snapshot.docs) {
        final doctorId = doc['doctorId'] as String;
        if (!results.containsKey(doctorId)) continue;
        if (results[doctorId]!) continue;

        final slotDate = (doc['date'] as Timestamp).toDate();
        final normalizedSlotDate = DateTime(
          slotDate.year,
          slotDate.month,
          slotDate.day,
        );

        if (!normalizedSlotDate.isBefore(today) &&
            normalizedSlotDate.isBefore(endOfWeek)) {
          results[doctorId] = true;
        }
      }

      return results;
    } catch (e) {
      print('Error in batch week availability check: $e');
      return results;
    }
  }
}
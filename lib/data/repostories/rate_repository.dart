import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:idoc_user/data/models/rating_model.dart';

class RatingRepository {
  final FirebaseFirestore _firestore;

  // Simple in-memory cache so we don't re-fetch the same user repeatedly
  final Map<String, Map<String, String?>> _userCache = {};

  RatingRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ── User info fetching ────────────────────────────────────────────────────

  /// Fetches name + profileImageUrl for a userId from the `users` collection.
  /// Results are cached for the lifetime of this repository instance.
  Future<Map<String, String?>> _fetchUserInfo(String userId) async {
    if (_userCache.containsKey(userId)) return _userCache[userId]!;

    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) {
        _userCache[userId] = {'name': null, 'profileImageUrl': null};
        return _userCache[userId]!;
      }
      final data = doc.data()!;
      // Supports common field name variants
      final name = (data['name'] ?? data['fullName'] ?? data['displayName'])
          as String?;
      final image =
          (data['profileImageUrl'] ?? data['photoUrl'] ?? data['avatar'])
              as String?;
      _userCache[userId] = {'name': name, 'profileImageUrl': image};
      return _userCache[userId]!;
    } catch (e) {
      log('Error fetching user info for $userId: $e');
      _userCache[userId] = {'name': null, 'profileImageUrl': null};
      return _userCache[userId]!;
    }
  }

  /// Enriches a list of RatingModels with user names and profile images.
  /// Uses batch concurrent fetches — one Firestore read per unique user.
  Future<List<RatingModel>> _enrichWithUserInfo(
      List<RatingModel> ratings) async {
    // Collect unique user IDs to avoid duplicate fetches
    final uniqueUserIds = ratings.map((r) => r.userId).toSet().toList();

    // Fetch all user infos concurrently
    await Future.wait(uniqueUserIds.map(_fetchUserInfo));

    // Attach user info to each rating
    return ratings.map((r) {
      final info = _userCache[r.userId];
      return r.withUserInfo(
        name: info?['name'],
        profileImage: info?['profileImageUrl'],
      );
    }).toList();
  }

  // ── Consultation check ──────────────────────────────────────────────────

  /// Returns `true` if the user has at least one completed consultation
  /// with the given doctor in the `appointments` collection.
  ///
  /// A consultation is considered "completed" if:
  ///   1. Its Firestore `status` field is explicitly `'completed'`, **OR**
  ///   2. The appointment's end time has already passed (i.e.
  ///      `DateTime.now() > appointmentDate + endTime`) and the appointment
  ///      was **not** cancelled.
  ///
  /// This allows the rating section to unlock automatically once the
  /// consultation time window ends, without requiring a manual status update.
  Future<bool> hasCompletedConsultation(
      String doctorId, String userId) async {
    try {
      log('Checking consultation: doctorId=$doctorId, userId=$userId');

      final snapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('userId', isEqualTo: userId)
          .get();

      log('Found ${snapshot.docs.length} appointment(s) between user and doctor');

      final now = DateTime.now();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final status = (data['status'] as String?)?.toLowerCase().trim() ?? '';
        log('  → Appointment ${doc.id}: status="$status"');

        // ① Explicit "completed" status — always honour it.
        if (status == 'completed') {
          log('  ✅ Found explicitly completed consultation');
          return true;
        }

        // ② Skip cancelled appointments — they should never unlock ratings.
        if (status == 'cancelled') {
          log('  ⏭ Skipping cancelled appointment');
          continue;
        }

        // ③ Time-based completion: check if the slot's end time has passed.
        if (_isAppointmentTimePassed(data, now)) {
          log('  ✅ Consultation time has passed — treating as completed');
          return true;
        }
      }

      log('  ❌ No completed consultation found');
      return false;
    } catch (e) {
      log('Error checking consultation status: $e');
      return false;
    }
  }

  /// Parses the `appointmentDate` + `endTime` from a Firestore document
  /// and returns `true` if that combined DateTime is before [now].
  ///
  /// Handles `endTime` stored as either:
  ///   • 24-hour format: `"14:30"`
  ///   • 12-hour format: `"02:30 PM"` / `"02:30PM"`
  ///
  /// Returns `false` on any parsing failure (safe default — keeps rating
  /// locked rather than unlocking it prematurely).
  bool _isAppointmentTimePassed(Map<String, dynamic> data, DateTime now) {
    try {
      // ── Parse the appointment date ──────────────────────────────────────
      final dynamic rawDate = data['appointmentDate'];
      DateTime appointmentDate;
      if (rawDate is Timestamp) {
        appointmentDate = rawDate.toDate();
      } else if (rawDate is DateTime) {
        appointmentDate = rawDate;
      } else {
        log('  ⚠ Could not parse appointmentDate: $rawDate');
        return false;
      }

      // ── Parse endTime string → hour + minute ───────────────────────────
      final String endTimeStr = (data['endTime'] as String?)?.trim() ?? '';
      if (endTimeStr.isEmpty) return false;

      final endTimeParts = _parseTimeString(endTimeStr);
      if (endTimeParts == null) {
        log('  ⚠ Could not parse endTime: "$endTimeStr"');
        return false;
      }

      // ── Build the full end DateTime ────────────────────────────────────
      final endDateTime = DateTime(
        appointmentDate.year,
        appointmentDate.month,
        appointmentDate.day,
        endTimeParts.$1, // hour
        endTimeParts.$2, // minute
      );

      return now.isAfter(endDateTime);
    } catch (e) {
      log('  ⚠ Error in _isAppointmentTimePassed: $e');
      return false;
    }
  }

  /// Parses a time string into (hour, minute) in 24-hour format.
  ///
  /// Supported formats:
  ///   • `"14:30"`        → (14, 30)
  ///   • `"02:30 PM"`     → (14, 30)
  ///   • `"12:00 AM"`     → (0, 0)
  (int, int)? _parseTimeString(String time) {
    try {
      final upper = time.toUpperCase().trim();
      final isPM = upper.contains('PM');
      final isAM = upper.contains('AM');

      // Strip the AM/PM suffix
      final cleaned =
          upper.replaceAll('AM', '').replaceAll('PM', '').trim();
      final parts = cleaned.split(':');
      if (parts.length < 2) return null;

      int hour = int.parse(parts[0].trim());
      final int minute = int.parse(parts[1].trim());

      if (isPM && hour != 12) hour += 12;
      if (isAM && hour == 12) hour = 0;

      return (hour, minute);
    } catch (_) {
      return null;
    }
  }

  // ── Ratings CRUD ──────────────────────────────────────────────────────────

  /// Submit or update a rating
  Future<bool> submitRating({
    required String doctorId,
    required String userId,
    required double rating,
    String? review,
  }) async {
    try {
      final existingRating = await getUserRatingForDoctor(doctorId, userId);

      if (existingRating != null) {
        await _firestore.collection('ratings').doc(existingRating.id).update({
          'rating': rating,
          'review': review,
          'updatedAt': Timestamp.now(),
        });
      } else {
        final ratingModel = RatingModel(
          doctorId: doctorId,
          userId: userId,
          rating: rating,
          review: review,
        );
        await _firestore.collection('ratings').add(ratingModel.toMap());
      }

      await _updateDoctorRating(doctorId);
      return true;
    } catch (e) {
      log('Error submitting rating: $e');
      return false;
    }
  }

  /// Get the current user's rating for a doctor (no user enrichment needed)
  Future<RatingModel?> getUserRatingForDoctor(
      String doctorId, String userId) async {
    try {
      final snapshot = await _firestore
          .collection('ratings')
          .where('doctorId', isEqualTo: doctorId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return RatingModel.fromMap(
        snapshot.docs.first.data(),
        snapshot.docs.first.id,
      );
    } catch (e) {
      log('Error getting user rating: $e');
      return null;
    }
  }

  /// Get all ratings for a doctor, sorted newest first, enriched with user names
  Future<List<RatingModel>> getDoctorRatings(String doctorId) async {
    try {
      final snapshot = await _firestore
          .collection('ratings')
          .where('doctorId', isEqualTo: doctorId)
          .get();

      final ratings = snapshot.docs
          .map((doc) => RatingModel.fromMap(doc.data(), doc.id))
          .toList();

      ratings.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Enrich with real user names
      return await _enrichWithUserInfo(ratings);
    } catch (e) {
      log('Error getting doctor ratings: $e');
      return [];
    }
  }

  /// Stream ratings for a doctor, sorted newest first, enriched with user names
  Stream<List<RatingModel>> doctorRatingsStream(String doctorId) {
    return _firestore
        .collection('ratings')
        .where('doctorId', isEqualTo: doctorId)
        .snapshots()
        .asyncMap((snapshot) async {
      final ratings = snapshot.docs
          .map((doc) => RatingModel.fromMap(doc.data(), doc.id))
          .toList();

      ratings.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return await _enrichWithUserInfo(ratings);
    });
  }

  /// Update doctor's average rating in the doctors collection
  Future<void> _updateDoctorRating(String doctorId) async {
    try {
      final snapshot = await _firestore
          .collection('ratings')
          .where('doctorId', isEqualTo: doctorId)
          .get();

      if (snapshot.docs.isEmpty) {
        await _firestore.collection('doctors').doc(doctorId).update({
          'averageRating': 0.0,
          'totalRatings': 0,
        });
        return;
      }

      final ratings = snapshot.docs
          .map((doc) => (doc.data()['rating'] as num).toDouble())
          .toList();

      final average = ratings.reduce((a, b) => a + b) / ratings.length;

      await _firestore.collection('doctors').doc(doctorId).update({
        'averageRating': double.parse(average.toStringAsFixed(1)),
        'totalRatings': ratings.length,
      });
    } catch (e) {
      log('Error updating doctor rating: $e');
    }
  }
}
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:idoc_user/data/models/rating_model.dart';

class RatingRepository {
  final FirebaseFirestore _firestore;

  RatingRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Submit or update a rating
  Future<bool> submitRating({
    required String doctorId,
    required String userId,
    required double rating,
    String? review,
  }) async {
    try {
      // Check if user has already rated this doctor
      final existingRating = await getUserRatingForDoctor(doctorId, userId);

      if (existingRating != null) {
        // Update existing rating
        await _firestore.collection('ratings').doc(existingRating.id).update({
          'rating': rating,
          'review': review,
          'updatedAt': Timestamp.now(),
        });
      } else {
        // Create new rating
        final ratingModel = RatingModel(
          doctorId: doctorId,
          userId: userId,
          rating: rating,
          review: review,
        );
        await _firestore.collection('ratings').add(ratingModel.toMap());
      }

      // Update doctor's average rating
      await _updateDoctorRating(doctorId);
      return true;
    } catch (e) {
      log('Error submitting rating: $e');
      return false;
    }
  }

  /// Get user's rating for a specific doctor
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

  /// Get all ratings for a doctor (without ordering - no index needed)
  Future<List<RatingModel>> getDoctorRatings(String doctorId) async {
    try {
      final snapshot = await _firestore
          .collection('ratings')
          .where('doctorId', isEqualTo: doctorId)
          .get();

      // Convert to list
      final ratings = snapshot.docs
          .map((doc) => RatingModel.fromMap(doc.data(), doc.id))
          .toList();

      // Sort in memory instead of Firestore
      ratings.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return ratings;
    } catch (e) {
      log('Error getting doctor ratings: $e');
      return [];
    }
  }

  /// Update doctor's average rating
  Future<void> _updateDoctorRating(String doctorId) async {
    try {
      final ratings = await getDoctorRatings(doctorId);

      if (ratings.isEmpty) {
        await _firestore.collection('doctors').doc(doctorId).update({
          'averageRating': 0.0,
          'totalRatings': 0,
        });
        return;
      }

      final totalRating = ratings.fold<double>(
        0.0,
        (sum, rating) => sum + rating.rating,
      );
      final averageRating = totalRating / ratings.length;

      await _firestore.collection('doctors').doc(doctorId).update({
        'averageRating': averageRating,
        'totalRatings': ratings.length,
      });
    } catch (e) {
      log('Error updating doctor rating: $e');
    }
  }

  /// Stream ratings for a doctor (without ordering - no index needed)
  Stream<List<RatingModel>> doctorRatingsStream(String doctorId) {
    return _firestore
        .collection('ratings')
        .where('doctorId', isEqualTo: doctorId)
        .snapshots()
        .map((snapshot) {
          final ratings = snapshot.docs
              .map((doc) => RatingModel.fromMap(doc.data(), doc.id))
              .toList();
          
          // Sort in memory
          ratings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          
          return ratings;
        });
  }
}
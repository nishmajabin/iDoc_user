abstract class DoctorRatingEvent {
  const DoctorRatingEvent();
}

/// Load preview (latest 5 reviews) + user's existing rating
class LoadDoctorRatings extends DoctorRatingEvent {
  final String doctorId;
  final String? userId; // nullable — user may not be logged in
  const LoadDoctorRatings({required this.doctorId, this.userId});
}

/// Submit or update a rating
class SubmitDoctorRating extends DoctorRatingEvent {
  final String doctorId;
  final String userId;
  final double rating;
  final String? review;
  const SubmitDoctorRating({
    required this.doctorId,
    required this.userId,
    required this.rating,
    this.review,
  });
}

/// Load ALL reviews (for the full-list screen)
class LoadAllDoctorRatings extends DoctorRatingEvent {
  final String doctorId;
  const LoadAllDoctorRatings({required this.doctorId});
}
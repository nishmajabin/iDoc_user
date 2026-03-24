import 'package:idoc_user/data/models/rating_model.dart';

abstract class DoctorRatingState {
  const DoctorRatingState();
}

class DoctorRatingInitial extends DoctorRatingState {
  const DoctorRatingInitial();
}

class DoctorRatingLoading extends DoctorRatingState {
  const DoctorRatingLoading();
}

class DoctorRatingLoaded extends DoctorRatingState {
  final List<RatingModel> previewReviews;
  final List<RatingModel> allReviews;
  final bool hasMore;
  final RatingModel? userRating;
  final bool hasCompletedConsultation;

  final bool isSubmitting;

  final bool? submitSuccess;

  const DoctorRatingLoaded({
    required this.previewReviews,
    this.allReviews = const [],
    required this.hasMore,
    this.userRating,
    this.hasCompletedConsultation = false,
    this.isSubmitting = false,
    this.submitSuccess,
  });

  DoctorRatingLoaded copyWith({
    List<RatingModel>? previewReviews,
    List<RatingModel>? allReviews,
    bool? hasMore,
    RatingModel? userRating,
    bool clearUserRating = false,
    bool? hasCompletedConsultation,
    bool? isSubmitting,
    bool? submitSuccess,
  }) {
    return DoctorRatingLoaded(
      previewReviews: previewReviews ?? this.previewReviews,
      allReviews: allReviews ?? this.allReviews,
      hasMore: hasMore ?? this.hasMore,
      userRating: clearUserRating ? null : (userRating ?? this.userRating),
      hasCompletedConsultation: hasCompletedConsultation ?? this.hasCompletedConsultation,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitSuccess: submitSuccess,
    );
  }
}

class DoctorRatingError extends DoctorRatingState {
  final String message;
  const DoctorRatingError(this.message);
}

/// Emitted after LoadAllDoctorRatings completes (used by AllReviewsScreen)
class AllDoctorRatingsLoaded extends DoctorRatingState {
  final List<RatingModel> reviews;
  const AllDoctorRatingsLoaded(this.reviews);
}
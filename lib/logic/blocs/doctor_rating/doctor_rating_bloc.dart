import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/data/models/rating_model.dart';
import 'package:idoc_user/data/repostories/rate_repository.dart';
import 'doctor_rating_event.dart';
import 'doctor_rating_state.dart';

class DoctorRatingBloc extends Bloc<DoctorRatingEvent, DoctorRatingState> {
  final RatingRepository _repository;

  static const int _previewLimit = 5;

  DoctorRatingBloc({RatingRepository? repository})
      : _repository = repository ?? RatingRepository(),
        super(const DoctorRatingInitial()) {
    on<LoadDoctorRatings>(_onLoad);
    on<SubmitDoctorRating>(_onSubmit);
    on<LoadAllDoctorRatings>(_onLoadAll);
  }

  // ── Load preview ──────────────────────────────────────────────────────────

  Future<void> _onLoad(
    LoadDoctorRatings event,
    Emitter<DoctorRatingState> emit,
  ) async {
    emit(const DoctorRatingLoading());
    try {
      // Fetch all reviews sorted by date (done in-memory in your repo)
      final all = await _repository.getDoctorRatings(event.doctorId);

      // Fetch user's existing rating + consultation status in parallel
      RatingModel? userRating;
      bool hasConsultation = false;

      if (event.userId != null) {
        final results = await Future.wait([
          _repository.getUserRatingForDoctor(event.doctorId, event.userId!),
          _repository.hasCompletedConsultation(event.doctorId, event.userId!),
        ]);
        userRating = results[0] as RatingModel?;
        hasConsultation = results[1] as bool;
        log('DoctorRatingBloc: hasConsultation=$hasConsultation for doctor=${event.doctorId}');
      }

      emit(DoctorRatingLoaded(
        previewReviews: all.take(_previewLimit).toList(),
        hasMore: all.length > _previewLimit,
        userRating: userRating,
        hasCompletedConsultation: hasConsultation,
      ));
    } catch (e) {
      emit(DoctorRatingError('Failed to load ratings: $e'));
    }
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _onSubmit(
    SubmitDoctorRating event,
    Emitter<DoctorRatingState> emit,
  ) async {
    if (state is! DoctorRatingLoaded) return;
    final current = state as DoctorRatingLoaded;

    emit(current.copyWith(isSubmitting: true, submitSuccess: null));

    try {
      final success = await _repository.submitRating(
        doctorId: event.doctorId,
        userId: event.userId,
        rating: event.rating,
        review: event.review,
      );

      if (success) {
        // Reload the preview so the new/updated review appears immediately
        final all = await _repository.getDoctorRatings(event.doctorId);
        final userRating = await _repository.getUserRatingForDoctor(
          event.doctorId,
          event.userId,
        );
        emit(DoctorRatingLoaded(
          previewReviews: all.take(_previewLimit).toList(),
          hasMore: all.length > _previewLimit,
          userRating: userRating,
          hasCompletedConsultation: current.hasCompletedConsultation,
          isSubmitting: false,
          submitSuccess: true,
        ));
      } else {
        emit(current.copyWith(isSubmitting: false, submitSuccess: false));
      }
    } catch (e) {
      emit(current.copyWith(isSubmitting: false, submitSuccess: false));
    }
  }

  // ── Load all (for AllReviewsScreen) ───────────────────────────────────────

  Future<void> _onLoadAll(
    LoadAllDoctorRatings event,
    Emitter<DoctorRatingState> emit,
  ) async {
    // Preserve existing preview state while loading
    if (state is DoctorRatingLoaded) {
      emit((state as DoctorRatingLoaded).copyWith(isSubmitting: false));
    } else {
      emit(const DoctorRatingLoading());
    }
    try {
      final all = await _repository.getDoctorRatings(event.doctorId);
      emit(AllDoctorRatingsLoaded(all));
    } catch (e) {
      emit(DoctorRatingError('Failed to load reviews: $e'));
    }
  }
}
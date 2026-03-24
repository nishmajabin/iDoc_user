import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/data/repostories/doctor_repository.dart';
import 'package:idoc_user/logic/blocs/featured_doctors/featured_doctors_event.dart';
import 'package:idoc_user/logic/blocs/featured_doctors/featured_doctors_state.dart';

class FeaturedDoctorsBloc
    extends Bloc<FeaturedDoctorsEvent, FeaturedDoctorsState> {
  final DoctorRepository _repository;

  FeaturedDoctorsBloc(this._repository) : super(FeaturedDoctorsInitial()) {
    on<LoadFeaturedDoctorsEvent>(_onLoadFeaturedDoctors);
  }

  Future<void> _onLoadFeaturedDoctors(
    LoadFeaturedDoctorsEvent event,
    Emitter<FeaturedDoctorsState> emit,
  ) async {
    emit(FeaturedDoctorsLoading());
    try {
      final doctors = await _repository.loadTopRatedDoctors(limit: 5);

      if (doctors.isEmpty) {
        emit(FeaturedDoctorsEmpty());
      } else {
        emit(FeaturedDoctorsLoaded(doctors: doctors));
      }
    } catch (e) {
      log('Error loading featured doctors: $e');
      emit(FeaturedDoctorsError('Failed to load featured doctors'));
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/data/repostories/doctor_repository.dart';
import 'package:idoc_user/logic/blocs/doctor_detail/doctor_detail_event.dart';
import 'package:idoc_user/logic/blocs/doctor_detail/doctor_detail_state.dart';

class DoctorDetailBloc extends Bloc<DoctorDetailEvent, DoctorDetailState> {
  final DoctorRepository _repository;

  DoctorDetailBloc(this._repository) : super(DoctorDetailInitial()) {
    on<LoadDoctorDetailEvent>(_onLoadDoctorDetail);
    on<RetryLoadDoctorDetailEvent>(_onRetryLoadDoctorDetail);
  }

  Future<void> _onLoadDoctorDetail(
    LoadDoctorDetailEvent event,
    Emitter<DoctorDetailState> emit,
  ) async {
    emit(DoctorDetailLoading());
    try {
      final doctor = await _repository.getDoctorById(event.doctorId);
      if (doctor != null) {
        emit(DoctorDetailLoaded(doctor));
      } else {
        emit(DoctorDetailError('Doctor not found'));
      }
    } catch (e) {
      emit(DoctorDetailError('Failed to load doctor details: $e'));
    }
  }

  void _onRetryLoadDoctorDetail(
    RetryLoadDoctorDetailEvent event,
    Emitter<DoctorDetailState> emit,
  ) {
    add(LoadDoctorDetailEvent(event.doctorId));
  }
}
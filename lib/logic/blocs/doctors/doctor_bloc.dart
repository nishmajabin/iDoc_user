import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/data/repostories/doctor_repository.dart';
import 'package:idoc_user/presentation/screens/home/widgets/doctor_event.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_state.dart';

class DoctorBloc extends Bloc<DoctorEvent, DoctorState> {
  final DoctorRepository _repository;

  DoctorBloc(this._repository) : super(DoctorInitial()) {
    on<LoadAllDoctorsEvent>(_onLoadAllDoctors);
    on<LoadDoctorsByCategoryEvent>(_onLoadDoctorsByCategory);
    on<SearchDoctorsEvent>(_onSearchDoctors);
    on<ResetSearchEvent>(_onResetSearch);
    on<RetryLoadDoctorsEvent>(_onRetryLoadDoctors);
  }

  Future<void> _onLoadAllDoctors(
    LoadAllDoctorsEvent event,
    Emitter<DoctorState> emit,
  ) async {
    emit(DoctorLoading());
    try {
      final doctors = await _repository.loadApprovedDoctors();
      emit(DoctorLoaded(
        doctors: doctors,
        allDoctors: doctors,
        currentCategory: null,
      ));
    } catch (e) {
      emit(DoctorError('Failed to load doctors: $e'));
    }
  }

  Future<void> _onLoadDoctorsByCategory(
    LoadDoctorsByCategoryEvent event,
    Emitter<DoctorState> emit,
  ) async {
    emit(DoctorLoading());
    try {
      final doctors = await _repository.loadDoctorsByCategory(event.category);
      emit(DoctorLoaded(
        doctors: doctors,
        allDoctors: doctors,
        currentCategory: event.category,
      ));
    } catch (e) {
      emit(DoctorError(
        'Failed to load doctors: $e',
        currentCategory: event.category,
      ));
    }
  }

  void _onSearchDoctors(
    SearchDoctorsEvent event,
    Emitter<DoctorState> emit,
  ) {
    if (state is DoctorLoaded) {
      final currentState = state as DoctorLoaded;
      
      if (event.query.isEmpty) {
        emit(currentState.copyWith(
          doctors: currentState.allDoctors,
          searchQuery: '',
        ));
        return;
      }

      final filteredDoctors = currentState.allDoctors
          .where((doctor) =>
              doctor.name.toLowerCase().contains(event.query.toLowerCase()) ||
              doctor.specialist.toLowerCase().contains(event.query.toLowerCase()) ||
              doctor.place.toLowerCase().contains(event.query.toLowerCase()))
          .toList();

      emit(currentState.copyWith(
        doctors: filteredDoctors,
        searchQuery: event.query,
      ));
    }
  }

  void _onResetSearch(
    ResetSearchEvent event,
    Emitter<DoctorState> emit,
  ) {
    if (state is DoctorLoaded) {
      final currentState = state as DoctorLoaded;
      emit(currentState.copyWith(
        doctors: currentState.allDoctors,
        searchQuery: '',
      ));
    }
  }

  void _onRetryLoadDoctors(
    RetryLoadDoctorsEvent event,
    Emitter<DoctorState> emit,
  ) {
    if (state is DoctorError) {
      final errorState = state as DoctorError;
      if (errorState.currentCategory != null) {
        add(LoadDoctorsByCategoryEvent(errorState.currentCategory!));
      } else {
        add(LoadAllDoctorsEvent());
      }
    } else if (state is DoctorLoaded) {
      final loadedState = state as DoctorLoaded;
      if (loadedState.currentCategory != null) {
        add(LoadDoctorsByCategoryEvent(loadedState.currentCategory!));
      } else {
        add(LoadAllDoctorsEvent());
      }
    } else {
      add(LoadAllDoctorsEvent());
    }
  }
}
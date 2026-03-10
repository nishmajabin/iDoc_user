import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/data/models/doctor_filter_model.dart';
import 'package:idoc_user/data/models/doctor_model.dart';
import 'package:idoc_user/data/repostories/doctor_repository.dart';
import 'package:idoc_user/data/services/doctor_availability_service.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_event.dart';
import 'package:idoc_user/logic/blocs/doctors/doctor_state.dart';

class DoctorBloc extends Bloc<DoctorEvent, DoctorState> {
  final DoctorRepository _repository;
  final DoctorAvailabilityService _availabilityService;

  DoctorBloc(
    this._repository,
    this._availabilityService,
  ) : super(DoctorInitial()) {
    on<LoadAllDoctorsEvent>(_onLoadAllDoctors);
    on<LoadDoctorsByCategoryEvent>(_onLoadDoctorsByCategory);
    on<SearchDoctorsEvent>(_onSearchDoctors);
    on<ResetSearchEvent>(_onResetSearch);
    on<RetryLoadDoctorsEvent>(_onRetryLoadDoctors);
    on<ApplyFiltersEvent>(_onApplyFilters);
    on<ClearFiltersEvent>(_onClearFilters);
    on<UpdateFilterEvent>(_onUpdateFilter);
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
        // Re-apply filters without search
        final filtered = _applyFilters(
          currentState.allDoctors,
          currentState.filter,
        );
        emit(currentState.copyWith(
          doctors: filtered,
          searchQuery: '',
        ));
        return;
      }

      final searchFiltered = currentState.allDoctors
          .where((doctor) =>
              doctor.name.toLowerCase().contains(event.query.toLowerCase()) ||
              doctor.specialist
                  .toLowerCase()
                  .contains(event.query.toLowerCase()) ||
              doctor.place.toLowerCase().contains(event.query.toLowerCase()))
          .toList();

      final filtered = _applyFilters(searchFiltered, currentState.filter);

      emit(currentState.copyWith(
        doctors: filtered,
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
      final filtered = _applyFilters(
        currentState.allDoctors,
        currentState.filter,
      );
      emit(currentState.copyWith(
        doctors: filtered,
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

  Future<void> _onApplyFilters(
    ApplyFiltersEvent event,
    Emitter<DoctorState> emit,
  ) async {
    if (state is DoctorLoaded) {
      final currentState = state as DoctorLoaded;
      emit(DoctorLoading());

      try {
        List<DoctorModel> baseList = currentState.allDoctors;
        if (currentState.searchQuery.isNotEmpty) {
          baseList = baseList
              .where((doctor) =>
                  doctor.name
                      .toLowerCase()
                      .contains(currentState.searchQuery.toLowerCase()) ||
                  doctor.specialist
                      .toLowerCase()
                      .contains(currentState.searchQuery.toLowerCase()) ||
                  doctor.place
                      .toLowerCase()
                      .contains(currentState.searchQuery.toLowerCase()))
              .toList();
          print('After search filter: ${baseList.length} doctors');
        }

        // Apply filters
        final filtered = await _applyFiltersAsync(baseList, event.filter);

        emit(currentState.copyWith(
          doctors: filtered,
          filter: event.filter,
        ));
      } catch (e) {
        print('Error applying filters: $e');
        // Revert to previous state on error
        emit(currentState);
      }
    }
  }

  void _onClearFilters(
    ClearFiltersEvent event,
    Emitter<DoctorState> emit,
  ) {
    if (state is DoctorLoaded) {
      final currentState = state as DoctorLoaded;

      print('=== CLEARING FILTERS ===');

      // Start with all doctors
      List<DoctorModel> baseList = currentState.allDoctors;

      // Apply search query if exists
      if (currentState.searchQuery.isNotEmpty) {
        baseList = baseList
            .where((doctor) =>
                doctor.name
                    .toLowerCase()
                    .contains(currentState.searchQuery.toLowerCase()) ||
                doctor.specialist
                    .toLowerCase()
                    .contains(currentState.searchQuery.toLowerCase()) ||
                doctor.place
                    .toLowerCase()
                    .contains(currentState.searchQuery.toLowerCase()))
            .toList();
      }

      print('After clearing filters: ${baseList.length} doctors');
      print('=======================');

      emit(currentState.copyWith(
        doctors: baseList,
        filter: const DoctorFilter(),
      ));
    }
  }

  void _onUpdateFilter(
    UpdateFilterEvent event,
    Emitter<DoctorState> emit,
  ) {
    if (state is DoctorLoaded) {
      final currentState = state as DoctorLoaded;
      emit(currentState.copyWith(filter: event.filter));
    }
  }

  /// Synchronous filter application for simple criteria
  List<DoctorModel> _applyFilters(
    List<DoctorModel> doctors,
    DoctorFilter filter,
  ) {
    var filtered = doctors;

    print('--- Applying sync filters ---');
    print('Starting with ${filtered.length} doctors');

    // Consultation Fee Filter
    if (filter.minFee != null || filter.maxFee != null) {
      filtered = filtered.where((doctor) {
        final fee = doctor.consultationFee;
        if (filter.minFee != null && fee < filter.minFee!) {
          return false;
        }
        if (filter.maxFee != null && fee > filter.maxFee!) {
          return false;
        }
        return true;
      }).toList();
      print('After fee filter: ${filtered.length} doctors');
    }

    // Rating Filter
    if (filter.minRating != null) {
      filtered = filtered
          .where((doctor) => doctor.averageRating >= filter.minRating!)
          .toList();
      print('After rating filter: ${filtered.length} doctors');
    }

    // Specialization Filter
    if (filter.specializations.isNotEmpty) {
      filtered = filtered
          .where((doctor) => filter.specializations.contains(doctor.specialist))
          .toList();
      print('After specialization filter: ${filtered.length} doctors');
    }

    // Experience Filter
    if (filter.experienceRanges.isNotEmpty) {
      filtered = filtered.where((doctor) {
        for (var range in filter.experienceRanges) {
          if (_matchesExperienceRange(doctor.experience, range)) {
            return true;
          }
        }
        return false;
      }).toList();
      print('After experience filter: ${filtered.length} doctors');
    }

    // Gender Filter
    if (filter.gender != null) {
      filtered = filtered
          .where((doctor) =>
              doctor.gender.toLowerCase() == filter.gender!.toLowerCase())
          .toList();
      print('After gender filter: ${filtered.length} doctors');
    }

    print('--- Sync filters complete ---');
    return filtered;
  }

  /// Async filter application for availability checks
  Future<List<DoctorModel>> _applyFiltersAsync(
    List<DoctorModel> doctors,
    DoctorFilter filter,
  ) async {
    print('--- Applying async filters ---');
    
    // First apply synchronous filters
    var filtered = _applyFilters(doctors, filter);

    // Availability filters require async checks
    if (filter.availableToday || filter.availableThisWeek) {
      final doctorIds = filtered.map((d) => d.id!).toList();

      if (doctorIds.isEmpty) {
        print('No doctors to check availability for');
        return filtered;
      }

      print('Checking availability for ${doctorIds.length} doctors');

      // Batch check availability for performance
      if (filter.availableToday) {
        print('Checking today availability...');
        final availability =
            await _availabilityService.checkTodayAvailabilityBatch(doctorIds);
        filtered = filtered
            .where((doctor) => availability[doctor.id!] == true)
            .toList();
        print('After today availability: ${filtered.length} doctors');
      } else if (filter.availableThisWeek) {
        print('Checking week availability...');
        final availability =
            await _availabilityService.checkWeekAvailabilityBatch(doctorIds);
        filtered = filtered
            .where((doctor) => availability[doctor.id!] == true)
            .toList();
        print('After week availability: ${filtered.length} doctors');
      }
    }

    print('--- Async filters complete ---');
    return filtered;
  }

  /// Helper to match experience ranges - UPDATED
  bool _matchesExperienceRange(int experience, String range) {
    print('Matching experience $experience against range $range');
    
    switch (range) {
      case '0-1 years':
        return experience >= 0 && experience <= 1;
      case '2-4 years':
        return experience >= 2 && experience <= 4;
      case '5-7 years':
        return experience >= 5 && experience <= 7;
      case '8+ years':
        return experience >= 8;
      default:
        print('Unknown experience range: $range');
        return false;
    }
  }
}
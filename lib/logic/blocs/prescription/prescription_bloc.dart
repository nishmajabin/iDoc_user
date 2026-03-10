import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/data/services/prescription_service.dart';
import 'prescription_event.dart';
import 'prescription_state.dart';

class UserPrescriptionBloc
    extends Bloc<UserPrescriptionEvent, UserPrescriptionState> {
  final UserPrescriptionService _service;

  UserPrescriptionBloc(this._service) : super(UserPrescriptionInitial()) {
    on<FetchUserPrescriptions>(_onFetch);
    on<RefreshUserPrescriptions>(_onRefresh);
  }

  Future<void> _onFetch(
    FetchUserPrescriptions event,
    Emitter<UserPrescriptionState> emit,
  ) async {
    emit(UserPrescriptionLoading());
    try {
      final records =
          await _service.fetchUserPrescriptions(event.userId);
      emit(UserPrescriptionLoaded(records));
    } catch (e) {
      emit(UserPrescriptionError('Failed to load prescriptions: $e'));
    }
  }

  Future<void> _onRefresh(
    RefreshUserPrescriptions event,
    Emitter<UserPrescriptionState> emit,
  ) async {
    // Silently refresh — keep current list visible, no full loading spinner
    try {
      final records =
          await _service.fetchUserPrescriptions(event.userId);
      emit(UserPrescriptionLoaded(records));
    } catch (e) {
      emit(UserPrescriptionError('Failed to refresh prescriptions: $e'));
    }
  }
}
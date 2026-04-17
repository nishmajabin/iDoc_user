import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/logic/blocs/appointment/appointment_bloc.dart';
import 'package:idoc_user/logic/blocs/appointment/appointment_event.dart';
import 'package:idoc_user/logic/blocs/appointment/appointment_state.dart';
import 'package:idoc_user/logic/cubits/appointment/patient_detail_state.dart';

class PatientDetailsCubit extends Cubit<PatientDetailsFormState> {
  final AppointmentBloc _appointmentBloc;

  PatientDetailsCubit({required AppointmentBloc appointmentBloc})
      : _appointmentBloc = appointmentBloc,
        super(
          PatientDetailsFormState(
            nameController: TextEditingController(),
            contactController: TextEditingController(),
            descriptionController: TextEditingController(),
            isNameLoading: true, 
          ),
        ) {

    _appointmentBloc.stream.listen(_onAppointmentBlocState);

    _onAppointmentBlocState(_appointmentBloc.state);
  }

  // ── Bloc state mirror ─────────────────────────────────────────────────────

  void _onAppointmentBlocState(dynamic blocState) {
    if (isClosed) return;

    if (blocState is PatientNameLoading) {
      emit(state.copyWith(isNameLoading: true, clearError: true));
    } else if (blocState is PatientNameFetched) {
      _applyFetchedName(blocState.patientName);
    }
  }

  void _applyFetchedName(String? name) {
    if (name != null && name.isNotEmpty) {
      state.nameController.text = name;
      emit(state.copyWith(isNameLoading: false, isNamePrefilled: true));
    } else {
      // Name unavailable — keep the editable text field empty.
      emit(state.copyWith(isNameLoading: false, isNamePrefilled: false));
    }
  }

  // ── Public API ────────────────────────────────────────────────────────────

  bool submitForm(GlobalKey<FormState> formKey) {
    // Clear any previous inline error first.
    emit(state.copyWith(clearError: true));

    if (!formKey.currentState!.validate()) return false;

    final name = state.isNamePrefilled
        ? state.nameController.text
        : state.nameController.text.trim();

    _appointmentBloc.add(
      SetPatientDetailsEvent(
        patientName: name,
        contactNumber: state.contactController.text.trim(),
        description: state.descriptionController.text.trim(),
      ),
    );
    return true;
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  Future<void> close() {
    state.nameController.dispose();
    state.contactController.dispose();
    state.descriptionController.dispose();
    return super.close();
  }
}
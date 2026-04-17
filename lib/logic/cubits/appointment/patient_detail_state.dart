import 'package:flutter/material.dart';

/// Represents every piece of UI state that [PatientDetailsCubit] manages.
///
/// Using a single immutable value class keeps rebuilds predictable — the
/// BlocBuilder only fires when a new *instance* is emitted, so partial
/// equality changes do not cause spurious redraws.
class PatientDetailsFormState {
  // ── Controllers ───────────────────────────────────────────────────────────
  // Controllers are kept here so they outlive widget rebuilds and are
  // properly disposed when the Cubit is closed.
  final TextEditingController nameController;
  final TextEditingController contactController;
  final TextEditingController descriptionController;

  // ── Name-fetch status ─────────────────────────────────────────────────────

  /// True while the Firestore fetch is in flight.
  final bool isNameLoading;

  /// True once Firestore returned a non-empty name and we pre-populated the
  /// name field. The name card (read-only) is shown instead of a text field.
  final bool isNamePrefilled;

  // ── Validation / submission ───────────────────────────────────────────────

  /// Non-null when form validation failed or an unexpected error occurred
  /// *before* handing off to [AppointmentBloc].
  final String? formError;

  const PatientDetailsFormState({
    required this.nameController,
    required this.contactController,
    required this.descriptionController,
    this.isNameLoading = false,
    this.isNamePrefilled = false,
    this.formError,
  });

  /// Convenience copy helper — only pass the fields that change.
  PatientDetailsFormState copyWith({
    bool? isNameLoading,
    bool? isNamePrefilled,
    String? formError,

    /// Pass `clearError: true` to explicitly set [formError] to null without
    /// relying on the `??` default in the constructor.
    bool clearError = false,
  }) {
    return PatientDetailsFormState(
      // Controllers are never replaced — they are always the same objects.
      nameController: nameController,
      contactController: contactController,
      descriptionController: descriptionController,
      isNameLoading: isNameLoading ?? this.isNameLoading,
      isNamePrefilled: isNamePrefilled ?? this.isNamePrefilled,
      formError: clearError ? null : (formError ?? this.formError),
    );
  }
}
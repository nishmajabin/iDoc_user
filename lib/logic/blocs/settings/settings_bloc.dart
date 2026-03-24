import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/data/models/settings_model.dart';
import 'package:idoc_user/data/repostories/settings_repository.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository _repository;
  String? _userId;

  SettingsBloc({SettingsRepository? repository})
      : _repository = repository ?? SettingsRepositoryImpl(),
        super(const SettingsInitial()) {
    on<LoadSettings>(_onLoad);
    on<ToggleNotifications>(_onTogglePush);
    on<ToggleEmailNotifications>(_onToggleEmail);
    on<ToggleAppointmentReminders>(_onToggleReminders);
    on<ToggleChatNotifications>(_onToggleChat);
  }

  UserSettingsModel? get _current =>
      state is SettingsLoaded ? (state as SettingsLoaded).settings : null;

  Future<void> _onLoad(LoadSettings e, Emitter<SettingsState> emit) async {
    _userId = e.userId;
    emit(const SettingsLoading());
    try {
      final s = await _repository.loadSettings(e.userId);
      emit(SettingsLoaded(settings: s));
    } catch (err) {
      debugPrint('[SettingsBloc] load: $err');
      emit(SettingsError(err.toString()));
    }
  }

  Future<void> _save(UserSettingsModel updated, Emitter<SettingsState> emit) async {
    emit(SettingsLoaded(settings: updated));
    if (_userId != null) await _repository.saveSettings(_userId!, updated);
  }

  Future<void> _onTogglePush(ToggleNotifications e, Emitter<SettingsState> emit) async {
    final c = _current;
    if (c == null) return;
    await _save(c.copyWith(pushNotificationsEnabled: e.enabled), emit);
  }

  Future<void> _onToggleEmail(ToggleEmailNotifications e, Emitter<SettingsState> emit) async {
    final c = _current;
    if (c == null) return;
    await _save(c.copyWith(emailNotificationsEnabled: e.enabled), emit);
  }

  Future<void> _onToggleReminders(ToggleAppointmentReminders e, Emitter<SettingsState> emit) async {
    final c = _current;
    if (c == null) return;
    await _save(c.copyWith(appointmentRemindersEnabled: e.enabled), emit);
  }

  Future<void> _onToggleChat(ToggleChatNotifications e, Emitter<SettingsState> emit) async {
    final c = _current;
    if (c == null) return;
    await _save(c.copyWith(chatNotificationsEnabled: e.enabled), emit);
  }

}
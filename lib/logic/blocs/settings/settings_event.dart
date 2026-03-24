import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {
  final String userId;
  const LoadSettings({required this.userId});
  @override
  List<Object?> get props => [userId];
}

class ToggleNotifications extends SettingsEvent {
  final bool enabled;
  const ToggleNotifications({required this.enabled});
  @override
  List<Object?> get props => [enabled];
}

class ToggleEmailNotifications extends SettingsEvent {
  final bool enabled;
  const ToggleEmailNotifications({required this.enabled});
  @override
  List<Object?> get props => [enabled];
}

class ToggleAppointmentReminders extends SettingsEvent {
  final bool enabled;
  const ToggleAppointmentReminders({required this.enabled});
  @override
  List<Object?> get props => [enabled];
}

class ToggleChatNotifications extends SettingsEvent {
  final bool enabled;
  const ToggleChatNotifications({required this.enabled});
  @override
  List<Object?> get props => [enabled];
}

// Logout is handled by LogoutBloc — not SettingsBloc.
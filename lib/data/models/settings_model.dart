class UserSettingsModel {
  final bool pushNotificationsEnabled;
  final bool emailNotificationsEnabled;
  final bool appointmentRemindersEnabled;
  final bool chatNotificationsEnabled;

  const UserSettingsModel({
    this.pushNotificationsEnabled = true,
    this.emailNotificationsEnabled = true,
    this.appointmentRemindersEnabled = true,
    this.chatNotificationsEnabled = true,
  });

  UserSettingsModel copyWith({
    bool? pushNotificationsEnabled,
    bool? emailNotificationsEnabled,
    bool? appointmentRemindersEnabled,
    bool? chatNotificationsEnabled,
  }) {
    return UserSettingsModel(
      pushNotificationsEnabled:
          pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      emailNotificationsEnabled:
          emailNotificationsEnabled ?? this.emailNotificationsEnabled,
      appointmentRemindersEnabled:
          appointmentRemindersEnabled ?? this.appointmentRemindersEnabled,
      chatNotificationsEnabled:
          chatNotificationsEnabled ?? this.chatNotificationsEnabled,
    );
  }

  Map<String, dynamic> toMap() => {
        'pushNotificationsEnabled': pushNotificationsEnabled,
        'emailNotificationsEnabled': emailNotificationsEnabled,
        'appointmentRemindersEnabled': appointmentRemindersEnabled,
        'chatNotificationsEnabled': chatNotificationsEnabled,
      };

  factory UserSettingsModel.fromMap(Map<String, dynamic> map) {
    return UserSettingsModel(
      pushNotificationsEnabled:
          map['pushNotificationsEnabled'] as bool? ?? true,
      emailNotificationsEnabled:
          map['emailNotificationsEnabled'] as bool? ?? true,
      appointmentRemindersEnabled:
          map['appointmentRemindersEnabled'] as bool? ?? true,
      chatNotificationsEnabled:
          map['chatNotificationsEnabled'] as bool? ?? true,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettingsModel &&
          pushNotificationsEnabled == other.pushNotificationsEnabled &&
          emailNotificationsEnabled == other.emailNotificationsEnabled &&
          appointmentRemindersEnabled == other.appointmentRemindersEnabled &&
          chatNotificationsEnabled == other.chatNotificationsEnabled;

  @override
  int get hashCode => Object.hash(
        pushNotificationsEnabled,
        emailNotificationsEnabled,
        appointmentRemindersEnabled,
        chatNotificationsEnabled,
      );
}
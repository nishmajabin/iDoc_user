import 'dart:typed_data';

enum ChatRole { user, assistant }

class MedicalChatMessage {
  final String id;
  final String? text;
  final ChatRole role;
  final DateTime timestamp;
  final bool isError;

  /// Raw image bytes (user messages only — for vision analysis).
  final Uint8List? imageBytes;

  const MedicalChatMessage({
    required this.id,
    this.text,
    required this.role,
    required this.timestamp,
    this.isError = false,
    this.imageBytes,
  });

  bool get isUser => role == ChatRole.user;
  bool get isAssistant => role == ChatRole.assistant;
  bool get hasImage => imageBytes != null && imageBytes!.isNotEmpty;
  bool get hasText => text != null && text!.isNotEmpty;

  MedicalChatMessage copyWith({
    String? id,
    String? text,
    ChatRole? role,
    DateTime? timestamp,
    bool? isError,
    Uint8List? imageBytes,
  }) {
    return MedicalChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      role: role ?? this.role,
      timestamp: timestamp ?? this.timestamp,
      isError: isError ?? this.isError,
      imageBytes: imageBytes ?? this.imageBytes,
    );
  }
}
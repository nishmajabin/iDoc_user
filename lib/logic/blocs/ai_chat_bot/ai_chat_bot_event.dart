import 'dart:typed_data';
import 'package:equatable/equatable.dart';

abstract class MedicalChatEvent extends Equatable {
  const MedicalChatEvent();

  @override
  List<Object?> get props => [];
}

/// Send a plain text message.
class SendMedicalTextEvent extends MedicalChatEvent {
  final String message;

  const SendMedicalTextEvent(this.message);

  @override
  List<Object?> get props => [message];
}

/// Send an image (with optional caption) for medical analysis.
class SendMedicalImageEvent extends MedicalChatEvent {
  final Uint8List imageBytes;
  final String? caption;

  const SendMedicalImageEvent({required this.imageBytes, this.caption});

  @override
  List<Object?> get props => [imageBytes, caption];
}

/// User selected an image — hold it as a pending attachment.
class ImageAttachedEvent extends MedicalChatEvent {
  final Uint8List imageBytes;

  const ImageAttachedEvent(this.imageBytes);

  @override
  List<Object?> get props => [imageBytes];
}

/// User removed the pending image preview.
class ImageRemovedEvent extends MedicalChatEvent {
  const ImageRemovedEvent();
}

/// Wipe the entire conversation.
class ClearMedicalChatEvent extends MedicalChatEvent {
  const ClearMedicalChatEvent();
}
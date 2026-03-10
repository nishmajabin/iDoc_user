import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/data/models/chat_message_model.dart';
import 'package:idoc_user/data/models/chat_room_model.dart';
import 'package:idoc_user/data/repostories/user_chat_repository.dart';

// ═════════════════════════════════════════════════════════════════════════════
// EVENTS
// ═════════════════════════════════════════════════════════════════════════════

abstract class UserChatEvent extends Equatable {
  const UserChatEvent();
  @override
  List<Object?> get props => [];
}

/// Fired when patient opens a chat from their appointment detail screen.
class InitializeUserChat extends UserChatEvent {
  final String doctorId;
  final String patientId;
  final String appointmentId;
  final String? doctorName;
  final String? patientName;
  final String? doctorProfileImageUrl;
  final String? patientProfileImageUrl;

  const InitializeUserChat({
    required this.doctorId,
    required this.patientId,
    required this.appointmentId,
    this.doctorName,
    this.patientName,
    this.doctorProfileImageUrl,
    this.patientProfileImageUrl,
  });

  @override
  List<Object?> get props => [doctorId, patientId, appointmentId];
}

class SendUserMessage extends UserChatEvent {
  final String messageText;
  const SendUserMessage(this.messageText);
  @override
  List<Object?> get props => [messageText];
}

class MarkUserMessagesRead extends UserChatEvent {
  const MarkUserMessagesRead();
}

class DisposeUserChat extends UserChatEvent {
  const DisposeUserChat();
}

// ═════════════════════════════════════════════════════════════════════════════
// STATES
// ═════════════════════════════════════════════════════════════════════════════

abstract class UserChatState extends Equatable {
  const UserChatState();
  @override
  List<Object?> get props => [];
}

class UserChatInitial extends UserChatState {
  const UserChatInitial();
}

class UserChatLoading extends UserChatState {
  const UserChatLoading();
}

/// Doctor hasn't tapped "Chat with Patient" yet — room document doesn't exist.
/// Show a friendly waiting state instead of an error.
class UserChatWaiting extends UserChatState {
  const UserChatWaiting();
}

class UserChatLoaded extends UserChatState {
  final ChatRoomModel chatRoom;
  final List<ChatMessageModel> messages;
  final String patientId;
  final bool isSending;

  const UserChatLoaded({
    required this.chatRoom,
    required this.messages,
    required this.patientId,
    this.isSending = false,
  });

  UserChatLoaded copyWith({
    ChatRoomModel? chatRoom,
    List<ChatMessageModel>? messages,
    String? patientId,
    bool? isSending,
  }) =>
      UserChatLoaded(
        chatRoom: chatRoom ?? this.chatRoom,
        messages: messages ?? this.messages,
        patientId: patientId ?? this.patientId,
        isSending: isSending ?? this.isSending,
      );

  @override
  List<Object?> get props => [chatRoom, messages, patientId, isSending];
}

class UserChatError extends UserChatState {
  final String message;
  const UserChatError(this.message);
  @override
  List<Object?> get props => [message];
}

// ═════════════════════════════════════════════════════════════════════════════
// BLOC
// ═════════════════════════════════════════════════════════════════════════════

class UserChatBloc extends Bloc<UserChatEvent, UserChatState> {
  final UserChatRepository _repository;

  String? _chatRoomId;
  String? _patientId;
  String? _doctorId;

  UserChatBloc({UserChatRepository? repository})
      : _repository = repository ?? UserChatRepository(),
        super(const UserChatInitial()) {
    on<InitializeUserChat>(_onInitialize);
    on<SendUserMessage>(_onSendMessage);
    on<MarkUserMessagesRead>(_onMarkRead);
    on<DisposeUserChat>(_onDispose);
  }

  // ── Initialize ─────────────────────────────────────────────────────────────

  Future<void> _onInitialize(
    InitializeUserChat event,
    Emitter<UserChatState> emit,
  ) async {
    emit(const UserChatLoading());

    _patientId = event.patientId;
    _doctorId = event.doctorId;
    _chatRoomId = _repository.generateChatRoomId(
      doctorId: event.doctorId,
      patientId: event.patientId,
      appointmentId: event.appointmentId,
    );

    try {
      // Step 1: Watch the chat ROOM document.
      // - If null → doctor hasn't created it yet → show UserChatWaiting
      // - If found → room exists → switch to watching MESSAGES stream
      //
      // We use two sequential emit.forEach calls:
      //   First  listens to the room doc (lightweight — 1 doc)
      //   Second listens to messages (once room is confirmed to exist)
      //
      // This avoids the "emit after handler completed" crash because
      // emit.forEach keeps the emitter alive for the stream's lifetime.

      await emit.forEach<ChatRoomModel?>(
        _repository.watchChatRoom(
          doctorId: event.doctorId,
          patientId: event.patientId,
          appointmentId: event.appointmentId,
        ),
        onData: (chatRoom) {
          if (chatRoom == null) {
            // Doctor hasn't opened chat yet — room doesn't exist in Firestore
            return const UserChatWaiting();
          }

          final current = state;
          if (current is UserChatLoaded) {
            // Room metadata updated (e.g. lastMessage) — preserve messages
            return current.copyWith(chatRoom: chatRoom);
          }

          // Room exists for the first time — emit with empty messages.
          // The message stream (started below) will populate them.
          return UserChatLoaded(
            chatRoom: chatRoom,
            messages: const [],
            patientId: event.patientId,
          );
        },
        onError: (_, __) {
          final current = state;
          if (current is UserChatLoaded) return current;
          return const UserChatError('Connection lost. Please retry.');
        },
      );
    } catch (e) {
      emit(UserChatError('Failed to initialize chat: ${e.toString()}'));
    }
  }

  // ── Send message ───────────────────────────────────────────────────────────

  Future<void> _onSendMessage(
    SendUserMessage event,
    Emitter<UserChatState> emit,
  ) async {
    final trimmed = event.messageText.trim();
    if (trimmed.isEmpty) return;

    final current = state;
    if (current is! UserChatLoaded || _chatRoomId == null) return;

    emit(current.copyWith(isSending: true));

    try {
      await _repository.sendMessage(
        chatRoomId: _chatRoomId!,
        senderId: _patientId!,
        receiverId: _doctorId!,
        messageText: trimmed,
      );

      // ✅ Do NOT emit anything here on success.
      //
      // The watchChatRoom stream (emit.forEach in _onInitialize) fires
      // onData with the new message the moment Firestore confirms the write.
      // That onData already resets isSending → false.
      //
      // Emitting currentState.copyWith(isSending: false) here would
      // overwrite the fresh stream state with the stale pre-send snapshot,
      // making the new message disappear — the same bug fixed in the doctor app.
    } catch (e) {
      // Read state freshly — stream may have updated it during the write
      final afterError = state;
      if (afterError is UserChatLoaded) {
        emit(afterError.copyWith(isSending: false));
      } else {
        emit(current.copyWith(isSending: false));
      }
    }
  }

  // ── Mark read ──────────────────────────────────────────────────────────────

  Future<void> _onMarkRead(
    MarkUserMessagesRead event,
    Emitter<UserChatState> emit,
  ) async {
    if (_chatRoomId == null || _patientId == null) return;
    await _repository.markMessagesAsRead(
      chatRoomId: _chatRoomId!,
      patientId: _patientId!,
    );
  }

  // ── Dispose ────────────────────────────────────────────────────────────────

  Future<void> _onDispose(
    DisposeUserChat event,
    Emitter<UserChatState> emit,
  ) async {
    _chatRoomId = null;
    _patientId = null;
    _doctorId = null;
    emit(const UserChatInitial());
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// PATIENT CHAT ROOM LIST BLOC (inbox)
// ═════════════════════════════════════════════════════════════════════════════

abstract class PatientChatListEvent extends Equatable {
  const PatientChatListEvent();
  @override
  List<Object?> get props => [];
}

class WatchPatientChatRooms extends PatientChatListEvent {
  final String patientId;
  const WatchPatientChatRooms(this.patientId);
  @override
  List<Object?> get props => [patientId];
}

abstract class PatientChatListState extends Equatable {
  const PatientChatListState();
  @override
  List<Object?> get props => [];
}

class PatientChatListInitial extends PatientChatListState {
  const PatientChatListInitial();
}

class PatientChatListLoading extends PatientChatListState {
  const PatientChatListLoading();
}

class PatientChatListLoaded extends PatientChatListState {
  final List<ChatRoomModel> rooms;
  const PatientChatListLoaded(this.rooms);
  @override
  List<Object?> get props => [rooms];
}

class PatientChatListError extends PatientChatListState {
  final String message;
  const PatientChatListError(this.message);
  @override
  List<Object?> get props => [message];
}

class PatientChatListBloc
    extends Bloc<PatientChatListEvent, PatientChatListState> {
  final UserChatRepository _repository;

  PatientChatListBloc({UserChatRepository? repository})
      : _repository = repository ?? UserChatRepository(),
        super(const PatientChatListInitial()) {
    on<WatchPatientChatRooms>(_onWatch);
  }

  Future<void> _onWatch(
    WatchPatientChatRooms event,
    Emitter<PatientChatListState> emit,
  ) async {
    emit(const PatientChatListLoading());
    await emit.forEach<List<ChatRoomModel>>(
      _repository.watchPatientChatRooms(event.patientId),
      onData: (rooms) => PatientChatListLoaded(rooms),
      onError: (e, _) =>
          PatientChatListError('Stream error: ${e.toString()}'),
    );
  }
}
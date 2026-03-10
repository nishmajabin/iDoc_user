import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/data/repostories/notification_repository.dart';

import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _repository;

  NotificationBloc({NotificationRepository? repository})
      : _repository = repository ?? NotificationRepository(),
        super(const NotificationInitial()) {
    on<InitializeNotifications>(_onInitialize);
    on<StartListeningForNotifications>(_onStartListening);
    on<StopNotifications>(_onStop);
  }

  // ──────────────────────────────────────────────────────────────────────────
  //  EVENT HANDLERS
  // ──────────────────────────────────────────────────────────────────────────

  /// Handles full initialization:
  ///  1. FCM setup, permissions, token storage
  ///  2. Starts Firestore listeners for appointments + chats + calls
  Future<void> _onInitialize(
    InitializeNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());

    try {
      // Initialize FCM, local notifications, permissions, token.
      await _repository.initialize(event.userId);

      // Start Firestore listeners.
      _repository.listenForAppointments(event.userId);
      _repository.listenForChatMessages(event.userId);
      _repository.listenForIncomingCalls(event.userId);

      emit(NotificationReady(userId: event.userId));
      debugPrint('[NotificationBloc] Initialized for ${event.userId}');
    } catch (e) {
      debugPrint('[NotificationBloc] Initialization error: $e');
      emit(NotificationError('Failed to initialize notifications: $e'));
    }
  }

  /// Starts Firestore listeners without re-running FCM initialization.
  /// Useful if the bloc was already initialized but listeners were stopped.
  Future<void> _onStartListening(
    StartListeningForNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      _repository.listenForAppointments(event.userId);
      _repository.listenForChatMessages(event.userId);
      _repository.listenForIncomingCalls(event.userId);

      emit(NotificationReady(userId: event.userId));
      debugPrint('[NotificationBloc] Listeners started for ${event.userId}');
    } catch (e) {
      debugPrint('[NotificationBloc] Start listening error: $e');
      emit(NotificationError('Failed to start notification listeners: $e'));
    }
  }

  /// Stops all listeners, removes the FCM token, and resets state.
  Future<void> _onStop(
    StopNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await _repository.removeFcmToken(event.userId);
      await _repository.dispose();

      emit(const NotificationStopped());
      debugPrint('[NotificationBloc] Stopped for ${event.userId}');
    } catch (e) {
      debugPrint('[NotificationBloc] Stop error: $e');
      emit(NotificationError('Failed to stop notifications: $e'));
    }
  }

  @override
  Future<void> close() async {
    await _repository.dispose();
    return super.close();
  }
}

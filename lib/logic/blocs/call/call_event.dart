import 'package:equatable/equatable.dart';

/// Events for [UserCallBloc].
abstract class UserCallEvent extends Equatable {
  const UserCallEvent();
  @override
  List<Object?> get props => [];
}

// ── Incoming-call listener lifecycle ────────────────────────────────────────

/// Start listening to Firestore for incoming calls for [userId].
class StartListeningForCalls extends UserCallEvent {
  final String userId;
  const StartListeningForCalls(this.userId);
  @override
  List<Object?> get props => [userId];
}

/// Stop listening (e.g. user logged out).
class StopListeningForCalls extends UserCallEvent {
  const StopListeningForCalls();
}

// ── Incoming-call actions ───────────────────────────────────────────────────

/// An incoming call was detected in Firestore.
class IncomingCallReceived extends UserCallEvent {
  final String callId;
  final String channelName;
  final String doctorId;
  final String doctorName;
  final String? doctorProfileImageUrl;
  const IncomingCallReceived({
    required this.callId,
    required this.channelName,
    required this.doctorId,
    required this.doctorName,
    this.doctorProfileImageUrl,
  });
  @override
  List<Object?> get props =>
      [callId, channelName, doctorId, doctorName, doctorProfileImageUrl];
}

/// User tapped "Accept" on the incoming-call screen.
class CallAccepted extends UserCallEvent {
  const CallAccepted();
}

/// User tapped "Reject" on the incoming-call screen.
class CallRejected extends UserCallEvent {
  const CallRejected();
}

/// The incoming call was cancelled (doctor hung up before user answered).
class IncomingCallCancelled extends UserCallEvent {
  const IncomingCallCancelled();
}

// ── In-call lifecycle ───────────────────────────────────────────────────────

/// Remote user joined the Agora channel.
class RemoteUserJoined extends UserCallEvent {
  final int uid;
  const RemoteUserJoined(this.uid);
  @override
  List<Object?> get props => [uid];
}

/// Remote user left the Agora channel.
class RemoteUserLeft extends UserCallEvent {
  final int uid;
  const RemoteUserLeft(this.uid);
  @override
  List<Object?> get props => [uid];
}

/// User ends the call.
class CallEndRequested extends UserCallEvent {
  const CallEndRequested();
}

/// Toggle microphone mute.
class CallMuteToggled extends UserCallEvent {
  const CallMuteToggled();
}

/// Switch front/back camera.
class CallCameraSwitched extends UserCallEvent {
  const CallCameraSwitched();
}

/// Timer tick — fired every second while in call.
class CallTimerTicked extends UserCallEvent {
  final int seconds;
  const CallTimerTicked(this.seconds);
  @override
  List<Object?> get props => [seconds];
}

/// An Agora or Firestore error occurred.
class CallErrorOccurred extends UserCallEvent {
  final String message;
  const CallErrorOccurred(this.message);
  @override
  List<Object?> get props => [message];
}

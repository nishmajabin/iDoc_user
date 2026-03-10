import 'package:equatable/equatable.dart';

/// States for [UserCallBloc].
abstract class UserCallState extends Equatable {
  const UserCallState();
  @override
  List<Object?> get props => [];
}

/// Idle — no incoming or active call.
class UserCallIdle extends UserCallState {
  const UserCallIdle();
}

/// An incoming call is ringing. Show IncomingCallScreen overlay.
class UserCallRinging extends UserCallState {
  final String callId;
  final String channelName;
  final String doctorId;
  final String doctorName;
  final String? doctorProfileImageUrl;

  const UserCallRinging({
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

/// User accepted — connecting to Agora channel.
class UserCallConnecting extends UserCallState {
  final String callId;
  final String channelName;
  final String doctorName;

  const UserCallConnecting({
    required this.callId,
    required this.channelName,
    required this.doctorName,
  });

  @override
  List<Object?> get props => [callId, channelName, doctorName];
}

/// Waiting for the doctor's video to appear.
class UserCallWaitingForPeer extends UserCallState {
  final String callId;
  final String channelName;
  final String doctorName;
  final bool isMuted;
  final int elapsedSeconds;

  const UserCallWaitingForPeer({
    required this.callId,
    required this.channelName,
    required this.doctorName,
    this.isMuted = false,
    this.elapsedSeconds = 0,
  });

  UserCallWaitingForPeer copyWith({
    bool? isMuted,
    int? elapsedSeconds,
  }) =>
      UserCallWaitingForPeer(
        callId: callId,
        channelName: channelName,
        doctorName: doctorName,
        isMuted: isMuted ?? this.isMuted,
        elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      );

  @override
  List<Object?> get props =>
      [callId, channelName, doctorName, isMuted, elapsedSeconds];
}

/// Both parties are in the call.
class UserCallActive extends UserCallState {
  final String callId;
  final String channelName;
  final String doctorName;
  final int remoteUid;
  final bool isMuted;
  final int elapsedSeconds;

  const UserCallActive({
    required this.callId,
    required this.channelName,
    required this.doctorName,
    required this.remoteUid,
    this.isMuted = false,
    this.elapsedSeconds = 0,
  });

  UserCallActive copyWith({
    int? remoteUid,
    bool? isMuted,
    int? elapsedSeconds,
  }) =>
      UserCallActive(
        callId: callId,
        channelName: channelName,
        doctorName: doctorName,
        remoteUid: remoteUid ?? this.remoteUid,
        isMuted: isMuted ?? this.isMuted,
        elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      );

  @override
  List<Object?> get props =>
      [callId, channelName, doctorName, remoteUid, isMuted, elapsedSeconds];
}

/// Doctor left the call.
class UserCallPeerLeft extends UserCallState {
  final int elapsedSeconds;
  const UserCallPeerLeft({this.elapsedSeconds = 0});
  @override
  List<Object?> get props => [elapsedSeconds];
}

/// Call ended normally.
class UserCallEnded extends UserCallState {
  const UserCallEnded();
}

/// An error occurred.
class UserCallError extends UserCallState {
  final String message;
  const UserCallError(this.message);
  @override
  List<Object?> get props => [message];
}

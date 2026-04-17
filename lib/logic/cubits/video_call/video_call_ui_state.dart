import 'package:equatable/equatable.dart';

/// Describes what the [VideoCallCubit] wants the video-call UI to render.
///
/// These are *derived, UI-optimised* states — a thin translation layer over
/// [UserCallState] that carries only what the screen actually needs, so
/// [BlocBuilder] / [BlocConsumer] can use simple `buildWhen` guards without
/// digging into [UserCallBloc] internals.
sealed class VideoCallUiState extends Equatable {
  const VideoCallUiState();
}

/// Initial state before the engine is ready.
class VideoCallUiConnecting extends VideoCallUiState {
  final String doctorName;

  const VideoCallUiConnecting({required this.doctorName});

  @override
  List<Object?> get props => [doctorName];
}

/// Engine joined, waiting for the remote peer to appear.
class VideoCallUiWaiting extends VideoCallUiState {
  final String doctorName;
  final String channelName;
  final bool isMuted;
  final int elapsedSeconds;

  const VideoCallUiWaiting({
    required this.doctorName,
    required this.channelName,
    required this.isMuted,
    required this.elapsedSeconds,
  });

  VideoCallUiWaiting copyWith({bool? isMuted, int? elapsedSeconds}) =>
      VideoCallUiWaiting(
        doctorName: doctorName,
        channelName: channelName,
        isMuted: isMuted ?? this.isMuted,
        elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      );

  @override
  List<Object?> get props => [doctorName, channelName, isMuted, elapsedSeconds];
}

/// Both peers are connected — the main in-call state.
class VideoCallUiActive extends VideoCallUiState {
  final String doctorName;
  final String channelName;
  final int remoteUid;
  final bool isMuted;
  final int elapsedSeconds;

  const VideoCallUiActive({
    required this.doctorName,
    required this.channelName,
    required this.remoteUid,
    required this.isMuted,
    required this.elapsedSeconds,
  });

  VideoCallUiActive copyWith({bool? isMuted, int? elapsedSeconds}) =>
      VideoCallUiActive(
        doctorName: doctorName,
        channelName: channelName,
        remoteUid: remoteUid,
        isMuted: isMuted ?? this.isMuted,
        elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      );

  @override
  List<Object?> get props =>
      [doctorName, channelName, remoteUid, isMuted, elapsedSeconds];
}

/// The remote peer temporarily left but the call document is still open.
class VideoCallUiPeerLeft extends VideoCallUiState {
  final int elapsedSeconds;

  const VideoCallUiPeerLeft({required this.elapsedSeconds});

  @override
  List<Object?> get props => [elapsedSeconds];
}

/// Terminal state — call ended cleanly.  UI should pop the screen.
class VideoCallUiEnded extends VideoCallUiState {
  const VideoCallUiEnded();

  @override
  List<Object?> get props => [];
}

/// Terminal state — an error occurred.  UI should show the error and pop.
class VideoCallUiError extends VideoCallUiState {
  final String message;

  const VideoCallUiError({required this.message});

  @override
  List<Object?> get props => [message];
}
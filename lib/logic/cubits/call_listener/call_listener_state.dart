import 'package:equatable/equatable.dart';

/// Describes what the [CallListenerCubit] wants the UI layer to do.
///
/// Each state is a *command* that the [CallListenerWrapper] reacts to exactly
/// once via [BlocListener].  Using distinct sealed subclasses guarantees the
/// listener only fires on a real state change (Equatable diffing), so there
/// are no duplicate overlays or pushes.
abstract class CallListenerState extends Equatable {
  const CallListenerState();
}

/// Nothing is happening — no overlay, no call screen.
class CallListenerIdle extends CallListenerState {
  const CallListenerIdle();

  @override
  List<Object?> get props => [];
}

/// A call is incoming — the UI should show the incoming-call overlay.
class CallListenerShowIncomingCall extends CallListenerState {
  final String callId;
  final String doctorName;
  final String? doctorProfileImageUrl;

  const CallListenerShowIncomingCall({
    required this.callId,
    required this.doctorName,
    this.doctorProfileImageUrl,
  });

  @override
  List<Object?> get props => [callId, doctorName, doctorProfileImageUrl];
}

/// The user accepted — the UI should remove the overlay and push the video
/// call screen.
class CallListenerNavigateToVideoCall extends CallListenerState {
  const CallListenerNavigateToVideoCall();

  @override
  List<Object?> get props => [];
}

/// The call was rejected, cancelled, ended, or errored — the UI should remove
/// the overlay (if still visible) and return to an idle appearance.
class CallListenerDismissOverlay extends CallListenerState {
  const CallListenerDismissOverlay();

  @override
  List<Object?> get props => [];
}
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/logic/blocs/call/call_bloc.dart';
import 'package:idoc_user/logic/blocs/call/call_event.dart';
import 'package:idoc_user/logic/blocs/call/call_state.dart';
import 'package:idoc_user/logic/cubits/video_call/video_call_cubit.dart';
import 'package:idoc_user/logic/cubits/video_call/video_call_ui_state.dart';
import 'package:idoc_user/presentation/screens/call/screens/video_call/widgets/video_call_msg.dart';
import 'package:idoc_user/presentation/screens/call/screens/video_call/widgets/video_call_pip.dart';
import 'package:idoc_user/presentation/screens/call/screens/video_call/widgets/video_call_toolbar.dart';
import 'package:idoc_user/presentation/screens/call/screens/video_call/widgets/video_call_top_bar.dart';
import 'package:idoc_user/presentation/screens/call/screens/video_call/widgets/video_view_cache.dart';

class VideoCallBody extends StatelessWidget {
  final VideoViewCache cache;

  const VideoCallBody({required this.cache, super.key});

  // ── Helpers ───────────────────────────────────────────────────────────────

  static String _fmt(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  void _end(BuildContext ctx) =>
      ctx.read<UserCallBloc>().add(const CallEndRequested());
  void _mute(BuildContext ctx) =>
      ctx.read<UserCallBloc>().add(const CallMuteToggled());
  void _flip(BuildContext ctx) =>
      ctx.read<UserCallBloc>().add(const CallCameraSwitched());

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _end(context);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0D0D),
        body: MultiBlocListener(
          listeners: [
            // ① Bridge: forward UserCallBloc → VideoCallCubit.
            BlocListener<UserCallBloc, UserCallState>(
              listener: (ctx, callState) {
                ctx.read<VideoCallCubit>().onUserCallStateChanged(callState);
              },
            ),

            // ② React: pop the screen on terminal states.
            BlocListener<VideoCallCubit, VideoCallUiState>(
              listenWhen: (_, s) =>
                  s is VideoCallUiEnded || s is VideoCallUiError,
              listener: (ctx, _) {
                if (Navigator.of(ctx).canPop()) Navigator.of(ctx).pop();
              },
            ),
          ],
          child: BlocBuilder<VideoCallCubit, VideoCallUiState>(
            buildWhen: (prev, curr) {
              if (prev.runtimeType != curr.runtimeType) return true;
              if (curr is VideoCallUiActive) {
                cache.remoteView(
                  uid: curr.remoteUid,
                  channel: curr.channelName,
                );
                // Only force a rebuild when the remote uid changes.
                if (prev is VideoCallUiActive) {
                  return prev.remoteUid != curr.remoteUid;
                }
              }

              // Lazily build local view if engine wasn't ready at push time.
              cache.localView;

              return false;
            },
            builder: (ctx, state) {
              // Ensure remote view is always pre-built in builder too
              if (state is VideoCallUiActive && cache.repo.isReady) {
                cache.remoteView(
                  uid: state.remoteUid,
                  channel: state.channelName,
                );
              }

              final doctorName = switch (state) {
                VideoCallUiConnecting s => s.doctorName,
                VideoCallUiWaiting s => s.doctorName,
                VideoCallUiActive s => s.doctorName,
                _ => 'Doctor',
              };

              final isMuted = switch (state) {
                VideoCallUiWaiting s => s.isMuted,
                VideoCallUiActive s => s.isMuted,
                _ => false,
              };

              final toolbarEnabled = state is VideoCallUiActive ||
                  state is VideoCallUiWaiting ||
                  state is VideoCallUiPeerLeft;

              final showPip = cache.shouldShowPip() &&
                  state is! VideoCallUiConnecting &&
                  state is! VideoCallUiEnded &&
                  state is! VideoCallUiError;

              final remoteView = cache.remoteUid != null
                  ? cache.remoteView(
                      uid: cache.remoteUid!,
                      channel: cache.remoteChannel!,
                    )
                  : null;

              return Stack(
                fit: StackFit.expand,
                children: [
                  // 1 ── Background ─────────────────────────────────────
                  const Positioned.fill(
                    key: ValueKey('bg'),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                        ),
                      ),
                    ),
                  ),

                  // 2 ── Remote video (full-screen, stable key) ──────────
                  if (remoteView != null)
                    Positioned.fill(
                      key: ValueKey(
                          'rv_${cache.remoteUid}_${cache.remoteChannel}'),
                      child: remoteView,
                    ),

                  // 3 ── Local PiP ───────────────────────────────────────
                  if (showPip)
                    Positioned(
                      key: const ValueKey('pip'),
                      top: 100,
                      right: 16,
                      width: 110,
                      height: 160,
                      child: VideoCallPip(child: cache.localView!),
                    ),

                  // 4 ── Top bar ─────────────────────────────────────────
                  Positioned(
                    key: const ValueKey('top'),
                    top: 0,
                    left: 0,
                    right: 0,
                    child: VideoCallTopBar(
                      state: state,
                      doctorName: doctorName,
                      formatDuration: _fmt,
                    ),
                  ),

                  // 5 ── Toolbar ─────────────────────────────────────────
                  Positioned(
                    key: const ValueKey('bar'),
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: VideoCallToolbar(
                      isMuted: isMuted,
                      enabled: toolbarEnabled,
                      onMute: () => _mute(ctx),
                      onEnd: () => _end(ctx),
                      onFlip: () => _flip(ctx),
                    ),
                  ),

                  // 6 ── Overlay (connecting / waiting / error) ──────────
                  if (_overlay(state) case final overlay?)
                    Positioned.fill(
                      key: const ValueKey('ov'),
                      child: overlay,
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget? _overlay(VideoCallUiState state) => switch (state) {
        VideoCallUiConnecting() => const VideoCallMsg(
            icon: Icons.videocam_rounded,
            title: 'Connecting…',
            sub: 'Setting up secure video connection',
            spin: true,
          ),
        VideoCallUiWaiting() => const VideoCallMsg(
            icon: Icons.person_outline_rounded,
            title: 'Waiting for doctor',
            sub: 'The doctor will appear shortly',
            spin: true,
          ),
        VideoCallUiPeerLeft() => const VideoCallMsg(
            icon: Icons.call_end_rounded,
            title: 'Doctor left the call',
            sub: 'You can end the call or wait for reconnection',
          ),
        VideoCallUiError s =>  VideoCallMsg(
            icon: Icons.error_outline_rounded,
            title: 'Connection error',
            sub: s.message,
            iconColor: Colors.redAccent,
          ),
        _ => null,
      };
}
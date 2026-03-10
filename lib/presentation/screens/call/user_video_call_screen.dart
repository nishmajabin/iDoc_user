import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/data/repostories/user_call_repository.dart';
import 'package:idoc_user/logic/blocs/call/call_bloc.dart';
import 'package:idoc_user/logic/blocs/call/call_event.dart';
import 'package:idoc_user/logic/blocs/call/call_state.dart';

class UserVideoCallScreen extends StatefulWidget {
  const UserVideoCallScreen({super.key});

  @override
  State<UserVideoCallScreen> createState() => _UserVideoCallScreenState();
}

class _UserVideoCallScreenState extends State<UserVideoCallScreen> {
  late final UserCallRepository _repo;

  // These widgets are built ONCE and never recreated.
  // Recreating an AgoraVideoView destroys its native Surface, which causes
  // the camera / remote feed to go blank.
  Widget? _localView;
  Widget? _remoteView;
  int? _remoteUid;
  String? _channelName;

  @override
  void initState() {
    super.initState();
    _repo = context.read<UserCallBloc>().repository;

    // Build local view immediately — engine is already up by the time
    // UserCallConnecting → UserVideoCallScreen is pushed.
    if (_repo.isReady) {
      _localView = _repo.buildLocalView();
      debugPrint('🎥 [Screen] Local view built in initState');
    }
  }

  // Builds the remote view exactly ONCE per (uid, channel).
  void _ensureRemoteView(int uid, String channel) {
    if (_remoteView != null && _remoteUid == uid && _channelName == channel) {
      return;
    }
    _remoteUid = uid;
    _channelName = channel;
    _remoteView = _repo.buildRemoteView(channelName: channel, remoteUid: uid);
    debugPrint('🎥 [Screen] Remote view built for uid=$uid');
  }

  String _fmt(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  void _end() => context.read<UserCallBloc>().add(const CallEndRequested());
  void _mute() => context.read<UserCallBloc>().add(const CallMuteToggled());
  void _flip() => context.read<UserCallBloc>().add(const CallCameraSwitched());

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _end();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0D0D),
        body: BlocConsumer<UserCallBloc, UserCallState>(
          listenWhen: (_, c) => c is UserCallEnded || c is UserCallError,
          listener: (ctx, _) {
            if (Navigator.of(ctx).canPop()) Navigator.of(ctx).pop();
          },
          buildWhen: (prev, curr) {
            // Lazily build local view if engine wasn't ready in initState.
            if (_localView == null && _repo.isReady) {
              _localView = _repo.buildLocalView();
              debugPrint('🎥 [Screen] Local view built lazily');
            }

            if (curr is UserCallActive) {
              // Pre-build remote surface immediately so Agora has a native
              // window to render into before the first frame arrives.
              _ensureRemoteView(curr.remoteUid, curr.channelName);
            }

            if (prev.runtimeType != curr.runtimeType) return true;
            if (prev is UserCallActive && curr is UserCallActive) {
              return prev.isMuted != curr.isMuted ||
                  prev.remoteUid != curr.remoteUid;
            }
            if (prev is UserCallWaitingForPeer &&
                curr is UserCallWaitingForPeer) {
              return prev.isMuted != curr.isMuted;
            }
            return true;
          },
          builder: (ctx, state) {
            // Derive display values.
            final doctorName = switch (state) {
              UserCallActive s => s.doctorName,
              UserCallWaitingForPeer s => s.doctorName,
              UserCallConnecting s => s.doctorName,
              _ => 'Doctor',
            };
            final channelName = switch (state) {
              UserCallActive s => s.channelName,
              UserCallWaitingForPeer s => s.channelName,
              UserCallConnecting s => s.channelName,
              _ => '',
            };
            final isMuted = switch (state) {
              UserCallActive s => s.isMuted,
              UserCallWaitingForPeer s => s.isMuted,
              _ => false,
            };
            final toolbarOn = state is UserCallActive ||
                state is UserCallWaitingForPeer ||
                state is UserCallPeerLeft;

            // Also ensure remote view in builder (covers edge cases where
            // buildWhen returned false).
            if (state is UserCallActive && _repo.isReady) {
              _ensureRemoteView(state.remoteUid, channelName);
            }

            final showPip = _localView != null &&
                _repo.isReady &&
                state is! UserCallConnecting &&
                state is! UserCallIdle &&
                state is! UserCallEnded &&
                state is! UserCallError;

            final overlay = _overlay(state);

            return Stack(
              fit: StackFit.expand,
              children: [
                // 1 ── Background ────────────────────────────────────────
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

                // 2 ── Remote video (full-screen) ─────────────────────────
                // Kept in the tree with a STABLE key from the moment we have
                // a remoteUid. This gives Agora a live Surface to push frames
                // into immediately — eliminating the race condition that caused
                // blank remote video in the previous version.
                if (_remoteView != null)
                  Positioned.fill(
                    key: ValueKey('rv_${_remoteUid}_$_channelName'),
                    child: _remoteView!,
                  ),

                // 3 ── Local PIP ──────────────────────────────────────────
                if (showPip)
                  Positioned(
                    key: const ValueKey('pip'),
                    top: 100,
                    right: 16,
                    width: 110,
                    height: 160,
                    child: _Pip(child: _localView!),
                  ),

                // 4 ── Top bar ────────────────────────────────────────────
                Positioned(
                  key: const ValueKey('top'),
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _TopBar(
                    state: state,
                    doctorName: doctorName,
                    formatDuration: _fmt,
                  ),
                ),

                // 5 ── Toolbar ────────────────────────────────────────────
                Positioned(
                  key: const ValueKey('bar'),
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _Toolbar(
                    isMuted: isMuted,
                    enabled: toolbarOn,
                    onMute: _mute,
                    onEnd: _end,
                    onFlip: _flip,
                  ),
                ),

                // 6 ── Waiting / error overlay ────────────────────────────
                // Sits on top of the (initialising) remote video until
                // state becomes UserCallActive, at which point this returns
                // null and the remote video becomes visible.
                if (overlay != null)
                  Positioned.fill(
                    key: const ValueKey('ov'),
                    child: overlay,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget? _overlay(UserCallState state) => switch (state) {
        UserCallConnecting() => const _Msg(
            icon: Icons.videocam_rounded,
            title: 'Connecting…',
            sub: 'Setting up secure video connection',
            spin: true,
          ),
        UserCallWaitingForPeer() => const _Msg(
            icon: Icons.person_outline_rounded,
            title: 'Waiting for doctor',
            sub: 'The doctor will appear shortly',
            spin: true,
          ),
        UserCallPeerLeft() => const _Msg(
            icon: Icons.call_end_rounded,
            title: 'Doctor left the call',
            sub: 'You can end the call or wait for reconnection',
          ),
        UserCallError s => _Msg(
            icon: Icons.error_outline_rounded,
            title: 'Connection error',
            sub: s.message,
            iconColor: Colors.redAccent,
          ),
        _ => null,
      };
}

// ── PIP wrapper ───────────────────────────────────────────────────────────────

class _Pip extends StatelessWidget {
  final Widget child;
  const _Pip({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 4))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: child,
      ),
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final UserCallState state;
  final String doctorName;
  final String Function(int) formatDuration;

  const _TopBar({
    required this.state,
    required this.doctorName,
    required this.formatDuration,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black87, Colors.transparent],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    doctorName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  _StatusChip(state: state),
                ],
              ),
            ),
            if (state is UserCallActive ||
                state is UserCallWaitingForPeer ||
                state is UserCallPeerLeft)
              BlocBuilder<UserCallBloc, UserCallState>(
                buildWhen: (p, c) {
                  int ps = p is UserCallActive
                      ? p.elapsedSeconds
                      : p is UserCallWaitingForPeer
                          ? p.elapsedSeconds
                          : -1;
                  int cs = c is UserCallActive
                      ? c.elapsedSeconds
                      : c is UserCallWaitingForPeer
                          ? c.elapsedSeconds
                          : -1;
                  return ps != cs;
                },
                builder: (_, s) {
                  final secs = s is UserCallActive
                      ? s.elapsedSeconds
                      : s is UserCallWaitingForPeer
                          ? s.elapsedSeconds
                          : 0;
                  return _TimerBadge(formatDuration(secs));
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final UserCallState state;
  const _StatusChip({required this.state});

  @override
  Widget build(BuildContext context) {
    final (String label, Color color) = switch (state) {
      UserCallConnecting() => ('Connecting…', Colors.orange),
      UserCallWaitingForPeer() => ('Waiting for doctor…', Colors.yellowAccent),
      UserCallActive() => ('In call', Colors.greenAccent),
      UserCallPeerLeft() => ('Doctor left', Colors.redAccent),
      _ => ('', Colors.transparent),
    };
    if (label.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }
}

class _TimerBadge extends StatelessWidget {
  final String duration;
  const _TimerBadge(this.duration);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.circle, color: Colors.greenAccent, size: 8),
          const SizedBox(width: 6),
          Text(duration,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ── Toolbar ───────────────────────────────────────────────────────────────────

class _Toolbar extends StatelessWidget {
  final bool isMuted;
  final bool enabled;
  final VoidCallback onMute;
  final VoidCallback onEnd;
  final VoidCallback onFlip;
  const _Toolbar({
    required this.isMuted,
    required this.enabled,
    required this.onMute,
    required this.onEnd,
    required this.onFlip,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.only(bottom: 30, top: 20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black87, Colors.transparent],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _Btn(
              icon: isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
              label: isMuted ? 'Unmute' : 'Mute',
              bg: isMuted ? Colors.white : Colors.white24,
              fg: isMuted ? Colors.black : Colors.white,
              onTap: enabled ? onMute : null,
            ),
            _Btn(
              icon: Icons.call_end_rounded,
              label: 'End',
              bg: Colors.red,
              fg: Colors.white,
              size: 64,
              onTap: onEnd,
            ),
            _Btn(
              icon: Icons.flip_camera_ios_rounded,
              label: 'Flip',
              bg: Colors.white24,
              fg: Colors.white,
              onTap: enabled ? onFlip : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bg;
  final Color fg;
  final VoidCallback? onTap;
  final double size;
  const _Btn({
    required this.icon,
    required this.label,
    required this.bg,
    required this.fg,
    this.onTap,
    this.size = 52,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: onTap == null ? Colors.white12 : bg,
              shape: BoxShape.circle,
              boxShadow: onTap != null
                  ? [
                      BoxShadow(
                          color: bg.withValues(alpha: .4),
                          blurRadius: 12,
                          spreadRadius: 2)
                    ]
                  : null,
            ),
            child: Icon(icon, color: fg, size: size * 0.42),
          ),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: TextStyle(
                color: onTap == null ? Colors.white38 : Colors.white70,
                fontSize: 12)),
      ],
    );
  }
}

// ── Overlay message ───────────────────────────────────────────────────────────

class _Msg extends StatelessWidget {
  final IconData icon;
  final String title;
  final String sub;
  final bool spin;
  final Color iconColor;
  const _Msg({
    required this.icon,
    required this.title,
    required this.sub,
    this.spin = false,
    this.iconColor = Colors.white70,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        color: const Color(0xCC0D0D0D),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 64, color: iconColor),
              const SizedBox(height: 20),
              Text(title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(sub,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 14)),
              ),
              if (spin) ...[
                const SizedBox(height: 24),
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white38),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
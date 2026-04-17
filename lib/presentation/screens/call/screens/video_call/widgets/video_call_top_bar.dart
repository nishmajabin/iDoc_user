import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/logic/cubits/video_call/video_call_cubit.dart';
import 'package:idoc_user/logic/cubits/video_call/video_call_ui_state.dart';
import 'package:idoc_user/presentation/screens/call/screens/video_call/widgets/video_call_status_chip.dart';
import 'package:idoc_user/presentation/screens/call/screens/video_call/widgets/video_call_timer_badge.dart';

class VideoCallTopBar extends StatelessWidget {
  final VideoCallUiState state;
  final String doctorName;
  final String Function(int) formatDuration;

  const VideoCallTopBar({
    required this.state,
    required this.doctorName,
    required this.formatDuration,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    final showTimer = state is VideoCallUiActive ||
        state is VideoCallUiWaiting ||
        state is VideoCallUiPeerLeft;

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
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  VideoCallStatusChip(state: state),
                ],
              ),
            ),

            // Timer rebuilds on every tick but is scoped to this tiny widget.
            if (showTimer)
              BlocBuilder<VideoCallCubit, VideoCallUiState>(
                buildWhen: (prev, curr) {
                  // Only rebuild when elapsedSeconds changes.
                  final prevSecs = switch (prev) {
                    VideoCallUiActive s => s.elapsedSeconds,
                    VideoCallUiWaiting s => s.elapsedSeconds,
                    VideoCallUiPeerLeft s => s.elapsedSeconds,
                    _ => -1,
                  };
                  final currSecs = switch (curr) {
                    VideoCallUiActive s => s.elapsedSeconds,
                    VideoCallUiWaiting s => s.elapsedSeconds,
                    VideoCallUiPeerLeft s => s.elapsedSeconds,
                    _ => -1,
                  };
                  return prevSecs != currSecs;
                },
                builder: (_, s) {
                  final secs = switch (s) {
                    VideoCallUiActive s => s.elapsedSeconds,
                    VideoCallUiWaiting s => s.elapsedSeconds,
                    VideoCallUiPeerLeft s => s.elapsedSeconds,
                    _ => 0,
                  };
                  return VideoCallTimerBadge(formatDuration(secs));
                },
              ),
          ],
        ),
      ),
    );
  }
}
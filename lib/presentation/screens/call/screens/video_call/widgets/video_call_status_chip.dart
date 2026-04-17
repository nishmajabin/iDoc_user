import 'package:flutter/material.dart';
import 'package:idoc_user/logic/cubits/video_call/video_call_ui_state.dart';

class VideoCallStatusChip extends StatelessWidget {
  final VideoCallUiState state;

  const VideoCallStatusChip({required this.state, super.key});

  @override
  Widget build(BuildContext context) {
    final (String label, Color color) = switch (state) {
      VideoCallUiConnecting() => ('Connecting…', Colors.orange),
      VideoCallUiWaiting() => ('Waiting for doctor…', Colors.yellowAccent),
      VideoCallUiActive() => ('In call', Colors.greenAccent),
      VideoCallUiPeerLeft() => ('Doctor left', Colors.redAccent),
      _ => ('', Colors.transparent),
    };

    if (label.isEmpty) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }
}
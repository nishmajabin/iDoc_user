import 'package:flutter/material.dart';
import 'package:idoc_user/data/repostories/user_call_repository.dart';


class VideoViewCache {
  final UserCallRepository repo;

  Widget? _localView;
  Widget? _remoteView;
  int? _remoteUid;
  String? _remoteChannel;

  VideoViewCache({required this.repo});

  // ── Local view ────────────────────────────────────────────────────────────

  Widget? get localView {
    if (_localView == null && repo.isReady) {
      _localView = repo.buildLocalView();
      debugPrint('🎥 [VideoViewCache] Local view built');
    }
    return _localView;
  }

  // ── Remote view ───────────────────────────────────────────────────────────

  Widget? remoteView({required int uid, required String channel}) {
    if (_remoteView != null &&
        _remoteUid == uid &&
        _remoteChannel == channel) {
      return _remoteView;
    }
    if (!repo.isReady) return null;

    _remoteUid = uid;
    _remoteChannel = channel;
    _remoteView = repo.buildRemoteView(channelName: channel, remoteUid: uid);
    debugPrint('🎥 [VideoViewCache] Remote view built for uid=$uid');
    return _remoteView;
  }

  // ── Convenience getters used by the UI ───────────────────────────────────

  int? get remoteUid => _remoteUid;
  String? get remoteChannel => _remoteChannel;

  /// Whether the local PiP should be shown in the current [state] context.
  bool shouldShowPip() => _localView != null && repo.isReady;
}
import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

typedef OnRemoteUserJoined = void Function(int uid);
typedef OnRemoteUserLeft = void Function(int uid);
typedef OnError = void Function(String message);

/// Repository handling Agora RTC engine lifecycle and Firestore call signaling
/// for the **user (patient)** side.
class UserCallRepository {
  final FirebaseFirestore _firestore;

  UserCallRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  RtcEngine? _engine;
  RtcEngineEventHandler? _eventHandler;
  bool _isEngineCreated = false;
  bool _isJoined = false;

  // ── Firestore signaling ───────────────────────────────────────────────────

  Stream<QuerySnapshot<Map<String, dynamic>>> watchIncomingCalls({
    required String userId,
  }) {
    debugPrint(
        '👂 [UserCallRepository] Watching incoming calls for userId=$userId');
    return _firestore
        .collection('calls')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'ringing')
        .snapshots();
  }

  Stream<String?> watchCallStatus({required String callId}) {
    return _firestore
        .collection('calls')
        .doc(callId)
        .snapshots()
        .map((doc) =>
            doc.exists ? (doc.data() ?? {})['status'] as String? : null);
  }

  Future<void> acceptCall({required String callId}) async {
    debugPrint('✅ [UserCallRepository] Accepting call: $callId');
    await _firestore.collection('calls').doc(callId).update({
      'status': 'accepted',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> rejectCall({required String callId}) async {
    debugPrint('❌ [UserCallRepository] Rejecting call: $callId');
    await _firestore.collection('calls').doc(callId).update({
      'status': 'rejected',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> endCallDocument({required String callId}) async {
    debugPrint('🔚 [UserCallRepository] Ending call: $callId');
    await _firestore.collection('calls').doc(callId).update({
      'status': 'ended',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Agora engine ──────────────────────────────────────────────────────────

  static int uidFromString(String id) {
    var uid = id.hashCode & 0x7FFFFFFF;
    if (uid == 0) uid = 1;
    return uid;
  }

  Future<void> initAndJoin({
    required String appId,
    required String channelName,
    required String userId,
    required OnRemoteUserJoined onRemoteUserJoined,
    required OnRemoteUserLeft onRemoteUserLeft,
    required OnError onError,
  }) async {
    if (_isEngineCreated) {
      debugPrint('⚠️ [UserCallRepository] Engine already created, skipping');
      return;
    }

    // ── STEP 0: Request permissions FIRST ────────────────────────────────
    // localVideoStreamReasonFailure in the logs means the camera was denied
    // or not yet granted when Agora tried to open it. Always request
    // camera + microphone before touching the Agora engine.
    debugPrint('🔐 [UserCallRepository] Requesting camera/mic permissions');
    final cameraStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();

    debugPrint(
        '🔐 [UserCallRepository] Camera: ${cameraStatus.name}  Mic: ${micStatus.name}');

    if (!cameraStatus.isGranted) {
      const msg = 'Camera permission denied';
      debugPrint('❌ [UserCallRepository] $msg');
      onError(msg);
      return;
    }
    if (!micStatus.isGranted) {
      const msg = 'Microphone permission denied';
      debugPrint('❌ [UserCallRepository] $msg');
      onError(msg);
      return;
    }

    try {
      // ── STEP 1: Create engine ─────────────────────────────────────────
      debugPrint('🎬 [UserCallRepository] Creating RTC engine');
      _engine = createAgoraRtcEngine();
      _isEngineCreated = true;

      // ── STEP 2: Initialize ────────────────────────────────────────────
      debugPrint('🔧 [UserCallRepository] Initializing engine with appId');
      await _engine!.initialize(RtcEngineContext(appId: appId));

      // ── STEP 3: Channel profile (must be set before enableVideo) ──────
      debugPrint('🔊 [UserCallRepository] Setting channel profile');
      await _engine!.setChannelProfile(
        ChannelProfileType.channelProfileCommunication,
      );

      // ── STEP 4: Enable video module ───────────────────────────────────
      debugPrint('📹 [UserCallRepository] Enabling video module');
      await _engine!.enableVideo();

      // ── STEP 5: Explicitly enable the local video track ───────────────
      // Without this, the camera capture pipeline is not started and
      // localVideoStreamReasonFailure is thrown on some devices.
      debugPrint('🎥 [UserCallRepository] Enabling local video track');
      await _engine!.enableLocalVideo(true);

      // ── STEP 6: Enable audio module ───────────────────────────────────
      debugPrint('🔊 [UserCallRepository] Enabling audio module');
      await _engine!.enableAudio();
      await _engine!.enableLocalAudio(true);

      // ── STEP 7: Register event handlers ──────────────────────────────
      debugPrint('📡 [UserCallRepository] Registering event handlers');
      _eventHandler = RtcEngineEventHandler(
        onError: (ErrorCodeType err, String msg) {
          debugPrint('❌ [Agora] Error ${err.name}: $msg');
          onError('Agora error ${err.name}: $msg');
        },
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint(
              '✅ [Agora] Joined channel: ${connection.channelId} uid=${connection.localUid} after ${elapsed}ms');
        },
        onUserJoined:
            (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint('👤 [Agora] Remote user joined: $remoteUid');
          onRemoteUserJoined(remoteUid);
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          debugPrint(
              '👋 [Agora] Remote user left: $remoteUid (${reason.name})');
          onRemoteUserLeft(remoteUid);
        },
        onLocalVideoStateChanged: (VideoSourceType source,
            LocalVideoStreamState state,
            LocalVideoStreamReason reason) {
          debugPrint(
              '📹 [Agora] Local video → ${state.name} / ${reason.name}');
        },
        onRemoteVideoStateChanged: (RtcConnection connection,
            int remoteUid,
            RemoteVideoState state,
            RemoteVideoStateReason reason,
            int elapsed) {
          debugPrint(
              '📺 [Agora] Remote video uid=$remoteUid → ${state.name} / ${reason.name}');
        },
        onFirstRemoteVideoFrame: (RtcConnection connection,
            int remoteUid,
            int width,
            int height,
            int elapsed) {
          debugPrint(
              '🖼️ [Agora] First remote frame: uid=$remoteUid ${width}x$height');
        },
        onFirstLocalVideoFrame: (VideoSourceType source, int width,
            int height, int elapsed) {
          debugPrint(
              '🖼️ [Agora] First LOCAL frame: ${width}x$height source=${source.name}');
        },
      );
      _engine!.registerEventHandler(_eventHandler!);

      // ── STEP 8: Start camera preview ──────────────────────────────────
      // Must happen AFTER registerEventHandler so state callbacks fire.
      debugPrint('🎥 [UserCallRepository] Starting camera preview');
      await _engine!.startPreview();

      // ── STEP 9: Join channel ──────────────────────────────────────────
      if (!_isJoined) {
        _isJoined = true;
        final localUid = uidFromString(userId);
        debugPrint(
            '🚀 [UserCallRepository] Joining channel: $channelName uid=$localUid');
        await _engine!.joinChannel(
          token: '',
          channelId: channelName,
          uid: localUid,
          options: const ChannelMediaOptions(
            clientRoleType: ClientRoleType.clientRoleBroadcaster,
            channelProfile:
                ChannelProfileType.channelProfileCommunication,
            publishCameraTrack: true,
            publishMicrophoneTrack: true,
            autoSubscribeVideo: true,
            autoSubscribeAudio: true,
          ),
        );
        debugPrint('✅ [UserCallRepository] Join channel request sent');
      }
    } catch (e, stack) {
      debugPrint('❌ [UserCallRepository] Init failed: $e\n$stack');
      _isEngineCreated = false;
      _isJoined = false;
      rethrow;
    }
  }

  Future<void> leaveAndDispose() async {
    if (!_isEngineCreated) {
      debugPrint(
          '⚠️ [UserCallRepository] Engine not created, nothing to dispose');
      return;
    }

    debugPrint('🛑 [UserCallRepository] Starting cleanup');
    _isEngineCreated = false;
    _isJoined = false;

    try {
      if (_engine != null) {
        debugPrint('👋 [UserCallRepository] Leaving channel');
        await _engine!.leaveChannel();

        debugPrint('🎥 [UserCallRepository] Stopping preview');
        await _engine!.stopPreview();

        debugPrint('📡 [UserCallRepository] Unregistering handlers');
        if (_eventHandler != null) {
          _engine!.unregisterEventHandler(_eventHandler!);
          _eventHandler = null;
        }

        debugPrint('🗑️ [UserCallRepository] Releasing engine');
        await _engine!.release();
      }
    } catch (e) {
      debugPrint('⚠️ [UserCallRepository] Disposal error (non-fatal): $e');
    } finally {
      _engine = null;
      debugPrint('✅ [UserCallRepository] Cleanup complete');
    }
  }

  Future<void> muteLocalAudio({required bool mute}) async {
    if (_engine == null) return;
    await _engine!.muteLocalAudioStream(mute);
    debugPrint('🔇 [UserCallRepository] Audio ${mute ? "muted" : "unmuted"}');
  }

  Future<void> switchCamera() async {
    if (_engine == null) return;
    await _engine!.switchCamera();
    debugPrint('🔄 [UserCallRepository] Camera switched');
  }

  // ── Video view builders ───────────────────────────────────────────────────
  //
  // IMPORTANT — do NOT cache these widgets. The screen holds them as State
  // fields (built once, never recreated). The repository just constructs
  // a fresh AgoraVideoView each time it is called; stable identity is the
  // screen's responsibility via its State fields + ValueKeys.

  /// Builds the local (self) camera preview.
  ///
  /// setupMode = videoViewSetupReplace (value 0 in Agora's enum is ADD,
  /// value 1 is REPLACE — confirmed from the Agora Flutter SDK source).
  ///
  /// renderMode = renderModeHidden crops to fill (like WhatsApp PIP).
  Widget buildLocalView() {
    if (_engine == null) {
      debugPrint(
          '⚠️ [UserCallRepository] buildLocalView: engine is null');
      return const SizedBox.shrink();
    }
    debugPrint('🎥 [UserCallRepository] Building local view');
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: _engine!,
        canvas: const VideoCanvas(
          uid: 0, // 0 = local user
          setupMode: VideoViewSetupMode.videoViewSetupReplace,
          renderMode: RenderModeType.renderModeHidden,
        ),
      ),
    );
  }

  /// Builds the remote (doctor) video view.
  ///
  /// setupMode = videoViewSetupReplace ensures only ONE renderer is ever
  /// bound to the remote track — prevents blank remote video.
  Widget buildRemoteView({
    required String channelName,
    required int remoteUid,
  }) {
    if (_engine == null) {
      debugPrint(
          '⚠️ [UserCallRepository] buildRemoteView: engine is null');
      return const SizedBox.shrink();
    }
    debugPrint(
        '🎥 [UserCallRepository] Building remote view: uid=$remoteUid channel=$channelName');
    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: _engine!,
        canvas: VideoCanvas(
          uid: remoteUid,
          setupMode: VideoViewSetupMode.videoViewSetupReplace,
          renderMode: RenderModeType.renderModeHidden,
        ),
        connection: RtcConnection(channelId: channelName),
      ),
    );
  }

  bool get isReady => _engine != null && _isEngineCreated;
}
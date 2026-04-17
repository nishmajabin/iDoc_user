import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

typedef OnRemoteUserJoined = void Function(int uid);
typedef OnRemoteUserLeft = void Function(int uid);
typedef OnError = void Function(String message);

class UserCallRepository {
  final FirebaseFirestore _firestore;
  UserCallRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  RtcEngine? _engine;
  RtcEngineEventHandler? _eventHandler;
  bool _isEngineCreated = false;
  bool _isJoined = false;

  // ── Firestore signaling ───────────────────────────────────────────────────

  Stream<QuerySnapshot<Map<String, dynamic>>> watchIncomingCalls({required String userId}) =>
      _firestore.collection('calls')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'ringing')
          .snapshots();

  Stream<String?> watchCallStatus({required String callId}) =>
      _firestore.collection('calls').doc(callId).snapshots()
          .map((doc) => doc.exists ? (doc.data() ?? {})['status'] as String? : null);

  Future<void> _updateCallStatus(String callId, String status) =>
      _firestore.collection('calls').doc(callId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

  Future<void> acceptCall({required String callId}) => _updateCallStatus(callId, 'accepted');
  Future<void> rejectCall({required String callId}) => _updateCallStatus(callId, 'rejected');
  Future<void> endCallDocument({required String callId}) => _updateCallStatus(callId, 'ended');

  // ── Agora engine ──────────────────────────────────────────────────────────

  static int uidFromString(String id) {
    final uid = id.hashCode & 0x7FFFFFFF;
    return uid == 0 ? 1 : uid;
  }

  Future<void> initAndJoin({
    required String appId,
    required String channelName,
    required String userId,
    required OnRemoteUserJoined onRemoteUserJoined,
    required OnRemoteUserLeft onRemoteUserLeft,
    required OnError onError,
  }) async {
    if (_isEngineCreated) return;

    final cameraStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();

    if (!cameraStatus.isGranted) { onError('Camera permission denied'); return; }
    if (!micStatus.isGranted) { onError('Microphone permission denied'); return; }

    try {
      _engine = createAgoraRtcEngine();
      _isEngineCreated = true;

      await _engine!.initialize(RtcEngineContext(appId: appId));
      await _engine!.setChannelProfile(ChannelProfileType.channelProfileCommunication);
      await _engine!.enableVideo();
      await _engine!.enableLocalVideo(true);
      await _engine!.enableAudio();
      await _engine!.enableLocalAudio(true);

      _eventHandler = RtcEngineEventHandler(
        onError: (ErrorCodeType err, String msg) => onError('Agora error ${err.name}: $msg'),
        onUserJoined: (_, int remoteUid, __) => onRemoteUserJoined(remoteUid),
        onUserOffline: (_, int remoteUid, ___) => onRemoteUserLeft(remoteUid),
      );
      _engine!.registerEventHandler(_eventHandler!);

      await _engine!.startPreview();

      if (!_isJoined) {
        _isJoined = true;
        await _engine!.joinChannel(
          token: '',
          channelId: channelName,
          uid: uidFromString(userId),
          options: const ChannelMediaOptions(
            clientRoleType: ClientRoleType.clientRoleBroadcaster,
            channelProfile: ChannelProfileType.channelProfileCommunication,
            publishCameraTrack: true,
            publishMicrophoneTrack: true,
            autoSubscribeVideo: true,
            autoSubscribeAudio: true,
          ),
        );
      }
    } catch (e, stack) {
      _isEngineCreated = false;
      _isJoined = false;
      Error.throwWithStackTrace(e, stack);
    }
  }

  Future<void> leaveAndDispose() async {
    if (!_isEngineCreated) return;
    _isEngineCreated = false;
    _isJoined = false;

    try {
      await _engine?.leaveChannel();
      await _engine?.stopPreview();
      if (_eventHandler != null) {
        _engine?.unregisterEventHandler(_eventHandler!);
        _eventHandler = null;
      }
      await _engine?.release();
    } catch (_) {
    } finally {
      _engine = null;
    }
  }

  Future<void> muteLocalAudio({required bool mute}) =>
      _engine?.muteLocalAudioStream(mute) ?? Future.value();

  Future<void> switchCamera() =>
      _engine?.switchCamera() ?? Future.value();

  // ── Video view builders ───────────────────────────────────────────────────

  Widget buildLocalView() {
    if (_engine == null) return const SizedBox.shrink();
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: _engine!,
        canvas: const VideoCanvas(
          uid: 0,
          setupMode: VideoViewSetupMode.videoViewSetupReplace,
          renderMode: RenderModeType.renderModeHidden,
        ),
      ),
    );
  }

  Widget buildRemoteView({required String channelName, required int remoteUid}) {
    if (_engine == null) return const SizedBox.shrink();
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
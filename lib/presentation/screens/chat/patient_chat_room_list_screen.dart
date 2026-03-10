import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:idoc_user/data/models/chat_room_model.dart';
import 'package:idoc_user/data/repostories/user_chat_repository.dart';
import 'package:idoc_user/logic/blocs/chat/chat_bloc.dart';

import 'package:idoc_user/presentation/screens/chat/user_chat_screen.dart';
import 'package:intl/intl.dart';

class _C {
  static const primary = Color(0xFF0077B6);
  static const accent = Color(0xFF00B4D8);
  static const primaryLight = Color(0xFF90E0EF);
  static const bgBase = Color(0xFFF2F8FF);
  static const cardBg = Colors.white;
  static const textPrimary = Color(0xFF1A2332);
  static const textSecondary = Color(0xFF6B7A91);
  static const textMuted = Color(0xFFADB8C9);
}

class PatientChatRoomListScreen extends StatelessWidget {
  final String patientId;
  final String? patientName;
  final String? patientProfileImageUrl;

  const PatientChatRoomListScreen({
    super.key,
    required this.patientId,
    this.patientName,
    this.patientProfileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PatientChatListBloc(repository: UserChatRepository())
        ..add(WatchPatientChatRooms(patientId)),
      child: _PatientChatListView(
        patientId: patientId,
        patientName: patientName,
        patientProfileImageUrl: patientProfileImageUrl,
      ),
    );
  }
}

class _PatientChatListView extends StatelessWidget {
  final String patientId;
  final String? patientName;
  final String? patientProfileImageUrl;

  const _PatientChatListView({
    required this.patientId,
    this.patientName,
    this.patientProfileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: _C.bgBase,
        body: Column(
          children: [
            _ListAppBar(
              patientName: patientName,
              avatarUrl: patientProfileImageUrl,
            ),
            Expanded(
              child: BlocBuilder<PatientChatListBloc, PatientChatListState>(
                builder: (context, state) {
                  if (state is PatientChatListLoading ||
                      state is PatientChatListInitial) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: _C.primary,
                        strokeWidth: 2.5,
                      ),
                    );
                  }
                  if (state is PatientChatListError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: const Color(0xFFE05C5C)),
                      ),
                    );
                  }
                  if (state is PatientChatListLoaded) {
                    if (state.rooms.isEmpty) {
                      return const _EmptyInboxView();
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 20),
                      itemCount: state.rooms.length,
                      itemBuilder: (_, i) => _RoomTile(
                        room: state.rooms[i],
                        patientId: patientId,
                        patientName: patientName,
                        patientProfileImageUrl: patientProfileImageUrl,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App bar
// ─────────────────────────────────────────────────────────────────────────────

class _ListAppBar extends StatelessWidget {
  final String? patientName;
  final String? avatarUrl;

  const _ListAppBar({this.patientName, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.only(
          top: topPad + 12, bottom: 16, left: 20, right: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF005F8E), _C.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Messages',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Your doctor consultations',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withOpacity(0.3), width: 2),
            ),
            child: ClipOval(
              child: avatarUrl != null && avatarUrl!.isNotEmpty
                  ? Image.network(avatarUrl!, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _PatientInitial(
                            name: patientName))
                  : _PatientInitial(name: patientName),
            ),
          ),
        ],
      ),
    );
  }
}

class _PatientInitial extends StatelessWidget {
  final String? name;
  const _PatientInitial({this.name});
  @override
  Widget build(BuildContext context) {
    final i =
        (name != null && name!.isNotEmpty) ? name![0].toUpperCase() : 'P';
    return Container(
      color: Colors.white.withOpacity(0.2),
      child: Center(
        child: Text(i,
            style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Room tile
// ─────────────────────────────────────────────────────────────────────────────

class _RoomTile extends StatelessWidget {
  final ChatRoomModel room;
  final String patientId;
  final String? patientName;
  final String? patientProfileImageUrl;

  const _RoomTile({
    required this.room,
    required this.patientId,
    this.patientName,
    this.patientProfileImageUrl,
  });

  String _formatTime(DateTime? t) {
    if (t == null) return '';
    final now = DateTime.now();
    final diff = now.difference(t);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return DateFormat('hh:mm a').format(t);
    if (diff.inDays == 1) return 'Yesterday';
    return DateFormat('MMM d').format(t);
  }

  @override
  Widget build(BuildContext context) {
    final unread = room.unreadCountPatient;
    final hasUnread = unread > 0;
    final doctorName = room.doctorName ?? 'Doctor';
    final avatarUrl = room.doctorProfileImageUrl;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            UserChatScreen.route(
              doctorId: room.doctorId,
              patientId: room.patientId,
              appointmentId: room.appointmentId,
              doctorName: room.doctorName,
              patientName: room.patientName,
              doctorProfileImageUrl: room.doctorProfileImageUrl,
              patientProfileImageUrl: room.patientProfileImageUrl,
            ),
          ),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _C.cardBg,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                )
              ],
              border: hasUnread
                  ? Border.all(
                      color: _C.primary.withOpacity(0.2), width: 1)
                  : null,
            ),
            child: Row(
              children: [
                // Doctor avatar + unread badge
                Stack(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                            colors: [_C.primaryLight, _C.accent]),
                      ),
                      child: ClipOval(
                        child: avatarUrl != null && avatarUrl.isNotEmpty
                            ? Image.network(avatarUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _DoctorTileAvatar(name: doctorName))
                            : _DoctorTileAvatar(name: doctorName),
                      ),
                    ),
                    if (hasUnread)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle, color: _C.primary),
                          child: Center(
                            child: Text(
                              unread > 9 ? '9+' : '$unread',
                              style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Dr. $doctorName',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: hasUnread
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: _C.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatTime(room.lastMessageTime),
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: hasUnread
                                  ? _C.primary
                                  : _C.textMuted,
                              fontWeight: hasUnread
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (room.lastMessageSenderId == patientId)
                            Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Icon(Icons.done_all,
                                  size: 14,
                                  color: hasUnread
                                      ? _C.primary
                                      : _C.textMuted),
                            ),
                          Expanded(
                            child: Text(
                              room.lastMessage ?? 'Tap to start chatting',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: hasUnread
                                    ? _C.textPrimary
                                    : _C.textMuted,
                                fontWeight: hasUnread
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded,
                    color: _C.textMuted, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DoctorTileAvatar extends StatelessWidget {
  final String name;
  const _DoctorTileAvatar({required this.name});
  @override
  Widget build(BuildContext context) => Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : 'D',
          style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty inbox
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyInboxView extends StatelessWidget {
  const _EmptyInboxView();

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _C.primary.withOpacity(0.08),
                ),
                child: const Icon(
                  Icons.inbox_rounded,
                  size: 44,
                  color: _C.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No Messages Yet',
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _C.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Your doctor will send you a message\nafter your appointment.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    fontSize: 14, color: _C.textSecondary, height: 1.5),
              ),
            ],
          ),
        ),
      );
}
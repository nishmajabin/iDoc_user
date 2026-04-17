import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/data/models/chat_room_model.dart';
import 'package:idoc_user/presentation/screens/chat/chat_room_list/widgets/chat_room_doctor_tile_avatar.dart';
import 'package:idoc_user/presentation/screens/chat/user_chat/screen/user_chat_screen.dart';
import 'package:intl/intl.dart';

class ChatRoomTile extends StatelessWidget {
  final ChatRoomModel room;
  final String patientId;
  final String? patientName;
  final String? patientProfileImageUrl;

  const ChatRoomTile({
    required this.room,
    required this.patientId,
    this.patientName,
    this.patientProfileImageUrl,
    super.key
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
              color: AppColors.cardBg,
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
                      color: AppColors.primary.withOpacity(0.2), width: 1)
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
                            colors: [AppColors.primaryLight, AppColors.accent]),
                      ),
                      child: ClipOval(
                        child: avatarUrl != null && avatarUrl.isNotEmpty
                            ? Image.network(avatarUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    ChatRoomDoctorTileAvatar(name: doctorName))
                            : ChatRoomDoctorTileAvatar(name: doctorName),
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
                              shape: BoxShape.circle, color: AppColors.primary),
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
                                color: AppColors.textPrimary,
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
                                  ? AppColors.primary
                                  : AppColors.textMuted,
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
                                      ? AppColors.primary
                                      : AppColors.textMuted),
                            ),
                          Expanded(
                            child: Text(
                              room.lastMessage ?? 'Tap to start chatting',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: hasUnread
                                    ? AppColors.textPrimary
                                    : AppColors.textMuted,
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
                    color: AppColors.textMuted, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

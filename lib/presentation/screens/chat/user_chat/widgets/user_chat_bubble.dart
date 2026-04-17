import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:idoc_user/core/theme/color.dart';
import 'package:idoc_user/data/models/chat_message_model.dart';
import 'package:intl/intl.dart';

class UserChatBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isFromPatient;

  const UserChatBubble({
    required this.message,
    required this.isFromPatient,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          isFromPatient ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 3,
          bottom: 3,
          left: isFromPatient ? 60 : 0,
          right: isFromPatient ? 0 : 60,
        ),
        child: Column(
          crossAxisAlignment: isFromPatient
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: isFromPatient
                    ?  LinearGradient(
                        colors: [AppColors.sentBubble1, AppColors.sentBubble2],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isFromPatient ? null : AppColors.receivedBubble,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isFromPatient ? 18 : 4),
                  bottomRight: Radius.circular(isFromPatient ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.messageText,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: isFromPatient ? Colors.white : AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('hh:mm a').format(message.timestamp),
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                ),
                if (isFromPatient) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead
                        ? Icons.done_all_rounded
                        : Icons.done_rounded,
                    size: 13,
                    color: message.isRead ? AppColors.accent : AppColors.textMuted,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
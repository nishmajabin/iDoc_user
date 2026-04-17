import 'package:flutter/material.dart';
import 'package:idoc_user/data/models/chat_message_model.dart';
import 'package:idoc_user/presentation/screens/chat/user_chat/widgets/user_chat_bubble.dart';
import 'package:idoc_user/presentation/screens/chat/user_chat/widgets/user_chat_date_seperator.dart';
import 'package:intl/intl.dart';

class UserChatMessageList extends StatelessWidget {
  final List<ChatMessageModel> messages;
  final String patientId;
  final ScrollController scrollCtrl;

  const UserChatMessageList({
    required this.messages,
    required this.patientId,
    required this.scrollCtrl,
    super.key
  });

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _dayLabel(DateTime dt) {
    final now = DateTime.now();
    if (_isSameDay(dt, now)) return 'Today';
    final yesterday = now.subtract(const Duration(days: 1));
    if (_isSameDay(dt, yesterday)) return 'Yesterday';
    return DateFormat('MMMM d, y').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollCtrl,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: messages.length,
      itemBuilder: (_, i) {
        final msg = messages[i];
        final isFromPatient = msg.senderId == patientId;
        final showDate =
            i == 0 || !_isSameDay(messages[i - 1].timestamp, msg.timestamp);

        return Column(
          children: [
            if (showDate) UserChatDateSeperator(label: _dayLabel(msg.timestamp)),
            UserChatBubble(message: msg, isFromPatient: isFromPatient),
          ],
        );
      },
    );
  }
}
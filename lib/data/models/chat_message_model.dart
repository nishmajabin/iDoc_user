import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Must remain structurally identical to the doctor app's ChatMessageModel.
/// Field names are a contract — changing them breaks cross-app messaging.
class ChatMessageModel extends Equatable {
  final String messageId;
  final String senderId;
  final String receiverId;
  final String messageText;
  final DateTime timestamp;
  final bool isRead;

  const ChatMessageModel({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.messageText,
    required this.timestamp,
    this.isRead = false,
  });

  factory ChatMessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessageModel(
      messageId: doc.id,
      senderId: data['senderId'] as String? ?? '',
      receiverId: data['receiverId'] as String? ?? '',
      messageText: data['messageText'] as String? ?? '',
      timestamp: data['timestamp'] != null
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      isRead: data['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'senderId': senderId,
        'receiverId': receiverId,
        'messageText': messageText,
        'timestamp': Timestamp.fromDate(timestamp),
        'isRead': isRead,
      };

  ChatMessageModel copyWith({
    String? messageId,
    String? senderId,
    String? receiverId,
    String? messageText,
    DateTime? timestamp,
    bool? isRead,
  }) =>
      ChatMessageModel(
        messageId: messageId ?? this.messageId,
        senderId: senderId ?? this.senderId,
        receiverId: receiverId ?? this.receiverId,
        messageText: messageText ?? this.messageText,
        timestamp: timestamp ?? this.timestamp,
        isRead: isRead ?? this.isRead,
      );

  @override
  List<Object?> get props =>
      [messageId, senderId, receiverId, messageText, timestamp, isRead];
}
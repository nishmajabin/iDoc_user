import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:idoc_user/data/models/chat_message_model.dart';
import 'package:idoc_user/data/models/chat_room_model.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// UserChatRepository
///
/// Firestore contract (shared with doctor app — do NOT modify paths):
///   Collection : chatRooms
///   Document   : chatRooms/{chatRoomId}
///   Sub-coll   : chatRooms/{chatRoomId}/messages/{messageId}
///
/// chatRoomId formula: "{doctorId}_{patientId}_{appointmentId}"
/// This formula is LOCKED — it must match the doctor app exactly.
/// ─────────────────────────────────────────────────────────────────────────────
class UserChatRepository {
  final FirebaseFirestore _firestore;

  UserChatRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ── ID generation (must stay identical to doctor app) ──────────────────────

  String generateChatRoomId({
    required String doctorId,
    required String patientId,
    required String appointmentId,
  }) =>
      '${doctorId}_${patientId}_$appointmentId';

  // ── Chat room ───────────────────────────────────────────────────────────────

  /// Stream a single room document.
  /// Emits null when the doctor hasn't opened chat yet (room not created).
  /// Emits ChatRoomModel once the doctor creates the room from their app.
  Stream<ChatRoomModel?> watchChatRoom({
    required String doctorId,
    required String patientId,
    required String appointmentId,
  }) {
    final id = generateChatRoomId(
      doctorId: doctorId,
      patientId: patientId,
      appointmentId: appointmentId,
    );
    return _firestore
        .collection('chatRooms')
        .doc(id)
        .snapshots()
        .map((doc) => doc.exists ? ChatRoomModel.fromFirestore(doc) : null);
  }

  /// All chat rooms for the current patient — client-side sorted.
  /// Single-field where clause avoids composite index requirement.
  Stream<List<ChatRoomModel>> watchPatientChatRooms(String patientId) {
    return _firestore
        .collection('chatRooms')
        .where('patientId', isEqualTo: patientId)
        .snapshots()
        .map((snap) {
      final rooms =
          snap.docs.map((doc) => ChatRoomModel.fromFirestore(doc)).toList();
      // Sort descending by lastMessageTime — most recent conversation first
      rooms.sort((a, b) {
        if (a.lastMessageTime == null && b.lastMessageTime == null) return 0;
        if (a.lastMessageTime == null) return 1;
        if (b.lastMessageTime == null) return -1;
        return b.lastMessageTime!.compareTo(a.lastMessageTime!);
      });
      return rooms;
    });
  }

  // ── Messages ────────────────────────────────────────────────────────────────

  /// Real-time stream — ascending timestamp so newest is at bottom.
  Stream<List<ChatMessageModel>> watchMessages(String chatRoomId) {
    return _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => ChatMessageModel.fromFirestore(doc)).toList());
  }

  /// Send patient → doctor message via atomic batch write.
  /// Increments unreadCountDoctor (not patient) because patient is sending.
  Future<void> sendMessage({
    required String chatRoomId,
    required String senderId,   // patientId
    required String receiverId, // doctorId
    required String messageText,
  }) async {
    final batch = _firestore.batch();

    final messageRef = _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(); // auto-ID

    final now = DateTime.now();

    batch.set(messageRef, {
      'senderId': senderId,
      'receiverId': receiverId,
      'messageText': messageText.trim(),
      'timestamp': Timestamp.fromDate(now),
      'isRead': false,
    });

    // Update chat room metadata — patient sends → doctor's unread goes up
    batch.update(
      _firestore.collection('chatRooms').doc(chatRoomId),
      {
        'lastMessage': messageText.trim(),
        'lastMessageTime': Timestamp.fromDate(now),
        'lastMessageSenderId': senderId,
        'unreadCountDoctor': FieldValue.increment(1),
      },
    );

    await batch.commit();
  }

  /// Mark all messages sent by doctor (receiverId == patientId) as read.
  /// Resets the patient's unread counter on the room document.
  Future<void> markMessagesAsRead({
    required String chatRoomId,
    required String patientId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('chatRooms')
          .doc(chatRoomId)
          .collection('messages')
          .where('isRead', isEqualTo: false)
          .where('receiverId', isEqualTo: patientId)
          .get();

      if (snapshot.docs.isEmpty) return;

      // Batch in groups of 500 (Firestore limit)
      const batchSize = 500;
      for (int i = 0; i < snapshot.docs.length; i += batchSize) {
        final batch = _firestore.batch();
        final end = (i + batchSize < snapshot.docs.length)
            ? i + batchSize
            : snapshot.docs.length;
        for (int j = i; j < end; j++) {
          batch.update(snapshot.docs[j].reference, {'isRead': true});
        }
        await batch.commit();
      }

      // Reset patient's unread counter
      await _firestore.collection('chatRooms').doc(chatRoomId).update({
        'unreadCountPatient': 0,
      });
    } catch (_) {
      // Non-critical — fail silently
    }
  }
}
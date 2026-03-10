import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:idoc_user/data/models/notification_item_model.dart';

/// Firestore CRUD service for persisted notification records.
///
/// Notifications live under: `users/{userId}/notifications/{notifId}`
class NotificationStorageService {
  final FirebaseFirestore _firestore;

  NotificationStorageService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Reference to the user's notification sub-collection.
  CollectionReference<Map<String, dynamic>> _colRef(String userId) =>
      _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications');

  // ── CREATE ─────────────────────────────────────────────────────────────────

  Future<void> saveNotification(NotificationItemModel notification) async {
    try {
      await _colRef(notification.userId)
          .doc(notification.notificationId)
          .set(notification.toFirestore());
      debugPrint(
          '[NotifStorage] Saved: ${notification.notificationId}');
    } catch (e) {
      debugPrint('[NotifStorage] Error saving notification: $e');
    }
  }

  // ── READ ───────────────────────────────────────────────────────────────────

  /// Real-time stream of all notifications (newest first).
  /// Only returns notifications whose timestamp ≤ now, so future-scheduled
  /// reminders remain hidden until their actual trigger time.
  Stream<List<NotificationItemModel>> watchNotifications(String userId) {
    return _colRef(userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) {
      final now = DateTime.now();
      return snap.docs
          .map((doc) => NotificationItemModel.fromFirestore(doc))
          .where((n) => !n.timestamp.isAfter(now))
          .toList();
    });
  }

  /// One-shot fetch. Only returns notifications whose timestamp ≤ now.
  Future<List<NotificationItemModel>> fetchNotifications(
      String userId) async {
    final snap = await _colRef(userId)
        .orderBy('timestamp', descending: true)
        .get();
    final now = DateTime.now();
    return snap.docs
        .map((doc) => NotificationItemModel.fromFirestore(doc))
        .where((n) => !n.timestamp.isAfter(now))
        .toList();
  }

  /// Count of unread notifications (excluding future-scheduled ones).
  Stream<int> watchUnreadCount(String userId) {
    return _colRef(userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snap) {
      final now = DateTime.now();
      return snap.docs
          .map((doc) => NotificationItemModel.fromFirestore(doc))
          .where((n) => !n.timestamp.isAfter(now))
          .length;
    });
  }

  // ── UPDATE ─────────────────────────────────────────────────────────────────

  Future<void> markAsRead(String userId, String notificationId) async {
    try {
      await _colRef(userId).doc(notificationId).update({'isRead': true});
    } catch (e) {
      debugPrint('[NotifStorage] Error marking read: $e');
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      final snap =
          await _colRef(userId).where('isRead', isEqualTo: false).get();
      if (snap.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (final doc in snap.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
      debugPrint('[NotifStorage] Marked all as read');
    } catch (e) {
      debugPrint('[NotifStorage] Error marking all read: $e');
    }
  }

  // ── DELETE ─────────────────────────────────────────────────────────────────

  Future<void> deleteNotification(String userId, String notificationId) async {
    try {
      await _colRef(userId).doc(notificationId).delete();
    } catch (e) {
      debugPrint('[NotifStorage] Error deleting: $e');
    }
  }

  Future<void> clearAll(String userId) async {
    try {
      final snap = await _colRef(userId).get();
      if (snap.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      debugPrint('[NotifStorage] Cleared all notifications');
    } catch (e) {
      debugPrint('[NotifStorage] Error clearing all: $e');
    }
  }
}

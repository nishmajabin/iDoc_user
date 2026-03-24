import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:idoc_user/data/models/settings_model.dart';

abstract class SettingsRepository {
  Future<UserSettingsModel> loadSettings(String userId);
  Future<void> saveSettings(String userId, UserSettingsModel settings);
}

class SettingsRepositoryImpl implements SettingsRepository {
  final FirebaseFirestore _firestore;

  SettingsRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _doc(String userId) => _firestore
      .collection('users')
      .doc(userId)
      .collection('meta')
      .doc('settings');

  @override
  Future<UserSettingsModel> loadSettings(String userId) async {
    try {
      final snap = await _doc(userId).get();
      if (snap.exists && snap.data() != null) {
        return UserSettingsModel.fromMap(snap.data()!);
      }
      return const UserSettingsModel();
    } catch (e) {
      debugPrint('[SettingsRepo] load error: $e');
      return const UserSettingsModel();
    }
  }

  @override
  Future<void> saveSettings(String userId, UserSettingsModel settings) async {
    try {
      await _doc(userId).set(settings.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('[SettingsRepo] save error: $e');
    }
  }
}
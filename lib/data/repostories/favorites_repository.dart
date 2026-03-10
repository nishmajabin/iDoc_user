
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritesRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FavoritesRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  Future<void> toggleFavorite(String doctorId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final favoriteRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(doctorId);

    final doc = await favoriteRef.get();
    if (doc.exists) {
      await favoriteRef.delete();
    } else {
      await favoriteRef.set({
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Stream<List<String>> getFavoriteIdsStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }
}

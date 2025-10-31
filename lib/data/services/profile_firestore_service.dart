
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileFirestoreService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  ProfileFirestoreService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getUserProfile() async {
    final user = _getCurrentUserOrThrow();
    final email = user.email ?? '';
    final username = email.split('@').first;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        // Create initial document
        final initialData = {
          'name': user.displayName ?? username,
          'email': email,
          'mobileNumber': null,
          'address': '',
          'profileImageUrl': user.photoURL,
          'createdAt': FieldValue.serverTimestamp(),
        };
        
        await _firestore.collection('users').doc(user.uid).set(initialData);
        return initialData;
      }
    } catch (e) {
      // Return basic user data if Firestore fails
      return {
        'name': user.displayName ?? username,
        'email': email,
        'mobileNumber': null,
        'address': '',
        'profileImageUrl': user.photoURL,
      };
    }
  }

  Future<void> updateUserProfile({
    required String name,
    String? mobileNumber,
    required String address,
  }) async {
    final user = _getCurrentUserOrThrow();

    // Update display name in Firebase Auth
    await user.updateDisplayName(name);

    // Update Firestore document
    await _firestore.collection('users').doc(user.uid).set({
      'name': name,
      'email': user.email,
      'mobileNumber': mobileNumber,
      'address': address,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updateProfileImage(String imageUrl) async {
    final user = _getCurrentUserOrThrow();

    // Update Firestore
    await _firestore.collection('users').doc(user.uid).set({
      'profileImageUrl': imageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Update Firebase Auth profile photo
    try {
      await user.updatePhotoURL(imageUrl);
    } catch (e) {
      Exception('Warning: Could not update Auth profile photo: $e');
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final user = _getCurrentUserOrThrow();
    return {
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
    };
  }

  User _getCurrentUserOrThrow() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No user logged in');
    }
    return user;
  }
}
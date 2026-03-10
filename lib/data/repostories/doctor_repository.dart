// lib/data/repositories/doctor_repository.dart
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:idoc_user/data/models/doctor_model.dart';

class DoctorRepository {
  final FirebaseFirestore _firestore;

  DoctorRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Load all approved doctors
  Future<List<DoctorModel>> loadApprovedDoctors() async {
    try {
      final snapshot = await _firestore
          .collection('doctors')
          .where('status', isEqualTo: 'approved')
          .get();

      return snapshot.docs
          .map((doc) => DoctorModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      log('Error loading doctors: $e');
      return [];
    }
  }

  /// Load doctors by category/specialist
  Future<List<DoctorModel>> loadDoctorsByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection('doctors')
          .where('status', isEqualTo: 'approved')
          .where('specialist', isEqualTo: category)
          .get();

      return snapshot.docs
          .map((doc) => DoctorModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      log('Error loading doctors by category: $e');
      return [];
    }
  }

  /// Search doctors by name
  Future<List<DoctorModel>> searchDoctorsByName(String query) async {
    try {
      final snapshot = await _firestore
          .collection('doctors')
          .where('status', isEqualTo: 'approved')
          .get();

      // Filter locally for case-insensitive search
      return snapshot.docs
          .map((doc) => DoctorModel.fromMap(doc.data(), doc.id))
          .where((doctor) =>
              doctor.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
     log('Error searching doctors: $e');
      return [];
    }
  }

  /// Get single doctor by ID
  Future<DoctorModel?> getDoctorById(String doctorId) async {
    try {
      final doc = await _firestore.collection('doctors').doc(doctorId).get();

      if (!doc.exists) return null;

      return DoctorModel.fromMap(doc.data()!, doctorId);
    } catch (e) {
      print('Error getting doctor: $e');
      return null;
    }
  }

  /// Stream approved doctors
  Stream<List<DoctorModel>> approvedDoctorsStream() {
    return _firestore
        .collection('doctors')
        .where('status', isEqualTo: 'approved')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DoctorModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}


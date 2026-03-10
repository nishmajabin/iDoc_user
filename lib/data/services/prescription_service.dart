import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:idoc_user/data/models/prescription_model.dart';

class UserPrescriptionService {
  final FirebaseFirestore _firestore;

  UserPrescriptionService(this._firestore);

  /// Fetches all prescriptions for a given user by scanning their appointments.
  /// For each appointment that has a prescription subcollection, it attaches
  /// the doctor info from the appointment document.
  Future<List<UserPrescriptionRecord>> fetchUserPrescriptions(
    String userId,
  ) async {
    // 1. Get all of the user's appointments
    final appointmentsSnapshot = await _firestore
        .collection('appointments')
        .where('userId', isEqualTo: userId)
        .get();

    final records = <UserPrescriptionRecord>[];

    // 2. For each appointment, check for prescriptions subcollection
    for (final appointmentDoc in appointmentsSnapshot.docs) {
      final appointmentData = appointmentDoc.data();
      final appointmentId = appointmentDoc.id;

      final doctorName = appointmentData['doctorName'] as String?;
      final doctorSpecialist = appointmentData['doctorSpecialist'] as String?;
      final doctorProfileImageUrl =
          appointmentData['doctorProfileImageUrl'] as String?;

      final prescriptionSnapshot = await _firestore
          .collection('appointments')
          .doc(appointmentId)
          .collection('prescription')
          .orderBy('timestamp', descending: true)
          .get();

      for (final prescDoc in prescriptionSnapshot.docs) {
        records.add(
          UserPrescriptionRecord.fromFirestore(
            docId: prescDoc.id,
            appointmentId: appointmentId,
            data: prescDoc.data(),
            doctorName: doctorName,
            doctorSpecialist: doctorSpecialist,
            doctorProfileImageUrl: doctorProfileImageUrl,
          ),
        );
      }
    }

    // 3. Sort all prescriptions newest first
    records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return records;
  }

  /// Fetch prescriptions for a single appointment (for detail view refresh).
  Future<List<UserPrescriptionRecord>> fetchPrescriptionsForAppointment(
    String appointmentId,
  ) async {
    final appointmentDoc =
        await _firestore.collection('appointments').doc(appointmentId).get();

    final appointmentData = appointmentDoc.data() ?? {};
    final doctorName = appointmentData['doctorName'] as String?;
    final doctorSpecialist = appointmentData['doctorSpecialist'] as String?;
    final doctorProfileImageUrl =
        appointmentData['doctorProfileImageUrl'] as String?;

    final snapshot = await _firestore
        .collection('appointments')
        .doc(appointmentId)
        .collection('prescription')
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs
        .map(
          (doc) => UserPrescriptionRecord.fromFirestore(
            docId: doc.id,
            appointmentId: appointmentId,
            data: doc.data(),
            doctorName: doctorName,
            doctorSpecialist: doctorSpecialist,
            doctorProfileImageUrl: doctorProfileImageUrl,
          ),
        )
        .toList();
  }
}
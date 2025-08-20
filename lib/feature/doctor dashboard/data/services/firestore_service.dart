// lib/features/doctor_dashboard/data/services/firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String doctorId = FirebaseAuth.instance.currentUser!.uid;

  Stream<DocumentSnapshot> getDoctorStream() {
    return _firestore.collection('users').doc(doctorId).snapshots();
  }

  Stream<QuerySnapshot> getRequestsStream(String status) {
    return _firestore
        .collection('requests')
        .where('doctorId', isEqualTo: doctorId)
        .where('status', isEqualTo: status)
        .snapshots();
  }

  Future<DocumentSnapshot> getPatientData(String patientId) {
    return _firestore.collection('users').doc(patientId).get();
  }

  Future<void> updateRequestStatus(
      DocumentReference requestRef, String status, String patientId) async {
    await requestRef.update({'status': status});
    await _firestore.collection('users').doc(patientId).update({
      'isBooked': status == 'accepted',
      'bookedDoctorId': status == 'accepted' ? doctorId : FieldValue.delete(),
    });
  }
}
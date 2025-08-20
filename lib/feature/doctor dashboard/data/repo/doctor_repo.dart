// lib/features/doctor_dashboard/data/repositories/doctor_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doctor.dart';
import '../services/firestore_service.dart';

class DoctorRepository {
  final FirestoreService _firestoreService;

  DoctorRepository(this._firestoreService);

  Stream<Doctor> getDoctor() {
    return _firestoreService.getDoctorStream().map((snapshot) {
      return Doctor.fromMap(snapshot.data() as Map<String, dynamic>, snapshot.id);
    });
  }

  Stream<List<QueryDocumentSnapshot>> getRequests(String status) {
    return _firestoreService.getRequestsStream(status).map((snapshot) {
      return snapshot.docs;
    });
  }

  Future<Map<String, dynamic>> getPatientData(String patientId) async {
    final snapshot = await _firestoreService.getPatientData(patientId);
    return snapshot.data() as Map<String, dynamic>;
  }

  Future<void> updateRequestStatus(
      DocumentReference requestRef, String status, String patientId) {
    return _firestoreService.updateRequestStatus(requestRef, status, patientId);
  }
}
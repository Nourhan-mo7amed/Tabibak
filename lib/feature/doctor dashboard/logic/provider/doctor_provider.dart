// lib/features/doctor_dashboard/logic/providers/doctor_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../data/models/doctor.dart';
import '../../data/repo/doctor_repo.dart';

class DoctorProvider with ChangeNotifier {
  final DoctorRepository _repository;
  int _selectedIndex = 0;

  DoctorProvider(this._repository);

  int get selectedIndex => _selectedIndex;

  set selectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  Stream<Doctor> getDoctor() => _repository.getDoctor();

  Stream<List<QueryDocumentSnapshot>> getRequests(String status) =>
      _repository.getRequests(status);

  Future<Map<String, dynamic>> getPatientData(String patientId) =>
      _repository.getPatientData(patientId);

  Future<void> updateRequestStatus(
      DocumentReference requestRef, String status, String patientId) {
    return _repository.updateRequestStatus(requestRef, status, patientId);
  }
}
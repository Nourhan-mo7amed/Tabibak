import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PatientProfileRepository {
  // جلب بيانات المريض من Firestore
  Future<DocumentSnapshot> getPatientProfile(String userId) async {
    return await FirebaseFirestore.instance.collection('users').doc(userId).get();
  }

  // حفظ التغييرات في Firestore
  Future<void> saveProfileChanges(String userId, Map<String, dynamic> updateData) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update(updateData);
  }

  // الحصول على معرف المستخدم الحالي
  String? getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  // تسجيل الخروج
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
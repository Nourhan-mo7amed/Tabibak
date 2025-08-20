import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DoctorProfileRepository {
  // جلب بيانات الطبيب من Firestore
  Stream<DocumentSnapshot> getDoctorProfileStream(String userId) {
    return FirebaseFirestore.instance.collection('users').doc(userId).snapshots();
  }

  // حفظ التغييرات في Firestore
  Future<void> saveProfileChanges(String docId, Map<String, dynamic> updateData) async {
    await FirebaseFirestore.instance.collection('users').doc(docId).update(updateData);
  }

  String? getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid;
  }
}
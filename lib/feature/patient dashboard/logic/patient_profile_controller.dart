import 'package:flutter/material.dart';
import '../../auth/ui/views/login_screen.dart';
import '../../doctor dashboard/data/models/field_config.dart';
import '../data/repo/patient_profile_repository.dart';

class PatientProfileController {
  final PatientProfileRepository repository;
  final Map<String, TextEditingController> controllers = {};
  String email = "";
  String? imageUrl;
  bool isLoading = true;
  bool isEditing = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // إعدادات الحقول القابلة للتعديل
  final List<FieldConfig> fields = [
    FieldConfig(key: 'name', label: 'Name', icon: Icons.person), // إضافة حقل الاسم
    FieldConfig(
        key: 'phone',
        label: 'Phone Number',
        icon: Icons.phone,
        keyboardType: TextInputType.phone),
    FieldConfig(
        key: 'age',
        label: 'Age',
        icon: Icons.cake,
        keyboardType: TextInputType.number),
    FieldConfig(key: 'address', label: 'Address', icon: Icons.home),
  ];

  PatientProfileController(this.repository) {
    // تهيئة Controllers لكل حقل
    for (var field in fields) {
      controllers[field.key] = TextEditingController();
    }
  }

  // تنظيف Controllers
  void dispose() {
    controllers.values.forEach((controller) => controller.dispose());
  }

  // جلب بيانات المستخدم
  Future<void> loadUserData(VoidCallback setState) async {
    final userId = repository.getCurrentUserId();
    if (userId != null) {
      final snapshot = await repository.getPatientProfile(userId);
      final data = snapshot.data() as Map<String, dynamic>?;
      if (data != null) {
        controllers['name']!.text = data['name'] ?? ''; // تحديث حقل الاسم
        email = data['email'] ?? '';
        imageUrl = data['imageUrl'];
        controllers['phone']!.text = data['phone'] ?? '';
        controllers['address']!.text = data['address'] ?? '';
        controllers['age']!.text = data['age']?.toString() ?? '';
        isLoading = false;
        setState();
      }
    }
  }

  // التحقق من صحة الإدخال
  String? validateInput(String? value, String label) {
    if (value == null || value.isEmpty) {
      return "Please enter $label";
    }
    if (label == 'Age' && int.tryParse(value) == null) {
      return "Age must be a valid number";
    }
    return null;
  }

  // حفظ التغييرات
  Future<void> saveChanges(BuildContext context, VoidCallback setState) async {
    if (formKey.currentState!.validate()) {
      final userId = repository.getCurrentUserId();
      if (userId != null) {
        isLoading = true;
        setState();
        try {
          final updateData = {
            'name': controllers['name']!.text.trim(), // إضافة الاسم
            'phone': controllers['phone']!.text.trim(),
            'address': controllers['address']!.text.trim(),
            'age': int.tryParse(controllers['age']!.text.trim()) ?? 0,
          };
          await repository.saveProfileChanges(userId, updateData);
          setState();
          isEditing = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Changes saved successfully")),
          );
        } catch (e) {
          String errorMessage;
          if (e.toString().contains('permission-denied')) {
            errorMessage = 'Permission denied. Check Firestore rules.';
          } else if (e.toString().contains('network')) {
            errorMessage = 'Network error. Please check your connection.';
          } else {
            errorMessage = 'Failed to save changes: $e';
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        } finally {
          isLoading = false;
          setState();
        }
      }
    }
  }

  // تسجيل الخروج
  Future<void> signOut(BuildContext context) async {
    await repository.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
}
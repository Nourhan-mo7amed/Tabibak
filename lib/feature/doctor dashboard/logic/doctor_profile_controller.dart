import 'package:flutter/material.dart';
import '../data/models/field_config.dart';
import '../data/repo/doctor_profile_repository.dart';

class DoctorProfileController {
  final DoctorProfileRepository repository;
  final Map<String, TextEditingController> controllers = {};
  Map<String, dynamic>? doctorData;
  bool isEditing = false;
  bool isLoading = false;

  // إعدادات الحقول
  final List<FieldConfig> fields = [
    FieldConfig(key: 'name', label: 'Name', icon: Icons.person),
    FieldConfig(key: 'specialty', label: 'Specialty', icon: Icons.local_hospital),
    FieldConfig(
        key: 'email',
        label: 'Email',
        icon: Icons.email,
        keyboardType: TextInputType.emailAddress),
    FieldConfig(
        key: 'phone',
        label: 'Phone Number',
        icon: Icons.phone,
        keyboardType: TextInputType.phone),
    FieldConfig(key: 'address', label: 'Address', icon: Icons.home),
    FieldConfig(
        key: 'experience',
        label: 'Experience (years)',
        icon: Icons.school,
        keyboardType: TextInputType.number),
    FieldConfig(
        key: 'fee',
        label: 'Fee',
        icon: Icons.money,
        keyboardType: TextInputType.number),
    FieldConfig(
        key: 'patients',
        label: 'Patients',
        icon: Icons.people,
        keyboardType: TextInputType.number),
    FieldConfig(key: 'time', label: 'Working Hours', icon: Icons.schedule),
    FieldConfig(
        key: 'availability',
        label: 'Availability',
        icon: Icons.event_available),
    FieldConfig(
        key: 'description',
        label: 'Description',
        icon: Icons.description,
        keyboardType: TextInputType.multiline),
  ];

  DoctorProfileController(this.repository) {
    for (var field in fields) {
      controllers[field.key] = TextEditingController();
    }
  }

  // تنظيف Controllers
  void dispose() {
    controllers.values.forEach((controller) => controller.dispose());
  }

  // ملء الحقول بالبيانات
  void populateControllers(Map<String, dynamic> data) {
    for (var field in fields) {
      controllers[field.key]!.text = data[field.key]?.toString() ?? '';
    }
    doctorData = data;
  }

  // التحقق من صحة الإدخال
  String? validateInput() {
    if (controllers['name']!.text.trim().isEmpty) {
      return 'Name cannot be empty';
    }
    if (controllers['specialty']!.text.trim().isEmpty) {
      return 'Specialty cannot be empty';
    }
    if (controllers['experience']!.text.trim().isNotEmpty &&
        int.tryParse(controllers['experience']!.text.trim()) == null) {
      return 'Experience must be a valid number';
    }
    if (controllers['fee']!.text.trim().isNotEmpty &&
        double.tryParse(controllers['fee']!.text.trim()) == null) {
      return 'Fee must be a valid number';
    }
    if (controllers['patients']!.text.trim().isNotEmpty &&
        int.tryParse(controllers['patients']!.text.trim()) == null) {
      return 'Patients must be a valid number';
    }
    return null;
  }

  // حفظ التغييرات
  Future<void> saveChanges(BuildContext context, VoidCallback setState) async {
    if (doctorData == null) return;

    final docId = doctorData!['id'];
    if (docId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doctor ID not found, cannot update')),
      );
      return;
    }

    final validationError = validateInput();
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationError)),
      );
      return;
    }

    isLoading = true;
    setState();

    try {
      print('Updating: ${fields.map((field) => '${field.key}=${controllers[field.key]!.text}').join(', ')}');
      final updateData = {
        for (var field in fields)
          field.key: field.key == 'experience' || field.key == 'patients'
              ? int.tryParse(controllers[field.key]!.text.trim()) ?? 0
              : field.key == 'fee'
                  ? double.tryParse(controllers[field.key]!.text.trim()) ?? 0
                  : controllers[field.key]!.text.trim(),
      };

      await repository.saveProfileChanges(docId, updateData);

      isEditing = false;
      setState();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Changes saved successfully')),
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
      setState();
      isLoading = false;
    }
  }
}
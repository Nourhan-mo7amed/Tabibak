import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../auth/ui/views/login_screen.dart';
import '../../../doctor dashboard/data/models/field_config.dart';
import '../../data/repo/patient_profile_repository.dart';
import '../../logic/patient_profile_controller.dart';

class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({super.key});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  late final PatientProfileController _controller;
  bool _isInitialized = false; // متغير لتتبع حالة التهيئة

  @override
  void initState() {
    super.initState();
    try {
      _controller = PatientProfileController(PatientProfileRepository());
      _controller.loadUserData(
        () => setState(() {
          _isInitialized = true; // تحديث حالة التهيئة بعد اكتمال loadUserData
        }),
      );
    } catch (e) {
      print('Error initializing controller: $e');
      setState(() {
        _isInitialized = true; // حتى لو حدث خطأ، نحدد التهيئة كمكتملة
      });
    }
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _controller.dispose();
    }
    super.dispose();
  }

  // بناء حقل قابل للتعديل
  Widget _buildEditableField(FieldConfig field) {
    return _controller.isEditing && field.editable
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: TextFormField(
              controller: _controller.controllers[field.key],
              keyboardType: field.keyboardType,
              validator: (value) =>
                  _controller.validateInput(value, field.label),
              decoration: InputDecoration(
                prefixIcon: Icon(field.icon, color: Colors.blueAccent),
                labelText: field.label,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          )
        : _buildInfoTile(
            field.icon,
            field.label,
            _controller.controllers[field.key]?.text ?? 'Not specified',
          );
  }

  // بناء حقل غير قابل للتعديل
  Widget _buildInfoTile(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$title: ${value.isEmpty ? "Not specified" : value}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xff285DD8),
        title: const Text(
          "Profile",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              _controller.isEditing ? Icons.close : Icons.edit,
              color: Colors.white,
            ),
            onPressed: () {
              if (_controller.isEditing) {
                _controller.loadUserData(() => setState(() {}));
              }
              setState(() {
                _controller.isEditing = !_controller.isEditing;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _controller.formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            _controller.imageUrl != null &&
                                _controller.imageUrl!.isNotEmpty
                            ? NetworkImage(_controller.imageUrl!)
                            : const AssetImage(
                                    'assets/images/default_avatar.png',
                                  )
                                  as ImageProvider,
                      ),
                      const SizedBox(height: 12),
                      _controller.isEditing
                          ? TextFormField(
                              controller: _controller.controllers['name'],
                              validator: (value) =>
                                  _controller.validateInput(value, 'Name'),
                              decoration: const InputDecoration(
                                labelText: 'Name',
                                border: OutlineInputBorder(),
                              ),
                            )
                          : Text(
                              _controller.controllers['name']?.text ??
                                  'Not specified',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                      const SizedBox(height: 8),
                      Text(
                        _controller.email.isNotEmpty
                            ? _controller.email
                            : 'Not specified',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildEditableField(
                  _controller.fields.firstWhere(
                    (field) => field.key == 'phone',
                    orElse: () => FieldConfig(
                      key: 'phone',
                      label: 'Phone Number',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildEditableField(
                  _controller.fields.firstWhere(
                    (field) => field.key == 'age',
                    orElse: () => FieldConfig(
                      key: 'age',
                      label: 'Age',
                      icon: Icons.cake,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildEditableField(
                  _controller.fields.firstWhere(
                    (field) => field.key == 'address',
                    orElse: () => FieldConfig(
                      key: 'address',
                      label: 'Address',
                      icon: Icons.home,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_controller.isEditing)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff285DD8),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () =>
                        _controller.saveChanges(context, () => setState(() {})),
                    child: const Text(
                      "Save Changes",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _controller.signOut(context),
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

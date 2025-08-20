import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import '../widgets/auth_button.dart';
import '../widgets/auth_container.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_switch_text.dart';
import '../widgets/auth_text_field.dart';
import 'login_screen.dart';

class ExtraInfoScreen extends StatefulWidget {
  final String name;
  final String email;
  final String password;
  final String role;

  const ExtraInfoScreen({
    super.key,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  @override
  State<ExtraInfoScreen> createState() => _ExtraInfoScreenState();
}

class _ExtraInfoScreenState extends State<ExtraInfoScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String? selectedSpecialty;
  File? _profileImage;
  bool isLoading = false;

  final List<String> specialties = [
    'الأنف والأذن والحنجرة',
    'الباطنة',
    'الجراحة العامة',
    'الجلدية',
    'النساء والتوليد',
    'العيون',
    'العظام',
    'القلب',
    'المخ والأعصاب',
    'الأسنان',
    'الأطفال',
    'الطب النفسي',
    'التغذية',
    'التحاليل الطبية',
    'الأورام',
    'التخدير',
    'الروماتيزم',
  ];

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImage != null) {
      setState(() => _profileImage = File(pickedImage.path));
    }
  }

  Future<String?> uploadImageToImgbb(File imageFile) async {
    final apiKey = '13bc3617dca04f77981a9c02ea8cbebb';
    final url = Uri.parse("https://api.imgbb.com/1/upload?key=$apiKey");

    try {
      final base64Image = base64Encode(await imageFile.readAsBytes());
      final response = await http.post(url, body: {"image": base64Image});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['url'];
      } else {
        return null;
      }
    } catch (_) {
      return null;
    }
  }

  Future<void> _completeSignUp() async {
    setState(() => isLoading = true);

    try {
      String imageUrl = 'https://i.ibb.co/YTN2gGk/default-avatar.png';
      if (_profileImage != null) {
        final uploadedUrl = await uploadImageToImgbb(_profileImage!);
        if (uploadedUrl != null) imageUrl = uploadedUrl;
      }

      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: widget.email,
            password: widget.password,
          );

      final data = {
        'name': widget.name,
        'email': widget.email,
        'role': widget.role,
        'imageUrl': imageUrl,
        'phone': phoneController.text.trim(),
        'address': addressController.text.trim(),
        'age': ageController.text.trim(),
      };

      // لو هو دكتور، ضيف التخصص والوصف
      if (widget.role == 'Doctor') {
        data.addAll({
          'specialty': selectedSpecialty ?? '',
          'description': descriptionController.text.trim(),
          'fee': '150 EGP',
          'time': '10:00 - 4:00',
          'rating': '4.9',
        });
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(data);

      if (widget.role == 'Doctor') {
        Navigator.pushReplacementNamed(context, '/doctorDashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/patientDashboard');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred during sign up")),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const AuthHeader(),
          AuthContainer(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  Text(
                    widget.role == 'Doctor'
                        ? "Doctor's Information"
                        : "Complete Your Information",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: const Color(0xff285DD8).withOpacity(0.2),
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : null,
                      child: _profileImage == null
                          ? const Icon(
                              Icons.camera_alt,
                              size: 32,
                              color: Color(0xff285DD8),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  AuthTextField(
                    hintText: "Enter your phone number",
                    controller: phoneController,
                    prefixIcon: Icons.phone,
                  ),
                  const SizedBox(height: 15),
                  AuthTextField(
                    hintText: "Enter your address",
                    controller: addressController,
                    prefixIcon: Icons.home,
                  ),
                  const SizedBox(height: 15),
                  AuthTextField(
                    hintText: "Enter your age",
                    controller: ageController,
                    prefixIcon: Icons.calendar_today,
                  ),
                  const SizedBox(height: 15),
                  if (widget.role == 'Doctor') ...[
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Choose Specialty',
                        prefixIcon: Icon(Icons.local_hospital),
                      ),
                      value: selectedSpecialty,
                      onChanged: (value) =>
                          setState(() => selectedSpecialty = value),
                      items: specialties
                          .map(
                            (specialty) => DropdownMenuItem(
                              value: specialty,
                              child: Text(specialty),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 15),
                    AuthTextField(
                      hintText: "Enter a brief description",
                      controller: descriptionController,
                      prefixIcon: Icons.description,
                    ),
                  ],
                  const SizedBox(height: 30),
                  AuthButton(
                    text: "Sign Up",
                    isLoading: isLoading,
                    onPressed: _completeSignUp,
                  ),
                  const SizedBox(height: 15),
                  AuthSwitchText(
                    text: "Already have an account? ",
                    linkText: "Sign in",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

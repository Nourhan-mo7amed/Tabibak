import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../data/models/field_config.dart';
import '../../data/repo/doctor_profile_repository.dart';
import '../../logic/doctor_profile_controller.dart';
import '../widgets/build_info_tile.dart';
import '../widgets/build_section_title.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  late final DoctorProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DoctorProfileController(DoctorProfileRepository());
  }

  @override
  void dispose() {
    _controller.dispose();
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
              decoration: InputDecoration(
                prefixIcon: Icon(field.icon, color: const Color(0xff285DD8)),
                labelText: field.label,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          )
        : buildInfoTile(
            field.icon,
            field.label,
            _controller.controllers[field.key]!.text,
          );
  }

  @override
  Widget build(BuildContext context) {
    final userId = _controller.repository.getCurrentUserId();

    if (userId == null) {
      return const Scaffold(body: Center(child: Text('User not logged in')));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Doctor Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xff285DD8),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              _controller.isEditing ? Icons.close : Icons.edit,
              color: Colors.white,
            ),
            onPressed: () {
              if (_controller.isEditing && _controller.doctorData != null) {
                _controller.populateControllers(_controller.doctorData!);
              }
              setState(() {
                _controller.isEditing = !_controller.isEditing;
              });
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _controller.repository.getDoctorProfileStream(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data?.data() == null) {
            return const Center(child: Text('No data available'));
          }

          _controller.doctorData =
              snapshot.data!.data() as Map<String, dynamic>;
          _controller.doctorData!['id'] = snapshot.data!.id;

          if (!_controller.isEditing) {
            _controller.populateControllers(_controller.doctorData!);
          }

          final imageUrl = _controller.doctorData!['imageUrl'] ?? '';

          return _controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // الجزء العلوي (الصورة والاسم والتخصص والتقييم)
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: imageUrl.isNotEmpty
                                  ? NetworkImage(imageUrl)
                                  : const AssetImage(
                                          'assets/images/default_avatar.png',
                                        )
                                        as ImageProvider,
                            ),
                            const SizedBox(height: 12),
                            _controller.isEditing
                                ? TextFormField(
                                    controller: _controller.controllers['name'],
                                    decoration: const InputDecoration(
                                      labelText: 'Name',
                                      border: OutlineInputBorder(),
                                    ),
                                  )
                                : Text(
                                    'Dr. ${_controller.controllers['name']!.text}',
                                    style: const TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                            const SizedBox(height: 8),
                            _buildEditableField(
                              _controller.fields.firstWhere(
                                (field) => field.key == 'specialty',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.star, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text(
                                  '${_controller.doctorData!['rating'] ?? '0'} / 5',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // معلومات التواصل
                      buildSectionTitle("Contact Information"),
                      _buildEditableField(
                        _controller.fields.firstWhere(
                          (field) => field.key == 'email',
                        ),
                      ),
                      _buildEditableField(
                        _controller.fields.firstWhere(
                          (field) => field.key == 'phone',
                        ),
                      ),
                      _buildEditableField(
                        _controller.fields.firstWhere(
                          (field) => field.key == 'address',
                        ),
                      ),

                      // الخبرة والتخصص
                      buildSectionTitle("Experience & Specialty"),
                      _buildEditableField(
                        _controller.fields.firstWhere(
                          (field) => field.key == 'experience',
                        ),
                      ),
                      _buildEditableField(
                        _controller.fields.firstWhere(
                          (field) => field.key == 'fee',
                        ),
                      ),
                      _buildEditableField(
                        _controller.fields.firstWhere(
                          (field) => field.key == 'patients',
                        ),
                      ),
                      _buildEditableField(
                        _controller.fields.firstWhere(
                          (field) => field.key == 'time',
                        ),
                      ),
                      _buildEditableField(
                        _controller.fields.firstWhere(
                          (field) => field.key == 'availability',
                        ),
                      ),

                      // معلومات إضافية
                      buildSectionTitle("Additional Information"),
                      _buildEditableField(
                        _controller.fields.firstWhere(
                          (field) => field.key == 'description',
                        ),
                      ),
                      buildInfoTile(
                        Icons.reviews,
                        'Reviews Count',
                        '${_controller.doctorData!['reviews'] ?? '29'}',
                      ),

                      const SizedBox(height: 30),

                      // زر حفظ التغييرات
                      if (_controller.isEditing)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff285DD8),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => _controller.saveChanges(
                            context,
                            () => setState(() {}),
                          ),
                          child: const Text(
                            "Save Changes",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                );
        },
      ),
    );
  }
}

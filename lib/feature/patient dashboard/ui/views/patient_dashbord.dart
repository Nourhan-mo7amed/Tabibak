import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/buildBookingsTab.dart';
import '../widgets/buildFavoritesTab.dart';
import '../widgets/buildHeader.dart';
import '../widgets/doctor_cart.dart';
import 'doctor_profile_screen.dart';
import 'patient_profile.dart';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  final currentUser = FirebaseAuth.instance.currentUser;
  int _selectedIndex = 0;
  String _selectedSpecialty = '';

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> predefinedSpecialties = [
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

  Widget _buildServices() {
    final allSpecialties = ['الكل', ...predefinedSpecialties];

    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: allSpecialties.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final specialty = allSpecialties[index];
          final isSelected =
              (_selectedSpecialty.isEmpty && specialty == 'الكل') ||
              (_selectedSpecialty == specialty);

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedSpecialty = specialty == 'الكل' ? '' : specialty;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blueAccent : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.5),

                          //  offset: const Offset(0, 10),
                        ),
                      ]
                    : [],
              ),
              child: Text(
                specialty,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text("Not logged in")));
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          buildHomeTab(),
          buildBookingsTab(),
          buildFavoritesTab(),
          PatientProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget buildHomeTab() {
    return SafeArea(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .where('patientId', isEqualTo: currentUser!.uid)
            .where('status', whereIn: ['pending', 'accepted'])
            .snapshots(),
        builder: (context, requestSnapshot) {
          if (!requestSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          requestSnapshot.data!.docs
              .map((doc) => doc['doctorId']?.toString())
              .where((id) => id != null)
              .cast<String>()
              .toList();

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('role', isEqualTo: 'Doctor')
                .snapshots(),
            builder: (context, doctorSnapshot) {
              if (!doctorSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final doctors = doctorSnapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final name = (data['name'] ?? '').toString().toLowerCase();
                final specialty = (data['specialty'] ?? '').toString();
                final matchesSearch =
                    name.contains(_searchQuery) ||
                    specialty.toLowerCase().contains(_searchQuery);
                final matchesSpecialty =
                    _selectedSpecialty.isEmpty ||
                    specialty == _selectedSpecialty;
                return matchesSearch && matchesSpecialty;
              }).toList();

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildHeader(),
                    const SizedBox(height: 20),
                    _buildSearchBar(),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Categories",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            "See All",
                            style: TextStyle(color: Colors.blueAccent),
                          ),
                        ),
                      ],
                    ),
                    _buildServices(),
                    const SizedBox(height: 24),
                    const Text(
                      "Top Doctors",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (doctors.isEmpty)
                      const Center(child: Text("لا يوجد طبيب بهذا التخصص")),
                    if (doctors.isNotEmpty)
                      Expanded(
                        child: ListView.builder(
                          itemCount: doctors.length,
                          itemBuilder: (context, index) {
                            final doc = doctors[index];
                            final data = doc.data() as Map<String, dynamic>;
                            return DoctorCard(
                              name: "Dr. ${data['name'] ?? 'Unknown'}",
                              specialty: data['specialty'] ?? 'Not specified',
                              imageUrl: data.containsKey('imageUrl')
                                  ? data['imageUrl']
                                  : 'https://cdn-icons-png.flaticon.com/512/147/147142.png',
                              time: data['time'] ?? 'Not specified',
                              fee: data['fee']?.toString() ?? 'Not specified',
                              rating: data['rating']?.toString() ?? '0.0',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DoctorProfileScreen(
                                      doctorData: {...data, 'id': doc.id},
                                    ),
                                  ),
                                );
                              },
                              doctorData: {...data, 'id': doc.id},
                            );
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        // Container فيه ظل حول TextField
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, 2), // ظل خفيف من تحت
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Search for a doctor...",
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.transparent, // شيلنا الحدود لأنها داخل ظل
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.blueAccent.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // زر الفلتر
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              print("Filter icon pressed");
            },
          ),
        ),
      ],
    );
  }
}

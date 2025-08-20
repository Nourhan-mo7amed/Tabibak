import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../views/doctor_profile_screen.dart';
import 'doctor_cart.dart';

Widget buildFavoritesTab() {
  final currentUser = FirebaseAuth.instance.currentUser;
  return SafeArea(
    child: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xff285DD8),
        title: const Row(
          children: [
            Icon(Icons.favorite, color: Colors.white, size: 24),
            SizedBox(width: 8),
            Text(
              "Favorites Doctors",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // يمكن إضافة وظيفة بحث لاحقًا
              print("Search favorites pressed");
            },
            tooltip: "Search Favorites",
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('favorites')
            .where('patientId', isEqualTo: currentUser!.uid)
            .snapshots(),
        builder: (context, favSnapshot) {
          if (favSnapshot.hasError) {
            return const Center(child: Text('Error loading favorites'));
          }
          if (!favSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final favoriteDoctorIds = favSnapshot.data!.docs
              .map((doc) {
                final doctorId = doc['doctorId'];
                return doctorId is String ? doctorId : null;
              })
              .where((id) => id != null)
              .cast<String>()
              .toList();

          if (favoriteDoctorIds.isEmpty) {
            return const Center(child: Text("No favorite doctors yet."));
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .where('role', isEqualTo: 'Doctor')
                .snapshots(),
            builder: (context, doctorSnapshot) {
              if (doctorSnapshot.hasError) {
                return const Center(child: Text('Error loading doctors'));
              }
              if (!doctorSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final doctors = doctorSnapshot.data!.docs.where((doc) {
                return favoriteDoctorIds.contains(doc.id);
              }).toList();

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: doctors.length,
                itemBuilder: (context, index) {
                  final doc = doctors[index];
                  final data = doc.data() as Map<String, dynamic>;

                  return DoctorCard(
                    name: data['name'] ?? 'Unknown',
                    specialty: data['specialty'] ?? 'Not specified',
                    imageUrl:
                        data['imageUrl'] ??
                        'https://cdn-icons-png.flaticon.com/512/147/147142.png',
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
              );
            },
          );
        },
      ),
    ),
  );
}

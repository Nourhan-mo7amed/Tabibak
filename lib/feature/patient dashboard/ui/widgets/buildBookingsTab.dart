import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../views/doctor_profile_screen.dart';
import 'doctor_cart.dart';

Widget buildBookingsTab() {
  final currentUser = FirebaseAuth.instance.currentUser;
  return SafeArea(
    child: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xff285DD8),
        title: const Row(
          children: [
            Icon(Icons.calendar_month, color: Colors.white, size: 24),
            SizedBox(width: 8),
            Text(
              "My Bookings",
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
              print("Search bookings pressed");
            },
            tooltip: "Search Bookings",
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .where('patientId', isEqualTo: currentUser!.uid)
            .where('status', isEqualTo: 'accepted')
            .snapshots(),
        builder: (context, bookingSnapshot) {
          if (bookingSnapshot.hasError) {
            return const Center(child: Text('Error loading bookings'));
          }
          if (!bookingSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final acceptedBookings = bookingSnapshot.data!.docs;
          if (acceptedBookings.isEmpty) {
            return const Center(child: Text('No accepted bookings'));
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

              final doctors = doctorSnapshot.data!.docs;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: acceptedBookings.map((booking) {
                  final doctorId = booking['doctorId'];
                  final matchingDoctors = doctors
                      .where((doc) => doc.id == doctorId)
                      .toList();
                  if (matchingDoctors.isEmpty) return const SizedBox();
                  final doctor = matchingDoctors.first;
                  final data = doctor.data() as Map<String, dynamic>;

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
                            doctorData: {...data, 'id': doctor.id},
                          ),
                        ),
                      );
                    },
                    doctorData: {...data, 'id': doctor.id},
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    ),
  );
}

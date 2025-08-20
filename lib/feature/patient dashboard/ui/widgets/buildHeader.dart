import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Widget buildHeader() {
  final currentUser = FirebaseAuth.instance.currentUser;
  return Row(
    children: [
      StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircleAvatar(
              radius: 26,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white),
            );
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>?;
          final imageUrl = userData?['imageUrl'] as String?;

          return CircleAvatar(
            radius: 26,
            backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                ? NetworkImage(imageUrl)
                : const AssetImage('assets/images/default_avatar.png')
                      as ImageProvider,
          );
        },
      ),
      const SizedBox(width: 12),
      StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>?;
          final fullName = userData?['name'] ?? 'User';
          final firstName = fullName.toString().split(' ').first;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Hello",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              Text(
                "$firstName!",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          );
        },
      ),
      const Spacer(),
      const Icon(
        Icons.notifications_none_rounded,
        size: 28,
        color: Colors.black,
      ),
    ],
  );
}

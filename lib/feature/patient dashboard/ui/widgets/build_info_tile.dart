import 'package:flutter/material.dart';

Widget buildInfoTile(IconData icon, String title, String value) {
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
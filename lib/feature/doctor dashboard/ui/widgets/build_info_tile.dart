import 'package:flutter/material.dart';

Widget buildInfoTile(IconData icon, String title, String value) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 6),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xff285DD8)),
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
        Icon(icon, color: const Color(0xff285DD8)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            '$title: ${value.isEmpty ? "Not Available" : value}',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    ),
  );
}

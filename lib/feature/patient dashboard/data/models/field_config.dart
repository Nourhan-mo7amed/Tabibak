import 'package:flutter/material.dart';

class FieldConfig {
  final String key;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
  final bool editable;

  FieldConfig({
    required this.key,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.editable = true,
  });
}
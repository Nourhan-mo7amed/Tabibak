import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final IconData? prefixIcon;
  final bool isPasswordField;
  final bool isConfirmPasswordField;
  final bool isObscure;
  final VoidCallback? onToggleVisibility;

  const AuthTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.prefixIcon,
    this.isPasswordField = false,
    this.isConfirmPasswordField = false,
    this.isObscure = true,
    this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: isPasswordField || isConfirmPasswordField
          ? isObscure
          : false,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: Colors.grey)
            : null,
        suffixIcon: (isPasswordField || isConfirmPasswordField)
            ? IconButton(
                icon: Icon(
                  isObscure ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: onToggleVisibility,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

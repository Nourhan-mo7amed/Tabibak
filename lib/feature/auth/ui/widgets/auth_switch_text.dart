// lib/auth/widgets/auth_switch_text.dart
import 'package:flutter/material.dart';

class AuthSwitchText extends StatelessWidget {
  final String text;
  final String linkText;
  final VoidCallback onTap;

  const AuthSwitchText({
    super.key,
    required this.text,
    required this.linkText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text.rich(
        TextSpan(
          text: text,
          style: const TextStyle(color: Colors.black),
          children: [
            TextSpan(
              text: linkText,
              style: const TextStyle(
                color: Color(0xff285DD8),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

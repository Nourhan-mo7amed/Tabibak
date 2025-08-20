// lib/auth/widgets/auth_header.dart
import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 270,
            height: 270,
            decoration: BoxDecoration(
              color: const Color(0xff285DD8).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          top: -80,
          right: -80,
          child: Container(
            width: 230,
            height: 230,
            decoration: const BoxDecoration(
              color: Color(0xff285DD8),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          top: 30,
          left: 0,
          right: 170,
          child: Center(
            child: Image.asset(
              'assets/icons_images/tabibak2.png',
              height: 110,
            ),
          ),
        ),
      ],
    );
  }
}

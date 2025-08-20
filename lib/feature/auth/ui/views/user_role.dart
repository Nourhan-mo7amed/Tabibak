
import 'package:flutter/material.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_container.dart';
import '../widgets/auth_header.dart';
import 'signup_screen.dart';

class UserRoleScreen extends StatefulWidget {
  const UserRoleScreen({super.key});

  @override
  State<UserRoleScreen> createState() => _UserRoleScreenState();
}

class _UserRoleScreenState extends State<UserRoleScreen> {
  String? selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const AuthHeader(),

          Align(
            alignment: Alignment.bottomCenter,
            child: AuthContainer(
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  const Text(
                    "You Are ?",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Choose your role to continue",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildRoleOption("Patient", 'assets/imeges/patient2.png'),
                      _buildRoleOption("Doctor", 'assets/imeges/doctor1.png'),
                    ],
                  ),
                  const SizedBox(height: 30),
                  AuthButton(
                    text: "Next",
                    isLoading: false,
                    onPressed: () {
                      if (selectedRole != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignUp(role: selectedRole!),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text.rich(
                      TextSpan(
                        text: "Already have an account? ",
                        style: TextStyle(color: Colors.black),
                        children: [
                          TextSpan(
                            text: "Login",
                            style: TextStyle(
                              color: Color(0xff285DD8),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleOption(String role, String imagePath) {
    final isSelected = selectedRole == role;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRole = role;
        });
      },
      child: Container(
        width: 140,
        height: 190,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? const Color(0xff285DD8) : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        child: Column(
          children: [
            Image.asset(imagePath, height: 110),
            const SizedBox(height: 30),
            Text(
              role,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xff285DD8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

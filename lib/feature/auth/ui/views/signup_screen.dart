import 'package:flutter/material.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_container.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_switch_text.dart';
import '../widgets/auth_text_field.dart';
import 'ExtraInfo_Screen.dart';
import 'login_screen.dart';

class SignUp extends StatefulWidget {
  final String role;

  const SignUp({super.key, required this.role});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _goToExtraInfoScreen() {
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      _showSnackBar("Please fill in all fields");
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      _showSnackBar("Passwords do not match");
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExtraInfoScreen(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
          role: widget.role,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const AuthHeader(),
          AuthContainer(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  const Text(
                    "Register with us!",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Your information is safe with us",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  AuthTextField(
                    hintText: "Enter your full name",
                    controller: nameController,
                    prefixIcon: Icons.person_outline,
                  ),
                  const SizedBox(height: 15),
                  AuthTextField(
                    hintText: "Enter your email",
                    controller: emailController,
                    prefixIcon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 15),
                  AuthTextField(
                    hintText: "Enter your password",
                    controller: passwordController,
                    prefixIcon: Icons.lock_outline,
                    isPasswordField: true,
                    isObscure: !isPasswordVisible,
                    onToggleVisibility: () =>
                        setState(() => isPasswordVisible = !isPasswordVisible),
                  ),
                  const SizedBox(height: 15),
                  AuthTextField(
                    hintText: "Confirm your password",
                    controller: confirmPasswordController,
                    prefixIcon: Icons.lock_outline,
                    isConfirmPasswordField: true,
                    isObscure: !isConfirmPasswordVisible,
                    onToggleVisibility: () => setState(
                      () =>
                          isConfirmPasswordVisible = !isConfirmPasswordVisible,
                    ),
                  ),
                  const SizedBox(height: 30),
                  AuthButton(
                    text: "Next",
                    isLoading: isLoading,
                    onPressed: _goToExtraInfoScreen,
                  ),
                  const SizedBox(height: 20),
                  AuthSwitchText(
                    text: "Already have an account? ",
                    linkText: "Sign in",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
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
}

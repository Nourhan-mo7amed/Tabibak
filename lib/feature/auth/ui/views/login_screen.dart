import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../doctor dashboard/ui/views/doctor_dashbord.dart';
import '../../../patient dashboard/ui/views/patient_dashbord.dart';
import '../widgets/auth_container.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_text_field.dart';
import 'Forget_Page.dart';
import 'user_role.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  bool isPasswordVisible = false;

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
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    _buildHeader(),
                    const SizedBox(height: 30),
                    _buildAuthTextField(
                      controller: emailController,
                      hintText: "Email",
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 15),
                    _buildAuthTextField(
                      controller: passwordController,
                      hintText: "Password",
                      icon: Icons.lock_outline,
                      isObscure: !isPasswordVisible,
                      onToggleVisibility: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildForgotPasswordButton(),
                    const SizedBox(height: 10),
                    _buildLoginButton(),
                    const SizedBox(height: 20),
                    _buildSignUpButton(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() => Column(
    children: const [
      Text(
        "Welcome Back!",
        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 10),
      Text(
        "Login to your account",
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    ],
  );

  Widget _buildAuthTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isObscure = false,
    VoidCallback? onToggleVisibility,
  }) {
    return AuthTextField(
      hintText: hintText,
      controller: controller,
      prefixIcon: icon,
      isObscure: isObscure,
      onToggleVisibility: onToggleVisibility,
    );
  }

  Widget _buildForgotPasswordButton() => Align(
    alignment: Alignment.centerRight,
    child: TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ForgetPasswordScreen()),
        );
      },
      child: const Text(
        "Forgot Password?",
        style: TextStyle(color: Colors.grey),
      ),
    ),
  );

  Widget _buildLoginButton() => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: isLoading ? null : _login,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff285DD8),
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text(
              "Login",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
    ),
  );

  Widget _buildSignUpButton() => TextButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const UserRoleScreen()),
      );
    },
    child: const Text.rich(
      TextSpan(
        text: "Don't have an account? ",
        style: TextStyle(color: Colors.black),
        children: [
          TextSpan(
            text: "Sign up",
            style: TextStyle(
              color: Color(0xff285DD8),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );

  Future<void> _login() async {
    setState(() => isLoading = true);

    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );
      final uid = userCredential.user!.uid;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!userDoc.exists) {
        _showSnackBar("User not found in the database!");
        return;
      }

      final role = userDoc.data()?['role'];

      _showSnackBar("Login successful ✅");

      if (role == "Doctor") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => DoctorDashboardScreen()),
        );
      } else if (role == "Patient") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => PatientDashboard()),
        );
      } else {
        _showSnackBar("Unknown user role!");
      }
    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? "Failed to login");
    } catch (_) {
      _showSnackBar("An unexpected error occurred");
    }

    setState(() => isLoading = false);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

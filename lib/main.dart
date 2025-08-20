import 'package:cinic_app/feature/intro/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'feature/auth/ui/views/login_screen.dart';
import 'feature/doctor dashboard/data/repo/doctor_repo.dart';
import 'feature/doctor dashboard/data/services/firestore_service.dart';
import 'feature/doctor dashboard/logic/provider/doctor_provider.dart';
import 'feature/doctor dashboard/ui/views/doctor_dashbord.dart';
import 'feature/patient dashboard/ui/views/patient_dashbord.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getStartScreen() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final role = userDoc.data()?['role'];

      if (role == "Doctor") {
        return const DoctorDashboardScreen();
      } else if (role == "Patient") {
        return const PatientDashboard();
      }
    }
    return const LoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        Provider<DoctorRepository>(
          create: (context) =>
              DoctorRepository(context.read<FirestoreService>()),
        ),
        ChangeNotifierProvider<DoctorProvider>(
          create: (context) => DoctorProvider(context.read<DoctorRepository>()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: FutureBuilder<Widget>(
          future: _getStartScreen(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            }
            return snapshot.data!;
          },
        ),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/doctorDashboard': (context) => const DoctorDashboardScreen(),
          '/patientDashboard': (context) => const PatientDashboard(),
        },
      ),
    );
  }
}

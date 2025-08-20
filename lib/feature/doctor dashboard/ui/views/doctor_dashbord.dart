// lib/features/doctor_dashboard/ui/screens/doctor_dashboard_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../auth/ui/views/login_screen.dart';
import '../../data/models/doctor.dart';
import '../../logic/provider/doctor_provider.dart';
import '../widgets/profile_widget.dart';
import '../widgets/request_list_widget.dart';
import 'DoctorProfileScreen.dart';

class DoctorDashboardScreen extends StatelessWidget {
  const DoctorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DoctorProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder(
        stream: provider.getDoctor(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final doctor = snapshot.data!;
          final firstName = doctor.name.split(' ').first;

          return Column(
            children: [
              _buildHeader(context, doctor, firstName),
              const SizedBox(height: 20),
              _buildTabButtons(context, provider),
              const SizedBox(height: 20),
              Expanded(
                child: IndexedStack(
                  index: provider.selectedIndex,
                  children: [
                    RequestListWidget(
                      status: 'accepted',
                      emptyMessage: "No accepted bookings",
                      titleBuilder: (patientName) =>
                          "Confirmed booking for $patientName",
                      subtitle: "Booking confirmed successfully",
                      actionsBuilder: null,
                    ),
                    RequestListWidget(
                      status: 'pending',
                      emptyMessage: "No requests currently",
                      titleBuilder: (patientName) => "Request from $patientName",
                      subtitle: "wants to book an appointment with you",
                      actionsBuilder: (request, patientId) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () => provider.updateRequestStatus(
                                request.reference, 'accepted', patientId),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => provider.updateRequestStatus(
                                request.reference, 'rejected', patientId),
                          ),
                        ],
                      ),
                    ),
                    const ProfileWidget(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Doctor doctor, String firstName) {
    return Stack(
      children: [
        Container(
          height: 270,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/imeges/bg1.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 50,
          left: 15,
          child: Row(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundImage: doctor.imageUrl != null
                    ? NetworkImage(doctor.imageUrl!)
                    : const AssetImage('assets/images/default_avatar.png')
                        as ImageProvider,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Welcome",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "Dr.$firstName!",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: 40,
          right: 10,
          child: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) async {
              if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DoctorProfileScreen(),
                  ),
                );
              } else if (value == 'logout') {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.black54),
                    SizedBox(width: 8),
                    Text("profile"),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.black54),
                    SizedBox(width: 8),
                    Text("logout"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabButtons(BuildContext context, DoctorProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => provider.selectedIndex = 0,
              icon: const Icon(Icons.today),
              label: const Text("Today Appointments"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: provider.selectedIndex == 0
                    ? Colors.blueAccent
                    : Colors.grey[300],
                foregroundColor:
                    provider.selectedIndex == 0 ? Colors.white : Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => provider.selectedIndex = 1,
              icon: const Icon(Icons.pending_actions),
              label: const Text("Requests"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: provider.selectedIndex == 1
                    ? Colors.blueAccent
                    : Colors.grey[300],
                foregroundColor:
                    provider.selectedIndex == 1 ? Colors.white : Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
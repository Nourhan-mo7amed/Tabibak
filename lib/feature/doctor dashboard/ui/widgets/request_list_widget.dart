import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../logic/provider/doctor_provider.dart';

class RequestListWidget extends StatelessWidget {
  final String status;
  final String emptyMessage;
  final String Function(String) titleBuilder;
  final String subtitle;
  final Widget? Function(QueryDocumentSnapshot, String)? actionsBuilder;

  const RequestListWidget({
    super.key,
    required this.status,
    required this.emptyMessage,
    required this.titleBuilder,
    required this.subtitle,
    this.actionsBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DoctorProvider>(context);

    return StreamBuilder<List<QueryDocumentSnapshot>>(
      stream: provider.getRequests(status),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final requests = snapshot.data!;

        if (requests.isEmpty) {
          return Center(child: Text(emptyMessage));
        }

        return ListView.builder(
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            final patientId = request['patientId'] as String;

            return FutureBuilder<Map<String, dynamic>>(
              future: provider.getPatientData(patientId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (!snapshot.hasData) {
                  return const SizedBox();
                }

                final patientData = snapshot.data!;
                final patientName = patientData['name'] ?? 'مريض غير معروف';
                final patientImage = patientData['imageUrl'] ?? '';
                final dateField = request['date'];
                String bookingDate = 'غير محدد';

                if (dateField != null && dateField is Timestamp) {
                  final localDate = dateField.toDate().toLocal();
                  bookingDate = DateFormat('dd/MM/yyyy HH:mm').format(localDate);
                }

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.6),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundImage: patientImage.isNotEmpty
                          ? NetworkImage(patientImage)
                          : const AssetImage('assets/images/default_avatar.png')
                              as ImageProvider,
                    ),
                    title: Text(
                      titleBuilder(patientName),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        "موعد: $bookingDate",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                    trailing: actionsBuilder != null
                        ? actionsBuilder!(request, patientId)
                        : null,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
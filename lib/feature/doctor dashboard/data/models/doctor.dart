// lib/features/doctor_dashboard/data/models/doctor.dart
class Doctor {
  final String id;
  final String name;
  final String email;
  final String? imageUrl;

  Doctor({
    required this.id,
    required this.name,
    required this.email,
    this.imageUrl,
  });

  factory Doctor.fromMap(Map<String, dynamic> data, String id) {
    return Doctor(
      id: id,
      name: data['name'] ?? 'اسم غير معروف',
      email: data['email'] ?? 'بريد غير معروف',
      imageUrl: data['imageUrl'],
    );
  }
}
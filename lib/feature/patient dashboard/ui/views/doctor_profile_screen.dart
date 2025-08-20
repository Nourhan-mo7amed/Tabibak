import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class DoctorProfileScreen extends StatefulWidget {
  final Map<String, dynamic> doctorData;

  const DoctorProfileScreen({super.key, required this.doctorData});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  bool isBooked = false;
  String requestStatus = 'none';
  bool isFavorited = false;
  bool isBookingLoading = false;

  final String patientId = FirebaseAuth.instance.currentUser!.uid;

  final Color primaryColor = const Color(0xFF2B4D78);
  DateTime? selectedDate;
  String? selectedTime;

  final List<String> times = [
    "08:00AM",
    "09:00AM",
    "10:00AM",
    "11:00PM",
    "12:00PM",
    "01:00PM",
  ];

  @override
  void initState() {
    super.initState();
    _checkBookingStatus();
    _checkFavoriteStatus();
  }

  //=================== Booking & Favorite ===================//
  Future<void> _checkBookingStatus() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('requests')
          .where('doctorId', isEqualTo: widget.doctorData['id'])
          .where('patientId', isEqualTo: patientId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        setState(() {
          isBooked = true;
          requestStatus = data['status'] ?? 'pending';

          // استرجاع التاريخ
          if (data['date'] != null) {
            selectedDate = (data['date'] as Timestamp).toDate();
          }

          // استرجاع الوقت
          selectedTime = data['time'];
        });
      }
    } catch (e) {
      _showSnackBar('خطأ أثناء التحقق من حالة الحجز');
    }
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('favorites')
          .where('doctorId', isEqualTo: widget.doctorData['id'])
          .where('patientId', isEqualTo: patientId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() => isFavorited = true);
      }
    } catch (e) {
      _showSnackBar('خطأ أثناء التحقق من المفضلة');
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      final favoritesRef = FirebaseFirestore.instance.collection('favorites');
      final snapshot = await favoritesRef
          .where('doctorId', isEqualTo: widget.doctorData['id'])
          .where('patientId', isEqualTo: patientId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        await favoritesRef.add({
          'doctorId': widget.doctorData['id'],
          'patientId': patientId,
          'timestamp': FieldValue.serverTimestamp(),
        });
        setState(() => isFavorited = true);
        _showSnackBar('تمت الإضافة إلى المفضلة ❤️');
      } else {
        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }
        setState(() => isFavorited = false);
        _showSnackBar('تمت الإزالة من المفضلة');
      }
    } catch (e) {
      _showSnackBar('حدث خطأ أثناء تعديل المفضلة');
    }
  }

  Future<void> _handleBooking() async {
    if (selectedDate == null || selectedTime == null) {
      _showSnackBar('اختر تاريخ ووقت الحجز أولاً');
      return;
    }

    // تحويل الـ selectedTime (String) إلى ساعة ودقيقة
    final timeParts = selectedTime!.replaceAll(RegExp(r'[APM]'), '').split(':');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);

    // لو الوقت فيه "PM" و الساعة أقل من 12، نضيف 12 ساعة
    if (selectedTime!.contains("PM") && hour < 12) {
      hour += 12;
    }
    // لو الوقت فيه "AM" والساعة 12 نحولها إلى 0
    if (selectedTime!.contains("AM") && hour == 12) {
      hour = 0;
    }

    // دمج التاريخ والوقت في DateTime واحد
    DateTime finalDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      hour,
      minute,
    );

    setState(() => isBookingLoading = true);
    try {
      await FirebaseFirestore.instance.collection('requests').add({
        'doctorId': widget.doctorData['id'],
        'patientId': patientId,
        'status': 'pending',
        'date': Timestamp.fromDate(finalDateTime), // التاريخ + الوقت
        'time': selectedTime, // نخزن الوقت كنص برضه لو حبيت تعرضه
        'timestamp': FieldValue.serverTimestamp(),
      });
      setState(() {
        isBooked = true;
        requestStatus = 'pending';
      });
      _showSnackBar('تم إرسال طلب الحجز بنجاح!');
    } catch (e) {
      _showSnackBar('حدث خطأ أثناء الحجز');
    } finally {
      setState(() => isBookingLoading = false);
    }
  }

  Future<void> _cancelBooking() async {
    setState(() => isBookingLoading = true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('requests')
          .where('doctorId', isEqualTo: widget.doctorData['id'])
          .where('patientId', isEqualTo: patientId)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
      setState(() {
        isBooked = false;
        requestStatus = 'none';
      });
      _showSnackBar('تم إلغاء الحجز بنجاح!');
    } catch (e) {
      _showSnackBar('حدث خطأ أثناء الإلغاء');
    } finally {
      setState(() => isBookingLoading = false);
    }
  }

  //=================== UI Widgets ===================//
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.grey[200],
          child: Icon(icon, color: primaryColor),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final doctor = widget.doctorData;

    final String doctorName = "Dr. ${doctor['name'] ?? 'No Name'}";
    final String specialty = doctor['specialty'] ?? 'Specialist';
    final String imageUrl =
        doctor['imageUrl'] ?? 'https://via.placeholder.com/150';
    final String patientsCount = (doctor['patients'] ?? 36).toString();
    final String experienceYears = (doctor['experience'] ?? 3).toString();
    final String rating = (doctor['rating'] ?? 4.5).toString();
    final String reviewsCount = (doctor['reviews'] ?? 23).toString();

    final String aboutMe = doctor['description'] ?? 'No description available.';
    final String phone = doctor['phone'] ?? 'No phone';
    final String address = doctor['address'] ?? 'No address';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Doctor', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Doctor Image
            Card(
              elevation: 4,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    child: Image.network(
                      imageUrl,
                      height: 330,
                      width: 350,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: GestureDetector(
                      onTap: _toggleFavorite,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(
                          isFavorited ? Icons.favorite : Icons.favorite_border,
                          color: isFavorited ? Colors.redAccent : Colors.grey,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Name & Rating
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      doctorName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(Icons.star, color: Colors.amber),
                  Text(
                    '$rating ($reviewsCount reviews)',
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.local_hospital,
                    color: Colors.grey[600],
                    size: 20,
                  ), // أيقونة التخصص
                  const SizedBox(width: 6), // مسافة بين الأيقونة والكلام
                  Text(
                    specialty,
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            ),

            // هنا نضيف رقم التليفون والعنوان
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.phone, color: Colors.grey[700]),
                      const SizedBox(width: 8),
                      Text(
                        phone,
                        style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.grey[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          address,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Stats
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(Icons.person, patientsCount, "Patients"),
                  _buildStatItem(
                    Icons.check_box_outlined,
                    experienceYears,
                    "Years",
                  ),
                  _buildStatItem(Icons.star, rating, "Rating"),
                  _buildStatItem(
                    Icons.chat_bubble_outline,
                    '$reviewsCount+',
                    "Reviews",
                  ),
                ],
              ),
            ),

            // About Me
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About Me',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    aboutMe,
                    style: TextStyle(color: Colors.grey[700], height: 1.5),
                  ),
                ],
              ),
            ),

            // اختيار التاريخ
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: const Text(
                      'Select Date',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  GestureDetector(
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (pickedDate != null) {
                        setState(() => selectedDate = pickedDate);
                      }
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: selectedDate != null
                            ? const Color.fromARGB(122, 0, 29, 98)
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selectedDate != null
                              ? primaryColor
                              : Colors.grey.shade400,
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        selectedDate == null
                            ? 'Choose Date'
                            : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: selectedDate != null
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // عرض الأوقات في شكل شبكة
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, // عدد الأعمدة
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 2.5,
                        ),
                    itemCount: times.length,
                    itemBuilder: (context, index) {
                      final time = times[index];
                      final bool isSelected = selectedTime == time;

                      return GestureDetector(
                        onTap: () {
                          setState(() => selectedTime = time);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color.fromARGB(122, 0, 29, 98)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? primaryColor
                                  : Colors.grey.shade400,
                              width: 1.5,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            time,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Bottom Button
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: isBookingLoading || requestStatus == 'accepted'
                ? null
                : isBooked
                ? _cancelBooking
                : _handleBooking,
            style: ElevatedButton.styleFrom(
              backgroundColor: requestStatus == 'accepted'
                  ? Colors.green
                  : isBooked
                  ? Colors.red
                  : primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: isBookingLoading
                ? const SpinKitThreeBounce(color: Colors.white, size: 24.0)
                : Text(
                    requestStatus == 'accepted'
                        ? 'Accepted'
                        : isBooked
                        ? 'Cancel Booking'
                        : 'Book Appointment',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

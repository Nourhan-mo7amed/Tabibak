import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../auth/ui/views/login_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _controller = PageController();
  bool onLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                onLastPage = (index == 2);
              });
            },
            children: const [
              IntroPage(
                imagePath: 'assets/imeges/3.png',
                title: 'Find a Specialist Doctor',
                description:
                    'Explore a wide range of doctors in various fields.',
              ),
              IntroPage(
                imagePath: 'assets/imeges/1.png',
                title: 'Book Appointments Easily',
                description:
                    'Choose the right time and confirm your booking effortlessly.',
              ),
              IntroPage(
                imagePath: 'assets/imeges/2.png',
                title: 'Track Your Visits',
                description:
                    'Keep a record of your visits and stay updated on your health.',
              ),
            ],
          ),

          // Skip button
          Positioned(
            top: 50,
            left: 20,
            child: TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Text(
                'Skip',
                style: TextStyle(fontSize: 16, color: Color(0xff285DD8)),
              ),
            ),
          ),

          // Page indicator
          Positioned(
            bottom: 70,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _controller,
                count: 3,
                effect: WormEffect(
                  activeDotColor: const Color(0xff285DD8),
                  dotHeight: 10,
                  dotWidth: 20,
                ),
              ),
            ),
          ),

          // Next / Start button
        ],
      ),
    );
  }
}

class IntroPage extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;

  const IntroPage({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath, height: 350),
          const SizedBox(height: 30),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xff285DD8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          Text(
            description,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

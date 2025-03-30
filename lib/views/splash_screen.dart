import 'package:flutter/material.dart';
import 'dart:math';
import 'package:go_router/go_router.dart';

// Import the AuthService to check sign-in status
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoAnimation;
  late Animation<double> _particleAnimation;
  final List<Particle> _particles = List.generate(30, (index) => Particle());

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _logoAnimation = Tween(begin: 10.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.25, curve: Curves.easeOutCubic),
      ),
    );

    _particleAnimation = Tween(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward().then((_) {
      // Check if the user is signed in when animation completes
      navigateBasedOnAuthStatus();
    });
  }

  // Method to navigate based on authentication status
  void navigateBasedOnAuthStatus() {
    // Check if user has seen intro screen before
    final hasSeenIntro = true; // Replace with actual logic (e.g., using SharedPreferences)
    
    // Check if user is signed in
    final isSignedIn = FirebaseAuth.instance.currentUser != null;
    
    if (!hasSeenIntro) {
      // If user hasn't seen intro screen, navigate there first
      context.go('/intro');
    } else if (isSignedIn) {
      // If user is signed in, navigate to home with default category (0)
      context.go('/home/0');
    } else {
      // If user is not signed in, navigate to auth screen
      context.go('/auth');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2A2D5E), Color(0xFF00F5D4)],
          ),
        ),
        child: Stack(
          children: [
            // Floating particles
            AnimatedBuilder(
              animation: _particleAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: ParticlePainter(
                    particles: _particles,
                    progress: _particleAnimation.value,
                  ),
                );
              },
            ),
            
            Center(
              child: ScaleTransition(
                scale: _logoAnimation,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundColor: Colors.transparent,
                      child: Image.asset('assets/logos/logo.png'),
                    ),
                    const SizedBox(height: 20),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF00F5D4), Colors.white],
                      ).createShader(bounds),
                      child: const Text(
                        'BREVITY',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Short, Smart, Straight to the point',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ),
      
            // Progress Bar
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _controller.value,
                    minHeight: 4,
                    backgroundColor: Colors.white.withAlpha(51),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color(0xFF00F5D4).withAlpha(205),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Particle {
  late double x;
  late double y;
  late double radius;
  late double speed;

  Particle() {
    final random = Random();
    x = random.nextDouble();
    y = random.nextDouble();
    radius = random.nextDouble() * 2 + 1;
    speed = random.nextDouble() * 0.5 + 0.1;
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double progress;

  ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00F5D4)
      ..style = PaintingStyle.fill;

    for (var particle in particles) {
      final dx = (0.5 - particle.x) * progress * size.width;
      final dy = (0.5 - particle.y) * progress * size.height;

      canvas.drawCircle(
        Offset(
          particle.x * size.width + dx,
          particle.y * size.height + dy,
        ),
        particle.radius * (1 - progress),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
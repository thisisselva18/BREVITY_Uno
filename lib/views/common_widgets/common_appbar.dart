import 'dart:math';
import 'package:flutter/material.dart';

class ParticlesHeader extends StatelessWidget {
  final String title;
  final Color themeColor;
  final Animation<double> particleAnimation;
  final Widget? child;
  final double height;

  const ParticlesHeader({
    Key? key,
    required this.title,
    required this.themeColor,
    required this.particleAnimation,
    this.child,
    this.height = 80,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [themeColor.withAlpha(100), themeColor.withAlpha(25)],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: particleAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: ParticlesPainter(
                    themeColor,
                    particleAnimation.value,
                  ),
                );
              },
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 35, 0, 0),
              child:
                  child ??
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Roboto',
                      letterSpacing: 1.2,
                      color: Color.fromARGB(255, 223, 223, 223),
                      fontWeight: FontWeight.bold,
                      fontSize: 23,
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedPageTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const AnimatedPageTransition({
    Key? key,
    required this.animation,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}

class ParticlesPainter extends CustomPainter {
  final Color themeColor;
  final double animationValue;

  ParticlesPainter(this.themeColor, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withAlpha(50)
          ..style = PaintingStyle.fill;

    final random = 42;
    for (var i = 0; i < 30; i++) {
      final baseX = (random * i * 7) % size.width;
      final baseY = (random * i * 11) % size.height;
      final x = (baseX + (sin(animationValue * 3 + i) * 30)) % size.width;
      final y = (baseY + (cos(animationValue * 4 + i) * 25)) % size.height;
      final radius =
          ((random * i) % 4 + 1) * (0.8 + (sin(animationValue + i) * 0.2));
      final opacity =
          ((i % 5) * 0.1 + 0.1 + (sin(animationValue * 2 + i) * 0.05)) *
          255.toInt();
      canvas.drawCircle(
        Offset(x, y),
        radius.toDouble(),
        paint..color = themeColor.withAlpha(opacity.toInt()),
      );
    }
  }

  @override
  bool shouldRepaint(covariant ParticlesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.themeColor != themeColor;
  }
}

class AppScaffold extends StatelessWidget {
  final Widget body;

  const AppScaffold({Key? key, required this.body}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF121212), Color(0xFF1E1E1E)],
          ),
        ),
        child: body,
      ),
    );
  }
}

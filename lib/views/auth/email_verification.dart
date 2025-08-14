import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:brevity/controller/services/auth_service.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final bool isFromLogin;
  
  const EmailVerificationScreen({
    super.key,
    required this.email,
    this.isFromLogin = false,
  });

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen>
    with TickerProviderStateMixin {
  bool _isCheckingVerification = false;
  bool _isResendingEmail = false;
  
  // Timer related variables
  Timer? _resendTimer;
  Timer? _autoCheckTimer;
  int _resendCooldown = 0;
  int _resendAttempts = 0;
  static const List<int> _cooldownDurations = [30, 60, 120, 300]; // 30s, 1m, 2m, 5m
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _bounceController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Initialize animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );

    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start animations
    _startAnimations();
    
    // Start periodic check for email verification (every 10 seconds)
    if (AuthService().isAuthenticated) {
      _startPeriodicCheck();
    }
  }

  void _startPeriodicCheck() {
    _autoCheckTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (!mounted || _isCheckingVerification) return;
      
      try {
        await AuthService().refreshUser();
        final user = AuthService().currentUser;
        
        if (user != null && user.emailVerified) {
          timer.cancel();
          if (!mounted) return;
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Email verified successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navigate based on where user came from
          if (widget.isFromLogin) {
            context.go('/home/0');
          } else {
            context.go('/intro');
          }
        }
      } catch (e) {
        // Silently fail for auto-checks, user can manually check if needed
        if (e.toString().contains('Token expired')) {
          timer.cancel();
        }
      }
    });
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _slideController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _bounceController.forward();
    
    // Start pulse animation
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _autoCheckTimer?.cancel();
    _fadeController.dispose();
    _slideController.dispose();
    _bounceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startResendCooldown() {
    // Get cooldown duration based on attempts, with a maximum
    final duration = _resendAttempts < _cooldownDurations.length 
        ? _cooldownDurations[_resendAttempts] 
        : _cooldownDurations.last;
    
    setState(() {
      _resendCooldown = duration;
    });

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _resendCooldown--;
      });

      if (_resendCooldown <= 0) {
        timer.cancel();
        _resendTimer = null;
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    }
    return '${remainingSeconds}s';
  }

  Future<void> _checkVerification() async {
    setState(() => _isCheckingVerification = true);
    
    try {
      // Refresh user data from server
      await AuthService().refreshUser();
      final user = AuthService().currentUser;
      
      if (user != null && user.emailVerified) {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email verified successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate based on where user came from
        if (widget.isFromLogin) {
          context.go('/home/0');
        } else {
          context.go('/intro');
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email not yet verified. Please check your email and click the verification link.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      // More specific error handling
      String errorMessage = 'Error checking verification';
      if (e.toString().contains('Token expired') || e.toString().contains('401')) {
        errorMessage = 'Session expired. Please log in again.';
        // Clear auth state and redirect to login
        await AuthService().signOut(context: context);
        return;
      } else if (e.toString().contains('Network') || e.toString().contains('connection')) {
        errorMessage = 'Network error. Please check your connection and try again.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isCheckingVerification = false);
    }
  }

  Future<void> _resendVerificationEmail() async {
    // Check if cooldown is active
    if (_resendCooldown > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please wait ${_formatTime(_resendCooldown)} before resending'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isResendingEmail = true);
    
    try {
      await AuthService().resendVerificationEmail(widget.email);
      
      // Increment attempts and start cooldown
      _resendAttempts++;
      _startResendCooldown();
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification email sent! Please check your inbox and spam folder.'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      String errorMessage = 'Error sending email';
      if (e.toString().contains('already verified')) {
        errorMessage = 'Email is already verified! Try refreshing or logging in again.';
        // Auto-check verification status
        Future.delayed(Duration(seconds: 1), () => _checkVerification());
      } else if (e.toString().contains('User not found')) {
        errorMessage = 'User not found. Please contact support.';
      } else if (e.toString().contains('Server error')) {
        errorMessage = 'Server error. Please try again later.';
      } else if (e.toString().contains('Network error')) {
        errorMessage = 'Network error. Please check your connection.';
      } else {
        errorMessage = 'Error sending email. Please try again.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) setState(() => _isResendingEmail = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 4, 16, 54),
              Color.fromARGB(255, 20, 25, 78),
              Color.fromARGB(255, 27, 52, 105),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Back button
                Align(
                  alignment: Alignment.topLeft,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: IconButton(
                      onPressed: () {
                        // Stop auto-check timer when navigating away
                        _autoCheckTimer?.cancel();
                        context.go('/auth');
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated Email Icon
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: AnimatedBuilder(
                            animation: _bounceAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _bounceAnimation.value,
                                child: AnimatedBuilder(
                                  animation: _pulseAnimation,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: _pulseAnimation.value,
                                      child: Container(
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color.fromARGB(255, 26, 175, 255),
                                              Color.fromARGB(255, 9, 121, 232),
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color.fromARGB(255, 26, 175, 255)
                                                  .withValues(alpha: 0.3),
                                              blurRadius: 20,
                                              spreadRadius: 5,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.email,
                                          size: 60,
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Title
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                Color.fromARGB(255, 26, 175, 255),
                                Colors.white,
                              ],
                            ).createShader(bounds),
                            child: const Text(
                              'Verify Your Email',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Description
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Text(
                            widget.isFromLogin
                                ? 'We\'ve sent a verification link to\n${widget.email}\n\nPlease check your email and click the verification link, then try logging in again.'
                                : 'We\'ve sent a verification link to\n${widget.email}\n\nPlease check your email and click the verification link to activate your account.',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                              fontFamily: 'Poppins',
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                      const SizedBox(height: 50),

                      // Check Verification Button - Only show if token is stored (user is authenticated)
                      // This allows checking verification after app restart or when token is available
                      if (AuthService().isAuthenticated) ...[
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: AnimatedButton(
                              onPressed: _isCheckingVerification ? null : _checkVerification,
                              isLoading: _isCheckingVerification,
                              text: 'Check Verification',
                              loadingText: 'Checking...',
                              delay: 600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Resend Email Button
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: AnimatedOutlinedButton(
                            onPressed: (_isResendingEmail || _resendCooldown > 0) ? null : _resendVerificationEmail,
                            isLoading: _isResendingEmail,
                            text: _resendCooldown > 0 
                                ? 'Resend in ${_formatTime(_resendCooldown)}'
                                : 'Resend Verification Email',
                            loadingText: 'Sending...',
                            delay: widget.isFromLogin ? 600 : 800, // Adjust delay for login case
                          ),
                        ),
                      ),

                      // Back to Login Button - Only show for login case
                      if (widget.isFromLogin) ...[
                        const SizedBox(height: 20),
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: TextButton(
                              onPressed: () => context.go('/auth'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white70,
                                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                              ),
                              child: const Text(
                                'Back to Login',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom animated button widget
class AnimatedButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String text;
  final String loadingText;
  final int delay;

  const AnimatedButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
    required this.text,
    required this.loadingText,
    required this.delay,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 9, 121, 232),
                  Color.fromARGB(255, 26, 175, 255),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 26, 175, 255)
                      .withValues(alpha: 0.3),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: widget.onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 55),
              ),
              child: widget.isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          widget.loadingText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    )
                  : Text(
                      widget.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}

// Custom animated outlined button widget
class AnimatedOutlinedButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String text;
  final String loadingText;
  final int delay;

  const AnimatedOutlinedButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
    required this.text,
    required this.loadingText,
    required this.delay,
  });

  @override
  State<AnimatedOutlinedButton> createState() => _AnimatedOutlinedButtonState();
}

class _AnimatedOutlinedButtonState extends State<AnimatedOutlinedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: OutlinedButton(
            onPressed: widget.onPressed,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(
                color: Color.fromARGB(255, 26, 175, 255),
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(double.infinity, 55),
            ),
            child: widget.isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Color.fromARGB(255, 26, 175, 255),
                          strokeWidth: 2,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        widget.loadingText,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 26, 175, 255),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  )
                : Text(
                    widget.text,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 26, 175, 255),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
          ),
        );
      },
    );
  }
}

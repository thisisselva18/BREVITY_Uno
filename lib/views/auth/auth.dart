import 'package:flutter/material.dart';
import 'package:newsai/views/auth/signup.dart';
import 'package:newsai/views/auth/login.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> {
  late PageController _pageController;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pages = [
      LoginScreen(goToSignupPage: goToSignupPage),
      SignupScreen(goToLoginPage: goToLoginPage),
    ];
  }

  void goToLoginPage() {
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuad,
    );
  }

  void goToSignupPage() {
    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuad,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
    );
  }
}
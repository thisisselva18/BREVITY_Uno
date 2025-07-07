import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';
import 'package:brevity/controller/cubit/theme/theme_cubit.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController, _slideController, _pulseController, _scaleController;
  late Animation<double> _fadeAnimation, _pulseAnimation, _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: Duration(milliseconds: 1000));
    _slideController = AnimationController(vsync: this, duration: Duration(milliseconds: 800));
    _pulseController = AnimationController(vsync: this, duration: Duration(milliseconds: 2000))..repeat(reverse: true);
    _scaleController = AnimationController(vsync: this, duration: Duration(milliseconds: 1200));
    
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.5), end: Offset.zero).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut));

    _fadeController.forward();
    _slideController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Widget _buildGlassContainer({
    required Widget child,
    required Color primaryColor,
    double? opacity,
    List<BoxShadow>? shadows,
    EdgeInsets? margin,
    EdgeInsets? padding,
    BorderRadius? borderRadius,
  }) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(opacity ?? 0.08),
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
        boxShadow: shadows ?? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), child: child),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(padding: EdgeInsets.all(10), child: Icon(icon, color: color, size: 18)),
        ),
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Unity News App - Contact&body=Hello Unity Team,\n\n',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.read<ThemeCubit>().currentTheme;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              theme.primaryColor.withOpacity(0.12),
              Colors.black,
              theme.primaryColor.withOpacity(0.05),
              Colors.black.withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _buildAppBar(theme),
                Gap(20),
                _buildHeroSection(theme),
                Gap(30),
                _buildTeamSection(theme),
                Gap(30),
                _buildAppInfoSection(theme),
                Gap(30),
                _buildFooter(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(theme) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: _buildGlassContainer(
        primaryColor: theme.primaryColor,
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            _buildIconButton(Icons.arrow_back_ios_new, theme.primaryColor, () => Navigator.pop(context)),
            Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [Colors.white, theme.primaryColor],
                    ).createShader(bounds),
                    child: Text(
                      'Contact Unity',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    'Get in touch with our team',
                    style: TextStyle(
                      color: theme.primaryColor.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(theme) {
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: _buildGlassContainer(
          primaryColor: theme.primaryColor,
          padding: EdgeInsets.all(24),
          shadows: [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.2),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
          child: Column(
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: theme.primaryColor.withOpacity(0.4),
                        blurRadius: 15,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(Icons.groups_rounded, color: Colors.white, size: 40),
                ),
                builder: (context, child) => Transform.scale(
                  scale: _pulseAnimation.value,
                  child: child,
                ),
              ),
              Gap(20),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [Colors.white, theme.primaryColor],
                ).createShader(bounds),
                child: Text(
                  'Unity',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              Gap(8),
              Text(
                'Revolutionizing News with AI',
                style: TextStyle(
                  color: theme.primaryColor.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Gap(16),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: theme.primaryColor.withOpacity(0.3), width: 1),
                ),
                child: Text(
                  'We\'re here to help you stay informed!',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamSection(theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Meet Our Team', theme),
        Gap(16),
        _buildTeamMember(
          name: 'Yash',
          role: 'Lead Developer',
          email: 'yashmalihan3@gmail.com',
          phone: '+91 8882462047',
          icon: Icons.code_rounded,
          theme: theme,
          delay: 0,
        ),
        Gap(16),
        _buildTeamMember(
          name: 'Samarth Sharma',
          role: 'Co-Developer',
          email: 'saysamarth26@gmail.com',
          phone: '+91 8800894252',
          icon: Icons.developer_mode_rounded,
          theme: theme,
          delay: 200,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, theme) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [Colors.white, theme.primaryColor],
          ).createShader(bounds),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeamMember({
    required String name,
    required String role,
    required String email,
    required String phone,
    required IconData icon,
    required theme,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 800 + delay),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: _buildGlassContainer(
              primaryColor: theme.primaryColor,
              padding: EdgeInsets.all(20),
              shadows: [
                BoxShadow(
                  color: theme.primaryColor.withOpacity(0.15),
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: theme.primaryColor.withOpacity(0.3),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Icon(icon, color: Colors.white, size: 24),
                      ),
                      Gap(16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Gap(2),
                            Text(
                              role,
                              style: TextStyle(
                                color: theme.primaryColor.withOpacity(0.8),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Gap(20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildContactButton(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          onTap: () => _launchEmail(email),
                          theme: theme,
                        ),
                      ),
                      Gap(12),
                      Expanded(
                        child: _buildContactButton(
                          icon: Icons.phone_outlined,
                          label: 'Call',
                          onTap: () => _launchPhone(phone),
                          theme: theme,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required theme,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: theme.primaryColor.withOpacity(0.3), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: theme.primaryColor, size: 18),
                Gap(8),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppInfoSection(theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('About Unity News', theme),
        Gap(16),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 1000),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 30 * (1 - value)),
                child: _buildGlassContainer(
                  primaryColor: theme.primaryColor,
                  padding: EdgeInsets.all(24),
                  shadows: [
                    BoxShadow(
                      color: theme.primaryColor.withOpacity(0.15),
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ],
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: theme.primaryColor.withOpacity(0.4), width: 1),
                        ),
                        child: Icon(Icons.auto_awesome, color: theme.primaryColor, size: 28),
                      ),
                      Gap(16),
                      Text(
                        'AI-Powered News Experience',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Gap(12),
                      Text(
                        'Unity brings you the latest news with an intelligent chatbot that helps you understand, discuss, and analyze articles in real-time. Our AI assistant is powered by advanced technology to provide you with insightful conversations about current events.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Gap(20),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: theme.primaryColor.withOpacity(0.3), width: 1),
                        ),
                        child: Text(
                          '🤖 Chat • 📰 Read • 🧠 Learn',
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFooter(theme) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 1200),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: _buildGlassContainer(
            primaryColor: theme.primaryColor,
            padding: EdgeInsets.all(20),
            opacity: 0.05,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: theme.primaryColor.withOpacity(0.4), width: 1),
                  ),
                  child: Icon(Icons.info_outline, color: theme.primaryColor, size: 20),
                ),
                Gap(12),
                Text(
                  'Unity is an unregistered entity created solely for app publication compliance.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                Gap(8),
                Text(
                  'Thank you for using Unity News! 🚀',
                  style: TextStyle(
                    color: theme.primaryColor.withOpacity(0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'dart:ui';
import 'package:brevity/controller/cubit/theme/theme_cubit.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Widget _buildGlassContainer({
    required Widget child,
    required Color primaryColor,
    double? opacity,
    EdgeInsets? margin,
    EdgeInsets? padding,
    BorderRadius? borderRadius,
  }) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((opacity ?? 0.08 * 255).toInt()),
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha((0.12 * 255).toInt()), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.08 * 255).toInt()),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: child,
        ),
      ),
    );
  }

  void _copyToClipboard(String text, String type) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$type copied to clipboard'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.green.withAlpha((0.8 * 255).toInt()),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.read<ThemeCubit>().currentTheme;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.primaryColor.withAlpha((0.08 * 255).toInt()),
              Colors.black,
              Colors.black.withAlpha((0.95 * 255).toInt()),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _buildAppBar(theme),
                Gap(24),
                _buildContactSection(theme),
                Gap(20),
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
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(minWidth: 32, minHeight: 32),
            ),
            Gap(8),
            Text(
              'Contact Us',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection(theme) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: _buildGlassContainer(
        primaryColor: theme.primaryColor,
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withAlpha((0.2 * 255).toInt()),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.support_agent_rounded,
                    color: theme.primaryColor,
                    size: 20,
                  ),
                ),
                Gap(12),
                Text(
                  'Get in Touch',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Gap(16),
            Text(
              'For support, feedback, or questions about the app, reach out to our development team.',
              style: TextStyle(
                color: Colors.white.withAlpha((0.7 * 255).toInt()),
                fontSize: 14,
                height: 1.4,
              ),
            ),
            Gap(24),
            _buildContactCard(
              name: 'Samarth Sharma',
              role: 'Co-Developer',
              email: 'saysamarth26@gmail.com',
              phone: '+91 8800894252',
              theme: theme,
            ),
            Gap(16),
            _buildContactCard(
              name: 'Yash',
              role: 'Co-Developer',
              email: 'yashmalihan3@gmail.com',
              phone: '+91 8882462047',
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required String name,
    required String role,
    required String email,
    required String phone,
    required theme,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.04 * 255).toInt()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha((0.08 * 255).toInt()), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: theme.primaryColor.withAlpha((0.2 * 255).toInt()),
                child: Text(
                  name.split(' ').map((n) => n[0]).take(2).join(),
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      role,
                      style: TextStyle(
                        color: theme.primaryColor.withAlpha((0.8 * 255).toInt()),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Gap(16),
          _buildContactItem(
            icon: Icons.email_outlined,
            label: 'Email',
            value: email,
            onTap: () => _copyToClipboard(email, 'Email'),
            theme: theme,
          ),
          Gap(8),
          _buildContactItem(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: phone,
            onTap: () => _copyToClipboard(phone, 'Phone number'),
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
    required theme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, color: theme.primaryColor.withAlpha((0.7 * 255).toInt()), size: 16),
            Gap(8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withAlpha((0.7 * 255).toInt()),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            Gap(8),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.copy,
              color: theme.primaryColor.withAlpha((0.5 * 255).toInt()),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(theme) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: _buildGlassContainer(
        primaryColor: theme.primaryColor,
        padding: EdgeInsets.all(16),
        opacity: 0.04,
        child: Row(
          children: [
            Icon(
              Icons.schedule_outlined,
              color: theme.primaryColor.withAlpha((0.7 * 255).toInt()),
              size: 16,
            ),
            Gap(8),
            Expanded(
              child: Text(
                'We typically respond within 1-2 business days',
                style: TextStyle(
                  color: Colors.white.withAlpha((0.7 * 255).toInt()),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';
import 'package:brevity/controller/cubit/theme/theme_cubit.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen>
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
        color: Colors.white.withAlpha(((opacity ?? 0.08) * 255).toInt()),
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withAlpha(((0.12) * 255).toInt()),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(((0.08) * 255).toInt()),
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

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
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
                _buildAppInfoSection(theme),
                Gap(20),
                _buildFeaturesSection(theme),
                Gap(20),
                _buildDeveloperSection(theme),
                Gap(20),
                _buildVersionSection(theme),
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
              'About Unity',
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

  Widget _buildAppInfoSection(theme) {
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
                    Icons.newspaper_rounded,
                    color: theme.primaryColor,
                    size: 20,
                  ),
                ),
                Gap(12),
                Text(
                  'Unity News',
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
              'AI-Powered News Platform',
              style: TextStyle(
                color: theme.primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Gap(12),
            Text(
              'Stay informed with curated news from reliable sources. Our intelligent chatbot helps you understand and discuss articles in real-time.',
              style: TextStyle(
                color: Colors.white.withAlpha((0.7 * 255).toInt()),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesSection(theme) {
    final features = [
      {
        'icon': Icons.auto_awesome,
        'title': 'AI Chat Assistant',
        'description': 'Discuss articles with our intelligent chatbot',
      },
      {
        'icon': Icons.article_outlined,
        'title': 'Curated Content',
        'description': 'News from reliable sources',
      },
      {
        'icon': Icons.speed,
        'title': 'Real-time Updates',
        'description': 'Stay updated with the latest news',
      },
    ];

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
                    Icons.star_rounded,
                    color: theme.primaryColor,
                    size: 20,
                  ),
                ),
                Gap(12),
                Text(
                  'Features',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Gap(16),
            ...features.map((feature) => _buildFeatureItem(theme, feature)),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(theme, Map<String, dynamic> feature) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.04 * 255).toInt()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withAlpha((0.08 * 255).toInt()),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.primaryColor.withAlpha((0.2 * 255).toInt()),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(feature['icon'], color: theme.primaryColor, size: 16),
          ),
          Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature['title'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Gap(2),
                Text(
                  feature['description'],
                  style: TextStyle(
                    color: Colors.white.withAlpha((0.7 * 255).toInt()),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperSection(theme) {
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
                  child: Icon(Icons.code, color: theme.primaryColor, size: 20),
                ),
                Gap(12),
                Text(
                  'Developers',
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
              'Meet the talented developers behind Unity News.',
              style: TextStyle(
                color: Colors.white.withAlpha((0.7 * 255).toInt()),
                fontSize: 14,
                height: 1.4,
              ),
            ),
            Gap(24),
            _buildDeveloperCard(
              name: 'Samarth Sharma',
              role: 'Co-Developer',
              portfolioUrl: 'https://saysamarth.netlify.app/',
              linkedinUrl: 'https://www.linkedin.com/in/saysamarth/',
              theme: theme,
            ),
            Gap(16),
            _buildDeveloperCard(
              name: 'Yash',
              role: 'Co-Developer',
              portfolioUrl: 'https://portfolio-yash-914981.netlify.app/',
              linkedinUrl: 'https://www.linkedin.com/in/yash-kumar101/',
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeveloperCard({
    required String name,
    required String role,
    required String portfolioUrl,
    required String linkedinUrl,
    required theme,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.04 * 255).toInt()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withAlpha((0.08 * 255).toInt()),
          width: 1,
        ),
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
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _launchUrl(portfolioUrl),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withAlpha((0.1 * 255).toInt()),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.primaryColor.withAlpha((0.3 * 255).toInt()),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.web, color: theme.primaryColor, size: 16),
                        Gap(6),
                        Text(
                          'Portfolio',
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Gap(8),
              Expanded(
                child: InkWell(
                  onTap: () => _launchUrl(linkedinUrl),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(((0.04) * 255).toInt()),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withAlpha(((0.12) * 255).toInt()),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.business,
                          color: Colors.white.withAlpha(((0.8) * 255).toInt()),
                          size: 16,
                        ),
                        Gap(6),
                        Text(
                          'LinkedIn',
                          style: TextStyle(
                            color: Colors.white.withAlpha(
                              ((0.8) * 255).toInt(),
                            ),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVersionSection(theme) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: _buildGlassContainer(
        primaryColor: theme.primaryColor,
        padding: EdgeInsets.all(16),
        opacity: 0.04,
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: theme.primaryColor.withAlpha((0.7 * 255).toInt()),
              size: 16,
            ),
            Gap(8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Version 1.0.0 • Built with Flutter',
                    style: TextStyle(
                      color: Colors.white.withAlpha(((0.8) * 255).toInt()),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Gap(2),
                  Text(
                    'Unity is created for news consumption and educational purposes.',
                    style: TextStyle(
                      color: Colors.white.withAlpha(((0.6) * 255).toInt()),
                      fontSize: 11,
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
}

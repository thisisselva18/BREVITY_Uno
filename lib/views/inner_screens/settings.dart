import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:newsai/controller/services/auth_service.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:ui';
import 'package:newsai/views/common_widgets/common_appbar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = true;
  String _selectedLanguage = 'English';
  Color _selectedThemeColor = Colors.blue;
  late AnimationController _animationController;
  late Animation<double> _animation;
  late AnimationController _particleAnimationController;

  final List<Color> _themeColors = [
    Colors.blue,
    Colors.purple,
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    _particleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(); // Makes it run forever

    // Add listener to force repaints for animation
    _particleAnimationController.addListener(() {
      setState(() {
        // Empty setState to trigger rebuild
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _particleAnimationController.dispose();
    super.dispose();
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder:
          (context) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _selectedThemeColor.withAlpha(50),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 5,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Select Language',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.4,
                      ),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildLanguageOption('English'),
                            _buildLanguageOption('Spanish'),
                            _buildLanguageOption('French'),
                            _buildLanguageOption('German'),
                            _buildLanguageOption('Hindi'),
                            _buildLanguageOption('Chinese'),
                            _buildLanguageOption('Japanese'),
                            _buildLanguageOption('Russian'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildLanguageOption(String language) {
    final isSelected = _selectedLanguage == language;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        color:
            isSelected ? _selectedThemeColor.withAlpha(50) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          language,
          style: TextStyle(
            color: isSelected ? _selectedThemeColor : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing:
            isSelected
                ? Icon(Icons.check_circle, color: _selectedThemeColor)
                : null,
        onTap: () {
          setState(() => _selectedLanguage = language);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showThemeColorPicker() {
    showDialog(
      context: context,
      builder:
          (context) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _selectedThemeColor.withAlpha(50),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Select Theme Color',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 15,
                      runSpacing: 15,
                      alignment: WrapAlignment.center,
                      children:
                          _themeColors.map((color) {
                            final isSelected = _selectedThemeColor == color;
                            return GestureDetector(
                              onTap: () {
                                setState(() => _selectedThemeColor = color);
                                Navigator.pop(context);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : Colors.transparent,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.withAlpha(100),
                                      blurRadius: isSelected ? 12 : 5,
                                      spreadRadius: isSelected ? 2 : 0,
                                    ),
                                  ],
                                ),
                                child:
                                    isSelected
                                        ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                        )
                                        : null,
                              ),
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Close',
                        style: TextStyle(
                          color: _selectedThemeColor,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  void _confirmDeleteProfile() {
    showDialog(
      context: context,
      builder:
          (context) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withAlpha(50),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Color.fromARGB(255, 198, 48, 37),
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Delete Profile',
                      style: TextStyle(
                        color: Color.fromARGB(255, 198, 48, 37),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Are you sure you want to delete your profile? This action cannot be undone.',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[800],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Implement delete profile logic
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 198, 48, 37),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: const Color.fromARGB(210, 0, 0, 0),
            expandedHeight: 220,
            pinned: true,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              color: Colors.white70,
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: ParticlesHeader(
                title: "",
                themeColor: _selectedThemeColor,
                particleAnimation: _particleAnimationController,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [_selectedThemeColor, Colors.purpleAccent],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _selectedThemeColor.withAlpha(125),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        backgroundImage: NetworkImage(
                          'https://a0.anyrgb.com/pngimg/1140/162/user-profile-login-avatar-heroes-user-blue-icons-circle-symbol-logo-thumbnail.png',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'John Doe',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(color: Colors.black45, blurRadius: 5)],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'john.doe@example.com',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        shadows: const [
                          Shadow(color: Colors.black45, blurRadius: 5),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              FadeTransition(
                opacity: _animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(_animation),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 0, 8),
                          child: const Text(
                            'Settings',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              letterSpacing: 1.2,
                              color: Color.fromARGB(255, 223, 223, 223),
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                            ),
                          ),
                        ),
                      ),
                      _buildSectionHeader('Appearance'),
                      _buildAnimatedCard(
                        child: _buildSwitchTile(
                          icon: Icons.dark_mode,
                          title: 'Dark Mode',
                          value: _darkModeEnabled,
                          onChanged:
                              (val) => setState(() => _darkModeEnabled = val),
                        ),
                      ),
                      _buildAnimatedCard(
                        child: _buildListTile(
                          icon: Icons.color_lens,
                          title: 'App Theme',
                          subtitle: 'Change app accent color',
                          trailingWidget: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: _selectedThemeColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _selectedThemeColor.withOpacity(0.4),
                                  blurRadius: 5,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          onTap: _showThemeColorPicker,
                        ),
                      ),
                      _buildSectionHeader('Preferences'),
                      _buildAnimatedCard(
                        child: _buildSwitchTile(
                          icon: Icons.notifications_active,
                          title: 'Push Notifications',
                          value: _notificationsEnabled,
                          onChanged:
                              (val) =>
                                  setState(() => _notificationsEnabled = val),
                        ),
                      ),
                      _buildAnimatedCard(
                        child: _buildListTile(
                          icon: Icons.language,
                          title: 'Language',
                          subtitle: _selectedLanguage,
                          onTap: _showLanguageDialog,
                        ),
                      ),
                      _buildSectionHeader('App'),
                      _buildAnimatedCard(
                        child: _buildListTile(
                          icon: Icons.share,
                          title: 'Share App',
                          subtitle: 'Tell your friends about us',
                          onTap:
                              () => Share.share(
                                'Check out this awesome news app!',
                              ),
                        ),
                      ),
                      _buildAnimatedCard(
                        child: _buildListTile(
                          icon: Icons.star_rate,
                          title: 'Rate App',
                          subtitle: 'Leave feedback on the store',
                          onTap: () {
                            // Implement app rating logic
                          },
                        ),
                      ),
                      _buildSectionHeader('Account'),
                      _buildAnimatedCard(
                        child: _buildListTile(
                          icon: Icons.logout,
                          titleColor: _selectedThemeColor,
                          title: 'Log Out',
                          subtitle: 'See you again soon',
                          onTap: () {
                            // Implement logout logic
                            AuthService().signOut().then((value) {
                              context.go('/slpash');
                            },);
                          },
                        ),
                      ),
                      _buildAnimatedCard(
                        color: Colors.red.withOpacity(0.05),
                        child: _buildListTile(
                          icon: Icons.delete_forever,
                          iconColor: Colors.red,
                          title: 'Delete Profile',
                          titleColor: Colors.red,
                          subtitle: 'Permanently erase your data',
                          onTap: _confirmDeleteProfile,
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedCard({required Widget child, Color? color}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color ?? Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Row(
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: _selectedThemeColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _selectedThemeColor.withAlpha(125),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile.adaptive(
      secondary: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _selectedThemeColor.withAlpha(25),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: _selectedThemeColor, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      value: value,
      activeColor: _selectedThemeColor,
      activeTrackColor: _selectedThemeColor.withOpacity(0.3),
      inactiveTrackColor: Colors.grey[800],
      inactiveThumbColor: Colors.grey[400],
      onChanged: onChanged,
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? titleColor,
    Color? iconColor,
    Widget? trailingWidget,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: (iconColor ?? _selectedThemeColor).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor ?? _selectedThemeColor, size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      subtitle:
          subtitle != null
              ? Text(
                subtitle,
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              )
              : null,
      trailing:
          trailingWidget ??
          Icon(Icons.arrow_forward_ios, color: Colors.grey[600], size: 16),
      onTap: onTap,
    );
  }
}

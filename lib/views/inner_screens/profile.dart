import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsai/controller/cubit/theme/theme_cubit.dart';
import 'package:newsai/controller/cubit/user_profile/user_profile_cubit.dart';
import 'package:newsai/controller/cubit/user_profile/user_profile_state.dart';
import 'package:newsai/views/common_widgets/common_appbar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _particleAnimationController;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _particleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    context.read<UserProfileCubit>().loadUserProfile();
  }

  @override
  void dispose() {
    _particleAnimationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final userProfileCubit = context.read<UserProfileCubit>();
    userProfileCubit
        .updateProfile(displayName: _nameController.text)
        .then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
        })
        .catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating profile: $error')),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    // Access current theme from ThemeCubit for dynamic theming
    final currentTheme = context.read<ThemeCubit>().currentTheme;

    return BlocConsumer<UserProfileCubit, UserProfileState>(
      listener: (context, state) {
        if (state.status == UserProfileStatus.loaded && state.user != null) {
          _nameController.text = state.user!.displayName;
          _emailController.text = state.user!.email;
        }
      },
      builder: (context, state) {
        if (state.status == UserProfileStatus.loading) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                // Apply theme's primary color to loading indicator
                color: currentTheme.primaryColor,
              ),
            ),
          );
        }

        if (state.status == UserProfileStatus.error) {
          return Scaffold(
            body: Center(child: Text('Error: ${state.errorMessage}')),
          );
        }

        final user = state.user;
        return AppScaffold(
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                backgroundColor: const Color.fromARGB(210, 0, 0, 0),
                expandedHeight: 90,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: ParticlesHeader(
                    title: "Profile Settings",
                    // Apply theme's primary color to particle header
                    themeColor: currentTheme.primaryColor,
                    particleAnimation: _particleAnimationController,
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  color: Colors.white70,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              // Apply theme color to avatar background with opacity
                              backgroundColor: currentTheme.primaryColor
                                  .withAlpha(80),
                              child: Text(
                                user?.displayName.isNotEmpty == true
                                    ? user!.displayName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                // Apply theme's primary color to edit button
                                color: currentTheme.primaryColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.edit,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        _buildProfileField(
                          icon: Icons.person,
                          label: 'Full Name',
                          controller: _nameController,
                          currentTheme:
                              currentTheme, // Pass theme to field builder
                        ),
                        const SizedBox(height: 20),
                        _buildProfileField(
                          icon: Icons.email,
                          label: 'Email Address',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          enabled: false,
                          currentTheme:
                              currentTheme, // Pass theme to field builder
                        ),
                        const SizedBox(height: 30),

                        _buildProfileOption(
                          icon: Icons.verified_user,
                          title: 'Email Verified',
                          subtitle: user?.emailVerified == true ? 'Yes' : 'No',
                          onTap: () {},
                          currentTheme:
                              currentTheme, // Pass theme to option builder
                        ),
                        _buildProfileOption(
                          icon: Icons.calendar_today,
                          title: 'Account Created',
                          subtitle:
                              user?.createdAt != null
                                  ? '${user!.createdAt!.day}/${user.createdAt!.month}/${user.createdAt!.year}'
                                  : 'Unknown',
                          onTap: () {},
                          currentTheme:
                              currentTheme, // Pass theme to option builder
                        ),
                        _buildProfileOption(
                          icon: Icons.update,
                          title: 'Last Updated',
                          subtitle:
                              user?.updatedAt != null
                                  ? '${user!.updatedAt!.day}/${user.updatedAt!.month}/${user.updatedAt!.year}'
                                  : 'Never',
                          onTap: () {},
                          currentTheme:
                              currentTheme, // Pass theme to option builder
                        ),
                        const SizedBox(height: 40),

                        ElevatedButton(
                          onPressed: _saveProfile,
                          style: ElevatedButton.styleFrom(
                            // Apply theme's primary color to save button
                            backgroundColor: currentTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ],
          ),
        );
      },
    );
  }

  // Updated profile field builder with theme parameter
  Widget _buildProfileField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    required currentTheme, // Add theme parameter for dynamic styling
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E222A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        enabled: enabled,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          // Apply theme's primary color to prefix icon
          prefixIcon: Icon(icon, color: currentTheme.primaryColor),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  // Updated profile option builder with theme parameter
  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required currentTheme, // Add theme parameter for dynamic styling
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF1E222A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        // Apply theme's primary color to leading icon
        leading: Icon(icon, color: currentTheme.primaryColor),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          // Apply theme's primary color to trailing arrow
          color: currentTheme.primaryColor,
        ),
        onTap: onTap,
      ),
    );
  }
}

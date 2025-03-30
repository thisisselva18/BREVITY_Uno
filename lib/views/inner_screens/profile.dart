import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    
    // Initialize animation controller
    _particleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    
    // Load user profile on init
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
    // Update profile using the cubit
    final userProfileCubit = context.read<UserProfileCubit>();
    userProfileCubit.updateProfile(
      displayName: _nameController.text,
    ).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserProfileCubit, UserProfileState>(
      listener: (context, state) {
        // Update text controllers when user data is loaded
        if (state.status == UserProfileStatus.loaded && state.user != null) {
          _nameController.text = state.user!.displayName;
          _emailController.text = state.user!.email;
        }
      },
      builder: (context, state) {
        // Show loading indicator while data is loading
        if (state.status == UserProfileStatus.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        // Show error if loading failed
        if (state.status == UserProfileStatus.error) {
          return Scaffold(
            body: Center(child: Text('Error: ${state.errorMessage}')),
          );
        }
        
        // Build UI with loaded data
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
                    themeColor: Colors.blue,
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
                              backgroundColor: Colors.blue.withAlpha(80),
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
                                color: Colors.blue,
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
                        ),
                        const SizedBox(height: 20),
                        _buildProfileField(
                          icon: Icons.email,
                          label: 'Email Address',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          enabled: false, // Email should not be editable
                        ),
                        const SizedBox(height: 30),

                        // Account Information
                        _buildProfileOption(
                          icon: Icons.verified_user,
                          title: 'Email Verified',
                          subtitle: user?.emailVerified == true ? 'Yes' : 'No',
                          onTap: () {}, 
                        ),
                        _buildProfileOption(
                          icon: Icons.calendar_today,
                          title: 'Account Created',
                          subtitle: user?.createdAt != null
                              ? '${user!.createdAt!.day}/${user.createdAt!.month}/${user.createdAt!.year}'
                              : 'Unknown',
                          onTap: () {},
                        ),
                        _buildProfileOption(
                          icon: Icons.update,
                          title: 'Last Updated',
                          subtitle: user?.updatedAt != null
                              ? '${user!.updatedAt!.day}/${user.updatedAt!.month}/${user.updatedAt!.year}'
                              : 'Never',
                          onTap: () {},
                        ),
                        const SizedBox(height: 40),

                        // Save Button
                        ElevatedButton(
                          onPressed: _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
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

  Widget _buildProfileField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
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
          prefixIcon: Icon(icon, color: Colors.blue),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF1E222A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.blue,
        ),
        onTap: onTap,
      ),
    );
  }
}
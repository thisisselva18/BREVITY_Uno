import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:brevity/controller/cubit/theme/theme_cubit.dart';
import 'package:lottie/lottie.dart';
import '../../controller/cubit/theme/theme_state.dart';
import '../../models/theme_model.dart';

class EndOfNewsScreen extends StatelessWidget {
  final String? customMessage;
  final VoidCallback? onRefresh;

  const EndOfNewsScreen({
    super.key,
    this.customMessage,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final currentTheme = themeState.currentTheme;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                currentTheme.primaryColor.withAlpha(15),
                const Color.fromARGB(255, 28, 28, 28),
                currentTheme.primaryColor.withAlpha(8),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Main Icon Container
                  _buildIconContainer(currentTheme),
                  const Gap(40),

                  // Primary Message
                  _buildPrimaryMessage(customMessage),
                  const Gap(20),

                  // Secondary Message
                  _buildSecondaryMessage(),
                  const Gap(48),

                  // Optional Refresh Button (only shown if callback provided)
                  if (onRefresh != null) _buildRefreshButton(currentTheme),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIconContainer(AppTheme currentTheme) {
    return Container(
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(25),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: currentTheme.primaryColor.withAlpha(80),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: currentTheme.primaryColor.withAlpha(40),
            blurRadius: 30,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: Colors.white.withAlpha(15),
            blurRadius: 50,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(30),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Lottie.asset(
          'assets/lottie/coffee_break.json',
          width: 120,
          height: 120,
          fit: BoxFit.contain,
          repeat: true,
        ),
      ),
    );
  }

  Widget _buildPrimaryMessage(String? customMessage) {
    return Text(
      customMessage ?? "You're done for the day",
      style: const TextStyle(
        color: Colors.white,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        fontFamily: 'Poppins',
        letterSpacing: -0.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSecondaryMessage() {
    return Column(
      children: [
        Text(
          'Take a break and enjoy your coffee',
          style: TextStyle(
            color: Colors.white.withAlpha(179),
            fontSize: 18,
            height: 1.4,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
        const Gap(8),
        Text(
          'Fresh news will be available soon',
          style: TextStyle(
            color: Colors.white.withAlpha(128),
            fontSize: 15,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRefreshButton(AppTheme currentTheme) {
    return GestureDetector(
      onTap: onRefresh,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: currentTheme.primaryColor.withAlpha(51),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: currentTheme.primaryColor.withAlpha(102),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: currentTheme.primaryColor.withAlpha(15),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.refresh_rounded,
              color: currentTheme.primaryColor,
              size: 22,
            ),
            const Gap(12),
            Text(
              'Check for updates',
              style: TextStyle(
                color: currentTheme.primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Alternative variant with newspaper icon
class EndOfNewsScreenNewspaper extends StatelessWidget {
  final String? customMessage;
  final VoidCallback? onRefresh;

  const EndOfNewsScreenNewspaper({
    super.key,
    this.customMessage,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final currentTheme = themeState.currentTheme;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                currentTheme.primaryColor.withAlpha(15),
                const Color.fromARGB(255, 28, 28, 28),
                currentTheme.primaryColor.withAlpha(8),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Newspaper Icon Container
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(10),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: Colors.white.withAlpha(20),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: currentTheme.primaryColor.withAlpha(25),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.newspaper_outlined,
                      size: 72,
                      color: currentTheme.primaryColor,
                    ),
                  ),
                  const Gap(40),

                  // Primary Message
                  Text(
                    customMessage ?? "No more news available",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(20),

                  // Secondary Message
                  Column(
                    children: [
                      Text(
                        'You\'ve caught up with all the latest stories',
                        style: TextStyle(
                          color: Colors.white.withAlpha(179),
                          fontSize: 18,
                          height: 1.4,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Gap(8),
                      Text(
                        'Check back later for more updates',
                        style: TextStyle(
                          color: Colors.white.withAlpha(128),
                          fontSize: 15,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const Gap(48),

                  // Optional Refresh Button
                  if (onRefresh != null)
                    GestureDetector(
                      onTap: onRefresh,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: currentTheme.primaryColor.withAlpha(51),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: currentTheme.primaryColor.withAlpha(102),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: currentTheme.primaryColor.withAlpha(15),
                              blurRadius: 8,
                              spreadRadius: 1,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.refresh_rounded,
                              color: currentTheme.primaryColor,
                              size: 22,
                            ),
                            const Gap(12),
                            Text(
                              'Refresh feed',
                              style: TextStyle(
                                color: currentTheme.primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Checkmark variant for completion feeling
class EndOfNewsScreenComplete extends StatelessWidget {
  final String? customMessage;
  final VoidCallback? onRefresh;

  const EndOfNewsScreenComplete({
    super.key,
    this.customMessage,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final currentTheme = themeState.currentTheme;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                currentTheme.primaryColor.withAlpha(15),
                const Color.fromARGB(255, 28, 28, 28),
                currentTheme.primaryColor.withAlpha(8),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Checkmark Icon Container
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(10),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: Colors.white.withAlpha(20),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: currentTheme.primaryColor.withAlpha(25),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.check_circle_outline,
                      size: 72,
                      color: currentTheme.primaryColor,
                    ),
                  ),
                  const Gap(40),

                  // Primary Message
                  Text(
                    customMessage ?? "You're all caught up!",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Gap(20),

                  // Secondary Message
                  Column(
                    children: [
                      Text(
                        'Great job staying informed',
                        style: TextStyle(
                          color: Colors.white.withAlpha(179),
                          fontSize: 18,
                          height: 1.4,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Gap(8),
                      Text(
                        'Come back later for fresh stories',
                        style: TextStyle(
                          color: Colors.white.withAlpha(128),
                          fontSize: 15,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  const Gap(48),

                  // Optional Refresh Button
                  if (onRefresh != null)
                    GestureDetector(
                      onTap: onRefresh,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: currentTheme.primaryColor.withAlpha(51),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: currentTheme.primaryColor.withAlpha(102),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: currentTheme.primaryColor.withAlpha(15),
                              blurRadius: 8,
                              spreadRadius: 1,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.refresh_rounded,
                              color: currentTheme.primaryColor,
                              size: 22,
                            ),
                            const Gap(12),
                            Text(
                              'Look for new stories',
                              style: TextStyle(
                                color: currentTheme.primaryColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

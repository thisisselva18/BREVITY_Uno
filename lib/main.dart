import 'package:brevity/views/inner_screens/about_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:brevity/controller/cubit/theme/theme_cubit.dart';
import 'package:brevity/models/article_model.dart';
import 'package:brevity/models/news_category.dart';
import 'package:brevity/views/auth/auth.dart';
import 'package:brevity/views/auth/email_verification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:brevity/firebase_options.dart';
import 'package:brevity/views/inner_screens/chat_screen.dart';
import 'package:brevity/views/inner_screens/profile.dart';
import 'package:brevity/views/inner_screens/search_result.dart';
import 'package:brevity/views/inner_screens/settings.dart';
import 'package:brevity/views/intro_screen/intro_screen.dart';
import 'package:brevity/views/inner_screens/bookmark.dart';
import 'package:brevity/views/nav_screen/home.dart';
import 'package:brevity/views/nav_screen/side_page.dart';
import 'package:brevity/views/splash_screen.dart';
import 'package:brevity/controller/services/bookmark_services.dart';
import 'package:brevity/controller/services/news_services.dart';
import 'package:brevity/controller/bloc/bookmark_bloc/bookmark_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:brevity/controller/cubit/user_profile/user_profile_cubit.dart';
import 'package:brevity/views/inner_screens/contact_screen.dart';
import 'package:brevity/controller/services/auth_service.dart';
import 'package:brevity/controller/bloc/news_scroll_bloc/news_scroll_bloc.dart';
import 'package:brevity/controller/cubit/theme/theme_state.dart';
import 'package:brevity/models/theme_model.dart';
// ADD THESE IMPORTS
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:brevity/controller/services/notification_service.dart';

// Create a router with auth state handling
final _routes = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) {
        return const SplashScreen();
      },
    ),
    GoRoute(
      path: '/auth',
      name: 'auth',
      builder: (context, state) {
        return const AuthScreen();
      },
    ),
    GoRoute(
      path: '/email-verification',
      name: 'email-verification',
      builder: (context, state) {
        final email = state.uri.queryParameters['email'] ?? '';
        final isFromLogin = state.uri.queryParameters['isFromLogin'] == 'true';
        return EmailVerificationScreen(
          email: email,
          isFromLogin: isFromLogin,
        );
      },
    ),
    GoRoute(
      path: '/contactUs',
      name: 'contactUs',
      builder: (context, state) {
        return const ContactUsScreen();
      },
    ),
    GoRoute(
      path: '/aboutUs',
      name: 'aboutUs',
      builder: (context, state) {
        return const AboutUsScreen();
      },
    ),
    GoRoute(
      path: '/intro',
      name: 'intro',
      builder: (context, state) {
        return const IntroductionScreen();
      },
    ),
    GoRoute(
      path: '/sidepage',
      name: 'sidepage',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: const SidePage(),
        transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
            ) {
          const begin = Offset(-1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          return SlideTransition(
            position: Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve)).animate(animation),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 225),
      ),
      routes: [
        GoRoute(
          path: '/bookmark',
          name: 'bookmark',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const BookmarkScreen(),
            transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
                ) {
              // Combine scale and fade animations
              return Align(
                alignment: Alignment.center,
                child: FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: animation.drive(
                      Tween<double>(
                        begin: 0.0,
                        end: 1.0,
                      ).chain(CurveTween(curve: Curves.easeInOutQuad)),
                    ),
                    child: child,
                  ),
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 225),
          ),
        ),
        GoRoute(
          path: 'settings', // CORRECTED: Removed leading '/'
          name: 'settings',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const SettingsScreen(),
            transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
                ) {
              return Align(
                alignment: Alignment.center,
                child: FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: animation.drive(
                      Tween<double>(
                        begin: 0.0,
                        end: 1.0,
                      ).chain(CurveTween(curve: Curves.easeInOutQuad)),
                    ),
                    child: child,
                  ),
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 225),
          ),
        ),
        GoRoute(
          path: 'profile', // CORRECTED: Removed leading '/'
          name: 'profile',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const ProfileScreen(),
            transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
                ) {
              return Align(
                alignment: Alignment.center,
                child: FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: animation.drive(
                      Tween<double>(
                        begin: 0.0,
                        end: 1.0,
                      ).chain(CurveTween(curve: Curves.easeInOutQuad)),
                    ),
                    child: child,
                  ),
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 225),
          ),
        ),
        GoRoute(
          path: 'searchResults', // CORRECTED: Removed leading '/'
          name: 'searchResults',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: SearchResultsScreen(
              query: state.uri.queryParameters['query']!, // Only query parameter
            ),
            transitionsBuilder: (
                context,
                animation,
                secondaryAnimation,
                child,
                ) {
              // Combine scale and fade animations
              return Align(
                alignment: Alignment.center,
                child: FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: animation.drive(
                      Tween<double>(
                        begin: 0.0,
                        end: 1.0,
                      ).chain(CurveTween(curve: Curves.easeInOutQuad)),
                    ),
                    child: child,
                  ),
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 225),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/home/:category',
      name: 'home',
      pageBuilder: (context, state) {
        final category = NewsCategory.fromIndex(
          int.parse(state.pathParameters['category'] ?? '0'),
        );
        return CustomTransitionPage(
          key: state.pageKey,
          child: HomeScreen(category: category),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            return SlideTransition(
              position: Tween(
                begin: begin,
                end: end,
              ).chain(CurveTween(curve: curve)).animate(animation),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 225),
        );
      },
    ),
    GoRoute(
      path: '/chat',
      name: 'chat',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: ChatScreen(article: state.extra as Article),
        transitionsBuilder: (
            context,
            animation,
            secondaryAnimation,
            child,
            ) {
          // Combine scale and fade animations
          return Align(
            alignment: Alignment.center,
            child: FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: animation.drive(
                  Tween<double>(
                    begin: 0.0,
                    end: 1.0,
                  ).chain(CurveTween(curve: Curves.easeInOutQuad)),
                ),
                child: child,
              ),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 225),
      ),
    ),
  ],
  // Add redirect logic to handle authentication state
  redirect: (context, state) {
    // Allow access to splash screen
    if (state.matchedLocation == '/splash') return null;

    // Check for routes that should be accessible without authentication
    final allowedPaths = ['/auth', '/intro', '/email-verification'];
    if (allowedPaths.contains(state.matchedLocation)) return null;

    // Get the AuthService instance
    final authService = AuthService();

    // If user is not signed in, redirect to auth
    if (!authService.isAuthenticated) {
      return '/auth';
    }

    // If user is authenticated but email is not verified, redirect to email verification
    if (authService.isAuthenticated && !authService.isEmailVerified) {
      final currentUser = authService.currentUser;
      if (currentUser != null) {
        return '/email-verification?email=${Uri.encodeComponent(currentUser.email)}&isFromLogin=true';
      }
    }

    // Allow access to authenticated routes
    return null;
  },
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // ADD THIS: Initialize timezone data
  tz.initializeTimeZones();

  // Initialize your AuthService
  await AuthService().initializeAuth();

  // ADD THIS: Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();

  await dotenv.load(fileName: ".env");

  final bookmarkRepository = BookmarkServices();
  final newsService = NewsService();

  await bookmarkRepository.initialize();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: newsService),
        RepositoryProvider.value(value: bookmarkRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => NewsBloc(newsService: newsService)),
          BlocProvider(create: (context) => BookmarkBloc(bookmarkRepository)),
          BlocProvider(create: (context) => UserProfileCubit()),
          BlocProvider(create: (context) => ThemeCubit()..initializeTheme()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    // UPDATED: Wrap with BlocBuilder to react to theme changes
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return MaterialApp.router(
          title: 'Brevity',
          debugShowCheckedModeBanner: false,
          routerConfig: _routes,
          // UPDATED: Apply the dynamic theme from the ThemeCubit state
          theme: createAppTheme(state.currentTheme),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:newsai/models/news_category.dart';
import 'package:newsai/views/auth/auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:newsai/firebase_options.dart';
import 'package:newsai/views/intro_screen/intro_screen.dart';
import 'package:newsai/views/nav_screen/home.dart';
import 'package:newsai/views/nav_screen/side_page.dart';
import 'package:newsai/views/splash_screen.dart';

final _routes = GoRouter(
  initialLocation: '/sidepage',
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
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          return SlideTransition(
            position: Tween(begin: begin, end: end)
                .chain(CurveTween(curve: curve))
                .animate(animation),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
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
            const begin = Offset(-1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            return SlideTransition(
              position: Tween(begin: begin, end: end)
                  .chain(CurveTween(curve: curve))
                  .animate(animation),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
      },
    ),
  ],
);
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'NewsAI',
      debugShowCheckedModeBanner: false,
      routerConfig: _routes,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:newsai/controller/bloc/news_scroll_bloc.dart';
import 'package:newsai/controller/bloc/news_scroll_event.dart';
import 'package:newsai/controller/services/news_services.dart';
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
      builder: (context, state) {
        return SidePage();
      },
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) {
        return HomeScreen();
      },
    ),
  ],
);
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Create NewsService instance
  final newsService = NewsService();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) =>
                  NewsBloc(newsService: newsService)..add(FetchInitialNews()),
        ),
      ],
      child: const MyApp(),
    ),
  );
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

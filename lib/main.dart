import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:newsai/models/news_category.dart';
import 'package:newsai/views/auth/auth.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:newsai/firebase_options.dart';
import 'package:newsai/views/inner_screens/search_result.dart';
import 'package:newsai/views/intro_screen/intro_screen.dart';
import 'package:newsai/views/inner_screens/bookmark.dart';
import 'package:newsai/views/nav_screen/home.dart';
import 'package:newsai/views/nav_screen/side_page.dart';
import 'package:newsai/views/splash_screen.dart';
import 'package:newsai/controller/services/bookmark_services.dart';
import 'package:newsai/controller/services/news_services.dart';
import 'package:newsai/controller/bloc/bookmark_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final _routes = GoRouter(
  initialLocation: '/sidepage', // Change initial route to home
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
      pageBuilder:
          (context, state) => CustomTransitionPage(
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
        // Nested route for bookmark inside sidepage
        GoRoute(
          path: 'bookmark',
          name: 'bookmark',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const BookmarkScreen(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
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
              ),
        ),
        GoRoute(
          path: '/searchResults',
          name: 'searchResults',
          builder: (context, state) {
            return SearchResultsScreen(
              query: state.uri.queryParameters['query']!,
            );
          },
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
      path: '/bookmark',
      name: 'bookmark',
      builder: (context, state) {
        return const BookmarkScreen();
      },
    ),
  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  final bookmarkRepository = BookmarkServices();
  final newsService = NewsService();
  await bookmarkRepository.initialize();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await dotenv.load(fileName: ".env");

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: newsService),
        RepositoryProvider.value(value: bookmarkRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => BookmarkBloc(bookmarkRepository)),
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
    return MaterialApp.router(
      title: 'Brevity',
      debugShowCheckedModeBanner: false,
      routerConfig: _routes,
    );
  }
}

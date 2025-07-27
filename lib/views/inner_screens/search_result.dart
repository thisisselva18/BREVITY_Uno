import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:brevity/controller/bloc/bookmark_bloc/bookmark_bloc.dart';
import 'package:brevity/controller/bloc/bookmark_bloc/bookmark_event.dart';
import 'package:brevity/controller/cubit/theme/theme_cubit.dart';
import 'package:brevity/controller/services/news_services.dart';
import 'package:brevity/models/article_model.dart';
import 'package:brevity/views/common_widgets/common_appbar.dart';
import 'package:brevity/views/common_widgets/list_of_article.dart';
import 'package:url_launcher/url_launcher.dart';

class SearchResultsScreen extends StatefulWidget {
  final String query;

  const SearchResultsScreen({super.key, required this.query});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen>
    with TickerProviderStateMixin {
  late Future<List<Article>> _searchResults;
  late Animation<double> _animation;
  late AnimationController _animationController;
  late AnimationController _particleAnimationController;
  final NewsService _newsService = NewsService();

  @override
  void initState() {
    super.initState();
    _searchResults = _newsService.searchNews(widget.query);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _particleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _particleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Access current theme from ThemeCubit for dynamic theming
    final currentTheme = context.read<ThemeCubit>().currentTheme;

    return AppScaffold(
      body: FutureBuilder<List<Article>>(
        future: _searchResults,
        builder: (context, snapshot) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                backgroundColor: const Color.fromARGB(210, 0, 0, 0),
                expandedHeight: 70,
                pinned: true,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: ParticlesHeader(
                    title: "Results for ${widget.query}",
                    // Apply theme's primary color to particle header
                    themeColor: currentTheme.primaryColor,
                    particleAnimation: _particleAnimationController,
                  ),
                ),
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  color: Colors.white70,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 35)),
              _buildContentSlivers(snapshot, currentTheme),
            ],
          );
        },
      ),
    );
  }

  void _launchArticle(String url) async {
    // Access current theme for themed error messages
    final currentTheme = context.read<ThemeCubit>().currentTheme;

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF4F5B73),
            content: Text(
              'Failed to open article: $e',
              style: const TextStyle(color: Colors.white),
            ),
            action: SnackBarAction(
              label: 'DISMISS',
              // Apply theme's primary color to snackbar action
              textColor: currentTheme.primaryColor,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  // Updated content slivers with theme parameter for dynamic styling
  Widget _buildContentSlivers(
    AsyncSnapshot<List<Article>> snapshot,
    currentTheme,
  ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(
            // Apply theme's primary color to loading indicator
            color: currentTheme.primaryColor,
          ),
        ),
      );
    }

    if (snapshot.hasError) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 60,
                // Apply theme's secondary color to error icon for visual variety
                color: currentTheme.secondaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Error: ${snapshot.error}',
                style: TextStyle(
                  // Apply theme's secondary color to error text
                  color: currentTheme.secondaryColor,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  // Apply theme's primary color to retry button
                  backgroundColor: currentTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  // Refresh search results
                  setState(() {
                    _searchResults = _newsService.searchNews(widget.query);
                  });
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh, size: 18),
                    SizedBox(width: 8),
                    Text('Retry Search'),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final results = snapshot.data ?? [];

    if (results.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E222A),
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      // Apply theme color to empty state shadow
                      color: currentTheme.primaryColor.withAlpha((0.15 * 255).toInt()),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.search_off,
                  size: 70,
                  // Apply theme's primary color to empty search icon
                  color: currentTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No results found for "${widget.query}"',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Try a different search term',
                style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  // Apply theme's primary color to search again button
                  backgroundColor: currentTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  // Apply theme color to button shadow
                  shadowColor: currentTheme.primaryColor.withAlpha((0.5 * 255).toInt()),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search),
                    SizedBox(width: 8),
                    Text(
                      'Search Again',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final article = results[index];
        return FadeTransition(
          opacity: _animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(_animation),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10, left: 22, right: 22),
              child: ArticleListItem(
                onSide:
                    () => context.read<BookmarkBloc>().add(
                      ToggleBookmarkEvent(article),
                    ),
                article: article,
                onTap: () => _launchArticle(article.url),
                showBookmark: true,
                showRemove: false,
              ),
            ),
          ),
        );
      }, childCount: results.length),
    );
  }
}

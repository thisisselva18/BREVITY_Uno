import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newsai/controller/services/news_services.dart';
import 'package:newsai/models/article_model.dart';
import 'package:newsai/views/common_widgets/List_of_article.dart';
import 'package:newsai/controller/bloc/bookmark_bloc/bookmark_event.dart';
import 'package:newsai/controller/bloc/bookmark_bloc/bookmark_bloc.dart';
import 'package:newsai/views/common_widgets/common_appbar.dart';
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
                    themeColor: Colors.blue,
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
              SliverToBoxAdapter(child: SizedBox(height: 35)),
              _buildContentSlivers(snapshot),
            ],
          );
        },
      ),
    );
  }

  void _launchArticle(String url) async {
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
              textColor: const Color(0xFF64B5F6),
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  Widget _buildContentSlivers(AsyncSnapshot<List<Article>> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF64B5F6)),
        ),
      );
    }

    if (snapshot.hasError) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Color(0xFFEF5350)),
              SizedBox(height: 16),
              Text(
                'Error: ${snapshot.error}',
                style: TextStyle(color: Color(0xFFEF5350), fontSize: 16),
                textAlign: TextAlign.center,
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
              Icon(Icons.search_off, size: 70, color: Color(0xFFB0BEC5)),
              SizedBox(height: 16),
              Text(
                'No results found for "${widget.query}"',
                style: TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Try a different search term',
                style: TextStyle(color: Color(0xFFB0BEC5), fontSize: 16),
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
              begin: Offset(0, 0.1),
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

import 'package:flutter/material.dart';
import 'package:newsai/controller/services/news_services.dart';
import 'package:newsai/models/article_model.dart';
import 'package:newsai/views/common_widgets/article_list_item.dart';
import 'package:url_launcher/url_launcher.dart';

class SearchResultsScreen extends StatefulWidget {
  final String query;

  const SearchResultsScreen({
    super.key,
    required this.query,
  });

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late Future<List<Article>> _searchResults;
  final NewsService _newsService = NewsService();

  @override
  void initState() {
    super.initState();
    _searchResults = _newsService.searchNews(widget.query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Results for "${widget.query}"'),
      ),
      body: FutureBuilder<List<Article>>(
        future: _searchResults,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final results = snapshot.data ?? [];

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: results.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final article = results[index];
              return ArticleListItem(
                article: article,
                onTap: () => _launchArticle(article.url),
                showBookmark: true,
              );
            },
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to open article: $e')),
      );
    }
  }
}
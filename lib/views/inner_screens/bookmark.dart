import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:newsai/controller/bloc/bookmark_bloc.dart';
import 'package:newsai/controller/bloc/bookmark_event.dart';
import 'package:newsai/controller/bloc/bookmark_state.dart';
import 'package:newsai/models/article_model.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BookmarkBloc>().add(LoadBookmarksEvent());
  }

  Future<void> _launchArticleUrl(String url, BuildContext context) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open article: $e')),
      );
    }
  }

  void _removeBookmark(Article article) {
    context.read<BookmarkBloc>().add(ToggleBookmarkEvent(article));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bookmarks',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<BookmarkBloc, BookmarkState>(
        builder: (context, state) {
          if (state is BookmarkInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is BookmarkError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (state is BookmarksLoaded) {
            if (state.bookmarks.isEmpty) {
              return _buildEmptyBookmarksView();
            }
            return _buildBookmarksList(state.bookmarks);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildEmptyBookmarksView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 100,
            color: Colors.grey[400],
          ),
          const Gap(20),
          Text(
            'No Bookmarks Yet',
            style: TextStyle(
              fontSize: 22,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(10),
          Text(
            'Save articles you want to read later',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarksList(List<Article> bookmarks) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: bookmarks.length,
      separatorBuilder: (context, index) => const Gap(16),
      itemBuilder: (context, index) {
        final article = bookmarks[index];
        return _BookmarkCard(
          article: article,
          onRemove: () => _removeBookmark(article),
          onTap: () => _launchArticleUrl(article.url, context),
        );
      },
    );
  }
}

class _BookmarkCard extends StatelessWidget {
  final Article article;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const _BookmarkCard({
    required this.article,
    required this.onRemove,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Article Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: CachedNetworkImage(
                imageUrl: article.urlToImage,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey[200]),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, color: Colors.white),
                ),
              ),
            ),
            
            // Article Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.sourceName.toUpperCase(),
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(8),
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Gap(8),
                    Text(
                      DateFormat('MMM dd, y • h:mm a').format(article.publishedAt),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Remove Bookmark Button
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}
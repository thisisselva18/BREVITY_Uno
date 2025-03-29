import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:newsai/models/article_model.dart';
import 'package:newsai/controller/services/news_services.dart';
import 'package:newsai/models/news_category.dart';

class SidePage extends StatefulWidget {
  const SidePage({super.key});

  @override
  State<SidePage> createState() => _SidePageState();
}

class _SidePageState extends State<SidePage> {
  final NewsService _newsService = NewsService();
  late Future<List<Article>> _topNewsFuture;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _topNewsFuture = _newsService.fetchGeneralNews(page: 1, pageSize: 3);
  }

  void _handleSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a search query')),
      );
      return;
    }
    context.pushNamed(
      'searchResults',
      queryParameters: {'query': query},
    );
    _searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final textScaler = MediaQuery.textScalerOf(context);

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! < -5) {
          context.goNamed(
            'home',
            pathParameters: {'category': NewsCategory.general.index.toString()},
          );
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: Colors.black45,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.01),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color.fromARGB(255, 207, 207, 207),
                      radius: screenWidth * 0.05,
                      child: IconButton(
                        color: Colors.black,
                        icon: Icon(Icons.person, size: screenWidth * 0.06),
                        onPressed: () {},
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () {
                        context.goNamed(
                          'home',
                          pathParameters: {'category': NewsCategory.general.index.toString()},
                        );
                      },
                      icon: Text(
                        'MY FEED',
                        style: TextStyle(
                          fontSize: textScaler.scale(14),
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(221, 249, 249, 249),
                        ),
                      ),
                      label: Icon(
                        Icons.arrow_forward,
                        size: screenWidth * 0.05,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: screenHeight * 0.025),
                TextField(
                  controller: _searchController,
                  style: TextStyle(fontSize: textScaler.scale(16)),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Search news topics...',
                    hintStyle: TextStyle(fontSize: textScaler.scale(16)),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _handleSearch,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        screenWidth * 0.07,
                      ),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 215, 214, 214),
                  ),
                
                  onSubmitted: (_) => _handleSearch(),
                ),

                SizedBox(height: screenHeight * 0.01),

                SizedBox(
                  height: screenHeight * 0.15,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    children: [
                      _buildMenuButton('My Feed', Icons.home, context, NewsCategory.general),
                      _buildMenuButton(
                        'Top Stories',
                        Icons.trending_up,
                        context,
                        NewsCategory.general,
                      ),
                      _buildMenuButton('Bookmarks', Icons.bookmark, context, null),
                      _buildMenuButton('Setting', Icons.settings, context, null),
                      _buildMenuButton('Unread', Icons.markunread, context, null),
                      _buildMenuButton('Unseen', Icons.visibility_off, context, null),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),

                Text(
                  'TOP NEWS',
                  style: TextStyle(
                    color: const Color.fromARGB(221, 248, 248, 248),
                    fontSize: textScaler.scale(18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                FutureBuilder<List<Article>>(
                  future: _topNewsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Column(
                        children: List.generate(
                          3,
                          (index) => _buildNewsItem(context, null),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02,
                        ),
                        child: Text(
                          'Failed to load top news',
                          style: TextStyle(
                            fontSize: textScaler.scale(14),
                            color: Colors.red,
                          ),
                        ),
                      );
                    }
                    return Column(
                      children:
                          snapshot.data!
                              .map(
                                (article) => _buildNewsItem(context, article),
                              )
                              .toList(),
                    );
                  },
                ),

                SizedBox(height: screenHeight * 0.03),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOPICS',
                      style: TextStyle(
                        color: const Color.fromARGB(221, 248, 248, 248),
                        fontSize: textScaler.scale(18),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: screenHeight * 0.015,
                      crossAxisSpacing: screenWidth * 0.001,
                      childAspectRatio: 1.65,
                      padding: EdgeInsets.zero,
                      children: [
                        _buildImageContainer(
                          'Technology',
                          'https://www.simplilearn.com/ice9/free_resources_article_thumb/Technology_Trends.jpg',
                          context,
                          NewsCategory.technology,
                        ),
                        _buildImageContainer(
                          'Politics',
                          'https://www.livemint.com/lm-img/img/2025/01/30/600x338/-FILES--US-President-Donald-Trump--L--shakes-hands_1738253783512_1738253792847.jpg',
                          context,
                          NewsCategory.politics,
                        ),
                        _buildImageContainer(
                          'Sports',
                          'https://student-cms.prd.timeshighereducation.com/sites/default/files/styles/default/public/different_sports.jpg?itok=CW5zK9vp',
                          context,
                          NewsCategory.sports,
                        ),
                        _buildImageContainer(
                          'Entertainment',
                          'https://www.jansatta.com/wp-content/uploads/2025/03/ENT-NEWS-LIVE-2.jpg?w=440',
                          context,
                          NewsCategory.entertainment,
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(String text, IconData icon, BuildContext context, NewsCategory? category) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaler = MediaQuery.textScalerOf(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: InkWell(
        onTap: () {
          if (category != null) {
            context.goNamed(
              'home',
              pathParameters: {'category': category.index.toString()},
            );
          } else if (text == 'Bookmarks') {
            context.go('/sidepage/bookmark');
          } else if (text == 'Setting') {
            context.go('/sidepage/settings');
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: screenWidth * 0.11,
              color: const Color.fromARGB(255, 20, 116, 195),
            ),
            SizedBox(height: screenWidth * 0.02),
            Text(
              text,
              style: TextStyle(
                fontSize: textScaler.scale(12),
                fontWeight: FontWeight.w600,
                color: const Color.fromARGB(221, 246, 246, 246),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsItem(BuildContext context, Article? article) {
    final screenSize = MediaQuery.of(context).size;
    final textScaler = MediaQuery.textScalerOf(context);

    return Container(
      margin: EdgeInsets.symmetric(vertical: screenSize.height * 0.011),
      child: Row(
        children: [
          Container(
            width: screenSize.width * 0.22,
            height: screenSize.height * 0.10,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(screenSize.width * 0.03),
              image: DecorationImage(
                image:
                    article?.urlToImage != null
                        ? CachedNetworkImageProvider(article!.urlToImage)
                        : const AssetImage('assets/logos/no_image.png')
                            as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: screenSize.width * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article?.title ?? 'Error Loading News!!',
                  style: TextStyle(
                    color: const Color.fromARGB(221, 246, 246, 246),
                    fontWeight: FontWeight.bold,
                    fontSize: textScaler.scale(14),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: screenSize.height * 0.003),
                Text(
                  article?.description ??
                      'News description text goes here with 3-4 lines of sample text...',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color.fromARGB(255, 166, 166, 166),
                    fontSize: textScaler.scale(12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContainer(
    String text,
    String imageUrl,
    BuildContext context,
    NewsCategory category,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final textScaler = MediaQuery.textScalerOf(context);
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.013),
      child: GestureDetector(
        onTap: () {
          // Navigate to home with the selected category
          context.goNamed(
            'home',
            pathParameters: {'category': category.index.toString()},
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(screenWidth * 0.03),
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: textScaler.scale(19),
                fontWeight: FontWeight.bold,
                shadows: const [
                  Shadow(
                    blurRadius: 15,
                    color: Colors.black,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
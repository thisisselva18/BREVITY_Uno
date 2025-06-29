import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
// Add these imports for your theme
import 'package:newsai/controller/cubit/theme/theme_cubit.dart';
import 'package:newsai/controller/cubit/theme/theme_state.dart';
import 'package:newsai/controller/services/news_services.dart';
import 'package:newsai/models/article_model.dart';
import 'package:newsai/models/news_category.dart';
import 'package:newsai/views/common_widgets/common_appbar.dart';

class SidePage extends StatefulWidget {
  const SidePage({super.key});

  @override
  State<SidePage> createState() => _SidePageState();
}

class _SidePageState extends State<SidePage> with TickerProviderStateMixin {
  final NewsService _newsService = NewsService();
  late Future<List<Article>> _topNewsFuture;
  final TextEditingController _searchController = TextEditingController();
  late Animation<double> _animation;
  late AnimationController _animationController;
  late AnimationController _particleAnimationController;

  @override
  void initState() {
    super.initState();
    _topNewsFuture = _newsService.fetchGeneralNews(page: 1, pageSize: 3);

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

  void _handleSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a search query')),
      );
      return;
    }
    context.pushNamed('searchResults', queryParameters: {'query': query});
    _searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final textScaler = MediaQuery.textScalerOf(context);

    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final currentTheme = themeState.currentTheme;

        return GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity! < -5) {
              context.goNamed(
                'home',
                pathParameters: {
                  'category': NewsCategory.general.index.toString(),
                },
              );
            }
          },
          behavior: HitTestBehavior.opaque,
          child: AppScaffold(
            //backgroundColor: Colors.black45,
            body: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  backgroundColor: const Color.fromARGB(210, 0, 0, 0),
                  expandedHeight: 155,
                  //pinned: true,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: ParticlesHeader(
                      title: "",
                      themeColor: currentTheme.primaryColor, // Use theme color
                      particleAnimation: _particleAnimationController,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    207,
                                    207,
                                    207,
                                  ),
                                  radius: screenWidth * 0.05,
                                  child: IconButton(
                                    color: Colors.black,
                                    icon: Icon(
                                      Icons.person,
                                      size: screenWidth * 0.06,
                                    ),
                                    onPressed: () {
                                      context.push("/sidepage/profile");
                                    },
                                  ),
                                ),
                                const Spacer(),
                                TextButton.icon(
                                  onPressed: () {
                                    context.goNamed(
                                      'home',
                                      pathParameters: {
                                        'category':
                                            NewsCategory.general.index
                                                .toString(),
                                      },
                                    );
                                  },
                                  icon: Text(
                                    'MY FEED',
                                    style: TextStyle(
                                      fontSize: textScaler.scale(14),
                                      fontWeight: FontWeight.bold,
                                      color: const Color.fromARGB(
                                        221,
                                        249,
                                        249,
                                        249,
                                      ),
                                    ),
                                  ),
                                  label: Icon(
                                    Icons.arrow_forward,
                                    size: screenWidth * 0.04,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.03),
                            TextField(
                              controller: _searchController,
                              style: TextStyle(fontSize: textScaler.scale(16)),
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: 'Search news topics...',
                                hintStyle: TextStyle(
                                  fontSize: textScaler.scale(16),
                                ),
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
                                fillColor: const Color.fromARGB(
                                  255,
                                  215,
                                  214,
                                  214,
                                ),
                              ),
                              onSubmitted: (_) => _handleSearch(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    Container(
                      // Apply theme color to SliverList background with opacity
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            currentTheme.primaryColor.withOpacity(0.1),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: FadeTransition(
                        opacity: _animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.1),
                            end: Offset.zero,
                          ).animate(_animation),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              MediaQuery.of(context).size.width * 0.05,
                              6,
                              MediaQuery.of(context).size.width * 0.05,
                              20,
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: screenHeight * 0.15,
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    children: [
                                      _buildMenuButton(
                                        'My Feed',
                                        Icons.home,
                                        context,
                                        NewsCategory.general,
                                        currentTheme
                                            .primaryColor, // Pass theme color
                                      ),
                                      _buildMenuButton(
                                        'Top Stories',
                                        Icons.trending_up,
                                        context,
                                        NewsCategory.general,
                                        currentTheme
                                            .primaryColor, // Pass theme color
                                      ),
                                      _buildMenuButton(
                                        'Bookmarks',
                                        Icons.bookmark,
                                        context,
                                        null,
                                        currentTheme
                                            .primaryColor, // Pass theme color
                                      ),
                                      _buildMenuButton(
                                        'Setting',
                                        Icons.settings,
                                        context,
                                        null,
                                        currentTheme
                                            .primaryColor, // Pass theme color
                                      ),
                                      _buildMenuButton(
                                        'Unseen',
                                        Icons.visibility_off,
                                        context,
                                        null,
                                        currentTheme
                                            .primaryColor, // Pass theme color
                                      ),
                                    ],
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    'TOP NEWS',
                                    style: TextStyle(
                                      color: const Color.fromARGB(
                                        221,
                                        248,
                                        248,
                                        248,
                                      ),
                                      fontSize: textScaler.scale(18),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.01),
                                FutureBuilder<List<Article>>(
                                  future: _topNewsFuture,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Column(
                                        children: List.generate(
                                          3,
                                          (index) =>
                                              _buildNewsItem(context, null),
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
                                                (article) => _buildNewsItem(
                                                  context,
                                                  article,
                                                ),
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
                                        letterSpacing: 1.05,
                                        color: const Color.fromARGB(
                                          221,
                                          248,
                                          248,
                                          248,
                                        ),
                                        fontSize: textScaler.scale(18),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.02),
                                    GridView.count(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      crossAxisCount: 2,
                                      mainAxisSpacing: screenHeight * 0.015,
                                      crossAxisSpacing: screenWidth * 0.001,
                                      childAspectRatio: 1.65,
                                      padding: EdgeInsets.zero,
                                      children: [
                                        _buildImageContainer(
                                          'Technology',
                                          'https://i.pinimg.com/736x/6b/8e/97/6b8e974572105a1e4096c1a8e2b6a7bc.jpg',
                                          context,
                                          NewsCategory.technology,
                                        ),
                                        _buildImageContainer(
                                          'Politics',
                                          'https://i.pinimg.com/736x/f2/c0/9c/f2c09c8daf5c64c92ea5738507f4ed26.jpg',
                                          context,
                                          NewsCategory.politics,
                                        ),
                                        _buildImageContainer(
                                          'Sports',
                                          'https://i.pinimg.com/736x/fe/67/49/fe674914b51da2170019d092e19f5440.jpg',
                                          context,
                                          NewsCategory.sports,
                                        ),
                                        _buildImageContainer(
                                          'Entertainment',
                                          'https://i.pinimg.com/736x/c1/f6/52/c1f6526d8499d10a45e27cee47281996.jpg',
                                          context,
                                          NewsCategory.entertainment,
                                        ),
                                        _buildImageContainer(
                                          'Health',
                                          'https://i.pinimg.com/736x/3d/42/04/3d42045f076135a461c62e1949a35099.jpg',
                                          context,
                                          NewsCategory.health,
                                        ),
                                        _buildImageContainer(
                                          'Business',
                                          'https://i.pinimg.com/736x/1c/4e/89/1c4e8918b36ea9a6e54eab713f630689.jpg',
                                          context,
                                          NewsCategory.business,
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
                    ),
                  ]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuButton(
    String text,
    IconData icon,
    BuildContext context,
    NewsCategory? category,
    Color themeColor, // Add theme color parameter
  ) {
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
              size: screenWidth * 0.12,
              color: themeColor, // Use theme color instead of hardcoded blue
            ),
            SizedBox(height: screenWidth * 0.02),
            Text(
              text,
              style: TextStyle(
                fontSize: textScaler.scale(13),
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
                        : CachedNetworkImageProvider(
                          "https://static.vecteezy.com/system/resources/thumbnails/008/174/698/original/animation-loading-circle-icon-loading-gif-loading-screen-gif-loading-spinner-gif-loading-animation-loading-on-black-background-free-video.jpg",
                        ),
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
                  article?.title ?? 'Loading News!!',
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
                      'News description text will come here with 3-4 lines of sample text...',
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

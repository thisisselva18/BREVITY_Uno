import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

class IntroductionScreen extends StatefulWidget {
  const IntroductionScreen({super.key});

  @override
  State<IntroductionScreen> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _opacityAnimation;

  final List<IntroductionPage> _pages = [
    IntroductionPage(
      title: 'Concise News,\nMaximum Clarity',
      description:
          'Get AI-curated news briefs in 50-60 words - stay informed without information overload',
      image:
          'https://images.unsplash.com/photo-1586339949916-3e9457bef6d3?ixlib=rb-1.2.1&auto=format&fit=crop&w=600&q=60',
      color: Color(0xFF2A2E3D),
    ),
    IntroductionPage(
      title: 'AI-Powered\nNews Companion',
      description:
          'Ask detailed questions about any story with our advanced AI assistant - context-aware answers at your fingertips',
      image:
          'https://images.unsplash.com/photo-1542744173-8e7e53415bb0?ixlib=rb-1.2.1&auto=format&fit=crop&w=600&q=60',
      color: Color(0xFF1F2833),
    ),
    IntroductionPage(
      title: 'Your News,\nYour Style',
      description:
          'Personalize reading experience with customizable themes - dark mode, accent colors, and visual preferences',
      image:
          'https://images.unsplash.com/photo-1556761175-5973dc0f32e7?ixlib=rb-1.2.1&auto=format&fit=crop&w=600&q=60',
      color: Color(0xFF151A21),
    ),
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo));

    _slideAnimation = Tween<double>(begin: 120.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();

    // Pre-cache images - optional but can help with performance
    _precacheImages();
  }

  Future<void> _precacheImages() async {
    for (final page in _pages) {
      final provider = CachedNetworkImageProvider(page.image);
      await precacheImage(provider, context);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
      _controller.reset();
      _controller.forward();
    });
  }

  void _navigateToHome() {
    context.pushReplacement('/home/0');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Images that cover the full screen
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return _BackgroundImage(
                image: _pages[index].image,
                color: _pages[index].color,
                isActive: index == _currentPage,
              );
            },
          ),

          // Overlay Content
          SafeArea(
            child: Column(
              children: [
                // Navigation Controls - Removed the back button, kept only Skip button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Spacer(),
                      TextButton(
                        onPressed: _navigateToHome,
                        child: const Text(
                          'Skip',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),

                // Page Indicator
                _PageIndicator(
                  pageCount: _pages.length,
                  currentPage: _currentPage,
                  color: Colors.tealAccent,
                ),

                // Content area
                Expanded(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return _PageContent(
                        page: _pages[_currentPage],
                        slideValue: _slideAnimation.value,
                        opacityValue: _opacityAnimation.value,
                        scaleValue: _scaleAnimation.value,
                        showButton: _currentPage == _pages.length - 1,
                        onPressed: _navigateToHome,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Add a transparent GestureDetector to handle swipes across the entire screen
          Positioned.fill(
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity! > 0 && _currentPage > 0) {
                  // Swipe right - go to previous page
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutQuad,
                  );
                } else if (details.primaryVelocity! < 0 &&
                    _currentPage < _pages.length - 1) {
                  // Swipe left - go to next page
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutQuad,
                  );
                }
              },
              behavior: HitTestBehavior.translucent,
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundImage extends StatelessWidget {
  final String image;
  final Color color;
  final bool isActive;

  const _BackgroundImage({
    required this.image,
    required this.color,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isActive ? 1 : 0,
      duration: const Duration(milliseconds: 800),
      child: Stack(
        fit: StackFit.expand, // This ensures the stack fills its parent
        children: [
          // Full-screen image
          CachedNetworkImage(
            imageUrl: image,
            fit: BoxFit.cover,
            height: double.infinity, // Ensure the image takes full height
            width: double.infinity, // Ensure the image takes full width
            memCacheWidth: 600, // Limit memory cache size
            placeholder: (context, url) => Container(color: Colors.black),
            errorWidget:
                (context, url, error) => Container(
                  color: Colors.black,
                  child: const Icon(Icons.error, color: Colors.white),
                ),
          ),
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.9),
                  Colors.transparent,
                  color.withOpacity(0.9),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageContent extends StatelessWidget {
  final IntroductionPage page;
  final double slideValue;
  final double opacityValue;
  final double scaleValue;
  final bool showButton;
  final VoidCallback onPressed;

  const _PageContent({
    required this.page,
    required this.slideValue,
    required this.opacityValue,
    required this.scaleValue,
    required this.showButton,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scaleValue,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title with sliding animation
            Container(
              padding: EdgeInsets.only(top: slideValue * 0.5),
              child: Opacity(
                opacity: opacityValue,
                child: Text(
                  page.title,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.2,
                    fontFamily: 'Georgia',
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Description with sliding animation
            Container(
              padding: EdgeInsets.only(top: slideValue),
              child: Opacity(
                opacity: opacityValue,
                child: Text(
                  page.description,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.4,
                    fontFamily: 'Helvetica',
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Get Started Button with sliding animation
            if (showButton)
              Container(
                padding: EdgeInsets.only(top: slideValue * 1.5, bottom: 30),
                child: Opacity(
                  opacity: opacityValue,
                  child: _SimplerButton(
                    onPressed: onPressed,
                    child: const Text(
                      'GET STARTED',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ),

            if (!showButton) const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final int pageCount;
  final int currentPage;
  final Color color;

  const _PageIndicator({
    required this.pageCount,
    required this.currentPage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(pageCount, (index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            width: currentPage == index ? 24 : 8,
            height: 4,
            decoration: BoxDecoration(
              color:
                  currentPage == index ? color : Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }
}

// Simpler button without animations
class _SimplerButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;

  const _SimplerButton({required this.child, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [Colors.tealAccent, Color(0xFF64FCD9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: child,
      ),
    );
  }
}

class IntroductionPage {
  final String title;
  final String description;
  final String image;
  final Color color;

  IntroductionPage({
    required this.title,
    required this.description,
    required this.image,
    required this.color,
  });
}

import 'package:flutter/material.dart';

class SidePage extends StatelessWidget {
  const SidePage({super.key});
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final textScaler = MediaQuery.textScalerOf(context);

    return Scaffold(
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
                    backgroundColor: Colors.grey[300],
                    radius: screenWidth * 0.05,
                    child: IconButton(
                      color: Colors.black,
                      icon: Icon(Icons.person,size: screenWidth * 0.06),
                      onPressed: () {},
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {},
                    icon: Text(
                      'MY FEED',
                      style: TextStyle(
                        fontSize: textScaler.scale(15),
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    label: Icon(Icons.arrow_forward,size: screenWidth * 0.06),
                  ),
                ],
              ),

              SizedBox(height: screenHeight * 0.025),

              TextField(
                style: TextStyle(fontSize: textScaler.scale(16)),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Search...',
                  hintStyle: TextStyle(fontSize: textScaler.scale(16)),
                  prefixIcon: Icon(Icons.search,size: screenWidth * 0.06),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.07),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 215, 214, 214),
                ),
              ),

              SizedBox(height: screenHeight * 0.02),

              SizedBox(
                height: screenHeight * 0.15,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  children: [
                    _buildMenuButton('My Feed', Icons.home, context),
                    _buildMenuButton('Top Stories', Icons.trending_up,context),
                    _buildMenuButton('Bookmarks', Icons.bookmark,context),
                    _buildMenuButton('Setting', Icons.settings,context),
                    _buildMenuButton('Unread', Icons.markunread,context),
                    _buildMenuButton('Unseen', Icons.visibility_off,context),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.03),

              Text(
                'TOP NEWS',
                style: TextStyle(fontSize: textScaler.scale(18), fontWeight: FontWeight.bold),
              ),
              SizedBox(height: screenHeight * 0.01),
              _buildNewsItem(context),
              _buildNewsItem(context),
              _buildNewsItem(context),

              SizedBox(height: screenHeight * 0.03),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOPICS',
                    style: TextStyle(fontSize: textScaler.scale(18), fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: screenHeight * 0.02,
                    crossAxisSpacing: screenWidth * 0.01,
                    childAspectRatio: screenWidth < 600 ? 1.4 : 1.6,
                    padding: EdgeInsets.zero,
                    children: [
                      _buildImageContainer(
                        'Technology',
                        'https://www.simplilearn.com/ice9/free_resources_article_thumb/Technology_Trends.jpg',context
                      ),
                      _buildImageContainer(
                        'Politics',
                        'https://www.livemint.com/lm-img/img/2025/01/30/600x338/-FILES--US-President-Donald-Trump--L--shakes-hands_1738253783512_1738253792847.jpg',context
                      ),
                      _buildImageContainer(
                        'Sports',
                        'https://student-cms.prd.timeshighereducation.com/sites/default/files/styles/default/public/different_sports.jpg?itok=CW5zK9vp',context
                      ),
                      _buildImageContainer(
                        'Entertainment',
                        'https://www.jansatta.com/wp-content/uploads/2025/03/ENT-NEWS-LIVE-2.jpg?w=440',context
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
    );
  }

  Widget _buildMenuButton(String text, IconData icon, BuildContext context) {
     final screenWidth = MediaQuery.of(context).size.width;
     final textScaler = MediaQuery.textScalerOf(context);
    
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,  size: screenWidth * 0.12, color: const Color.fromARGB(255, 39, 100, 149)),
          SizedBox(height: screenWidth * 0.02),
          Text(
            text,
            style: TextStyle(
              fontSize: textScaler.scale(13),
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsItem(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final textScaler = MediaQuery.textScalerOf(context);
    return Container(
      margin: EdgeInsets.symmetric(vertical: screenSize.height * 0.01),
      child: Row(
        children: [
          Container(
            width: screenSize.width * 0.25,
            height: screenSize.height * 0.12,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(screenSize.width * 0.03),
              image: DecorationImage(
                image: NetworkImage(
                  'https://www.hindustantimes.com/ht-img/img/2025/03/19/550x309/Israel_Gaza_ground_op_1742398771755_1742398775125.jpg',
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
                  'News Headline Here',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: textScaler.scale(15),),
                ),
                SizedBox(height: screenSize.height * 0.005),
                Text(
                  'News description text goes here with 3-4 lines of sample text to fill up the space with some amazing and best use of AI ...',
                  maxLines: 3,

                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[600],fontSize: textScaler.scale(13),),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContainer(String text, String imageUrl, BuildContext context) {
     final screenWidth = MediaQuery.of(context).size.width;
    final textScaler = MediaQuery.textScalerOf(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
      child: Container(
        width: screenWidth * 0.45,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
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
              fontSize: textScaler.scale(20),
              fontWeight: FontWeight.bold,
              shadows: [
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
    );
  }
}
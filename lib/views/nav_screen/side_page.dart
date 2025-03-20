import 'package:flutter/material.dart';

class SidePage extends StatelessWidget {
  const SidePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10), // Reduced from 20
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    radius: 20,
                    child: IconButton(
                      color: Colors.black,
                      icon: Icon(Icons.person),
                      onPressed: () {},
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {},
                    icon: Text(
                      'MY FEED',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    label: Icon(Icons.arrow_forward),
                  ),
                ],
              ),

              SizedBox(height: 20),

              TextField(
                style: TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Search...',
                  hintStyle: TextStyle(fontSize: 16),
                  prefixIcon: Icon(Icons.search, size: 24),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 215, 214, 214),
                ),
              ),

              SizedBox(height: 17),

              SizedBox(
                height: 110,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  children: [
                    _buildMenuButton('My Feed', Icons.home),
                    _buildMenuButton('Top Stories', Icons.trending_up),
                    _buildMenuButton('Bookmarks', Icons.bookmark),
                    _buildMenuButton('Setting', Icons.settings),
                    _buildMenuButton('Unread', Icons.markunread),
                    _buildMenuButton('Unseen', Icons.visibility_off),
                  ],
                ),
              ),
              SizedBox(height: 23),

              // Top News Section
              Text(
                'TOP NEWS',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              _buildNewsItem(),
              _buildNewsItem(),
              _buildNewsItem(),

              SizedBox(height: 25),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOPICS',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 15),
                  GridView.count(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 3,
                    childAspectRatio: 1.6, // Adjusted ratio
                    padding: EdgeInsets.zero,
                    children: [
                      _buildImageContainer(
                        'Technology',
                        'https://www.simplilearn.com/ice9/free_resources_article_thumb/Technology_Trends.jpg',
                      ),
                      _buildImageContainer(
                        'Politics',
                        'https://www.livemint.com/lm-img/img/2025/01/30/600x338/-FILES--US-President-Donald-Trump--L--shakes-hands_1738253783512_1738253792847.jpg',
                      ),
                      _buildImageContainer(
                        'Sports',
                        'https://student-cms.prd.timeshighereducation.com/sites/default/files/styles/default/public/different_sports.jpg?itok=CW5zK9vp',
                      ),
                      _buildImageContainer(
                        'Entertainment',
                        'https://www.jansatta.com/wp-content/uploads/2025/03/ENT-NEWS-LIVE-2.jpg?w=440',
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 17.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 50, color: const Color.fromARGB(255, 39, 100, 149)),
          const SizedBox(height: 10),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsItem() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 90,
            height: 85,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: NetworkImage(
                  'https://www.hindustantimes.com/ht-img/img/2025/03/19/550x309/Israel_Gaza_ground_op_1742398771755_1742398775125.jpg',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'News Headline Here',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(height: 5),
                Text(
                  'News description text goes here with 3-4 lines of sample text to fill up the space with some amazing and best use of AI ...',
                  maxLines: 3,

                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContainer(String text, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
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
              fontSize: 20,
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

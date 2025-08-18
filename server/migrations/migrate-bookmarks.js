const mongoose = require('mongoose');
require('dotenv').config();

// Connect to MongoDB
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/brevity', {
    useNewUrlParser: true,
    useUnifiedTopology: true,
});

const Article = require('../models/article');
const User = require('../models/user');

async function migrateBookmarks() {
    try {
        console.log('Starting bookmark migration...');

        // Find all articles that have userId (old bookmark system)
        const bookmarkedArticles = await mongoose.connection.db.collection('articles').find({ userId: { $exists: true } }).toArray();
        
        console.log(`Found ${bookmarkedArticles.length} bookmarked articles to migrate`);

        if (bookmarkedArticles.length === 0) {
            console.log('No bookmarks to migrate. Migration complete.');
            return;
        }

        const migrationStats = {
            usersUpdated: 0,
            articlesCreated: 0,
            articlesRemoved: 0,
            errors: 0
        };

        // Group articles by userId
        const articlesByUser = {};
        bookmarkedArticles.forEach(article => {
            const userId = article.userId.toString();
            if (!articlesByUser[userId]) {
                articlesByUser[userId] = [];
            }
            articlesByUser[userId].push(article);
        });

        // Process each user's bookmarks
        for (const [userId, userArticles] of Object.entries(articlesByUser)) {
            try {
                console.log(`Processing ${userArticles.length} bookmarks for user ${userId}`);

                const user = await User.findById(userId);
                if (!user) {
                    console.log(`User ${userId} not found, skipping...`);
                    continue;
                }

                const bookmarkedIds = [];

                for (const oldArticle of userArticles) {
                    // Create new article without userId
                    const { userId: _, _id: oldId, ...articleData } = oldArticle;
                    
                    // Check if article already exists (by URL)
                    let newArticle = await Article.findOne({ url: articleData.url });
                    
                    if (!newArticle) {
                        newArticle = await Article.create(articleData);
                        migrationStats.articlesCreated++;
                    }

                    bookmarkedIds.push(newArticle._id);

                    // Remove old article
                    await mongoose.connection.db.collection('articles').deleteOne({ _id: oldId });
                    migrationStats.articlesRemoved++;
                }

                // Update user with bookmarked articles
                user.bookmarked = [...new Set([...user.bookmarked, ...bookmarkedIds])]; // Remove duplicates
                await user.save();
                migrationStats.usersUpdated++;

                console.log(`Updated user ${userId} with ${bookmarkedIds.length} bookmarks`);

            } catch (error) {
                console.error(`Error processing user ${userId}:`, error);
                migrationStats.errors++;
            }
        }

        console.log('Migration completed!');
        console.log('Stats:', migrationStats);

    } catch (error) {
        console.error('Migration failed:', error);
    } finally {
        mongoose.connection.close();
    }
}

// Run migration if this file is executed directly
if (require.main === module) {
    migrateBookmarks();
}

module.exports = migrateBookmarks;

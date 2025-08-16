const express = require('express');

const { getArticlesWithReactions } = require('../controllers/news');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();

router.get('/',authMiddleware,getArticlesWithReactions);

module.exports = router;
=======
const { authMiddleware } = require('../middleware/auth');
const {
    getTrendingNews,
    getNewsByCategory,
    getGeneralNews,
    getPoliticsNews,
    searchNews
} = require('../controllers/news');

const router = express.Router();

// Public routes (no authentication required)
router.get('/trending', getTrendingNews);
router.get('/general', getGeneralNews);
router.get('/category/:category', getNewsByCategory);
router.get('/politics', getPoliticsNews);
router.get('/search', searchNews);

// Protected routes (authentication required) - if you want to track user activity
// router.get('/trending', authMiddleware, getTrendingNews);
// router.get('/general', authMiddleware, getGeneralNews);
// router.get('/category/:category', authMiddleware, getNewsByCategory);
// router.get('/politics', authMiddleware, getPoliticsNews);
// router.get('/search', authMiddleware, searchNews);

module.exports = router;

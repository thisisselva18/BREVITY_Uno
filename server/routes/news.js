const express = require('express');
const { authMiddleware } = require('../middleware/auth');
const {
    getTrendingNews,
    getNewsByCategory,
    getGeneralNews,
    getPoliticsNews,
    searchNews,
    getNewsById,
    getShareableLink
} = require('../controllers/news');

const router = express.Router();

// Get shareable link
router.post('/share', authMiddleware, getShareableLink);

// Get news by ID
router.get('/:newsId', authMiddleware,getNewsById);

// Public routes (no authentication required)
router.get('/trending', getTrendingNews);
router.get('/general', getGeneralNews);
router.get('/category/:category', getNewsByCategory);
router.get('/politics', getPoliticsNews);
router.get('/search', searchNews);

module.exports = router;

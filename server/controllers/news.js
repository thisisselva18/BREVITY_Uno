
const axios = require("axios");

const Reaction = require("../models/reaction");

const NEWS_API_KEY = process.env.NEWS_API_KEY;

const getArticlesWithReactions = async (req, res) => {
  const _topHeadlinesUrl = "https://newsapi.org/v2/top-headlines";
  const _everythingUrl = "https://newsapi.org/v2/everything";

  const { category, q, page = 1, pageSize = 10, sortedBy } = req.query;
  const userId =  req.user._id;

  let url;

  if (category) {
    url = `${_topHeadlinesUrl}?country=us&category=${category}&page=${page}&pageSize=${pageSize}&apiKey=${NEWS_API_KEY}`;
  } else if (q && sortedBy) {
    url = `${_everythingUrl}?q=${q}&language=en&sortBy=${sortedBy}&page=${page}&pageSize=${pageSize}&apiKey=${NEWS_API_KEY}`;
  } else {
    url = `${_topHeadlinesUrl}?country=us&page=${page}&pageSize=${pageSize}&apiKey=${NEWS_API_KEY}`;
  }

  try {
    const response = await axios.get(url);
    const articles = response.data.articles;
    const articleIds = articles.map((a) => a.url);

    // Aggregate likes & dislikes counts together
    const reactionCounts = await Reaction.aggregate([
      { $match: { articleid: { $in: articleIds } } },
      {
        $group: {
          _id: { articleid: "$articleid", reactiontype: "$reactiontype" },
          count: { $sum: 1 },
        },
      },
    ]);

    // Map counts by article and type
    const likeCountMap = {};
    const dislikeCountMap = {};
    reactionCounts.forEach((r) => {
      if (r._id.reactiontype === "like") {
        likeCountMap[r._id.articleid] = r.count;
      } else if (r._id.reactiontype === "dislike") {
        dislikeCountMap[r._id.articleid] = r.count;
      }
    });

    // Find which ones the user liked/disliked
    const likedByMe = await Reaction.find({
      articleid: { $in: articleIds },
      userid: userId,
      reactiontype: "like",
    });

    const dislikedByMe = await Reaction.find({
      articleid: { $in: articleIds },
      userid: userId,
      reactiontype: "dislike",
    });

    const likedSet = new Set(likedByMe.map((r) => r.articleid));
    const dislikedSet = new Set(dislikedByMe.map((r) => r.articleid));

    // Merge into articles
    const modifiedArticles = articles.map((article) => ({
      ...article,
      isLikedByMe: likedSet.has(article.url),
      likes: likeCountMap[article.url] || 0,
      isDislikedByMe: dislikedSet.has(article.url),
      dislikes: dislikeCountMap[article.url] || 0,
    }));

    return res.status(200).json(modifiedArticles);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

module.exports = {
  getArticlesWithReactions,
};
=======
const axios = require('axios');

const NEWS_API_KEY = process.env.NEWS_API_KEY;
const NEWS_BASE_URL = 'https://newsapi.org/v2';

// Helper function to handle API requests
const makeNewsRequest = async (url, params) => {
    try {
        const response = await axios.get(url, { params });
        return response.data;
    } catch (error) {
        console.error('News API Error:', error.response?.data || error.message);
        throw {
            status: error.response?.status || 500,
            message: error.response?.data?.message || error.message
        };
    }
};

// Fetch trending news
const getTrendingNews = async (req, res) => {
    try {
        const { page, pageSize } = req.query;

        const data = await makeNewsRequest(`${NEWS_BASE_URL}/top-headlines`, {
            country: 'us',
            category: 'general',
            page: parseInt(page),
            pageSize: parseInt(pageSize),
            apiKey: NEWS_API_KEY
        });

        res.json({
            success: true,
            data: data,
            timestamp: new Date().toISOString()
        });
    } catch (error) {
        res.status(error.status || 500).json({
            success: false,
            error: 'Failed to fetch trending news',
            message: error.message
        });
    }
};

// Fetch news by category
const getNewsByCategory = async (req, res) => {
    try {
        const { category } = req.params;
        const { page, pageSize } = req.query;

        const data = await makeNewsRequest(`${NEWS_BASE_URL}/top-headlines`, {
            country: 'us',
            category: category,
            page: parseInt(page),
            pageSize: parseInt(pageSize),
            apiKey: NEWS_API_KEY
        });

        res.json({
            success: true,
            data: data,
            timestamp: new Date().toISOString()
        });
    } catch (error) {
        res.status(error.status || 500).json({
            success: false,
            error: `Failed to fetch ${req.params.category} news`,
            message: error.message
        });
    }
};

// Fetch general news
const getGeneralNews = async (req, res) => {
    try {
        const { page, pageSize } = req.query;

        const data = await makeNewsRequest(`${NEWS_BASE_URL}/top-headlines`, {
            country: 'us',
            page: parseInt(page),
            pageSize: parseInt(pageSize),
            apiKey: NEWS_API_KEY
        });

        res.json({
            success: true,
            data: data,
            timestamp: new Date().toISOString()
        });
    } catch (error) {
        res.status(error.status || 500).json({
            success: false,
            error: 'Failed to fetch general news',
            message: error.message
        });
    }
};

// Fetch politics news using everything endpoint
const getPoliticsNews = async (req, res) => {
    try {
        const { page, pageSize } = req.query;

        const data = await makeNewsRequest(`${NEWS_BASE_URL}/everything`, {
            q: 'politics',
            language: 'en',
            sortBy: 'publishedAt',
            page: parseInt(page),
            pageSize: parseInt(pageSize),
            apiKey: NEWS_API_KEY
        });

        res.json({
            success: true,
            data: data,
            timestamp: new Date().toISOString()
        });
    } catch (error) {
        res.status(error.status || 500).json({
            success: false,
            error: 'Failed to fetch politics news',
            message: error.message
        });
    }
};

// Search news
const searchNews = async (req, res) => {
    try {
        const { q: query, page, pageSize } = req.query;

        if (!query) {
            return res.status(400).json({
                success: false,
                error: 'Search query is required'
            });
        }

        const data = await makeNewsRequest(`${NEWS_BASE_URL}/everything`, {
            q: query,
            language: 'en',
            sortBy: 'relevancy',
            page: parseInt(page),
            pageSize: parseInt(pageSize),
            apiKey: NEWS_API_KEY
        });

        res.json({
            success: true,
            data: data,
            timestamp: new Date().toISOString()
        });
    } catch (error) {
        res.status(error.status || 500).json({
            success: false,
            error: 'Failed to search news',
            message: error.message
        });
    }
};

module.exports = {
    getTrendingNews,
    getNewsByCategory,
    getGeneralNews,
    getPoliticsNews,
    searchNews
}

const express = require('express');
const { toggleReaction } = require('../controllers/reaction');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();

router.post('/',toggleReaction);

module.exports = router;
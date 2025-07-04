const express = require('express');
const { body } = require('express-validator');
const { authMiddleware } = require('../middleware/authMiddleware');
const { upload } = require('../services/cloudinaryService');
const {
    updateProfile,
    deleteProfileImage
} = require('../controllers/userController');

const router = express.Router();

// Validation rules
const updateProfileValidation = [
    body('displayName')
        .optional()
        .trim()
        .isLength({ min: 2, max: 50 })
        .withMessage('Display name must be between 2 and 50 characters'),
    body('preferences.categories')
        .optional()
        .isArray()
        .withMessage('Categories must be an array'),
    body('preferences.categories.*')
        .optional()
        .isIn(['technology', 'sports', 'politics', 'entertainment', 'business', 'health'])
        .withMessage('Invalid category'),
    body('preferences.language')
        .optional()
        .isLength({ min: 2, max: 5 })
        .withMessage('Language code must be between 2 and 5 characters')
];

// Routes
router.put('/profile', authMiddleware, upload.single('profileImage'), updateProfileValidation, updateProfile);
router.delete('/profile/image', authMiddleware, deleteProfileImage);

module.exports = router;
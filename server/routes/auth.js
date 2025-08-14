const express = require('express');
const { authMiddleware, authMiddlewareAllowUnverified } = require('../middleware/auth');
const { upload } = require('../services/cloudinary');
const {
    register,
    login,
    logout,
    getCurrentUser,
    forgotPassword,
    resetPassword,
    verifyEmail,
    resendVerification,
    googleAuth,
    googleCallback
} = require('../controllers/auth');

const router = express.Router();

//oauth routes
router.get('/google', googleAuth);
router.get('/google/callback', googleCallback);

// Routes
router.post('/register', upload.single('profileImage'), register);
router.post('/resend-verification', resendVerification);
router.get('/verify-email', verifyEmail);
router.post('/login', login);

router.post('/forgot-password', forgotPassword);
router.post('/reset-password', resetPassword);

router.post('/logout', authMiddleware, logout);
router.get('/me', authMiddlewareAllowUnverified, getCurrentUser);

module.exports = router;
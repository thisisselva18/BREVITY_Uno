const jwt = require('jsonwebtoken');
const JwtBlacklist = require('../models/jwtBlacklist');
const crypto = require('crypto');

const generateTokens = (userId) => {
    // Generate unique JTI (JWT ID) for tracking
    const jti = crypto.randomUUID();
    
    const accessToken = jwt.sign(
        { userId, jti },
        process.env.JWT_SECRET,
        { expiresIn: process.env.JWT_EXPIRE || '7d' }
    );

    const refreshToken = jwt.sign(
        { userId, jti: crypto.randomUUID() },
        process.env.JWT_REFRESH_SECRET,
        { expiresIn: process.env.JWT_REFRESH_EXPIRE || '30d' }
    );

    return { accessToken, refreshToken };
};

const verifyRefreshToken = (token) => {
    return jwt.verify(token, process.env.JWT_REFRESH_SECRET);
};

// Check if JWT is blacklisted
const isTokenBlacklisted = async (jti) => {
    if (!jti) return false;
    
    const blacklistedToken = await JwtBlacklist.findOne({ jti });
    return !!blacklistedToken;
};

// Blacklist a specific token
const blacklistToken = async (token, userId, reason = 'manual_revocation') => {
    if (!token || !userId) return false;
    
    try {
        // Decode the token to get jti and expiry
        const decoded = jwt.decode(token);
        if (!decoded || !decoded.jti) return false;
        
        const expiresAt = new Date(decoded.exp * 1000);
        
        await JwtBlacklist.create({
            jti: decoded.jti,
            userId,
            expiresAt,
            reason
        });
        
        return true;
    } catch (error) {
        console.error('Error blacklisting token:', error);
        return false;
    }
};

// Blacklist all tokens for a user (for account deletion)
const blacklistAllUserTokens = async (userId, reason = 'account_deletion') => {
    try {
        // Get all refresh tokens from user document
        const User = require('../models/user');
        const user = await User.findById(userId).select('refreshTokens');
        
        if (!user) return false;
        
        // Blacklist all refresh tokens
        const blacklistPromises = user.refreshTokens.map(async (tokenObj) => {
            try {
                const decoded = jwt.decode(tokenObj.token);
                if (decoded && decoded.jti) {
                    const expiresAt = new Date(decoded.exp * 1000);
                    return JwtBlacklist.create({
                        jti: decoded.jti,
                        userId,
                        expiresAt,
                        reason
                    });
                }
            } catch (error) {
                console.error('Error blacklisting refresh token:', error);
            }
        });
        
        await Promise.allSettled(blacklistPromises);
        return true;
    } catch (error) {
        console.error('Error blacklisting all user tokens:', error);
        return false;
    }
};

module.exports = { 
    generateTokens, 
    verifyRefreshToken, 
    isTokenBlacklisted, 
    blacklistToken, 
    blacklistAllUserTokens 
};
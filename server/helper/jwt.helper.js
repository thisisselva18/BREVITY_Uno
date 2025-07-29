const jwt = require('jsonwebtoken');
const dotenv = require('dotenv');

dotenv.config();

const encode = (payload) => {
    try {
        const token = jwt.sign(payload, process.env.JWT_SECRET, { expiresIn: process.env.JWT_EXPIRE });
        return token;
    } catch (error) {
        console.error('Error encoding JWT:', error);
        return null;
    }
};

const decode = (token) => {
    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        return decoded;
    } catch (error) {
        console.error('Error decoding JWT:', error);
        return null;
    }
};

module.exports = {
    encode,
    decode
};
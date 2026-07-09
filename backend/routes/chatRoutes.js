const express = require('express');
const router = express.Router();
const { chat, getChatHistory, clearChatHistory } = require('../controllers/chatController');

router.post('/', chat);
router.get('/history/:sessionId', getChatHistory);
router.delete('/history/:sessionId', clearChatHistory);

module.exports = router;

const express = require('express');
const router = express.Router();
const { getProfile, updateProfile, resetProfile, getRecommendationForSession } = require('../controllers/profileController');

router.get('/:sessionId', getProfile);
router.put('/:sessionId', updateProfile);
router.delete('/:sessionId', resetProfile);
router.get('/:sessionId/recommendation', getRecommendationForSession);

module.exports = router;

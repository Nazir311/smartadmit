const express = require('express');
const router = express.Router();
const { getStudentProfiles, getRecommendations, getReports, getPopularQuestions, getDashboardStats } = require('../controllers/adminController');

router.get('/dashboard', getDashboardStats);
router.get('/profiles', getStudentProfiles);
router.get('/recommendations', getRecommendations);
router.get('/reports', getReports);
router.get('/questions', getPopularQuestions);

module.exports = router;

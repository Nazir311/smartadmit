const express = require('express');
const router = express.Router();
const { getAllFAQs, getCategories } = require('../controllers/faqController');

router.get('/', getAllFAQs);
router.get('/meta/categories', getCategories);

module.exports = router;

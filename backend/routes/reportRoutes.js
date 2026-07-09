const express = require('express');
const router = express.Router();
const { generateReport, getReport } = require('../controllers/reportController');

router.post('/', generateReport);
router.get('/:sessionId', getReport);

module.exports = router;

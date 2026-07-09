const StudentProfile = require('../models/StudentProfile');
const Recommendation = require('../models/Recommendation');
const Report = require('../models/Report');
const { generatePDFBase64 } = require('../utils/pdfGenerator');

const generateReport = async (req, res) => {
  const { sessionId } = req.body;
  if (!sessionId) return res.status(400).json({ success: false, message: 'sessionId is required.' });

  const profile = await StudentProfile.findOne({ sessionId });
  const rec = await Recommendation.findOne({ sessionId });

  if (!rec || !profile) {
    return res.status(404).json({ success: false, message: 'Please complete the assessment before generating a report.' });
  }

  const pdfBase64 = generatePDFBase64(profile, rec.topDepartments, rec.parentSummaryEn);

  const report = await Report.findOneAndUpdate(
    { sessionId },
    { sessionId, studentName: profile.name || 'Student', pdfBase64 },
    { upsert: true, new: true }
  );

  await Recommendation.findOneAndUpdate({ sessionId }, { reportGenerated: true });

  return res.status(200).json({
    success: true,
    reportId: report._id,
    studentName: report.studentName,
    pdfBase64: report.pdfBase64,
    generatedAt: report.generatedAt
  });
};

const getReport = async (req, res) => {
  const report = await Report.findOne({ sessionId: req.params.sessionId });
  if (!report) return res.status(404).json({ success: false, message: 'Report not found. Generate one first via POST /api/report.' });
  return res.status(200).json({ success: true, pdfBase64: report.pdfBase64, studentName: report.studentName, generatedAt: report.generatedAt });
};

module.exports = { generateReport, getReport };

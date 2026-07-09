const StudentProfile = require('../models/StudentProfile');
const Recommendation = require('../models/Recommendation');
const Report = require('../models/Report');
const PopularQuestion = require('../models/PopularQuestion');
const ChatHistory = require('../models/ChatHistory');

const getStudentProfiles = async (req, res) => {
  const page = parseInt(req.query.page) || 1;
  const limit = parseInt(req.query.limit) || 20;
  const profiles = await StudentProfile.find()
    .sort({ createdAt: -1 })
    .skip((page - 1) * limit)
    .limit(limit);
  const total = await StudentProfile.countDocuments();
  return res.status(200).json({ success: true, total, page, data: profiles });
};

const getRecommendations = async (req, res) => {
  const page = parseInt(req.query.page) || 1;
  const limit = parseInt(req.query.limit) || 20;
  const recs = await Recommendation.find()
    .sort({ generatedAt: -1 })
    .skip((page - 1) * limit)
    .limit(limit);
  const total = await Recommendation.countDocuments();
  return res.status(200).json({ success: true, total, page, data: recs });
};

const getReports = async (req, res) => {
  const reports = await Report.find().select('-pdfBase64').sort({ generatedAt: -1 }).limit(50);
  const total = await Report.countDocuments();
  return res.status(200).json({ success: true, total, data: reports });
};

const getPopularQuestions = async (req, res) => {
  const questions = await PopularQuestion.find().sort({ count: -1 }).limit(30);
  return res.status(200).json({ success: true, data: questions });
};

const getDashboardStats = async (req, res) => {
  const [profiles, recs, reports, sessions, questions] = await Promise.all([
    StudentProfile.countDocuments(),
    Recommendation.countDocuments(),
    Report.countDocuments(),
    ChatHistory.countDocuments(),
    PopularQuestion.find().sort({ count: -1 }).limit(5)
  ]);
  const completedProfiles = await StudentProfile.countDocuments({ profileComplete: true });
  return res.status(200).json({
    success: true,
    stats: {
      totalProfiles: profiles,
      completedProfiles,
      totalRecommendations: recs,
      totalReports: reports,
      totalChatSessions: sessions,
      topQuestions: questions
    }
  });
};

module.exports = { getStudentProfiles, getRecommendations, getReports, getPopularQuestions, getDashboardStats };

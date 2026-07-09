const StudentProfile = require('../models/StudentProfile');
const Recommendation = require('../models/Recommendation');
const { processAgentMessage } = require('../utils/agentEngine');

const getProfile = async (req, res) => {
  const profile = await StudentProfile.findOne({ sessionId: req.params.sessionId });
  if (!profile) return res.status(404).json({ success: false, message: 'Profile not found.' });
  return res.status(200).json({ success: true, data: profile });
};

const updateProfile = async (req, res) => {
  const { sessionId } = req.params;
  const allowed = ['name', 'sscGpa', 'hscGpa', 'group', 'favoriteSubjects', 'skills', 'interests', 'careerGoals', 'financialConstraint', 'scholarshipInterest'];
  const update = {};
  for (const key of allowed) {
    if (req.body[key] !== undefined) update[key] = req.body[key];
  }
  const profile = await StudentProfile.findOneAndUpdate({ sessionId }, update, { new: true, upsert: true });
  return res.status(200).json({ success: true, data: profile });
};

const resetProfile = async (req, res) => {
  await StudentProfile.findOneAndDelete({ sessionId: req.params.sessionId });
  await Recommendation.findOneAndDelete({ sessionId: req.params.sessionId });
  return res.status(200).json({ success: true, message: 'Profile reset.' });
};

const getRecommendationForSession = async (req, res) => {
  const rec = await Recommendation.findOne({ sessionId: req.params.sessionId });
  if (!rec) return res.status(404).json({ success: false, message: 'No recommendation found. Complete the assessment first.' });
  return res.status(200).json({ success: true, data: rec });
};

module.exports = { getProfile, updateProfile, resetProfile, getRecommendationForSession };

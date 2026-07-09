const ChatHistory = require('../models/ChatHistory');
const StudentProfile = require('../models/StudentProfile');
const { processMessage } = require('../utils/aiEngine');
const { processAgentMessage } = require('../utils/agentEngine');

const generateSessionId = () => `sess_${Date.now()}_${Math.random().toString(36).substring(2, 10)}`;

const chat = async (req, res) => {
  const { message, sessionId, mode } = req.body;

  if (!message || typeof message !== 'string' || message.trim().length === 0) {
    return res.status(400).json({ success: false, message: 'Message is required.' });
  }
  if (message.length > 800) {
    return res.status(400).json({ success: false, message: 'Message too long. Max 800 characters.' });
  }

  const sid = (sessionId && sessionId.trim()) ? sessionId.trim() : generateSessionId();

  let session = await ChatHistory.findOne({ sessionId: sid });
  if (!session) session = new ChatHistory({ sessionId: sid, messages: [], context: {} });

  const historyForAI = session.messages.slice(-10).map(m => ({ role: m.role, content: m.content }));

  let result;

  if (mode === 'agent') {
    const profile = await StudentProfile.findOne({ sessionId: sid });
    if (!profile || profile.profileComplete) {
      result = await processMessage(message.trim(), session.context || {}, historyForAI, sid);
    } else {
      const agentResult = await processAgentMessage(message.trim(), sid);
      result = { response: agentResult.response, intent: `AGENT_${agentResult.stage?.toUpperCase() || 'FLOW'}`, context: session.context };
    }
  } else {
    if (/^start\s+assessment/i.test(message.trim())) {
      await StudentProfile.findOneAndDelete({ sessionId: sid });
      const agentResult = await processAgentMessage(message.trim(), sid);
      result = { response: agentResult.response, intent: 'AGENT_START', context: session.context };
    } else {
      const profile = await StudentProfile.findOne({ sessionId: sid });
      if (profile && !profile.profileComplete) {
        const agentResult = await processAgentMessage(message.trim(), sid);
        result = { response: agentResult.response, intent: `AGENT_${agentResult.stage?.toUpperCase()}`, context: session.context };
      } else {
        result = await processMessage(message.trim(), session.context || {}, historyForAI, sid);
      }
    }
  }

  session.messages.push({ role: 'user', content: message.trim(), intent: result.intent });
  session.messages.push({ role: 'assistant', content: result.response, intent: result.intent });
  session.context = result.context;
  session.totalMessages = session.messages.length;
  await session.save();

  return res.status(200).json({
    success: true,
    sessionId: sid,
    response: result.response,
    intent: result.intent,
    timestamp: new Date().toISOString()
  });
};

const getChatHistory = async (req, res) => {
  const session = await ChatHistory.findOne({ sessionId: req.params.sessionId });
  if (!session) return res.status(404).json({ success: false, message: 'Session not found.' });
  return res.status(200).json({ success: true, sessionId: session.sessionId, messages: session.messages, context: session.context });
};

const clearChatHistory = async (req, res) => {
  await ChatHistory.deleteOne({ sessionId: req.params.sessionId });
  await StudentProfile.findOneAndDelete({ sessionId: req.params.sessionId });
  return res.status(200).json({ success: true, message: 'Chat and profile cleared.' });
};

module.exports = { chat, getChatHistory, clearChatHistory };

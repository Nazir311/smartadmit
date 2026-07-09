require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
const connectDB = require('./config/db');

const chatRoutes = require('./routes/chatRoutes');
const departmentRoutes = require('./routes/departmentRoutes');
const recommendRoutes = require('./routes/recommendRoutes');
const faqRoutes = require('./routes/faqRoutes');
const profileRoutes = require('./routes/profileRoutes');
const reportRoutes = require('./routes/reportRoutes');
const adminRoutes = require('./routes/adminRoutes');

const errorHandler = require('./middleware/errorHandler');

const app = express();
const PORT = process.env.PORT || 3000;

// Database Connection
connectDB();

// Middleware
app.use(helmet());
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type']
}));

app.use(rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 300,
  message: {
    success: false,
    message: 'Too many requests.'
  }
}));

app.use(express.json({ limit: '2mb' }));
app.use(morgan('dev'));

// Root Route
app.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'DIU SmartAdmit API running',
    version: '2.0.0',
    endpoints: {
      health: 'GET /api/health',
      chat: 'POST /api/chat',
      departments: 'GET /api/departments',
      recommend: 'POST /api/recommend',
      faq: 'GET /api/faq',
      profile: 'GET /api/profile/:sessionId',
      report: 'POST /api/report',
      admin: 'GET /api/admin/dashboard'
    }
  });
});

// Health Check Route
app.get('/api/health', (req, res) => {
  res.status(200).json({
    success: true,
    status: 'online',
    message: 'DIU SmartAdmit Backend Running',
    database: 'connected',
    timestamp: new Date().toISOString()
  });
});

// API Routes
app.use('/api/chat', chatRoutes);
app.use('/api/departments', departmentRoutes);
app.use('/api/recommend', recommendRoutes);
app.use('/api/faq', faqRoutes);
app.use('/api/profile', profileRoutes);
app.use('/api/report', reportRoutes);
app.use('/api/admin', adminRoutes);

// 404 Handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route not found'
  });
});

// Error Handler
app.use(errorHandler);

// Start Server
app.listen(PORT, () => {
  console.log(`DIU SmartAdmit backend running on http://localhost:${PORT}`);
});

module.exports = app;
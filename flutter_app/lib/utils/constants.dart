class AppConstants {
  // For Chrome/Web
  static const String baseUrl = 'http://localhost:3000/api';

  static const String chatEndpoint = '/chat';
  static const String departmentsEndpoint = '/departments';
  static const String recommendEndpoint = '/recommend';
  static const String faqEndpoint = '/faq';
  static const String profileEndpoint = '/profile';
  static const String reportEndpoint = '/report';

  static const String appName = 'DIU SmartAdmit';
  static const String appSubtitle = 'AI Admission & Career Guidance';

  static const String sessionKey = 'smartadmit_session_id';
  static const String historyKey = 'smartadmit_history';
  static const String modeKey = 'smartadmit_chat_mode';

  static const Duration timeout = Duration(seconds: 30);

  static const String welcomeMessage =
      '👋 **Hello! Welcome to DIU SmartAdmit!**\n\n'
      'I\'m your AI-powered Admission & Career Guidance Assistant for **Daffodil International University**.\n\n'
      '**What I can do:**\n'
      '• 🤖 **Agent Mode** — Personalized step-by-step assessment\n'
      '• 💬 **Free Chat** — Ask any admission question\n'
      '• 🎯 **Confidence Scoring** — AI-powered department matching\n'
      '• 👨‍👩‍👧 **Parent Mode** — Summaries in English & Bangla\n'
      '• 📊 **Career Roadmap** — 4-year learning plan\n'
      '• 📄 **PDF Report** — Download your admission report\n\n'
      'Type **"Start Assessment"** for personalized guidance, or just ask me anything! 😊';

  static const List<Map<String, String>> quickPrompts = [
    {'label': '🤖 Start Assessment', 'value': 'Start Assessment'},
    {'label': '🏛️ All Departments', 'value': 'List all available departments'},
    {'label': '⚖️ CSE vs SWE', 'value': 'Compare CSE and SWE'},
    {'label': '💰 Tuition Fees', 'value': 'What are the tuition fees at DIU?'},
    {'label': '🎓 Scholarships', 'value': 'What scholarships are available at DIU?'},
    {'label': '📋 How to Apply', 'value': 'How do I apply for admission at DIU?'},
    {'label': '📝 Exam Format', 'value': 'What is the admission test format?'},
    {'label': '📅 Deadline', 'value': 'What is the admission deadline?'},
  ];
}
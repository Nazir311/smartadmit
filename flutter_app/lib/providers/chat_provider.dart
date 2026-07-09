import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/message_model.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class ChatProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  final _uuid = const Uuid();

  final List<MessageModel> _messages = [];
  bool _isLoading = false;
  bool _isTyping = false;
  String _sessionId = '';
  bool _serverOnline = false;
  String _chatMode = 'free'; // 'free' or 'agent'

  List<MessageModel> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  bool get isTyping => _isTyping;
  String get sessionId => _sessionId;
  bool get serverOnline => _serverOnline;
  String get chatMode => _chatMode;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _sessionId = prefs.getString(AppConstants.sessionKey) ?? '';
    if (_sessionId.isEmpty) {
      _sessionId = _uuid.v4();
      await prefs.setString(AppConstants.sessionKey, _sessionId);
    }
    final cached = prefs.getString(AppConstants.historyKey);
    if (cached != null && cached.isNotEmpty) {
      _messages.addAll(MessageModel.decodeList(cached));
    }
    if (_messages.isEmpty) {
      _addBotMessage(AppConstants.welcomeMessage);
    }
    _serverOnline = await _api.healthCheck();
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _isLoading) return;

    _messages.add(MessageModel(id: _uuid.v4(), content: trimmed, role: MessageRole.user, timestamp: DateTime.now()));
    _isLoading = true;
    _isTyping = true;
    notifyListeners();

    final result = await _api.sendChatMessage(message: trimmed, sessionId: _sessionId, mode: _chatMode);

    _isTyping = false;
    _isLoading = false;
    _addBotMessage(result['response'] as String? ?? 'Something went wrong. Please try again.');

    await _saveHistory();
    notifyListeners();
  }

  void setMode(String mode) {
    _chatMode = mode;
    notifyListeners();
  }

  Future<void> clearChat() async {
    _messages.clear();
    _sessionId = _uuid.v4();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.sessionKey, _sessionId);
    await prefs.remove(AppConstants.historyKey);
    _addBotMessage(AppConstants.welcomeMessage);
    notifyListeners();
  }

  void _addBotMessage(String content) {
    _messages.add(MessageModel(id: _uuid.v4(), content: content, role: MessageRole.assistant, timestamp: DateTime.now()));
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final toSave = _messages.length > 60 ? _messages.sublist(_messages.length - 60) : _messages;
    await prefs.setString(AppConstants.historyKey, MessageModel.encodeList(toSave));
  }
}

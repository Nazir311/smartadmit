import 'dart:convert';

enum MessageRole { user, assistant }

class MessageModel {
  final String id;
  final String content;
  final MessageRole role;
  final DateTime timestamp;

  const MessageModel({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
  });

  bool get isUser => role == MessageRole.user;

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'role': role.name,
    'timestamp': timestamp.toIso8601String(),
  };

  factory MessageModel.fromJson(Map<String, dynamic> j) => MessageModel(
    id: j['id'] as String? ?? '',
    content: j['content'] as String? ?? '',
    role: (j['role'] as String?) == 'user' ? MessageRole.user : MessageRole.assistant,
    timestamp: DateTime.tryParse(j['timestamp'] as String? ?? '') ?? DateTime.now(),
  );

  static String encodeList(List<MessageModel> list) =>
      jsonEncode(list.map((m) => m.toJson()).toList());

  static List<MessageModel> decodeList(String src) {
    try {
      return (jsonDecode(src) as List).map((e) => MessageModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }
}

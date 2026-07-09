import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/message_model.dart';
import '../utils/app_theme.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser) ...[_BotAvatar(), const SizedBox(width: 8)],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                message.isUser
                    ? _UserBubble(content: message.content)
                    : _BotBubble(content: message.content),
                const SizedBox(height: 3),
                _Timestamp(time: message.timestamp),
              ],
            ),
          ),
          if (message.isUser) ...[const SizedBox(width: 8), _UserAvatar()],
        ],
      ),
    );
  }
}

class _BotAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [AppTheme.primary, Color(0xFF3B82F6)]),
          borderRadius: BorderRadius.circular(9),
        ),
        child: const Center(child: Text('🤖', style: TextStyle(fontSize: 14))),
      );
}

class _UserAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
            color: AppTheme.accent, borderRadius: BorderRadius.circular(9)),
        child: const Icon(Icons.person, color: Colors.white, size: 17),
      );
}

class _UserBubble extends StatelessWidget {
  final String content;
  const _UserBubble({required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.70),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.userBubble,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(4),
        ),
        boxShadow: [
          BoxShadow(
              color: AppTheme.primary.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Text(content,
          style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.45)),
    );
  }
}

class _BotBubble extends StatelessWidget {
  final String content;
  const _BotBubble({required this.content});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: content));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Copied'), duration: Duration(seconds: 1)));
      },
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.76),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.botBubble,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          border: Border.all(color: AppTheme.divider),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04), blurRadius: 6)
          ],
        ),
        child: MarkdownBody(
          data: content,
          selectable: true,
          styleSheet: MarkdownStyleSheet(
            p: const TextStyle(
                fontSize: 14, color: AppTheme.botText, height: 1.5),
            strong: const TextStyle(
                fontSize: 14,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700),
            h1: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppTheme.primary),
            h2: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary),
            h3: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary),
            listBullet:
                const TextStyle(fontSize: 14, color: AppTheme.primary),
            tableBody: const TextStyle(
                fontSize: 12, color: AppTheme.textPrimary),
            tableHead: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary),
            blockquote: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                fontStyle: FontStyle.italic),
            code: const TextStyle(
                fontSize: 12,
                color: AppTheme.primary,
                backgroundColor: AppTheme.primaryLight),
          ),
        ),
      ),
    );
  }
}

class _Timestamp extends StatelessWidget {
  final DateTime time;
  const _Timestamp({required this.time});

  @override
  Widget build(BuildContext context) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return Text('$h:$m',
        style: const TextStyle(fontSize: 10, color: AppTheme.textHint));
  }
}

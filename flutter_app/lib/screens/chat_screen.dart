import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/message_model.dart';
import '../providers/chat_provider.dart';
import '../providers/recommendation_provider.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';
import 'recommendation_screen.dart';


class ChatScreen extends StatefulWidget {
  final String? initialMessage;
  const ChatScreen({super.key, this.initialMessage});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await context.read<ChatProvider>().sendMessage(widget.initialMessage!);
        _scrollToBottom();
        _checkAssessmentComplete();
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    _ctrl.clear();
    _focus.unfocus();
    await context.read<ChatProvider>().sendMessage(text);
    _scrollToBottom();
    _checkAssessmentComplete();
  }

  void _checkAssessmentComplete() {
    final msgs = context.read<ChatProvider>().messages;
    if (msgs.isEmpty) return;
    final last = msgs.last;
    if (last.role == MessageRole.assistant &&
        last.content.contains('Personalized Department Recommendations')) {
      final sessionId = context.read<ChatProvider>().sessionId;
      context.read<RecommendationProvider>().loadRecommendation(sessionId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _OfflineBanner(),
          Expanded(child: _MessageList(scroll: _scroll, onBottomNeeded: _scrollToBottom)),
          _RecommendationBanner(),
          _QuickReplies(onTap: (v) async {
            await context.read<ChatProvider>().sendMessage(v);
                _scrollToBottom();
                _checkAssessmentComplete();   
          }),
          _InputBar(ctrl: _ctrl, focus: _focus, onSend: _send),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.surface,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppTheme.primary, Color(0xFF3B82F6)]),
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Center(child: Text('🤖', style: TextStyle(fontSize: 15))),
        ),
        const SizedBox(width: 8),
        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('DIU SmartAdmit AI',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          Text('Admission Assistant',
              style: TextStyle(fontSize: 10, color: AppTheme.accent)),
        ]),
      ]),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppTheme.textSecondary),
          onSelected: (v) {
            if (v == 'clear') _confirmClear();
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: 'clear',
              child: Row(children: [
                Icon(Icons.delete_outline, size: 16, color: AppTheme.error),
                SizedBox(width: 8),
                Text('Clear chat'),
              ]),
            ),
          ],
        ),
      ],
    );
  }

  void _confirmClear() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear Chat'),
        content: const Text('Delete all messages and start a new session?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ChatProvider>().clearChat();
              context.read<RecommendationProvider>().clear();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (_, p, __) => p.serverOnline
          ? const SizedBox.shrink()
          : Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              color: AppTheme.warning.withOpacity(0.12),
              child: const Row(children: [
                Icon(Icons.warning_amber_rounded, size: 13, color: AppTheme.warning),
                SizedBox(width: 6),
                Text('Server offline — start backend on port 3000',
                    style: TextStyle(fontSize: 11, color: AppTheme.warning)),
              ]),
            ),
    );
  }
}

class _MessageList extends StatelessWidget {
  final ScrollController scroll;
  final VoidCallback onBottomNeeded;

  const _MessageList({required this.scroll, required this.onBottomNeeded});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (_, provider, __) {
        WidgetsBinding.instance.addPostFrameCallback((_) => onBottomNeeded());
        return ListView.builder(
          controller: scroll,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          itemCount: provider.messages.length + (provider.isTyping ? 1 : 0),
          itemBuilder: (ctx, i) {
            if (provider.isTyping && i == provider.messages.length) {
              return const TypingIndicator();
            }
            return MessageBubble(message: provider.messages[i]);
          },
        );
      },
    );
  }
}

class _RecommendationBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<RecommendationProvider>(
      builder: (_, recP, __) => recP.hasRecommendation
          ? GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RecommendationScreen()),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: AppTheme.accentLight,
                child: const Row(children: [
                  Text('🎯', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Recommendations ready! Tap to view confidence scores.',
                      style: TextStyle(fontSize: 12, color: AppTheme.accent, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 12, color: AppTheme.accent),
                ]),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

class _QuickReplies extends StatelessWidget {
  final Function(String) onTap;
  const _QuickReplies({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (_, p, __) {
        if (p.isLoading) return const SizedBox.shrink();
        return Container(
          height: 40,
          color: AppTheme.surface,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            itemCount: AppConstants.quickPrompts.length,
            itemBuilder: (ctx, i) {
              final q = AppConstants.quickPrompts[i];
              return GestureDetector(
                onTap: () => onTap(q['value']!),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
                  ),
                  child: Center(
                    child: Text(
                      q['label']!,
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController ctrl;
  final FocusNode focus;
  final VoidCallback onSend;

  const _InputBar({required this.ctrl, required this.focus, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          12, 10, 12, MediaQuery.of(context).padding.bottom + 10),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.divider)),
      ),
      child: Row(children: [
        Expanded(
  child: CallbackShortcuts(
    bindings: {
      const SingleActivator(LogicalKeyboardKey.enter): () {
        if (ctrl.text.trim().isNotEmpty) {
          onSend();
        }
      },
    },
    child: TextField(
  controller: ctrl,
  focusNode: focus,
  minLines: 1,
  maxLines: 1,
  keyboardType: TextInputType.text,
  textInputAction: TextInputAction.send,
  textCapitalization: TextCapitalization.sentences,
  style: const TextStyle(
    fontSize: 14,
    color: AppTheme.textPrimary,
  ),
  decoration: const InputDecoration(
    hintText: 'Ask about DIU admission...',
  ),
  onSubmitted: (_) => onSend(),
),
  ),
),
        const SizedBox(width: 10),
        Consumer<ChatProvider>(
          builder: (_, p, __) => GestureDetector(
            onTap: p.isLoading ? null : onSend,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: p.isLoading ? AppTheme.textHint : AppTheme.primary,
                borderRadius: BorderRadius.circular(22),
                boxShadow: p.isLoading
                    ? []
                    : [BoxShadow(
                        color: AppTheme.primary.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3))],
              ),
              child: Icon(
                p.isLoading ? Icons.hourglass_empty_rounded : Icons.send_rounded,
                color: Colors.white,
                size: 19,
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

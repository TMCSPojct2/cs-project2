import 'package:flutter/material.dart';
import '../data/assistant_content.dart';
import '../data/language_controller.dart';
import '../data/role_context.dart';
import '../services/assistant_api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/common_widgets.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  final List<String> _recentPrompts = [];
  String? _lastPrompt;
  bool _isTyping = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final role = currentUserRole(context);
    final suggestions = assistantSuggestionsForRole(role);

    return AppScaffold(
      bottomNavigationBar: RoleBottomNav(currentIndex: -1, items: NavItems.forRole(role), role: role),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
        child: Column(
          children: [
            BrandHeader(
              subtitle: LanguageController.text('${role.label} assistant', 'مساعد ${role.label}'),
              trailing: IconButton(onPressed: () => smartBack(context, currentUserRole(context)), icon: const Icon(Icons.arrow_back_rounded)),
            ),
            const SizedBox(height: 18),
            SurfaceCard(
              padding: const EdgeInsets.all(20),
              gradient: const LinearGradient(colors: [Color(0xFF152B44), Color(0xFF26476D), Color(0xFF315E8E)]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: .12), borderRadius: BorderRadius.circular(18)),
                        child: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
                      ),
                      const SizedBox(width: 14),
                      Text(LanguageController.text('NABIH Assistant', 'مساعد NABIH'), style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(_assistantRoleDescription(role), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: .78))),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: SurfaceCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    Expanded(child: _buildThread(context, role, suggestions)),
                    _PromptRail(
                      title: _recentPrompts.isEmpty ? LanguageController.text('Suggested prompts', 'اقتراحات') : LanguageController.text('Recent prompts', 'آخر الأسئلة'),
                      prompts: _recentPrompts.isEmpty ? suggestions : _recentPrompts,
                      onSelected: _usePrompt,
                    ),
                    _InputBar(
                      controller: _controller,
                      enabled: !_isTyping,
                      onSubmitted: () { _sendMessage(role); },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThread(BuildContext context, UserRole role, List<String> suggestions) {
    if (_messages.isEmpty && !_isTyping) {
      return _EmptyAssistantState(
        role: role,
        suggestions: suggestions.take(3).toList(),
        onSelected: _usePrompt,
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isTyping && index == _messages.length) {
          return const _TypingBubble();
        }
        return _MessageBubble(
          message: _messages[index],
          role: role,
          onAction: (action) => Navigator.pushNamed(context, action.route, arguments: role),
          onRegenerate: _messages[index].canRegenerate && _lastPrompt != null ? () { _regenerate(role); } : null,
        );
      },
    );
  }

  void _usePrompt(String prompt) {
    if (_isTyping) return;
    _controller.text = prompt;
    _controller.selection = TextSelection.collapsed(offset: prompt.length);
    _sendMessage(currentUserRole(context));
  }

  Future<void> _sendMessage(UserRole role) async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(LanguageController.text('Type a message first', 'اكتب رسالة أولًا'))));
      return;
    }
    if (_isTyping) {
      return;
    }

    setState(() {
      _controller.clear();
      _lastPrompt = text;
      _rememberPrompt(text);
      _messages.add(_ChatMessage.user(text));
      _isTyping = true;
    });
    _scrollToBottom();

    try {
      final apiReply = await AssistantApiService.instance.sendMessage(message: text, role: role);
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(_ChatMessage.assistant(apiReply, canRegenerate: true));
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(_ChatMessage.assistant(LanguageController.text('Unable to reach the assistant right now. Please try again shortly.', 'تعذر الاتصال بالمساعد الآن. حاول مرة أخرى بعد قليل.'), canRegenerate: true));
      });
    }
    _scrollToBottom();
  }

  Future<void> _regenerate(UserRole role) async {
    final prompt = _lastPrompt;
    if (prompt == null || _isTyping) {
      return;
    }

    setState(() {
      for (var i = _messages.length - 1; i >= 0; i--) {
        if (!_messages[i].isUser && _messages[i].canRegenerate) {
          _messages.removeAt(i);
          break;
        }
      }
      _isTyping = true;
    });
    _scrollToBottom();

    try {
      final apiReply = await AssistantApiService.instance.sendMessage(message: prompt, role: role);
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(_ChatMessage.assistant(apiReply, canRegenerate: true));
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(_ChatMessage.assistant(LanguageController.text('Unable to reach the assistant right now. Please try again shortly.', 'تعذر الاتصال بالمساعد الآن. حاول مرة أخرى بعد قليل.'), canRegenerate: true));
      });
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(LanguageController.text('Reply refreshed', 'تم تحديث الرد'))));
    _scrollToBottom();
  }

  void _rememberPrompt(String prompt) {
    _recentPrompts.remove(prompt);
    _recentPrompts.insert(0, prompt);
    if (_recentPrompts.length > 4) {
      _recentPrompts.removeLast();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    });
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  final List<AssistantAction> actions;
  final bool canRegenerate;

  const _ChatMessage({
    required this.text,
    required this.isUser,
    this.actions = const [],
    this.canRegenerate = false,
  });

  factory _ChatMessage.user(String text) {
    return _ChatMessage(text: text, isUser: true);
  }

  factory _ChatMessage.assistant(String text, {List<AssistantAction> actions = const [], bool canRegenerate = false}) {
    return _ChatMessage(text: text, isUser: false, actions: actions, canRegenerate: canRegenerate);
  }
}

String _assistantRoleDescription(UserRole role) {
  switch (role) {
    case UserRole.faculty:
      return LanguageController.text('Ask about teaching flow, section messages, university updates, or room guidance.', 'اسأل عن سير التدريس أو رسائل الشعب أو تحديثات الجامعة أو إرشاد الغرف.');
    case UserRole.admin:
      return LanguageController.text('Ask about campus announcements, public events, operational updates, or communication priorities.', 'اسأل عن إعلانات الحرم أو الفعاليات العامة أو التحديثات التشغيلية أو أولويات التواصل.');
    case UserRole.visitor:
      return LanguageController.text('Ask about visitor entry, public events, campus services, or where to go first.', 'اسأل عن دخول الزوار أو الفعاليات العامة أو خدمات الحرم أو أول وجهة مناسبة.');
    case UserRole.student:
      return LanguageController.text('Ask about classes, schedule priorities, GPA planning, alerts, or campus guidance.', 'اسأل عن المحاضرات أو أولويات الجدول أو تخطيط المعدل أو التنبيهات أو إرشاد الحرم.');
  }
}

class _EmptyAssistantState extends StatelessWidget {
  final UserRole role;
  final List<String> suggestions;
  final ValueChanged<String> onSelected;

  const _EmptyAssistantState({required this.role, required this.suggestions, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 12),
      children: [
        ...suggestions.map(
          (prompt) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _PromptTile(prompt: LanguageController.translateRaw(prompt), onTap: () => onSelected(prompt)),
          ),
        ),
      ],
    );
  }

}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;
  final UserRole role;
  final ValueChanged<AssistantAction> onAction;
  final VoidCallback? onRegenerate;

  const _MessageBubble({
    required this.message,
    required this.role,
    required this.onAction,
    this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final bubbleColor = isUser ? AppColors.primary : AppColors.mist;
    final textColor = isUser ? Colors.white : AppColors.ink;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: MediaQuery.of(context).size.width * .76,
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isUser) _AssistantIdentity(role: role),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(22),
                  topRight: const Radius.circular(22),
                  bottomLeft: Radius.circular(isUser ? 22 : 8),
                  bottomRight: Radius.circular(isUser ? 8 : 22),
                ),
                border: isUser ? null : Border.all(color: AppColors.line),
              ),
              child: Text(LanguageController.translateRaw(message.text), style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: textColor)),
            ),
            if (!isUser && (message.actions.isNotEmpty || onRegenerate != null)) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...message.actions.map((action) => _AssistantActionChip(action: action, onTap: () => onAction(action))),
                  if (onRegenerate != null)
                    _SmallActionChip(label: LanguageController.text('Regenerate', 'إعادة التوليد'), icon: Icons.refresh_rounded, onTap: onRegenerate!),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AssistantIdentity extends StatelessWidget {
  final UserRole role;

  const _AssistantIdentity({required this.role});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: .1), borderRadius: BorderRadius.circular(9)),
            child: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 15),
          ),
          const SizedBox(width: 8),
          Text('NABIH', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.w800)),
          const SizedBox(width: 6),
          Text(role.label, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.mist,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 18),
            const SizedBox(width: 10),
            Text(LanguageController.text('NABIH is typing', 'NABIH يكتب الآن'), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.ink)),
          ],
        ),
      ),
    );
  }
}

class _PromptRail extends StatelessWidget {
  final String title;
  final List<String> prompts;
  final ValueChanged<String> onSelected;

  const _PromptRail({required this.title, required this.prompts, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.line))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(LanguageController.translateRaw(title), style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800, color: AppColors.ink)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: prompts.map((prompt) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _PromptChip(label: LanguageController.translateRaw(prompt), onTap: () => onSelected(prompt)),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSubmitted;

  const _InputBar({required this.controller, required this.enabled, required this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.line))),
      child: Directionality(
        textDirection: LanguageController.direction,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSubmitted(),
                decoration: InputDecoration(
                  hintText: LanguageController.text('Message NABIH', 'اكتب رسالة إلى NABIH'),
                  prefixIcon: const Icon(Icons.chat_bubble_outline_rounded),
                ),
              ),
            ),
            const SizedBox(width: 10),
            InkWell(
              onTap: enabled ? onSubmitted : null,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: enabled ? AppColors.primary : AppColors.line,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.arrow_upward_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromptTile extends StatelessWidget {
  final String prompt;
  final VoidCallback onTap;

  const _PromptTile({required this.prompt, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            const Icon(Icons.auto_awesome_outlined, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(prompt, style: Theme.of(context).textTheme.bodyLarge)),
            const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

class _PromptChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PromptChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 260),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.mist,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.line),
        ),
        child: Text(label, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.ink)),
      ),
    );
  }
}

class _AssistantActionChip extends StatelessWidget {
  final AssistantAction action;
  final VoidCallback onTap;

  const _AssistantActionChip({required this.action, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _SmallActionChip(label: LanguageController.translateRaw(action.label), icon: action.icon, onTap: onTap);
  }
}

class _SmallActionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SmallActionChip({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 7),
            Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

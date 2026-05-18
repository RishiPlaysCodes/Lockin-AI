import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  String _currentMode = 'general';

  final List<Map<String, String>> _modes = [
    {'key': 'general', 'label': 'General'},
    {'key': 'teacher', 'label': 'Teacher'},
    {'key': 'quiz', 'label': 'Quiz'},
    {'key': 'motivate', 'label': 'Motivate'},
  ];

  final List<String> _quickPrompts = [
    'Give me a focus tip',
    'Create a study plan',
    'Motivate me',
    'Quiz me on study habits',
    'How to avoid distractions?',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final appProvider = Provider.of<AppProvider>(context, listen: false);
    appProvider.addChatMessage('user', text, _currentMode);
    _messageController.clear();

    // Generate AI response
    Future.delayed(const Duration(milliseconds: 500), () {
      final response = _generateResponse(text, _currentMode);
      appProvider.addChatMessage('assistant', response, _currentMode);
      _scrollToBottom();
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _generateResponse(String input, String mode) {
    final lower = input.toLowerCase();

    if (mode == 'motivate') {
      if (lower.contains('tired') || lower.contains('exhausted')) {
        return "It's okay to feel tired! Take a short 5-minute break, stretch, drink water, "
            "and come back stronger. Even 15 focused minutes is better than an unfocused hour. "
            "You've got this! \u{1F4AA}";
      }
      if (lower.contains('give up') || lower.contains('quit')) {
        return "Remember why you started! Every expert was once a beginner. "
            "Your future self will thank you for not giving up today. "
            "Take it one session at a time. \u{1F31F}";
      }
      return "You're doing amazing! Every minute of focus brings you closer to your goals. "
          "Stay consistent and trust the process. Small steps lead to big results! \u{1F680}";
    }

    if (mode == 'teacher') {
      if (lower.contains('pomodoro') || lower.contains('technique')) {
        return "The Pomodoro Technique involves working in 25-minute focused intervals "
            "followed by 5-minute breaks. After 4 pomodoros, take a longer 15-30 minute break. "
            "This helps maintain concentration and prevents burnout.";
      }
      if (lower.contains('study') && lower.contains('plan')) {
        return "Here's a study plan framework:\n\n"
            "1. Set clear goals for each session\n"
            "2. Break subjects into small chunks\n"
            "3. Use active recall (test yourself)\n"
            "4. Space your reviews over days\n"
            "5. Start with the hardest subject\n"
            "6. Take breaks every 25-45 minutes\n\n"
            "Would you like help with a specific subject?";
      }
      return "Great question! To be more effective in your studies, focus on understanding "
          "concepts rather than memorizing. Use active recall, spaced repetition, and teach "
          "what you learn to others. What subject would you like help with?";
    }

    if (mode == 'quiz') {
      if (lower.contains('study') || lower.contains('habit')) {
        return "Quiz Time! \u{1F4DD}\n\n"
            "Q: What is the optimal study session length for maximum retention?\n\n"
            "A) 15 minutes\nB) 25-50 minutes\nC) 2 hours\nD) 4 hours\n\n"
            "Think about it and reply with your answer!";
      }
      if (lower.contains('a') || lower.contains('b') || lower.contains('c') || lower.contains('d')) {
        return "The answer is B) 25-50 minutes! \u{2705}\n\n"
            "Research shows that focused study sessions of 25-50 minutes with breaks "
            "in between optimize retention. This aligns with the Pomodoro Technique. "
            "Want another question?";
      }
      return "Let's test your knowledge! \u{1F9E0}\n\n"
          "Q: Which of these is the most effective study technique?\n\n"
          "A) Re-reading notes\nB) Highlighting text\n"
          "C) Active recall & self-testing\nD) Copying notes\n\n"
          "What's your answer?";
    }

    // General mode
    if (lower.contains('hello') || lower.contains('hi') || lower.contains('hey')) {
      return "Hey there! \u{1F44B} I'm your Focus Guardian AI assistant. "
          "I can help you with study tips, motivation, quizzes, and creating study plans. "
          "What can I help you with today?";
    }
    if (lower.contains('focus') && lower.contains('tip')) {
      return "Here are some focus tips:\n\n"
          "\u{1F3AF} Remove all notifications before starting\n"
          "\u{1F3B5} Try lo-fi music or white noise\n"
          "\u{1F4F1} Put your phone in another room\n"
          "\u{2615} Stay hydrated\n"
          "\u{1F4CB} Write down your top 3 priorities\n"
          "\u{23F0} Use the Pomodoro technique (25 min focus, 5 min break)\n\n"
          "Would you like me to elaborate on any of these?";
    }
    if (lower.contains('distract')) {
      return "To manage distractions effectively:\n\n"
          "1. Use website blockers during study time\n"
          "2. Set your phone to Do Not Disturb\n"
          "3. Let people around you know you're studying\n"
          "4. Create a dedicated study space\n"
          "5. Keep a 'distraction notepad' - write down thoughts to address later\n\n"
          "The Focus Guardian app can help track and reduce your distractions over time!";
    }
    if (lower.contains('motivat')) {
      return "Remember: discipline beats motivation! \u{1F4AA}\n\n"
          "Motivation is fleeting, but habits last. Here's what works:\n"
          "- Start with just 5 minutes (the hardest part is starting)\n"
          "- Reward yourself after sessions\n"
          "- Track your streak - don't break the chain!\n"
          "- Visualize your future self succeeding\n\n"
          "You're already ahead of most people by being here! \u{1F31F}";
    }
    if (lower.contains('plan') || lower.contains('schedule')) {
      return "Let me help you create a study plan! \u{1F4C5}\n\n"
          "A good study plan includes:\n"
          "1. Specific time blocks for each subject\n"
          "2. Short breaks between sessions (5-10 min)\n"
          "3. A longer break after 2 hours\n"
          "4. Review sessions for spaced repetition\n"
          "5. One rest day per week\n\n"
          "What subjects are you studying? I can help you organize them!";
    }

    return "I'm here to help you stay focused and productive! \u{1F4A1}\n\n"
        "Try asking me about:\n"
        "\u{2022} Focus tips and techniques\n"
        "\u{2022} Study plans and schedules\n"
        "\u{2022} Motivation and mindset\n"
        "\u{2022} How to deal with distractions\n\n"
        "Or switch to a different mode above for specialized help!";
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final messages = appProvider.chatHistory;

    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'AI Chat',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.textMuted, size: 20),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppColors.card,
                        title: const Text('Clear Chat?', style: TextStyle(color: AppColors.textPrimary)),
                        content: const Text('This will delete all messages.', style: TextStyle(color: AppColors.textMuted)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
                          ),
                          TextButton(
                            onPressed: () {
                              appProvider.clearChat();
                              Navigator.pop(ctx);
                            },
                            child: const Text('Clear', style: TextStyle(color: AppColors.accent)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Mode selector
          Container(
            height: 38,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _modes.length,
              itemBuilder: (context, index) {
                final mode = _modes[index];
                final isSelected = mode['key'] == _currentMode;
                return GestureDetector(
                  onTap: () => setState(() => _currentMode = mode['key']!),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.cardBorder,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      mode['label']!,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textMuted,
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Messages
          Expanded(
            child: messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isUser = msg.role == 'user';
                      return _buildMessageBubble(msg.content, isUser);
                    },
                  ),
          ),

          // Quick prompts
          if (messages.isEmpty || messages.length < 3)
            SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _quickPrompts.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      _messageController.text = _quickPrompts[index];
                      _sendMessage();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _quickPrompts[index],
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 8),

          // Input area
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
            decoration: const BoxDecoration(
              color: AppColors.card,
              border: Border(top: BorderSide(color: AppColors.cardBorder)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ask anything...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.dark,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                    ),
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                    child: const Icon(Icons.send, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.1),
            ),
            child: const Icon(Icons.smart_toy_outlined, color: AppColors.primary, size: 40),
          ),
          const SizedBox(height: 16),
          const Text(
            'Focus Guardian AI',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ask me anything about studying,\nfocus, or motivation!',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String content, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : AppColors.card,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
          ),
          border: isUser ? null : Border.all(color: AppColors.cardBorder),
        ),
        child: Text(
          content,
          style: TextStyle(
            color: isUser ? Colors.white : AppColors.textPrimary,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

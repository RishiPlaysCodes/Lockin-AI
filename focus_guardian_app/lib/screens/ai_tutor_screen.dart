import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/ai_service.dart';
import '../providers/app_provider.dart';
import '../utils/theme.dart';

/// Professional AI Tutor Screen - ChatGPT-like interface
/// NO hardcoded responses. Real LLM-powered conversation.
class AITutorScreen extends StatefulWidget {
  const AITutorScreen({super.key});

  @override
  State<AITutorScreen> createState() => _AITutorScreenState();
}

class _AITutorScreenState extends State<AITutorScreen> with TickerProviderStateMixin {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  final AIService _aiService = AIService();

  String _currentMode = 'tutor';
  bool _isLoading = false;
  bool _isConfigured = false;
  String? _errorMessage;
  final List<_ChatMessage> _messages = [];

  // Mode definitions
  static const List<_ModeConfig> _modes = [
    _ModeConfig(
      key: 'tutor',
      label: 'Tutor',
      icon: Icons.school_rounded,
      color: Color(0xFF6C63FF),
      description: 'AI teaches you. Ask doubts, get explanations.',
    ),
    _ModeConfig(
      key: 'student',
      label: 'Student',
      icon: Icons.back_hand_rounded,
      color: Color(0xFF4ECDC4),
      description: 'AI pretends to be a student. YOU teach and correct it.',
    ),
    _ModeConfig(
      key: 'quiz',
      label: 'Quiz',
      icon: Icons.quiz_rounded,
      color: Color(0xFFFECA57),
      description: 'AI quizzes you. Tracks score and weak areas.',
    ),
    _ModeConfig(
      key: 'guardian',
      label: 'Guardian',
      icon: Icons.shield_rounded,
      color: Color(0xFFFF6B6B),
      description: 'AI monitors your discipline. Strict accountability.',
    ),
    _ModeConfig(
      key: 'planner',
      label: 'Planner',
      icon: Icons.calendar_month_rounded,
      color: Color(0xFF06D6A0),
      description: 'AI creates study plans. Tracks progress.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAI();
  }

  Future<void> _initializeAI() async {
    await _aiService.initialize();
    setState(() {
      _isConfigured = _aiService.isConfigured;
    });

    if (!_isConfigured) {
      _addSystemMessage(
        '⚙️ **AI not configured yet.**\n\n'
        'To use the real AI tutor, add your API key:\n'
        '• Go to **Settings > AI Configuration**\n'
        '• Add your OpenAI or Gemini API key\n'
        '• Get key from: platform.openai.com or ai.google.dev\n\n'
        'Once configured, I can teach like ChatGPT, quiz you, create study plans, and more.',
      );
    } else {
      _addSystemMessage(
        '🎓 **AI Tutor ready!** (${_aiService.currentProvider} / ${_aiService.currentModel})\n\n'
        'Current mode: **Tutor** - I\'ll explain concepts, answer doubts, and help you learn.\n\n'
        'Switch modes using the tabs above:\n'
        '• 🎓 **Tutor** - I teach you\n'
        '• 🙋 **Student** - You teach me (I make mistakes for you to correct)\n'
        '• 📝 **Quiz** - I test your knowledge\n'
        '• 🛡️ **Guardian** - I keep you accountable\n'
        '• 📅 **Planner** - I create study schedules\n\n'
        'What would you like to study?',
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addSystemMessage(String content) {
    setState(() {
      _messages.add(_ChatMessage(role: 'system', content: content, timestamp: DateTime.now()));
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    // Add user message
    setState(() {
      _messages.add(_ChatMessage(role: 'user', content: text, timestamp: DateTime.now()));
      _isLoading = true;
      _errorMessage = null;
    });
    _messageController.clear();
    _scrollToBottom();

    // Get student context
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final profile = appProvider.profile;

    try {
      final response = await _aiService.getResponse(
        message: text,
        mode: _currentMode,
        studentContext: {
          'level': profile.level,
          'streak': profile.streakDays,
          'focus_score': profile.focusScore,
          'total_study_hours': profile.totalStudyHours.toStringAsFixed(1),
        },
      );

      setState(() {
        _messages.add(_ChatMessage(role: 'assistant', content: response, timestamp: DateTime.now()));
        _isLoading = false;
      });

      // Save to chat history
      appProvider.addChatMessage('user', text, _currentMode);
      appProvider.addChatMessage('assistant', response, _currentMode);
    } on AIServiceException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
        _messages.add(_ChatMessage(
          role: 'error',
          content: '❌ ${e.message}',
          timestamp: DateTime.now(),
        ));
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Connection error. Check your internet and try again.';
        _messages.add(_ChatMessage(
          role: 'error',
          content: '❌ Connection error. Check internet and try again.',
          timestamp: DateTime.now(),
        ));
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _switchMode(String mode) {
    if (mode == _currentMode) return;
    setState(() {
      _currentMode = mode;
    });

    final modeConfig = _modes.firstWhere((m) => m.key == mode);
    _addSystemMessage(
      '🔄 Switched to **${modeConfig.label}** mode.\n${modeConfig.description}',
    );

    _aiService.clearHistory(mode); // Fresh conversation for new mode
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear Conversation?', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'This will delete all messages in this conversation and reset AI memory for the current mode.',
          style: TextStyle(color: AppColors.textMuted, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              setState(() => _messages.clear());
              _aiService.clearHistory(_currentMode);
              Navigator.pop(ctx);
              _addSystemMessage('💬 Conversation cleared. Start fresh!');
            },
            child: const Text('Clear', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          _buildModeSelector(),
          Expanded(child: _buildMessageList()),
          if (_isLoading) _buildTypingIndicator(),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final modeConfig = _modes.firstWhere((m) => m.key == _currentMode);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: modeConfig.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(modeConfig.icon, color: modeConfig.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI ${modeConfig.label}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  _isConfigured
                      ? '${_aiService.currentProvider} • ${_aiService.currentModel}'
                      : 'Not configured - add API key in Settings',
                  style: TextStyle(
                    fontSize: 11,
                    color: _isConfigured ? AppColors.secondary : AppColors.accent,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined, color: AppColors.textMuted, size: 20),
            onPressed: _clearChat,
            tooltip: 'Clear chat',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.textMuted, size: 20),
            onPressed: () => _showSettingsDialog(),
            tooltip: 'AI Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    return Container(
      height: 42,
      margin: const EdgeInsets.only(bottom: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _modes.length,
        itemBuilder: (context, index) {
          final mode = _modes[index];
          final isSelected = mode.key == _currentMode;
          return GestureDetector(
            onTap: () => _switchMode(mode.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isSelected ? mode.color.withOpacity(0.15) : AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? mode.color : AppColors.cardBorder,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(mode.icon, size: 15, color: isSelected ? mode.color : AppColors.textMuted),
                  const SizedBox(width: 6),
                  Text(
                    mode.label,
                    style: TextStyle(
                      color: isSelected ? mode.color : AppColors.textMuted,
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageList() {
    if (_messages.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        return _buildMessageBubble(msg);
      },
    );
  }

  Widget _buildEmptyState() {
    final modeConfig = _modes.firstWhere((m) => m.key == _currentMode);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: modeConfig.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(modeConfig.icon, color: modeConfig.color, size: 40),
            ),
            const SizedBox(height: 20),
            Text(
              'AI ${modeConfig.label}',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              modeConfig.description,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage msg) {
    final isUser = msg.role == 'user';
    final isError = msg.role == 'error';
    final isSystem = msg.role == 'system';

    if (isSystem) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.15)),
        ),
        child: SelectableText(
          msg.content.replaceAll('**', ''), // Simple markdown strip for display
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            height: 1.5,
          ),
        ),
      );
    }

    if (isError) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.accent.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.accent.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.accent, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                msg.content.replaceFirst('❌ ', ''),
                style: const TextStyle(color: AppColors.accent, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
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
        child: SelectableText(
          msg.content,
          style: TextStyle(
            color: isUser ? Colors.white : AppColors.textPrimary,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    final modeConfig = _modes.firstWhere((m) => m.key == _currentMode);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(modeConfig.color),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'AI is thinking...',
            style: TextStyle(color: modeConfig.color, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              focusNode: _focusNode,
              maxLines: 4,
              minLines: 1,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: _getPlaceholder(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.dark,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
              ),
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _isLoading ? null : _sendMessage,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isLoading ? AppColors.surface : AppColors.primary,
              ),
              child: Icon(
                Icons.arrow_upward_rounded,
                color: _isLoading ? AppColors.textMuted : Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getPlaceholder() {
    switch (_currentMode) {
      case 'tutor':
        return 'Ask a question or explain a concept...';
      case 'student':
        return 'Teach me something! Explain a concept...';
      case 'quiz':
        return 'Tell me a topic to quiz you on...';
      case 'guardian':
        return 'Report status or ask for accountability...';
      case 'planner':
        return 'Tell me your subjects and goals...';
      default:
        return 'Type a message...';
    }
  }

  void _showSettingsDialog() {
    final keyController = TextEditingController(text: _aiService.isConfigured ? '••••••••' : '');
    String selectedProvider = _aiService.currentProvider;
    String selectedModel = _aiService.currentModel;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Row(
            children: [
              Icon(Icons.settings, color: AppColors.primary, size: 22),
              SizedBox(width: 10),
              Text('AI Configuration', style: TextStyle(color: AppColors.textPrimary, fontSize: 18)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Provider',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _providerChip('openai', 'OpenAI', selectedProvider, (val) {
                      setDialogState(() {
                        selectedProvider = val;
                        selectedModel = 'gpt-3.5-turbo';
                      });
                    }),
                    const SizedBox(width: 8),
                    _providerChip('gemini', 'Gemini', selectedProvider, (val) {
                      setDialogState(() {
                        selectedProvider = val;
                        selectedModel = 'gemini-pro';
                      });
                    }),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Model',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                if (selectedProvider == 'openai')
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: ['gpt-3.5-turbo', 'gpt-4', 'gpt-4o-mini', 'gpt-4o'].map((model) {
                      final isSelected = model == selectedModel;
                      return GestureDetector(
                        onTap: () => setDialogState(() => selectedModel = model),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary.withOpacity(0.15) : AppColors.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : AppColors.cardBorder,
                            ),
                          ),
                          child: Text(
                            model,
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? AppColors.primary : AppColors.textMuted,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  )
                else
                  const Text('gemini-pro', style: TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                const SizedBox(height: 16),
                const Text(
                  'API Key',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: keyController,
                  obscureText: true,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: selectedProvider == 'openai' ? 'sk-...' : 'AIza...',
                    filled: true,
                    fillColor: AppColors.dark,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.cardBorder),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  selectedProvider == 'openai'
                      ? 'Get key: platform.openai.com/api-keys'
                      : 'Get key: ai.google.dev',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              onPressed: () async {
                final key = keyController.text.trim();
                if (key.isNotEmpty && key != '••••••••') {
                  await _aiService.configure(
                    apiKey: key,
                    provider: selectedProvider,
                    model: selectedModel,
                  );
                  setState(() => _isConfigured = true);
                  if (mounted) Navigator.pop(ctx);
                  _addSystemMessage('✅ AI configured! Provider: $selectedProvider, Model: $selectedModel');
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _providerChip(String value, String label, String selected, Function(String) onTap) {
    final isSelected = value == selected;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.15) : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.cardBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textMuted,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

/// Internal message model for the chat UI
class _ChatMessage {
  final String role; // 'user', 'assistant', 'system', 'error'
  final String content;
  final DateTime timestamp;

  _ChatMessage({required this.role, required this.content, required this.timestamp});
}

/// Mode configuration
class _ModeConfig {
  final String key;
  final String label;
  final IconData icon;
  final Color color;
  final String description;

  const _ModeConfig({
    required this.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.description,
  });
}

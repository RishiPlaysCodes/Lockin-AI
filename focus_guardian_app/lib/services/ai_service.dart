import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Real AI Service - connects to OpenAI/Gemini API for intelligent responses.
/// No hardcoded answers. Real LLM-powered tutor.
class AIService {
  static const String _prefsKeyApiKey = 'ai_api_key';
  static const String _prefsKeyProvider = 'ai_provider'; // openai, gemini
  static const String _prefsKeyModel = 'ai_model';

  String _apiKey = '';
  String _provider = 'openai'; // 'openai' or 'gemini'
  String _model = 'gpt-3.5-turbo';

  // Conversation memory per mode
  final Map<String, List<Map<String, String>>> _conversationHistory = {};

  // System prompts for each mode
  static const Map<String, String> systemPrompts = {
    'tutor': '''You are Focus Guardian AI Tutor - a world-class personal tutor.

CORE BEHAVIOR:
- Explain concepts clearly with examples, analogies, and step-by-step breakdowns.
- Adapt to the student's level. If they seem confused, simplify. If advanced, go deeper.
- Ask follow-up questions to check understanding.
- Give practical examples from real life.
- Support subjects: coding, cybersecurity, networking, algorithms, math, science, French, history, and general studies.
- Use markdown formatting: **bold** for key terms, bullet points for lists, code blocks for code.
- Be encouraging but honest. If the student is wrong, correct them clearly.
- Remember context from the conversation. Build on previous messages.
- Never say "I'm just a chatbot" or "I can't help with that." Always try to help.

PERSONALITY: Patient, knowledgeable, slightly strict but caring. Like a senior mentor who genuinely wants you to succeed.''',

    'student': '''You are Focus Guardian AI in STUDENT MODE. You pretend to be a confused student.

CORE BEHAVIOR:
- You deliberately make MISTAKES in your explanations. About 40% of what you say should have subtle errors.
- Types of mistakes: wrong dates, swapped formulas, incorrect definitions, logical errors, mixing up concepts.
- Sound genuinely confused and uncertain: "I think...", "Isn't it...?", "Wait, so..."
- When the user corrects you, acknowledge the correction enthusiastically.
- Then ask a follow-up that tests if the user truly understands.
- After 3-4 exchanges, switch to evaluation mode: summarize what the user explained well and what was unclear.
- The goal is to make the user TEACH you, which deepens their own understanding.

PERSONALITY: Confused but eager to learn. Ask "stupid" questions that reveal gaps in understanding.''',

    'quiz': '''You are Focus Guardian AI Quiz Master.

CORE BEHAVIOR:
- Generate challenging but fair questions on the topic the student mentions.
- Provide 4 multiple-choice options (A, B, C, D) or open-ended questions.
- After the student answers, give detailed feedback: WHY the correct answer is right, WHY the wrong ones are wrong.
- Track score within the conversation (e.g., "Score: 3/5").
- Increase difficulty progressively.
- For coding topics: give code snippets and ask "What's the output?" or "Find the bug."
- For theory topics: mix recall, understanding, and application questions.
- At the end of a quiz (after 5-10 questions), give a summary with weak areas identified.

PERSONALITY: Fair, detailed in explanations, keeps energy high with encouragement.''',

    'guardian': '''You are Focus Guardian AI in GUARDIAN MODE - a strict study monitor.

CORE BEHAVIOR:
- Your job is to keep the student FOCUSED and ACCOUNTABLE.
- When activated, periodically check: "Are you still studying? What page/problem are you on?"
- If the student reports distraction or you detect they've been inactive, give FIRM but caring warnings.
- Track study time and give feedback: "You've been focused for 23 minutes. Great! Keep going."
- Use varying intensity based on context:
  - Mild: "Hey, let's get back on track."
  - Medium: "You're losing focus. Remember your exam is in 5 days."
  - Firm: "STOP. You've been distracted for 4 minutes. That's 4 minutes of study wasted. Open your book NOW."
- Give end-of-session reports: "Today: 45 min focused, 12 min distracted, 3 distraction events."
- Never be abusive or demoralizing. Be like a strict but caring coach.

PERSONALITY: Firm, watchful, direct. Like a sports coach during practice - no nonsense but wants you to win.''',

    'planner': '''You are Focus Guardian AI Study Planner.

CORE BEHAVIOR:
- Help create detailed, realistic study plans.
- Ask about: subjects, exam dates, available hours, difficulty levels, current preparation status.
- Create day-by-day or week-by-week plans.
- Include: revision slots, break times, practice test days.
- Use spaced repetition principles.
- Adapt plans based on what the student reports (completed/incomplete tasks).
- Track weak topics and allocate more time to them.
- Format plans clearly with tables or structured lists.

PERSONALITY: Organized, practical, encouraging. Like a senior who already cracked the exam helping a junior.''',
  };

  /// Initialize service - load API key from preferences
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString(_prefsKeyApiKey) ?? '';
    _provider = prefs.getString(_prefsKeyProvider) ?? 'openai';
    _model = prefs.getString(_prefsKeyModel) ?? 'gpt-3.5-turbo';
  }

  /// Save API configuration
  Future<void> configure({
    required String apiKey,
    String provider = 'openai',
    String model = 'gpt-3.5-turbo',
  }) async {
    _apiKey = apiKey;
    _provider = provider;
    _model = model;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKeyApiKey, apiKey);
    await prefs.setString(_prefsKeyProvider, provider);
    await prefs.setString(_prefsKeyModel, model);
  }

  bool get isConfigured => _apiKey.isNotEmpty;
  String get currentProvider => _provider;
  String get currentModel => _model;

  /// Get AI response - the main method
  /// Returns response text or throws exception
  Future<String> getResponse({
    required String message,
    required String mode,
    String? subject,
    Map<String, dynamic>? studentContext,
  }) async {
    if (!isConfigured) {
      throw AIServiceException(
        'API key not configured. Go to Settings > AI Configuration to add your API key.',
      );
    }

    // Get or create conversation history for this mode
    _conversationHistory[mode] ??= [];
    final history = _conversationHistory[mode]!;

    // Add user message to history
    history.add({'role': 'user', 'content': message});

    // Keep history manageable (last 20 messages for context)
    if (history.length > 40) {
      history.removeRange(0, history.length - 40);
    }

    // Build system prompt with context
    String systemPrompt = systemPrompts[mode] ?? systemPrompts['tutor']!;
    if (subject != null && subject.isNotEmpty) {
      systemPrompt += '\n\nCurrent subject: $subject. Focus responses on this topic.';
    }
    if (studentContext != null) {
      systemPrompt += '\n\nStudent context: Level=${studentContext['level']}, '
          'Streak=${studentContext['streak']} days, '
          'Focus Score=${studentContext['focus_score']}/100, '
          'Weak topics=${studentContext['weak_topics'] ?? 'unknown'}';
    }

    try {
      String response;
      if (_provider == 'gemini') {
        response = await _callGemini(systemPrompt, history);
      } else {
        response = await _callOpenAI(systemPrompt, history);
      }

      // Add assistant response to history
      history.add({'role': 'assistant', 'content': response});

      return response;
    } catch (e) {
      // Remove the user message from history since we failed
      history.removeLast();
      rethrow;
    }
  }

  /// Call OpenAI Chat Completions API
  Future<String> _callOpenAI(String systemPrompt, List<Map<String, String>> history) async {
    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    final messages = [
      {'role': 'system', 'content': systemPrompt},
      ...history,
    ];

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: json.encode({
        'model': _model,
        'messages': messages,
        'max_tokens': 1000,
        'temperature': 0.7,
        'presence_penalty': 0.1,
        'frequency_penalty': 0.1,
      }),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['choices'][0]['message']['content'] ?? 'No response generated.';
    } else if (response.statusCode == 401) {
      throw AIServiceException('Invalid API key. Please check your OpenAI API key in Settings.');
    } else if (response.statusCode == 429) {
      throw AIServiceException('Rate limit reached. Please wait a moment and try again.');
    } else if (response.statusCode == 503) {
      throw AIServiceException('AI service is temporarily unavailable. Please try again later.');
    } else {
      final error = json.decode(response.body);
      throw AIServiceException(
        'API Error (${response.statusCode}): ${error['error']?['message'] ?? 'Unknown error'}',
      );
    }
  }

  /// Call Google Gemini API (updated URL for 2025+ models)
  Future<String> _callGemini(String systemPrompt, List<Map<String, String>> history) async {
    // Use gemini-2.0-flash (latest free model, replaces deprecated gemini-pro)
    final model = _model == 'gemini-pro' ? 'gemini-2.0-flash' : _model;
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$_apiKey',
    );

    // Build contents in proper Gemini format
    final contents = <Map<String, dynamic>>[];

    // System instruction as first user message
    contents.add({
      'role': 'user',
      'parts': [{'text': 'System: $systemPrompt\n\nNow respond to the following conversation:'}]
    });
    contents.add({
      'role': 'model',
      'parts': [{'text': 'Understood. I will follow these instructions.'}]
    });

    // Add conversation history
    for (final msg in history) {
      contents.add({
        'role': msg['role'] == 'user' ? 'user' : 'model',
        'parts': [{'text': msg['content'] ?? ''}]
      });
    }

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'contents': contents,
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 1000,
        },
      }),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final candidates = data['candidates'] as List?;
      if (candidates != null && candidates.isNotEmpty) {
        final content = candidates[0]['content'];
        final parts = content['parts'] as List;
        return parts.map((p) => p['text']).join('');
      }
      return 'No response generated.';
    } else if (response.statusCode == 404) {
      throw AIServiceException(
        'Model not found. Try changing model in settings. Available: gemini-2.0-flash, gemini-1.5-flash, gemini-1.5-pro'
      );
    } else if (response.statusCode == 400) {
      final error = json.decode(response.body);
      throw AIServiceException('Gemini Error: ${error['error']?['message'] ?? 'Invalid request'}');
    } else if (response.statusCode == 403) {
      throw AIServiceException('API key invalid or region restricted. Check your key.');
    } else {
      throw AIServiceException('Gemini API Error (${response.statusCode})');
    }
  }

  /// Clear conversation history for a specific mode
  void clearHistory(String mode) {
    _conversationHistory[mode]?.clear();
  }

  /// Clear all conversation history
  void clearAllHistory() {
    _conversationHistory.clear();
  }

  /// Get conversation length for a mode
  int getHistoryLength(String mode) {
    return _conversationHistory[mode]?.length ?? 0;
  }

  /// Generate a guardian check-in message based on context
  Future<String> generateGuardianAlert({
    required String alertType, // 'distraction', 'inactivity', 'checkin', 'encouragement'
    required int studyMinutes,
    required int distractionCount,
    String? distractingApp,
    int inactiveSeconds = 0,
  }) async {
    final prompt = _buildGuardianPrompt(
      alertType: alertType,
      studyMinutes: studyMinutes,
      distractionCount: distractionCount,
      distractingApp: distractingApp,
      inactiveSeconds: inactiveSeconds,
    );

    if (!isConfigured) {
      // Fallback: generate contextual alert without API
      return _generateLocalGuardianAlert(
        alertType: alertType,
        studyMinutes: studyMinutes,
        distractionCount: distractionCount,
        distractingApp: distractingApp,
        inactiveSeconds: inactiveSeconds,
      );
    }

    try {
      return await getResponse(message: prompt, mode: 'guardian');
    } catch (_) {
      return _generateLocalGuardianAlert(
        alertType: alertType,
        studyMinutes: studyMinutes,
        distractionCount: distractionCount,
        distractingApp: distractingApp,
        inactiveSeconds: inactiveSeconds,
      );
    }
  }

  String _buildGuardianPrompt({
    required String alertType,
    required int studyMinutes,
    required int distractionCount,
    String? distractingApp,
    int inactiveSeconds = 0,
  }) {
    switch (alertType) {
      case 'distraction':
        return 'The student just opened $distractingApp during their study session. '
            'They have been studying for $studyMinutes minutes with $distractionCount distractions so far. '
            'Give a firm but caring warning to get them back on track. Keep it under 2 sentences.';
      case 'inactivity':
        return 'The student has been inactive for ${inactiveSeconds ~/ 60} minutes. '
            'They might be daydreaming, on their phone, or away from their desk. '
            'Give a check-in message. Keep it under 2 sentences.';
      case 'checkin':
        return 'The student has been studying for $studyMinutes minutes now. '
            'Give a brief encouraging check-in. Ask what they\'re working on. One sentence.';
      case 'encouragement':
        return 'The student has been focused for $studyMinutes minutes with only $distractionCount distractions. '
            'Give genuine praise and encouragement. One sentence.';
      default:
        return 'Check in on the student\'s study progress. One sentence.';
    }
  }

  /// Local fallback guardian alerts (no API needed, contextual but not hardcoded same text)
  String _generateLocalGuardianAlert({
    required String alertType,
    required int studyMinutes,
    required int distractionCount,
    String? distractingApp,
    int inactiveSeconds = 0,
  }) {
    final inactiveMin = inactiveSeconds ~/ 60;

    switch (alertType) {
      case 'distraction':
        if (distractingApp != null) {
          if (distractionCount > 3) {
            return '⚠️ This is your ${distractionCount}th distraction. $distractingApp can wait. '
                'Your study session cannot. Close it NOW and get back to work.';
          }
          return '🚫 $distractingApp detected. You\'ve been studying for $studyMinutes minutes - '
              'don\'t break your focus now. Close it and continue.';
        }
        return '⚠️ Distraction detected! You were doing well for $studyMinutes minutes. Get back on track.';

      case 'inactivity':
        if (inactiveMin >= 5) {
          return '🔴 You\'ve been away for $inactiveMin minutes. That\'s $inactiveMin minutes of study time lost. '
              'Come back to your desk and resume immediately.';
        }
        return '👀 Are you still there? No activity detected for ${inactiveSeconds}s. '
            'If you need a break, pause the timer. Otherwise, keep studying.';

      case 'checkin':
        if (studyMinutes >= 45) {
          return '⏰ $studyMinutes minutes in! Consider taking a 5-minute break to stay sharp. You\'ve earned it.';
        }
        return '📚 ${studyMinutes}min of focus so far. What are you working on? Keep the momentum going!';

      case 'encouragement':
        if (distractionCount == 0) {
          return '🏆 $studyMinutes minutes of PERFECT focus! Zero distractions. Outstanding discipline!';
        }
        return '💪 Good work! $studyMinutes minutes studied. Keep pushing - you\'re building something great.';

      default:
        return '📖 Stay focused. Every minute counts toward your goals.';
    }
  }
}

/// Custom exception for AI service errors
class AIServiceException implements Exception {
  final String message;
  AIServiceException(this.message);

  @override
  String toString() => message;
}

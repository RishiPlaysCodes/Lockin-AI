import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/teacher_model.dart';

/// Manages AI Teacher state, camera monitoring, voice alerts, and focus tracking
class TeacherProvider extends ChangeNotifier {
  // Selected teacher
  AITeacher _selectedTeacher = AITeacher.availableTeachers[0];
  bool _isTeacherActive = false;
  bool _isCameraMonitoring = false;
  bool _isVoiceEnabled = true;

  // Camera monitoring
  CameraMonitorState _cameraState = CameraMonitorState(lastCheck: DateTime.now());
  Timer? _monitorTimer;
  Timer? _reminderTimer;

  // Alerts history
  List<TeacherAlert> _alerts = [];

  // Blocked accounts
  List<BlockedAccount> _blockedAccounts = [];

  // Friends
  List<StudyFriend> _friends = [];
  List<StudyFriend> _friendRequests = [];

  // Group sessions
  List<GroupStudySession> _groupSessions = [];
  GroupStudySession? _activeGroupSession;

  // AI Student mode
  bool _isStudentMode = false;
  String _studentModeSubject = '';

  // Getters
  AITeacher get selectedTeacher => _selectedTeacher;
  bool get isTeacherActive => _isTeacherActive;
  bool get isCameraMonitoring => _isCameraMonitoring;
  bool get isVoiceEnabled => _isVoiceEnabled;
  CameraMonitorState get cameraState => _cameraState;
  List<TeacherAlert> get alerts => _alerts;
  List<BlockedAccount> get blockedAccounts => _blockedAccounts;
  List<BlockedAccount> get activeBlockedAccounts =>
      _blockedAccounts.where((a) => a.isCurrentlyBlocked).toList();
  List<StudyFriend> get friends => _friends;
  List<StudyFriend> get onlineFriends =>
      _friends.where((f) => f.isOnline || f.status == 'studying').toList();
  List<StudyFriend> get friendRequests => _friendRequests;
  List<GroupStudySession> get groupSessions => _groupSessions;
  GroupStudySession? get activeGroupSession => _activeGroupSession;
  bool get isStudentMode => _isStudentMode;
  String get studentModeSubject => _studentModeSubject;

  // ============================================================
  // TEACHER MANAGEMENT
  // ============================================================

  void selectTeacher(String teacherId) {
    final teacher = AITeacher.availableTeachers.firstWhere(
      (t) => t.id == teacherId,
      orElse: () => AITeacher.availableTeachers[0],
    );
    _selectedTeacher = teacher;
    _saveData();
    notifyListeners();
  }

  void activateTeacher() {
    _isTeacherActive = true;
    _startMonitoring();
    notifyListeners();
  }

  void deactivateTeacher() {
    _isTeacherActive = false;
    _stopMonitoring();
    notifyListeners();
  }

  void toggleVoice() {
    _isVoiceEnabled = !_isVoiceEnabled;
    _saveData();
    notifyListeners();
  }

  // ============================================================
  // CAMERA MONITORING (Simulated for now - real impl needs camera plugin)
  // ============================================================

  void startCameraMonitoring() {
    _isCameraMonitoring = true;
    _cameraState = CameraMonitorState(
      lastCheck: DateTime.now(),
      isCameraActive: true,
    );
    // In real app: initialize camera, run ML model for face/gaze detection
    // For now: simulate with periodic checks
    _monitorTimer?.cancel();
    _monitorTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _simulateFocusCheck();
    });
    notifyListeners();
  }

  void stopCameraMonitoring() {
    _isCameraMonitoring = false;
    _monitorTimer?.cancel();
    _cameraState = CameraMonitorState(
      lastCheck: DateTime.now(),
      isCameraActive: false,
      focusedSeconds: _cameraState.focusedSeconds,
      distractedSeconds: _cameraState.distractedSeconds,
      alertsSent: _cameraState.alertsSent,
    );
    notifyListeners();
  }

  void _simulateFocusCheck() {
    // In production: use camera + ML to detect focus state
    // Simulated: 80% chance focused, 20% distracted
    final random = Random();
    final isFocused = random.nextDouble() > 0.2;

    if (isFocused) {
      _cameraState = CameraMonitorState(
        currentState: FocusState.focused,
        lastCheck: DateTime.now(),
        focusedSeconds: _cameraState.focusedSeconds + 10,
        distractedSeconds: _cameraState.distractedSeconds,
        alertsSent: _cameraState.alertsSent,
        isCameraActive: true,
      );
    } else {
      _cameraState = CameraMonitorState(
        currentState: FocusState.distracted,
        lastCheck: DateTime.now(),
        focusedSeconds: _cameraState.focusedSeconds,
        distractedSeconds: _cameraState.distractedSeconds + 10,
        alertsSent: _cameraState.alertsSent + 1,
        isCameraActive: true,
      );
      _triggerTeacherAlert('distraction');
    }
    notifyListeners();
  }

  // ============================================================
  // TEACHER ALERTS & VOICE
  // ============================================================

  void _startMonitoring() {
    _reminderTimer?.cancel();
    // Teacher sends periodic reminders based on strictness
    final intervalSeconds = (60 / _selectedTeacher.strictnessLevel).round();
    _reminderTimer = Timer.periodic(
      Duration(seconds: intervalSeconds.clamp(30, 300)),
      (_) {
        if (_isTeacherActive) {
          _triggerTeacherAlert('reminder');
        }
      },
    );
  }

  void _stopMonitoring() {
    _reminderTimer?.cancel();
    _monitorTimer?.cancel();
  }

  void _triggerTeacherAlert(String alertType) {
    final random = Random();
    final phrases = _selectedTeacher.catchPhrases;
    final message = phrases[random.nextInt(phrases.length)];

    final alert = TeacherAlert(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      teacherId: _selectedTeacher.id,
      message: message,
      alertType: alertType,
      severity: alertType == 'distraction' ? 'high' : 'low',
      timestamp: DateTime.now(),
      wasSpoken: _isVoiceEnabled,
    );

    _alerts.insert(0, alert);
    if (_alerts.length > 50) _alerts = _alerts.sublist(0, 50);
    notifyListeners();
  }

  /// Manual trigger for when user gets distracted
  void reportDistraction(String reason) {
    _triggerTeacherAlert('distraction');
    _cameraState = CameraMonitorState(
      currentState: FocusState.distracted,
      lastCheck: DateTime.now(),
      focusedSeconds: _cameraState.focusedSeconds,
      distractedSeconds: _cameraState.distractedSeconds + 30,
      alertsSent: _cameraState.alertsSent + 1,
      isCameraActive: _cameraState.isCameraActive,
    );
    notifyListeners();
  }

  // ============================================================
  // AI STUDENT MODE (AI pretends to be student, user corrects)
  // ============================================================

  void enableStudentMode(String subject) {
    _isStudentMode = true;
    _studentModeSubject = subject;
    notifyListeners();
  }

  void disableStudentMode() {
    _isStudentMode = false;
    _studentModeSubject = '';
    notifyListeners();
  }

  String getStudentModeResponse(String userMessage) {
    final random = Random();
    // AI deliberately makes mistakes for user to correct
    final responses = [
      "Hmm, I think Newton's 3rd law says that for every action, there's an EQUAL reaction in the SAME direction... right? 🤔",
      "Wait, isn't photosynthesis where plants take in oxygen and release carbon dioxide? I'm confused...",
      "I believe the mitochondria is the brain of the cell? Or wait, is that the nucleus?",
      "So the formula for acceleration is speed × time, correct? Let me write: a = v × t",
      "I studied that the French Revolution happened in 1889... same year as the Eiffel Tower was built!",
      "The quadratic formula is x = -b ± √(b² + 4ac) / 2a... I think the sign inside is plus?",
      "Ohm's law states V = I/R, meaning voltage equals current divided by resistance?",
      "I read that DNA stands for DeoxyriboNucleic Amino acid. Is that right?",
    ];

    if (userMessage.toLowerCase().contains('correct') ||
        userMessage.toLowerCase().contains('wrong') ||
        userMessage.toLowerCase().contains('no') ||
        userMessage.toLowerCase().contains('actually')) {
      final corrections = [
        "Oh! You're right! Thank you for correcting me. So the correct answer is... can you explain it once more? I want to make sure I understand. 📝",
        "Ah, I see my mistake now! Thanks for catching that. You're a great teacher! Can you explain WHY it's different? 🤓",
        "Oops! I knew something felt off. Your explanation makes much more sense. Let me try another question to test myself...",
        "You're absolutely right, I mixed that up. This is exactly why teaching others helps YOU learn better! What else should I know about this topic?",
      ];
      return corrections[random.nextInt(corrections.length)];
    }

    return responses[random.nextInt(responses.length)];
  }

  // ============================================================
  // BLOCKED ACCOUNTS (Cross-device social media blocking)
  // ============================================================

  void addBlockedAccount(String platform, String username, String email, String blockType, DateTime blockedUntil) {
    final account = BlockedAccount(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      platform: platform,
      username: username,
      email: email,
      isActive: true,
      blockedUntil: blockedUntil,
      blockType: blockType,
    );
    _blockedAccounts.add(account);
    _saveData();
    notifyListeners();
  }

  void removeBlockedAccount(String id) {
    _blockedAccounts.removeWhere((a) => a.id == id);
    _saveData();
    notifyListeners();
  }

  void toggleBlockedAccount(String id) {
    final idx = _blockedAccounts.indexWhere((a) => a.id == id);
    if (idx != -1) {
      _blockedAccounts[idx] = BlockedAccount(
        id: _blockedAccounts[idx].id,
        platform: _blockedAccounts[idx].platform,
        username: _blockedAccounts[idx].username,
        email: _blockedAccounts[idx].email,
        isActive: !_blockedAccounts[idx].isActive,
        blockedUntil: _blockedAccounts[idx].blockedUntil,
        blockType: _blockedAccounts[idx].blockType,
      );
      _saveData();
      notifyListeners();
    }
  }

  // ============================================================
  // FRIENDS SYSTEM
  // ============================================================

  void addFriend(String username, String displayName) {
    final friend = StudyFriend(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      username: username,
      displayName: displayName,
      avatarColor: '#${Random().nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0')}',
      status: 'offline',
      isOnline: false,
    );
    _friends.add(friend);
    _saveData();
    notifyListeners();
  }

  void removeFriend(String id) {
    _friends.removeWhere((f) => f.id == id);
    _saveData();
    notifyListeners();
  }

  void updateFriendStatus(String id, String status, bool isOnline) {
    final idx = _friends.indexWhere((f) => f.id == id);
    if (idx != -1) {
      _friends[idx] = StudyFriend(
        id: _friends[idx].id,
        username: _friends[idx].username,
        displayName: _friends[idx].displayName,
        avatarColor: _friends[idx].avatarColor,
        status: status,
        streakDays: _friends[idx].streakDays,
        level: _friends[idx].level,
        lastActive: DateTime.now(),
        isOnline: isOnline,
      );
      notifyListeners();
    }
  }

  // ============================================================
  // GROUP STUDY SESSIONS
  // ============================================================

  GroupStudySession createGroupSession(String name, String subject, int duration, List<String> friendIds) {
    final selectedFriends = _friends.where((f) => friendIds.contains(f.id)).toList();
    final session = GroupStudySession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      hostId: 'self',
      hostName: 'You',
      subject: subject,
      participantIds: ['self', ...friendIds],
      participantNames: ['You', ...selectedFriends.map((f) => f.displayName)],
      startTime: DateTime.now(),
      plannedDuration: duration,
      teacherId: _selectedTeacher.id,
    );
    _groupSessions.insert(0, session);
    _activeGroupSession = session;
    _activateTeacher(); // AI teacher monitors group session
    _saveData();
    notifyListeners();
    return session;
  }

  void endGroupSession(String sessionId) {
    final idx = _groupSessions.indexWhere((s) => s.id == sessionId);
    if (idx != -1) {
      _groupSessions[idx] = GroupStudySession(
        id: _groupSessions[idx].id,
        name: _groupSessions[idx].name,
        hostId: _groupSessions[idx].hostId,
        hostName: _groupSessions[idx].hostName,
        subject: _groupSessions[idx].subject,
        participantIds: _groupSessions[idx].participantIds,
        participantNames: _groupSessions[idx].participantNames,
        startTime: _groupSessions[idx].startTime,
        endTime: DateTime.now(),
        plannedDuration: _groupSessions[idx].plannedDuration,
        isActive: false,
        teacherId: _groupSessions[idx].teacherId,
      );
    }
    _activeGroupSession = null;
    deactivateTeacher();
    _saveData();
    notifyListeners();
  }

  void joinGroupSession(String sessionId) {
    final idx = _groupSessions.indexWhere((s) => s.id == sessionId);
    if (idx != -1) {
      _activeGroupSession = _groupSessions[idx];
      _activateTeacher();
      notifyListeners();
    }
  }

  // ============================================================
  // TEACHER AI CHAT RESPONSES
  // ============================================================

  String getTeacherResponse(String message, String mode) {
    final random = Random();
    final lower = message.toLowerCase();

    // Student mode
    if (_isStudentMode) {
      return getStudentModeResponse(message);
    }

    // Teacher personality-based responses
    if (_selectedTeacher.personality == 'strict') {
      return _getStrictTeacherResponse(lower, random);
    } else if (_selectedTeacher.personality == 'friendly') {
      return _getFriendlyTeacherResponse(lower, random);
    } else if (_selectedTeacher.personality == 'mentor') {
      return _getMentorTeacherResponse(lower, random);
    } else if (_selectedTeacher.personality == 'drill_sergeant') {
      return _getDrillSergeantResponse(lower, random);
    } else {
      return _getBuddyResponse(lower, random);
    }
  }

  String _getStrictTeacherResponse(String msg, Random random) {
    if (msg.contains('help') || msg.contains('explain')) {
      return "Fine. I'll explain, but pay attention - I won't repeat myself.\n\n"
          "First, tell me exactly WHAT you don't understand. Be specific.\n\n"
          "I expect you to have attempted the problem yourself before asking me. "
          "Show me your work, then I'll correct your mistakes.";
    }
    if (msg.contains('tired') || msg.contains('break')) {
      return "Tired? Your competitors are NOT tired. They're studying right now.\n\n"
          "You can rest AFTER you complete this session. Discipline means doing it "
          "even when you don't feel like it.\n\n"
          "5 more minutes of pure focus. Then we'll talk about breaks. Now FOCUS!";
    }
    return "Stop wasting time with unnecessary chat. Ask a specific academic question "
        "or get back to your study material.\n\n"
        "Every second you spend chatting is a second you're NOT learning. "
        "Your exam doesn't care about your excuses.";
  }

  String _getFriendlyTeacherResponse(String msg, Random random) {
    if (msg.contains('help') || msg.contains('explain')) {
      return "Of course! I'd love to help you understand this better! 😊\n\n"
          "Tell me what topic you're working on, and I'll break it down "
          "into simple steps. No question is too basic - asking is how we learn!\n\n"
          "Remember: understanding > memorizing. Let's make this concept click for you!";
    }
    if (msg.contains('tired') || msg.contains('break')) {
      return "I can see you've been working hard! That's amazing! 🌟\n\n"
          "Here's what I suggest:\n"
          "• Take a 5-min break - stretch, drink water\n"
          "• Come back refreshed for one more focused round\n"
          "• You've already done great today!\n\n"
          "Remember: rest is part of productive studying. I'm proud of your effort!";
    }
    return "Hey! Great to chat with you! 🎉\n\n"
        "I'm here to help you with anything:\n"
        "• Explain concepts in simple language\n"
        "• Create a study plan together\n"
        "• Quiz you on what you've learned\n"
        "• Just motivate you to keep going!\n\n"
        "What would help you most right now?";
  }

  String _getMentorTeacherResponse(String msg, Random random) {
    if (msg.contains('help') || msg.contains('explain')) {
      return "Before I explain, let me ask you something important:\n\n"
          "What do you ALREADY know about this topic? Start from there.\n\n"
          "True learning happens when you connect new knowledge to what you already understand. "
          "Tell me your current understanding, and I'll guide you to fill the gaps. "
          "This way, you'll remember it forever, not just until the exam.";
    }
    if (msg.contains('tired') || msg.contains('break')) {
      return "Feeling tired is natural - it means your brain has been working.\n\n"
          "Ask yourself: 'If I stop now, will I be satisfied with today's effort?'\n\n"
          "There's a difference between needing rest and avoiding difficulty. "
          "Which one is this? Be honest with yourself.\n\n"
          "If you truly need rest, take it without guilt. "
          "If it's resistance - push through just 10 more minutes. You'll thank yourself.";
    }
    return "I'm glad you're here. Let me share something:\n\n"
        "The students who succeed aren't necessarily the smartest - they're the most CONSISTENT.\n\n"
        "Right now, by being here and studying, you're already ahead of most people your age. "
        "What's your focus for today? Let's make it count.";
  }

  String _getDrillSergeantResponse(String msg, Random random) {
    if (msg.contains('help') || msg.contains('explain')) {
      return "LISTEN UP! Here's how we're doing this:\n\n"
          "1. You tell me the EXACT problem\n"
          "2. You show me what you've TRIED\n"
          "3. I correct your approach\n"
          "4. You solve 3 MORE problems on your own\n\n"
          "No spoon-feeding in my class! You WILL learn by DOING. "
          "Now state your problem - clearly and concisely!";
    }
    if (msg.contains('tired') || msg.contains('break')) {
      return "TIRED?! Did I hear that correctly?!\n\n"
          "Do you think IIT toppers get 'tired'? Do you think UPSC rank 1 takes 'breaks' "
          "every 20 minutes?!\n\n"
          "You have ONE job right now: STUDY. Everything else is an EXCUSE.\n\n"
          "Give me 15 more minutes of MAXIMUM effort. Then you've EARNED your break. "
          "NOW MOVE!";
    }
    return "ATTENTION SOLDIER!\n\n"
        "Status report:\n"
        "• Are you focused? ✅ or ❌\n"
        "• Is your phone away? ✅ or ❌\n"
        "• Are you on track with today's goals? ✅ or ❌\n\n"
        "If ANY of those are ❌, fix it RIGHT NOW.\n"
        "This is NOT a negotiation. This is WAR against your own laziness!\n\n"
        "Now get back to work, soldier! 💪";
  }

  String _getBuddyResponse(String msg, Random random) {
    if (msg.contains('help') || msg.contains('explain')) {
      return "Hey bro! Sure, let me help you out! 🤝\n\n"
          "What topic are you stuck on? I'll try to explain it like "
          "I'd explain to a friend over chai.\n\n"
          "No judgment here - we all struggle with some topics. "
          "The important thing is you're asking instead of just skipping it!";
    }
    if (msg.contains('tired') || msg.contains('break')) {
      return "Bro I feel you! 😅 Studying is tough.\n\n"
          "Tell you what - let's make a deal:\n"
          "• Study 10 more min with FULL focus\n"
          "• Then take a proper 5-min break\n"
          "• Come back and we'll tackle the next topic together\n\n"
          "Deal? Sometimes the hardest part is just starting again after a break. "
          "But you got this, I believe in you! 💪";
    }
    return "Yo! What's up? Ready to crush some chapters today? 🔥\n\n"
        "I'm here to study with you - think of me as your study partner who:\n"
        "• Keeps you accountable\n"
        "• Explains stuff in simple words\n"
        "• Makes studying less boring\n"
        "• Celebrates your wins!\n\n"
        "So what are we working on today, dude?";
  }

  // ============================================================
  // PERSISTENCE
  // ============================================================

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load selected teacher
    final teacherId = prefs.getString('selected_teacher') ?? 'strict_sir';
    selectTeacher(teacherId);

    _isVoiceEnabled = prefs.getBool('voice_enabled') ?? true;

    // Load blocked accounts
    final accountsJson = prefs.getString('blocked_accounts');
    if (accountsJson != null) {
      final List<dynamic> list = json.decode(accountsJson);
      _blockedAccounts = list.map((e) => BlockedAccount.fromJson(e)).toList();
    }

    // Load friends
    final friendsJson = prefs.getString('friends');
    if (friendsJson != null) {
      final List<dynamic> list = json.decode(friendsJson);
      _friends = list.map((e) => StudyFriend.fromJson(e)).toList();
    }

    // Load group sessions
    final sessionsJson = prefs.getString('group_sessions');
    if (sessionsJson != null) {
      final List<dynamic> list = json.decode(sessionsJson);
      _groupSessions = list.map((e) => GroupStudySession.fromJson(e)).toList();
    }

    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_teacher', _selectedTeacher.id);
    await prefs.setBool('voice_enabled', _isVoiceEnabled);
    await prefs.setString('blocked_accounts', json.encode(_blockedAccounts.map((e) => e.toJson()).toList()));
    await prefs.setString('friends', json.encode(_friends.map((e) => e.toJson()).toList()));
    await prefs.setString('group_sessions', json.encode(_groupSessions.map((e) => e.toJson()).toList()));
  }

  @override
  void dispose() {
    _monitorTimer?.cancel();
    _reminderTimer?.cancel();
    super.dispose();
  }
}

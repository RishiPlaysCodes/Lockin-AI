import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/session_model.dart';
import '../utils/constants.dart';

class AppProvider extends ChangeNotifier {
  UserProfile _profile = UserProfile();
  List<FocusSession> _sessions = [];
  List<BlockedSite> _blockedSites = [];
  List<ChatMessage> _chatHistory = [];
  List<String> _earnedBadges = [];
  String _currentQuote = '';
  String _currentAuthor = '';

  UserProfile get profile => _profile;
  List<FocusSession> get sessions => _sessions;
  List<FocusSession> get completedSessions =>
      _sessions.where((s) => !s.isActive).toList();
  List<BlockedSite> get blockedSites => _blockedSites;
  List<ChatMessage> get chatHistory => _chatHistory;
  List<String> get earnedBadges => _earnedBadges;
  String get currentQuote => _currentQuote;
  String get currentAuthor => _currentAuthor;

  int get todayMinutes {
    final today = DateTime.now();
    return completedSessions
        .where((s) =>
            s.startTime.year == today.year &&
            s.startTime.month == today.month &&
            s.startTime.day == today.day)
        .fold(0, (sum, s) => sum + s.durationMinutes.round());
  }

  int get weeklyMinutes {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return completedSessions
        .where((s) => s.startTime.isAfter(weekAgo))
        .fold(0, (sum, s) => sum + s.durationMinutes.round());
  }

  double get dailyGoalProgress {
    if (_profile.dailyGoalMinutes <= 0) return 100;
    return (todayMinutes / _profile.dailyGoalMinutes * 100).clamp(0, 100);
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    _profile.focusScore = prefs.getInt(AppConstants.keyFocusScore) ?? 100;
    _profile.totalStudyMinutes = prefs.getInt(AppConstants.keyTotalStudyMinutes) ?? 0;
    _profile.streakDays = prefs.getInt(AppConstants.keyStreakDays) ?? 0;
    _profile.longestStreak = prefs.getInt(AppConstants.keyLongestStreak) ?? 0;
    _profile.dailyGoalMinutes = prefs.getInt(AppConstants.keyDailyGoal) ?? 120;
    _profile.username = prefs.getString(AppConstants.keyUsername) ?? 'Student';
    _profile.level = _profile.computeLevel();

    // Load sessions
    final sessionsJson = prefs.getString(AppConstants.keySessions);
    if (sessionsJson != null) {
      final List<dynamic> list = json.decode(sessionsJson);
      _sessions = list.map((e) => FocusSession.fromJson(e)).toList();
      _profile.totalSessions = completedSessions.length;
    }

    // Load blocked sites
    final sitesJson = prefs.getString(AppConstants.keyBlockedSites);
    if (sitesJson != null) {
      final List<dynamic> list = json.decode(sitesJson);
      _blockedSites = list.map((e) => BlockedSite.fromJson(e)).toList();
    }

    // Load badges
    final badgesJson = prefs.getStringList(AppConstants.keyBadges);
    if (badgesJson != null) {
      _earnedBadges = badgesJson;
    }

    // Load chat
    final chatJson = prefs.getString(AppConstants.keyChatHistory);
    if (chatJson != null) {
      final List<dynamic> list = json.decode(chatJson);
      _chatHistory = list.map((e) => ChatMessage.fromJson(e)).toList();
    }

    // Random quote
    _refreshQuote();

    notifyListeners();
  }

  void _refreshQuote() {
    final random = Random();
    final q = AppConstants.quotes[random.nextInt(AppConstants.quotes.length)];
    _currentQuote = q['quote']!;
    _currentAuthor = q['author']!;
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.keyFocusScore, _profile.focusScore);
    await prefs.setInt(AppConstants.keyTotalStudyMinutes, _profile.totalStudyMinutes);
    await prefs.setInt(AppConstants.keyStreakDays, _profile.streakDays);
    await prefs.setInt(AppConstants.keyLongestStreak, _profile.longestStreak);
    await prefs.setInt(AppConstants.keyDailyGoal, _profile.dailyGoalMinutes);
    await prefs.setString(AppConstants.keySessions, json.encode(_sessions.map((e) => e.toJson()).toList()));
    await prefs.setString(AppConstants.keyBlockedSites, json.encode(_blockedSites.map((e) => e.toJson()).toList()));
    await prefs.setStringList(AppConstants.keyBadges, _earnedBadges);
    await prefs.setString(AppConstants.keyChatHistory, json.encode(_chatHistory.map((e) => e.toJson()).toList()));
  }

  // Session Management
  FocusSession startSession(String subject, int durationMinutes, String mood) {
    final session = FocusSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      subject: subject,
      plannedDuration: durationMinutes,
      startTime: DateTime.now(),
      moodBefore: mood,
    );
    _sessions.insert(0, session);
    _saveData();
    notifyListeners();
    return session;
  }

  Map<String, dynamic> endSession(String sessionId) {
    final idx = _sessions.indexWhere((s) => s.id == sessionId);
    if (idx == -1) return {};

    final session = _sessions[idx];
    session.isActive = false;
    session.endTime = DateTime.now();

    if (session.durationMinutes >= session.plannedDuration * 0.9) {
      session.isCompleted = true;
    }

    // Calculate score
    int score = 100;
    score -= session.distractionCount * 5;
    if (session.isCompleted) score += 10;
    if (session.distractionCount == 0 && session.durationMinutes >= 30) score += 5;
    score = score.clamp(0, 100);
    session.focusScore = score;

    // Update profile
    _profile.totalStudyMinutes += session.durationMinutes.round();
    _profile.totalSessions += 1;
    _profile.focusScore = ((_profile.focusScore * 0.7) + (score * 0.3)).round().clamp(0, 100);
    _profile.level = _profile.computeLevel();

    // Update streak
    _updateStreak();

    // Check badges
    final newBadges = _checkBadges(session);

    _saveData();
    notifyListeners();

    return {
      'score': score,
      'duration_minutes': session.durationMinutes.round(),
      'distractions': session.distractionCount,
      'is_completed': session.isCompleted,
      'new_badges': newBadges,
      'streak': _profile.streakDays,
    };
  }

  void logDistraction(String sessionId, String appName, String type) {
    final idx = _sessions.indexWhere((s) => s.id == sessionId);
    if (idx == -1) return;
    _sessions[idx].distractionCount++;
    _profile.focusScore = (_profile.focusScore - 5).clamp(0, 100);
    _profile.totalDistractions++;
    _saveData();
    notifyListeners();
  }

  void _updateStreak() {
    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month}-${today.day}';
    final prefs_lastDate = ''; // simplified: always increment on completion

    _profile.streakDays = (_profile.streakDays == 0) ? 1 : _profile.streakDays + 1;
    if (_profile.streakDays > _profile.longestStreak) {
      _profile.longestStreak = _profile.streakDays;
    }
  }

  List<String> _checkBadges(FocusSession session) {
    List<String> newBadges = [];

    void tryAward(String type) {
      if (!_earnedBadges.contains(type)) {
        _earnedBadges.add(type);
        newBadges.add(type);
      }
    }

    // First session
    if (completedSessions.length == 1) tryAward('first_session');

    // Streak badges
    if (_profile.streakDays >= 3) tryAward('streak_3');
    if (_profile.streakDays >= 7) tryAward('streak_7');
    if (_profile.streakDays >= 14) tryAward('streak_14');
    if (_profile.streakDays >= 30) tryAward('streak_30');

    // Hours badges
    double hours = _profile.totalStudyHours;
    if (hours >= 1) tryAward('hours_1');
    if (hours >= 5) tryAward('hours_5');
    if (hours >= 10) tryAward('hours_10');
    if (hours >= 20) tryAward('hours_20');
    if (hours >= 50) tryAward('hours_50');
    if (hours >= 100) tryAward('hours_100');

    // Zero distraction
    if (session.distractionCount == 0 && session.durationMinutes >= 15) {
      tryAward('no_distraction');
    }

    // Focus master
    if (_profile.focusScore >= 100) tryAward('focus_master');

    // Marathon
    if (session.durationMinutes >= 90 && session.isCompleted) tryAward('marathon');

    // Deep thinker
    if (session.durationMinutes >= 60 && session.isCompleted) tryAward('deep_thinker');

    // Early bird
    if (session.startTime.hour < 6) tryAward('early_bird');

    // Night owl
    if (session.startTime.hour >= 23) tryAward('night_owl');

    return newBadges;
  }

  // Blocked Sites
  void addBlockedSite(String name, String url, String category) {
    _blockedSites.add(BlockedSite(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      url: url,
      category: category,
    ));
    _saveData();
    notifyListeners();
  }

  void toggleBlockedSite(String id) {
    final idx = _blockedSites.indexWhere((s) => s.id == id);
    if (idx != -1) {
      _blockedSites[idx].isActive = !_blockedSites[idx].isActive;
      _saveData();
      notifyListeners();
    }
  }

  void removeBlockedSite(String id) {
    _blockedSites.removeWhere((s) => s.id == id);
    _saveData();
    notifyListeners();
  }

  // Chat
  void addChatMessage(String role, String content, String mode) {
    _chatHistory.add(ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      role: role,
      content: content,
      mode: mode,
      timestamp: DateTime.now(),
    ));
    _saveData();
    notifyListeners();
  }

  void clearChat() {
    _chatHistory.clear();
    _saveData();
    notifyListeners();
  }

  // Settings
  void updateDailyGoal(int minutes) {
    _profile.dailyGoalMinutes = minutes;
    _saveData();
    notifyListeners();
  }

  Future<void> resetAllData() async {
    _profile = UserProfile();
    _sessions.clear();
    _blockedSites.clear();
    _chatHistory.clear();
    _earnedBadges.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}

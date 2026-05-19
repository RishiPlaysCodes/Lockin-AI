/// Enhanced study tracking models for real analytics
/// Tracks: sessions, weak topics, quiz scores, distraction patterns, daily summaries

class StudyRecord {
  final String id;
  final String subject;
  final DateTime date;
  final int durationMinutes;
  final int focusScore;
  final int distractionCount;
  final double focusPercentage;
  final String sessionType; // pomodoro, deep_work, quiz, revision
  final List<String> topicsCovered;
  final String mood;

  StudyRecord({
    required this.id,
    required this.subject,
    required this.date,
    required this.durationMinutes,
    this.focusScore = 100,
    this.distractionCount = 0,
    this.focusPercentage = 100,
    this.sessionType = 'pomodoro',
    this.topicsCovered = const [],
    this.mood = 'neutral',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'subject': subject,
    'date': date.toIso8601String(),
    'duration_minutes': durationMinutes,
    'focus_score': focusScore,
    'distraction_count': distractionCount,
    'focus_percentage': focusPercentage,
    'session_type': sessionType,
    'topics_covered': topicsCovered,
    'mood': mood,
  };

  factory StudyRecord.fromJson(Map<String, dynamic> json) => StudyRecord(
    id: json['id'] ?? '',
    subject: json['subject'] ?? 'General',
    date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
    durationMinutes: json['duration_minutes'] ?? 0,
    focusScore: json['focus_score'] ?? 100,
    distractionCount: json['distraction_count'] ?? 0,
    focusPercentage: (json['focus_percentage'] ?? 100).toDouble(),
    sessionType: json['session_type'] ?? 'pomodoro',
    topicsCovered: List<String>.from(json['topics_covered'] ?? []),
    mood: json['mood'] ?? 'neutral',
  );
}

class WeakTopic {
  final String id;
  final String subject;
  final String topic;
  final int timesStruggled; // How many times got wrong in quizzes
  final int timesRevised;
  final DateTime lastAttempted;
  final double masteryLevel; // 0.0 to 1.0
  final String difficulty; // easy, medium, hard

  WeakTopic({
    required this.id,
    required this.subject,
    required this.topic,
    this.timesStruggled = 1,
    this.timesRevised = 0,
    required this.lastAttempted,
    this.masteryLevel = 0.0,
    this.difficulty = 'medium',
  });

  bool get needsRevision => masteryLevel < 0.7 && DateTime.now().difference(lastAttempted).inDays >= 1;
  bool get isMastered => masteryLevel >= 0.9;

  Map<String, dynamic> toJson() => {
    'id': id,
    'subject': subject,
    'topic': topic,
    'times_struggled': timesStruggled,
    'times_revised': timesRevised,
    'last_attempted': lastAttempted.toIso8601String(),
    'mastery_level': masteryLevel,
    'difficulty': difficulty,
  };

  factory WeakTopic.fromJson(Map<String, dynamic> json) => WeakTopic(
    id: json['id'] ?? '',
    subject: json['subject'] ?? '',
    topic: json['topic'] ?? '',
    timesStruggled: json['times_struggled'] ?? 1,
    timesRevised: json['times_revised'] ?? 0,
    lastAttempted: DateTime.tryParse(json['last_attempted'] ?? '') ?? DateTime.now(),
    masteryLevel: (json['mastery_level'] ?? 0.0).toDouble(),
    difficulty: json['difficulty'] ?? 'medium',
  );
}

class QuizScore {
  final String id;
  final String subject;
  final String topic;
  final int totalQuestions;
  final int correctAnswers;
  final DateTime date;
  final String difficulty;
  final List<String> wrongTopics; // Topics user got wrong

  QuizScore({
    required this.id,
    required this.subject,
    this.topic = '',
    required this.totalQuestions,
    required this.correctAnswers,
    required this.date,
    this.difficulty = 'medium',
    this.wrongTopics = const [],
  });

  double get percentage => totalQuestions > 0 ? (correctAnswers / totalQuestions * 100) : 0;
  String get grade {
    final p = percentage;
    if (p >= 90) return 'A+';
    if (p >= 80) return 'A';
    if (p >= 70) return 'B';
    if (p >= 60) return 'C';
    if (p >= 50) return 'D';
    return 'F';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'subject': subject,
    'topic': topic,
    'total_questions': totalQuestions,
    'correct_answers': correctAnswers,
    'date': date.toIso8601String(),
    'difficulty': difficulty,
    'wrong_topics': wrongTopics,
  };

  factory QuizScore.fromJson(Map<String, dynamic> json) => QuizScore(
    id: json['id'] ?? '',
    subject: json['subject'] ?? '',
    topic: json['topic'] ?? '',
    totalQuestions: json['total_questions'] ?? 0,
    correctAnswers: json['correct_answers'] ?? 0,
    date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
    difficulty: json['difficulty'] ?? 'medium',
    wrongTopics: List<String>.from(json['wrong_topics'] ?? []),
  );
}

class DailySummary {
  final DateTime date;
  final int totalStudyMinutes;
  final int totalSessions;
  final int totalDistractions;
  final double avgFocusScore;
  final double focusPercentage;
  final List<String> subjectsStudied;
  final String overallMood;
  final int quizzesTaken;
  final int badgesEarned;

  DailySummary({
    required this.date,
    this.totalStudyMinutes = 0,
    this.totalSessions = 0,
    this.totalDistractions = 0,
    this.avgFocusScore = 0,
    this.focusPercentage = 0,
    this.subjectsStudied = const [],
    this.overallMood = 'neutral',
    this.quizzesTaken = 0,
    this.badgesEarned = 0,
  });

  bool get isGoodDay => avgFocusScore >= 75 && totalStudyMinutes >= 60;
  bool get metGoal => totalStudyMinutes >= 120; // Default 2hr goal

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'total_study_minutes': totalStudyMinutes,
    'total_sessions': totalSessions,
    'total_distractions': totalDistractions,
    'avg_focus_score': avgFocusScore,
    'focus_percentage': focusPercentage,
    'subjects_studied': subjectsStudied,
    'overall_mood': overallMood,
    'quizzes_taken': quizzesTaken,
    'badges_earned': badgesEarned,
  };

  factory DailySummary.fromJson(Map<String, dynamic> json) => DailySummary(
    date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
    totalStudyMinutes: json['total_study_minutes'] ?? 0,
    totalSessions: json['total_sessions'] ?? 0,
    totalDistractions: json['total_distractions'] ?? 0,
    avgFocusScore: (json['avg_focus_score'] ?? 0).toDouble(),
    focusPercentage: (json['focus_percentage'] ?? 0).toDouble(),
    subjectsStudied: List<String>.from(json['subjects_studied'] ?? []),
    overallMood: json['overall_mood'] ?? 'neutral',
    quizzesTaken: json['quizzes_taken'] ?? 0,
    badgesEarned: json['badges_earned'] ?? 0,
  );
}

class DistractionRecord {
  final String id;
  final String appName;
  final String type; // app_switch, inactivity, self_reported, blocked_site
  final DateTime timestamp;
  final int durationSeconds;
  final String sessionId;

  DistractionRecord({
    required this.id,
    required this.appName,
    required this.type,
    required this.timestamp,
    this.durationSeconds = 0,
    this.sessionId = '',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'app_name': appName,
    'type': type,
    'timestamp': timestamp.toIso8601String(),
    'duration_seconds': durationSeconds,
    'session_id': sessionId,
  };

  factory DistractionRecord.fromJson(Map<String, dynamic> json) => DistractionRecord(
    id: json['id'] ?? '',
    appName: json['app_name'] ?? '',
    type: json['type'] ?? 'unknown',
    timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    durationSeconds: json['duration_seconds'] ?? 0,
    sessionId: json['session_id'] ?? '',
  );
}

/// Weekly analytics aggregation
class WeeklyReport {
  final DateTime weekStart;
  final DateTime weekEnd;
  final int totalMinutes;
  final int totalSessions;
  final int totalDistractions;
  final double avgFocusScore;
  final double avgFocusPercentage;
  final Map<String, int> subjectMinutes; // subject -> minutes
  final List<WeakTopic> weakTopicsIdentified;
  final int badgesEarned;
  final int streakDays;
  final String aiSummary; // AI-generated weekly feedback

  WeeklyReport({
    required this.weekStart,
    required this.weekEnd,
    this.totalMinutes = 0,
    this.totalSessions = 0,
    this.totalDistractions = 0,
    this.avgFocusScore = 0,
    this.avgFocusPercentage = 0,
    this.subjectMinutes = const {},
    this.weakTopicsIdentified = const [],
    this.badgesEarned = 0,
    this.streakDays = 0,
    this.aiSummary = '',
  });

  double get hoursStudied => totalMinutes / 60.0;
  String get performanceRating {
    if (avgFocusScore >= 85 && totalMinutes >= 600) return 'Excellent';
    if (avgFocusScore >= 70 && totalMinutes >= 420) return 'Good';
    if (avgFocusScore >= 55 && totalMinutes >= 240) return 'Average';
    return 'Needs Improvement';
  }

  Map<String, dynamic> toJson() => {
    'week_start': weekStart.toIso8601String(),
    'week_end': weekEnd.toIso8601String(),
    'total_minutes': totalMinutes,
    'total_sessions': totalSessions,
    'total_distractions': totalDistractions,
    'avg_focus_score': avgFocusScore,
    'avg_focus_percentage': avgFocusPercentage,
    'subject_minutes': subjectMinutes,
    'badges_earned': badgesEarned,
    'streak_days': streakDays,
    'ai_summary': aiSummary,
  };

  factory WeeklyReport.fromJson(Map<String, dynamic> json) => WeeklyReport(
    weekStart: DateTime.tryParse(json['week_start'] ?? '') ?? DateTime.now(),
    weekEnd: DateTime.tryParse(json['week_end'] ?? '') ?? DateTime.now(),
    totalMinutes: json['total_minutes'] ?? 0,
    totalSessions: json['total_sessions'] ?? 0,
    totalDistractions: json['total_distractions'] ?? 0,
    avgFocusScore: (json['avg_focus_score'] ?? 0).toDouble(),
    avgFocusPercentage: (json['avg_focus_percentage'] ?? 0).toDouble(),
    subjectMinutes: Map<String, int>.from(json['subject_minutes'] ?? {}),
    badgesEarned: json['badges_earned'] ?? 0,
    streakDays: json['streak_days'] ?? 0,
    aiSummary: json['ai_summary'] ?? '',
  );
}

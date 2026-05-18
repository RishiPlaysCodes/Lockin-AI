class FocusSession {
  final String id;
  final String subject;
  final String sessionType;
  final DateTime startTime;
  DateTime? endTime;
  final int plannedDuration;
  bool isActive;
  bool isCompleted;
  int focusScore;
  int distractionCount;
  String moodBefore;
  String moodAfter;
  String notes;

  FocusSession({
    required this.id,
    this.subject = 'General Study',
    this.sessionType = 'pomodoro',
    required this.startTime,
    this.endTime,
    this.plannedDuration = 25,
    this.isActive = true,
    this.isCompleted = false,
    this.focusScore = 100,
    this.distractionCount = 0,
    this.moodBefore = 'neutral',
    this.moodAfter = '',
    this.notes = '',
  });

  Duration get duration {
    if (endTime != null) return endTime!.difference(startTime);
    if (isActive) return DateTime.now().difference(startTime);
    return Duration.zero;
  }

  double get durationMinutes => duration.inSeconds / 60.0;

  String get durationFormatted {
    int totalSecs = duration.inSeconds;
    int hours = totalSecs ~/ 3600;
    int mins = (totalSecs % 3600) ~/ 60;
    if (hours > 0) return '${hours}h ${mins}m';
    return '${mins}m';
  }

  double get completionPercentage {
    if (plannedDuration <= 0) return 100;
    return (durationMinutes / plannedDuration * 100).clamp(0, 100);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'subject': subject,
    'session_type': sessionType,
    'start_time': startTime.toIso8601String(),
    'end_time': endTime?.toIso8601String(),
    'planned_duration': plannedDuration,
    'is_active': isActive,
    'is_completed': isCompleted,
    'focus_score': focusScore,
    'distraction_count': distractionCount,
    'mood_before': moodBefore,
    'mood_after': moodAfter,
    'notes': notes,
  };

  factory FocusSession.fromJson(Map<String, dynamic> json) {
    return FocusSession(
      id: json['id']?.toString() ?? '',
      subject: json['subject'] ?? 'General Study',
      sessionType: json['session_type'] ?? 'pomodoro',
      startTime: DateTime.tryParse(json['start_time'] ?? '') ?? DateTime.now(),
      endTime: json['end_time'] != null ? DateTime.tryParse(json['end_time']) : null,
      plannedDuration: json['planned_duration'] ?? 25,
      isActive: json['is_active'] ?? false,
      isCompleted: json['is_completed'] ?? false,
      focusScore: json['focus_score'] ?? 100,
      distractionCount: json['distraction_count'] ?? 0,
      moodBefore: json['mood_before'] ?? '',
      moodAfter: json['mood_after'] ?? '',
      notes: json['notes'] ?? '',
    );
  }
}

class Distraction {
  final String id;
  final String appName;
  final String type;
  final String severity;
  final DateTime timestamp;

  Distraction({
    required this.id,
    required this.appName,
    this.type = 'app_switch',
    this.severity = 'medium',
    required this.timestamp,
  });

  int get scorePenalty {
    switch (severity) {
      case 'high': return 10;
      case 'medium': return 5;
      case 'low': return 3;
      default: return 5;
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'app_name': appName,
    'type': type,
    'severity': severity,
    'timestamp': timestamp.toIso8601String(),
  };
}

class BlockedSite {
  final String id;
  String name;
  String url;
  String category;
  bool isActive;
  int timesBlocked;

  BlockedSite({
    required this.id,
    required this.name,
    required this.url,
    this.category = 'social_media',
    this.isActive = true,
    this.timesBlocked = 0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'url': url,
    'category': category,
    'is_active': isActive,
    'times_blocked': timesBlocked,
  };

  factory BlockedSite.fromJson(Map<String, dynamic> json) {
    return BlockedSite(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      url: json['url'] ?? '',
      category: json['category'] ?? 'social_media',
      isActive: json['is_active'] ?? true,
      timesBlocked: json['times_blocked'] ?? 0,
    );
  }
}

class ChatMessage {
  final String id;
  final String role;
  final String content;
  final String mode;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    this.mode = 'general',
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'role': role,
    'content': content,
    'mode': mode,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id']?.toString() ?? '',
      role: json['role'] ?? 'user',
      content: json['content'] ?? '',
      mode: json['mode'] ?? 'general',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }
}

class Badge {
  final String type;
  final String name;
  final String icon;
  final String description;
  final String rarity;
  final DateTime? earnedAt;
  final bool isEarned;

  Badge({
    required this.type,
    required this.name,
    required this.icon,
    required this.description,
    this.rarity = 'Common',
    this.earnedAt,
    this.isEarned = false,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'name': name,
    'earned_at': earnedAt?.toIso8601String(),
    'is_earned': isEarned,
  };
}

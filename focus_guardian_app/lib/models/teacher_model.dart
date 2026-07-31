/// AI Teacher personalities and configurations
class AITeacher {
  final String id;
  final String name;
  final String personality; // strict, friendly, mentor, drill_sergeant
  final String avatar;
  final String description;
  final String voiceStyle;
  final List<String> catchPhrases;
  final double strictnessLevel; // 0.0 to 1.0

  const AITeacher({
    required this.id,
    required this.name,
    required this.personality,
    required this.avatar,
    required this.description,
    required this.voiceStyle,
    required this.catchPhrases,
    required this.strictnessLevel,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'personality': personality,
    'avatar': avatar,
    'description': description,
    'voice_style': voiceStyle,
    'strictness_level': strictnessLevel,
  };

  factory AITeacher.fromJson(Map<String, dynamic> json) => AITeacher(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    personality: json['personality'] ?? 'friendly',
    avatar: json['avatar'] ?? '👨‍🏫',
    description: json['description'] ?? '',
    voiceStyle: json['voice_style'] ?? 'calm',
    catchPhrases: List<String>.from(json['catch_phrases'] ?? []),
    strictnessLevel: (json['strictness_level'] ?? 0.5).toDouble(),
  );

  /// Pre-built teacher personalities
  static const List<AITeacher> availableTeachers = [
    AITeacher(
      id: 'strict_sir',
      name: 'Strict Sir',
      personality: 'strict',
      avatar: '👨‍🏫',
      description: 'No-nonsense teacher. Will scold you if distracted. Expects discipline and results.',
      voiceStyle: 'firm',
      catchPhrases: [
        'Put that phone down NOW!',
        'Is this what you call studying?',
        'I expected better from you.',
        'Focus! Your exam is approaching.',
        'No excuses. Get back to work.',
        'You\'re wasting precious time!',
      ],
      strictnessLevel: 0.95,
    ),
    AITeacher(
      id: 'friendly_maam',
      name: 'Friendly Ma\'am',
      personality: 'friendly',
      avatar: '👩‍🏫',
      description: 'Supportive and encouraging. Motivates with kindness. Celebrates small wins.',
      voiceStyle: 'warm',
      catchPhrases: [
        'You\'re doing great! Keep it up!',
        'Take a small break if needed, then come back stronger.',
        'I believe in you! You can do this.',
        'Every minute counts. You\'re making progress!',
        'Let\'s get back on track together, okay?',
        'I\'m proud of your dedication today!',
      ],
      strictnessLevel: 0.3,
    ),
    AITeacher(
      id: 'mentor_guide',
      name: 'Mentor Guide',
      personality: 'mentor',
      avatar: '🧙‍♂️',
      description: 'Wise and balanced. Guides with questions. Helps you understand WHY you should focus.',
      voiceStyle: 'thoughtful',
      catchPhrases: [
        'Ask yourself - will this distraction help your future self?',
        'What would your goal look like if you stayed focused right now?',
        'Remember your WHY. What are you studying for?',
        'The disciplined mind achieves what others only dream of.',
        'Small consistent efforts build mountains over time.',
        'Your future self will thank you for this moment of focus.',
      ],
      strictnessLevel: 0.6,
    ),
    AITeacher(
      id: 'drill_sergeant',
      name: 'Drill Sergeant',
      personality: 'drill_sergeant',
      avatar: '💪',
      description: 'Military-style discipline. Zero tolerance for distractions. Pushes you to your limits.',
      voiceStyle: 'commanding',
      catchPhrases: [
        'ATTENTION! Back to your desk IMMEDIATELY!',
        'Did I give you permission to get distracted?!',
        'Drop and give me 25 minutes of PURE FOCUS!',
        'UNACCEPTABLE! Your competition is studying right now!',
        'This is WAR against laziness. Fight back!',
        'Champions don\'t make excuses. GET BACK TO WORK!',
      ],
      strictnessLevel: 1.0,
    ),
    AITeacher(
      id: 'study_buddy',
      name: 'Study Buddy',
      personality: 'buddy',
      avatar: '🤝',
      description: 'Like studying with a smart friend. Casual but focused. Makes learning fun.',
      voiceStyle: 'casual',
      catchPhrases: [
        'Bro, let\'s get back to it! We got this!',
        'Come on yaar, just 10 more minutes then break!',
        'Hey! Instagram can wait, your marks can\'t!',
        'Let\'s crush this chapter together!',
        'You and me vs distractions - we\'re winning!',
        'Almost there dude! Don\'t give up now!',
      ],
      strictnessLevel: 0.4,
    ),
  ];
}

/// Focus monitoring alert from AI teacher
class TeacherAlert {
  final String id;
  final String teacherId;
  final String message;
  final String alertType; // distraction, encouragement, reminder, warning
  final String severity; // low, medium, high, critical
  final DateTime timestamp;
  final bool wasSpoken; // Voice alert was played

  TeacherAlert({
    required this.id,
    required this.teacherId,
    required this.message,
    required this.alertType,
    this.severity = 'medium',
    required this.timestamp,
    this.wasSpoken = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'teacher_id': teacherId,
    'message': message,
    'alert_type': alertType,
    'severity': severity,
    'timestamp': timestamp.toIso8601String(),
    'was_spoken': wasSpoken,
  };
}

/// Camera monitoring state
enum FocusState {
  focused, // Student is looking at screen/book
  distracted, // Looking away, playing with objects
  absent, // Not in frame
  sleeping, // Eyes closed for extended time
  unknown, // Can't determine
}

class CameraMonitorState {
  final FocusState currentState;
  final DateTime lastCheck;
  final int focusedSeconds;
  final int distractedSeconds;
  final int alertsSent;
  final bool isCameraActive;

  CameraMonitorState({
    this.currentState = FocusState.unknown,
    required this.lastCheck,
    this.focusedSeconds = 0,
    this.distractedSeconds = 0,
    this.alertsSent = 0,
    this.isCameraActive = false,
  });

  double get focusPercentage {
    final total = focusedSeconds + distractedSeconds;
    if (total == 0) return 100;
    return (focusedSeconds / total * 100).clamp(0, 100);
  }
}

/// Blocked social media account
class BlockedAccount {
  final String id;
  final String platform; // instagram, facebook, youtube, twitter, tiktok
  final String username;
  final String email;
  final bool isActive;
  final DateTime blockedUntil;
  final String blockType; // time_based, session_based, permanent

  BlockedAccount({
    required this.id,
    required this.platform,
    required this.username,
    this.email = '',
    this.isActive = true,
    required this.blockedUntil,
    this.blockType = 'session_based',
  });

  String get platformIcon {
    switch (platform) {
      case 'instagram': return '📷';
      case 'facebook': return '👤';
      case 'youtube': return '▶️';
      case 'twitter': return '🐦';
      case 'tiktok': return '🎵';
      case 'snapchat': return '👻';
      case 'reddit': return '🤖';
      default: return '🌐';
    }
  }

  String get platformColor {
    switch (platform) {
      case 'instagram': return '#E4405F';
      case 'facebook': return '#1877F2';
      case 'youtube': return '#FF0000';
      case 'twitter': return '#1DA1F2';
      case 'tiktok': return '#000000';
      case 'snapchat': return '#FFFC00';
      default: return '#6C63FF';
    }
  }

  bool get isCurrentlyBlocked {
    return isActive && DateTime.now().isBefore(blockedUntil);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'platform': platform,
    'username': username,
    'email': email,
    'is_active': isActive,
    'blocked_until': blockedUntil.toIso8601String(),
    'block_type': blockType,
  };

  factory BlockedAccount.fromJson(Map<String, dynamic> json) => BlockedAccount(
    id: json['id'] ?? '',
    platform: json['platform'] ?? '',
    username: json['username'] ?? '',
    email: json['email'] ?? '',
    isActive: json['is_active'] ?? true,
    blockedUntil: DateTime.tryParse(json['blocked_until'] ?? '') ?? DateTime.now(),
    blockType: json['block_type'] ?? 'session_based',
  );
}

/// Friend / Study Partner
class StudyFriend {
  final String id;
  final String username;
  final String displayName;
  final String avatarColor;
  final String status; // online, studying, offline, in_session
  final int streakDays;
  final String level;
  final DateTime? lastActive;
  final bool isOnline;

  StudyFriend({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarColor = '#6C63FF',
    this.status = 'offline',
    this.streakDays = 0,
    this.level = 'Beginner',
    this.lastActive,
    this.isOnline = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'display_name': displayName,
    'avatar_color': avatarColor,
    'status': status,
    'streak_days': streakDays,
    'level': level,
    'last_active': lastActive?.toIso8601String(),
    'is_online': isOnline,
  };

  factory StudyFriend.fromJson(Map<String, dynamic> json) => StudyFriend(
    id: json['id'] ?? '',
    username: json['username'] ?? '',
    displayName: json['display_name'] ?? json['username'] ?? '',
    avatarColor: json['avatar_color'] ?? '#6C63FF',
    status: json['status'] ?? 'offline',
    streakDays: json['streak_days'] ?? 0,
    level: json['level'] ?? 'Beginner',
    lastActive: DateTime.tryParse(json['last_active'] ?? ''),
    isOnline: json['is_online'] ?? false,
  );
}

/// Group Study Session
class GroupStudySession {
  final String id;
  final String name;
  final String hostId;
  final String hostName;
  final String subject;
  final List<String> participantIds;
  final List<String> participantNames;
  final DateTime startTime;
  final DateTime? endTime;
  final int plannedDuration;
  final bool isActive;
  final String teacherId; // Which AI teacher is monitoring
  final Map<String, int> participantScores; // userId -> focus score

  GroupStudySession({
    required this.id,
    required this.name,
    required this.hostId,
    required this.hostName,
    required this.subject,
    required this.participantIds,
    required this.participantNames,
    required this.startTime,
    this.endTime,
    this.plannedDuration = 25,
    this.isActive = true,
    this.teacherId = 'strict_sir',
    this.participantScores = const {},
  });

  int get participantCount => participantIds.length;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'host_id': hostId,
    'host_name': hostName,
    'subject': subject,
    'participant_ids': participantIds,
    'participant_names': participantNames,
    'start_time': startTime.toIso8601String(),
    'end_time': endTime?.toIso8601String(),
    'planned_duration': plannedDuration,
    'is_active': isActive,
    'teacher_id': teacherId,
    'participant_scores': participantScores,
  };

  factory GroupStudySession.fromJson(Map<String, dynamic> json) => GroupStudySession(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    hostId: json['host_id'] ?? '',
    hostName: json['host_name'] ?? '',
    subject: json['subject'] ?? '',
    participantIds: List<String>.from(json['participant_ids'] ?? []),
    participantNames: List<String>.from(json['participant_names'] ?? []),
    startTime: DateTime.tryParse(json['start_time'] ?? '') ?? DateTime.now(),
    endTime: json['end_time'] != null ? DateTime.tryParse(json['end_time']) : null,
    plannedDuration: json['planned_duration'] ?? 25,
    isActive: json['is_active'] ?? true,
    teacherId: json['teacher_id'] ?? 'strict_sir',
    participantScores: Map<String, int>.from(json['participant_scores'] ?? {}),
  );
}

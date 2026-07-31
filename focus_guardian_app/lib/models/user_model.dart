class UserProfile {
  String username;
  String email;
  int focusScore;
  int totalStudyMinutes;
  int streakDays;
  int longestStreak;
  int totalSessions;
  int totalDistractions;
  int dailyGoalMinutes;
  String level;
  double levelProgress;
  int xpPoints;
  String avatarColor;
  String bio;

  UserProfile({
    this.username = 'Student',
    this.email = '',
    this.focusScore = 100,
    this.totalStudyMinutes = 0,
    this.streakDays = 0,
    this.longestStreak = 0,
    this.totalSessions = 0,
    this.totalDistractions = 0,
    this.dailyGoalMinutes = 120,
    this.level = 'Beginner',
    this.levelProgress = 0,
    this.xpPoints = 0,
    this.avatarColor = '#6c63ff',
    this.bio = '',
  });

  double get totalStudyHours => totalStudyMinutes / 60.0;

  String get focusGrade {
    if (focusScore >= 95) return 'A+';
    if (focusScore >= 90) return 'A';
    if (focusScore >= 85) return 'B+';
    if (focusScore >= 80) return 'B';
    if (focusScore >= 70) return 'C';
    if (focusScore >= 60) return 'D';
    return 'F';
  }

  String computeLevel() {
    double hours = totalStudyHours;
    if (hours >= 500) return 'Grandmaster';
    if (hours >= 200) return 'Master';
    if (hours >= 100) return 'Expert';
    if (hours >= 50) return 'Advanced';
    if (hours >= 20) return 'Intermediate';
    if (hours >= 5) return 'Apprentice';
    return 'Beginner';
  }

  Map<String, dynamic> toJson() => {
    'username': username,
    'email': email,
    'focus_score': focusScore,
    'total_study_minutes': totalStudyMinutes,
    'streak_days': streakDays,
    'longest_streak': longestStreak,
    'total_sessions': totalSessions,
    'total_distractions': totalDistractions,
    'daily_goal_minutes': dailyGoalMinutes,
    'avatar_color': avatarColor,
    'bio': bio,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      username: json['username'] ?? 'Student',
      email: json['email'] ?? '',
      focusScore: json['focus_score'] ?? 100,
      totalStudyMinutes: json['total_study_minutes'] ?? 0,
      streakDays: json['streak_days'] ?? 0,
      longestStreak: json['longest_streak'] ?? 0,
      totalSessions: json['total_sessions'] ?? 0,
      totalDistractions: json['total_distractions'] ?? 0,
      dailyGoalMinutes: json['daily_goal_minutes'] ?? 120,
      avatarColor: json['avatar_color'] ?? '#6c63ff',
      bio: json['bio'] ?? '',
    );
  }
}

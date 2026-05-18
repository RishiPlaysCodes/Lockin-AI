class AppConstants {
  static const String appName = 'Focus Guardian AI';
  static const String appVersion = '1.0.0';
  
  // API Base URL - change this to your Django server
  static const String baseUrl = 'http://10.0.2.2:8000'; // Android emulator localhost
  // static const String baseUrl = 'http://localhost:8000'; // iOS simulator
  // static const String baseUrl = 'https://your-production-url.com'; // Production
  
  // API Endpoints
  static const String loginUrl = '/login/';
  static const String signupUrl = '/signup/';
  static const String profileUrl = '/api/profile/';
  static const String sessionStartUrl = '/api/session/start/';
  static const String sessionEndUrl = '/api/session/end/';
  static const String sessionActiveUrl = '/api/session/active/';
  static const String distractionUrl = '/api/distraction/';
  static const String reportUrl = '/api/report/';
  static const String aiTeacherUrl = '/api/ai-teacher/';
  static const String chatClearUrl = '/api/chat/clear/';
  static const String quoteUrl = '/api/quote/';
  
  // Local storage keys
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUsername = 'username';
  static const String keyUserData = 'user_data';
  static const String keyFocusScore = 'focus_score';
  static const String keyTotalStudyMinutes = 'total_study_minutes';
  static const String keyStreakDays = 'streak_days';
  static const String keyLongestStreak = 'longest_streak';
  static const String keyLastStudyDate = 'last_study_date';
  static const String keyDailyGoal = 'daily_goal_minutes';
  static const String keyBlockedSites = 'blocked_sites';
  static const String keySessions = 'sessions';
  static const String keyBadges = 'badges';
  static const String keyChatHistory = 'chat_history';
  static const String keyTheme = 'theme';
  static const String keyTimerSound = 'timer_sound';
  static const String keyBreakDuration = 'break_duration';
  
  // Badge types
  static const List<Map<String, String>> badgeTypes = [
    {'type': 'first_session', 'name': 'First Session', 'icon': 'play_circle', 'desc': 'Complete your first focus session'},
    {'type': 'streak_3', 'name': '3 Day Streak', 'icon': 'local_fire_department', 'desc': 'Study 3 consecutive days'},
    {'type': 'streak_7', 'name': 'Week Warrior', 'icon': 'emoji_events', 'desc': 'Maintain a 7-day streak'},
    {'type': 'streak_14', 'name': '2 Week Champion', 'icon': 'stars', 'desc': '14 days straight!'},
    {'type': 'streak_30', 'name': 'Monthly Master', 'icon': 'diamond', 'desc': '30 day study streak'},
    {'type': 'hours_1', 'name': '1 Hour Club', 'icon': 'hourglass_bottom', 'desc': '1 hour total study'},
    {'type': 'hours_5', 'name': '5 Hours Club', 'icon': 'schedule', 'desc': '5 hours total study'},
    {'type': 'hours_10', 'name': '10 Hours Club', 'icon': 'alarm', 'desc': '10 hours total study'},
    {'type': 'hours_20', 'name': '20 Hours Club', 'icon': 'star', 'desc': '20 hours total study'},
    {'type': 'hours_50', 'name': '50 Hours Club', 'icon': 'rocket_launch', 'desc': '50 hours total study'},
    {'type': 'hours_100', 'name': 'Century Scholar', 'icon': 'workspace_premium', 'desc': '100 hours total study'},
    {'type': 'no_distraction', 'name': 'Zero Distraction', 'icon': 'shield', 'desc': '15+ min session, 0 distractions'},
    {'type': 'focus_master', 'name': 'Focus Master', 'icon': 'gps_fixed', 'desc': 'Achieve 100 focus score'},
    {'type': 'early_bird', 'name': 'Early Bird', 'icon': 'wb_sunny', 'desc': 'Session before 6 AM'},
    {'type': 'night_owl', 'name': 'Night Owl', 'icon': 'nightlight', 'desc': 'Study past 11 PM'},
    {'type': 'marathon', 'name': 'Marathon Runner', 'icon': 'directions_run', 'desc': '90+ minute session'},
    {'type': 'deep_thinker', 'name': 'Deep Thinker', 'icon': 'psychology', 'desc': '60+ min on one subject'},
  ];

  // Motivational quotes
  static const List<Map<String, String>> quotes = [
    {'quote': 'The secret of getting ahead is getting started.', 'author': 'Mark Twain'},
    {'quote': 'Focus is the art of knowing what to ignore.', 'author': 'James Clear'},
    {'quote': 'The successful warrior is the average man, with laser-like focus.', 'author': 'Bruce Lee'},
    {'quote': 'Where focus goes, energy flows.', 'author': 'Tony Robbins'},
    {'quote': 'Discipline is the bridge between goals and accomplishment.', 'author': 'Jim Rohn'},
    {'quote': 'A little progress each day adds up to big results.', 'author': 'Satya Nani'},
    {'quote': 'The expert in anything was once a beginner.', 'author': 'Helen Hayes'},
    {'quote': 'Start where you are. Use what you have. Do what you can.', 'author': 'Arthur Ashe'},
    {'quote': 'Don\'t watch the clock; do what it does. Keep going.', 'author': 'Sam Levenson'},
    {'quote': 'Believe you can and you\'re halfway there.', 'author': 'Theodore Roosevelt'},
  ];
}

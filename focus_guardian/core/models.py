from django.db import models
from django.contrib.auth.models import User
from django.utils import timezone
from django.core.validators import MinValueValidator, MaxValueValidator
from datetime import timedelta
import json


class UserProfile(models.Model):
    """Extended user profile with focus tracking data and preferences."""

    THEME_CHOICES = [
        ("dark", "Dark"),
        ("light", "Light"),
        ("midnight", "Midnight Blue"),
    ]

    SOUND_CHOICES = [
        ("bell", "Bell"),
        ("chime", "Chime"),
        ("digital", "Digital"),
        ("none", "No Sound"),
    ]

    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name="profile")
    
    # Core stats
    focus_score = models.IntegerField(
        default=100, validators=[MinValueValidator(0), MaxValueValidator(100)]
    )
    total_study_time = models.DurationField(default=timedelta(0))
    streak_days = models.IntegerField(default=0, validators=[MinValueValidator(0)])
    longest_streak = models.IntegerField(default=0, validators=[MinValueValidator(0)])
    last_study_date = models.DateField(null=True, blank=True)
    total_sessions_completed = models.IntegerField(default=0, validators=[MinValueValidator(0)])
    total_distractions = models.IntegerField(default=0, validators=[MinValueValidator(0)])
    
    # Profile info
    bio = models.CharField(max_length=200, blank=True, default="")
    avatar_color = models.CharField(max_length=7, default="#6c63ff")
    daily_goal_minutes = models.IntegerField(
        default=120, validators=[MinValueValidator(15), MaxValueValidator(720)],
        help_text="Daily study goal in minutes"
    )
    
    # Preferences
    theme = models.CharField(max_length=20, choices=THEME_CHOICES, default="dark")
    timer_sound = models.CharField(max_length=20, choices=SOUND_CHOICES, default="bell")
    break_duration = models.IntegerField(
        default=5, validators=[MinValueValidator(1), MaxValueValidator(30)],
        help_text="Break duration in minutes"
    )
    auto_start_breaks = models.BooleanField(default=True)
    show_motivational_quotes = models.BooleanField(default=True)
    distraction_alerts = models.BooleanField(default=True)
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        verbose_name = "User Profile"
        verbose_name_plural = "User Profiles"

    def __str__(self):
        return f"{self.user.username}'s Profile"

    @property
    def total_study_hours(self):
        total_seconds = self.total_study_time.total_seconds()
        return round(total_seconds / 3600, 1)

    @property
    def total_study_minutes_int(self):
        return int(self.total_study_time.total_seconds() / 60)

    @property
    def level(self):
        """Calculate user level based on total study hours."""
        hours = self.total_study_hours
        if hours >= 500:
            return "Grandmaster"
        elif hours >= 200:
            return "Master"
        elif hours >= 100:
            return "Expert"
        elif hours >= 50:
            return "Advanced"
        elif hours >= 20:
            return "Intermediate"
        elif hours >= 5:
            return "Apprentice"
        return "Beginner"

    @property
    def level_progress(self):
        """Progress percentage to next level."""
        hours = self.total_study_hours
        levels = [0, 5, 20, 50, 100, 200, 500]
        for i in range(len(levels) - 1):
            if hours < levels[i + 1]:
                progress = (hours - levels[i]) / (levels[i + 1] - levels[i]) * 100
                return min(round(progress, 1), 100)
        return 100

    @property
    def xp_points(self):
        """XP based on study time and achievements."""
        base_xp = int(self.total_study_time.total_seconds() / 60)  # 1 XP per minute
        badge_xp = self.user.badges.count() * 50  # 50 XP per badge
        streak_xp = self.streak_days * 10  # 10 XP per streak day
        return base_xp + badge_xp + streak_xp

    @property
    def daily_goal_progress(self):
        """Today's progress toward daily goal."""
        today = timezone.now().date()
        today_sessions = FocusSession.objects.filter(
            user=self.user, start_time__date=today, is_active=False
        )
        today_minutes = sum(s.duration_minutes for s in today_sessions)
        if self.daily_goal_minutes <= 0:
            return 100
        return min(round((today_minutes / self.daily_goal_minutes) * 100, 1), 100)

    @property
    def average_session_length(self):
        """Average session length in minutes."""
        if self.total_sessions_completed == 0:
            return 0
        total_mins = self.total_study_time.total_seconds() / 60
        return round(total_mins / self.total_sessions_completed, 1)

    @property
    def focus_grade(self):
        """Letter grade based on focus score."""
        score = self.focus_score
        if score >= 95:
            return "A+"
        elif score >= 90:
            return "A"
        elif score >= 85:
            return "B+"
        elif score >= 80:
            return "B"
        elif score >= 70:
            return "C"
        elif score >= 60:
            return "D"
        return "F"


class FocusSession(models.Model):
    """A single focus/study session with comprehensive tracking."""

    SESSION_TYPES = [
        ("pomodoro", "Pomodoro (25 min)"),
        ("deep_work", "Deep Work (50 min)"),
        ("short", "Short Session (15 min)"),
        ("custom", "Custom Duration"),
        ("marathon", "Marathon (90 min)"),
    ]

    MOOD_CHOICES = [
        ("great", "Feeling Great"),
        ("good", "Good"),
        ("neutral", "Neutral"),
        ("tired", "Tired"),
        ("stressed", "Stressed"),
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="focus_sessions")
    subject = models.CharField(max_length=100, default="General Study")
    session_type = models.CharField(max_length=20, choices=SESSION_TYPES, default="pomodoro")
    start_time = models.DateTimeField(auto_now_add=True)
    end_time = models.DateTimeField(null=True, blank=True)
    planned_duration = models.IntegerField(
        default=25, validators=[MinValueValidator(1), MaxValueValidator(300)],
        help_text="Planned duration in minutes"
    )
    is_active = models.BooleanField(default=True)
    is_completed = models.BooleanField(default=False, help_text="Did user complete the full planned duration?")
    notes = models.TextField(blank=True, default="")
    mood_before = models.CharField(max_length=20, choices=MOOD_CHOICES, blank=True, default="")
    mood_after = models.CharField(max_length=20, choices=MOOD_CHOICES, blank=True, default="")
    focus_score = models.IntegerField(
        default=100, validators=[MinValueValidator(0), MaxValueValidator(100)]
    )

    class Meta:
        ordering = ["-start_time"]
        indexes = [
            models.Index(fields=["user", "-start_time"]),
            models.Index(fields=["user", "is_active"]),
            models.Index(fields=["start_time"]),
        ]

    def __str__(self):
        return f"{self.user.username} - {self.subject} ({self.start_time.strftime('%Y-%m-%d %H:%M')})"

    @property
    def duration(self):
        """Get session duration."""
        if self.end_time:
            return self.end_time - self.start_time
        if self.is_active:
            return timezone.now() - self.start_time
        return timedelta(0)

    @property
    def duration_minutes(self):
        return round(self.duration.total_seconds() / 60, 1)

    @property
    def duration_formatted(self):
        """Human-readable duration."""
        total_seconds = int(self.duration.total_seconds())
        hours = total_seconds // 3600
        minutes = (total_seconds % 3600) // 60
        if hours > 0:
            return f"{hours}h {minutes}m"
        return f"{minutes}m"

    @property
    def distraction_count(self):
        return self.distractions.count()

    @property
    def completion_percentage(self):
        """How much of the planned duration was completed."""
        if self.planned_duration <= 0:
            return 100
        return min(round((self.duration_minutes / self.planned_duration) * 100, 1), 100)


class Distraction(models.Model):
    """Records a distraction event during a focus session."""

    DISTRACTION_TYPES = [
        ("app_switch", "App Switch"),
        ("website", "Blocked Website"),
        ("inactivity", "Inactivity"),
        ("tab_switch", "Tab Switch"),
        ("phone", "Phone Usage"),
        ("notification", "Notification"),
        ("manual", "Self-Reported"),
    ]

    SEVERITY_CHOICES = [
        ("low", "Low"),
        ("medium", "Medium"),
        ("high", "High"),
    ]

    session = models.ForeignKey(
        FocusSession, on_delete=models.CASCADE, related_name="distractions"
    )
    app_name = models.CharField(max_length=255)
    distraction_type = models.CharField(
        max_length=20, choices=DISTRACTION_TYPES, default="app_switch"
    )
    severity = models.CharField(max_length=10, choices=SEVERITY_CHOICES, default="medium")
    duration_seconds = models.IntegerField(
        default=0, validators=[MinValueValidator(0)],
        help_text="How long the distraction lasted"
    )
    timestamp = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-timestamp"]
        indexes = [
            models.Index(fields=["session", "-timestamp"]),
        ]

    def __str__(self):
        return f"{self.session.user.username} - {self.app_name} ({self.distraction_type})"

    @property
    def score_penalty(self):
        """Calculate score penalty based on severity."""
        penalties = {"low": 3, "medium": 5, "high": 10}
        return penalties.get(self.severity, 5)


class BlockedSite(models.Model):
    """Sites/apps that should be blocked during focus mode."""

    CATEGORY_CHOICES = [
        ("social_media", "Social Media"),
        ("entertainment", "Entertainment"),
        ("gaming", "Gaming"),
        ("news", "News"),
        ("shopping", "Shopping"),
        ("messaging", "Messaging"),
        ("video", "Video Streaming"),
        ("other", "Other"),
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="blocked_sites")
    name = models.CharField(max_length=100)
    url = models.CharField(max_length=255)
    category = models.CharField(max_length=50, choices=CATEGORY_CHOICES, default="social_media")
    is_active = models.BooleanField(default=True)
    times_blocked = models.IntegerField(default=0, validators=[MinValueValidator(0)])
    icon = models.CharField(max_length=50, blank=True, default="globe")
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["category", "name"]
        unique_together = ["user", "url"]

    def __str__(self):
        return f"{self.name} ({self.url})"

    @property
    def category_color(self):
        """Color for category badge."""
        colors = {
            "social_media": "#e74c3c",
            "entertainment": "#f39c12",
            "gaming": "#9b59b6",
            "news": "#3498db",
            "shopping": "#2ecc71",
            "messaging": "#1abc9c",
            "video": "#e67e22",
            "other": "#95a5a6",
        }
        return colors.get(self.category, "#95a5a6")


class StudyLog(models.Model):
    """Daily study log for tracking progress."""

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="study_logs")
    date = models.DateField(default=timezone.now)
    subject = models.CharField(max_length=100)
    duration_minutes = models.IntegerField(default=0, validators=[MinValueValidator(0)])
    sessions_count = models.IntegerField(default=0, validators=[MinValueValidator(0)])
    distractions_count = models.IntegerField(default=0, validators=[MinValueValidator(0)])
    focus_score = models.IntegerField(
        default=100, validators=[MinValueValidator(0), MaxValueValidator(100)]
    )
    notes = models.TextField(blank=True, default="")
    mood = models.CharField(max_length=20, blank=True, default="")

    class Meta:
        ordering = ["-date"]
        unique_together = ["user", "date", "subject"]
        indexes = [
            models.Index(fields=["user", "-date"]),
        ]

    def __str__(self):
        return f"{self.user.username} - {self.subject} ({self.date})"

    @property
    def hours_studied(self):
        return round(self.duration_minutes / 60, 1)


class Badge(models.Model):
    """Achievement badges for gamification."""

    BADGE_TYPES = [
        ("first_session", "First Session"),
        ("streak_3", "3 Day Streak"),
        ("streak_7", "Week Warrior"),
        ("streak_14", "Two Week Champion"),
        ("streak_30", "Monthly Master"),
        ("streak_60", "60 Day Legend"),
        ("streak_100", "100 Day Titan"),
        ("hours_1", "1 Hour Club"),
        ("hours_5", "5 Hours Club"),
        ("hours_10", "10 Hours Club"),
        ("hours_20", "20 Hours Club"),
        ("hours_50", "50 Hours Club"),
        ("hours_100", "Century Scholar"),
        ("hours_200", "200 Hour Hero"),
        ("no_distraction", "Zero Distraction"),
        ("no_distraction_5", "5 Perfect Sessions"),
        ("early_bird", "Early Bird"),
        ("night_owl", "Night Owl"),
        ("focus_master", "Focus Master"),
        ("marathon", "Marathon Runner"),
        ("consistent", "Consistency King"),
        ("comeback", "Comeback Kid"),
        ("speed_learner", "Speed Learner"),
        ("deep_thinker", "Deep Thinker"),
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="badges")
    badge_type = models.CharField(max_length=50, choices=BADGE_TYPES)
    earned_at = models.DateTimeField(auto_now_add=True)
    is_new = models.BooleanField(default=True)

    class Meta:
        unique_together = ["user", "badge_type"]
        ordering = ["-earned_at"]

    def __str__(self):
        return f"{self.user.username} - {self.get_badge_type_display()}"

    @property
    def icon(self):
        icons = {
            "first_session": "play-circle-fill",
            "streak_3": "fire",
            "streak_7": "trophy-fill",
            "streak_14": "stars",
            "streak_30": "gem",
            "streak_60": "diamond-fill",
            "streak_100": "crown",
            "hours_1": "hourglass-split",
            "hours_5": "clock-fill",
            "hours_10": "alarm-fill",
            "hours_20": "star-fill",
            "hours_50": "rocket-takeoff-fill",
            "hours_100": "award-fill",
            "hours_200": "lightning-charge-fill",
            "no_distraction": "shield-check",
            "no_distraction_5": "shield-fill-check",
            "early_bird": "sunrise-fill",
            "night_owl": "moon-stars-fill",
            "focus_master": "bullseye",
            "marathon": "activity",
            "consistent": "graph-up-arrow",
            "comeback": "arrow-repeat",
            "speed_learner": "lightning-fill",
            "deep_thinker": "book-fill",
        }
        return icons.get(self.badge_type, "award-fill")

    @property
    def color(self):
        """Badge color based on rarity."""
        rare_badges = ["streak_100", "hours_200", "hours_100", "streak_60"]
        epic_badges = ["streak_30", "hours_50", "no_distraction_5", "focus_master", "deep_thinker"]
        legendary_badges = ["marathon"]
        
        if self.badge_type in rare_badges:
            return "#ffd700"  # Gold
        elif self.badge_type in epic_badges:
            return "#a855f7"  # Purple
        elif self.badge_type in legendary_badges:
            return "#ef4444"  # Red
        return "#4ecdc4"  # Teal (common)

    @property
    def rarity(self):
        rare_badges = ["streak_100", "hours_200", "hours_100", "streak_60"]
        epic_badges = ["streak_30", "hours_50", "no_distraction_5", "focus_master", "deep_thinker"]
        legendary_badges = ["marathon"]
        
        if self.badge_type in legendary_badges:
            return "Legendary"
        elif self.badge_type in rare_badges:
            return "Rare"
        elif self.badge_type in epic_badges:
            return "Epic"
        return "Common"

    @property
    def description(self):
        """Detailed description for each badge."""
        descriptions = {
            "first_session": "Complete your very first focus session",
            "streak_3": "Study for 3 consecutive days",
            "streak_7": "Maintain a 7-day study streak",
            "streak_14": "Keep going for 14 days straight",
            "streak_30": "An entire month of daily study!",
            "streak_60": "60 days of unstoppable dedication",
            "streak_100": "100 days - you're a legend!",
            "hours_1": "Accumulate 1 hour of total study time",
            "hours_5": "Reach 5 hours of total study time",
            "hours_10": "Hit 10 hours of focused studying",
            "hours_20": "20 hours of dedication achieved",
            "hours_50": "50 hours of pure focus power",
            "hours_100": "100 hours - a true scholar!",
            "hours_200": "200 hours of mastery",
            "no_distraction": "Complete a 15+ min session with zero distractions",
            "no_distraction_5": "Achieve 5 perfect zero-distraction sessions",
            "early_bird": "Start a session before 6:00 AM",
            "night_owl": "Study past 11:00 PM",
            "focus_master": "Achieve a perfect 100 focus score",
            "marathon": "Complete a 90+ minute session without stopping",
            "consistent": "Complete 5+ sessions in a single day",
            "comeback": "Return after 3+ days of inactivity",
            "speed_learner": "Complete 3 sessions in under 2 hours",
            "deep_thinker": "Spend 60+ minutes on a single subject",
        }
        return descriptions.get(self.badge_type, "Keep studying to unlock!")


class ChatMessage(models.Model):
    """Stores AI chat history with metadata."""

    ROLE_CHOICES = [
        ("user", "User"),
        ("assistant", "AI Assistant"),
        ("system", "System"),
    ]

    MODE_CHOICES = [
        ("general", "General Chat"),
        ("teacher", "Teacher Mode"),
        ("quiz", "Quiz Mode"),
        ("study_plan", "Study Plan"),
        ("motivation", "Motivation"),
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="chat_messages")
    role = models.CharField(max_length=10, choices=ROLE_CHOICES)
    content = models.TextField()
    mode = models.CharField(max_length=20, choices=MODE_CHOICES, default="general")
    timestamp = models.DateTimeField(auto_now_add=True)
    is_pinned = models.BooleanField(default=False)

    class Meta:
        ordering = ["timestamp"]
        indexes = [
            models.Index(fields=["user", "timestamp"]),
        ]

    def __str__(self):
        return f"{self.user.username} [{self.role}]: {self.content[:50]}"


class DailyQuote(models.Model):
    """Motivational quotes for users."""

    quote = models.TextField()
    author = models.CharField(max_length=100)
    category = models.CharField(max_length=50, default="focus")

    def __str__(self):
        return f'"{self.quote[:50]}..." - {self.author}'

    class Meta:
        ordering = ["?"]  # Random ordering

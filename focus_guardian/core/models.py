from django.db import models
from django.contrib.auth.models import User
from django.utils import timezone
from datetime import timedelta


class UserProfile(models.Model):
    """Extended user profile with focus tracking data."""

    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name="profile")
    focus_score = models.IntegerField(default=100)
    total_study_time = models.DurationField(default=timedelta(0))
    streak_days = models.IntegerField(default=0)
    last_study_date = models.DateField(null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.username}'s Profile"

    @property
    def total_study_hours(self):
        total_seconds = self.total_study_time.total_seconds()
        return round(total_seconds / 3600, 1)

    @property
    def level(self):
        """Calculate user level based on total study hours."""
        hours = self.total_study_hours
        if hours >= 100:
            return "Master"
        elif hours >= 50:
            return "Expert"
        elif hours >= 20:
            return "Advanced"
        elif hours >= 5:
            return "Intermediate"
        return "Beginner"


class FocusSession(models.Model):
    """A single focus/study session."""

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="focus_sessions")
    subject = models.CharField(max_length=100, default="General Study")
    start_time = models.DateTimeField(auto_now_add=True)
    end_time = models.DateTimeField(null=True, blank=True)
    planned_duration = models.IntegerField(default=25, help_text="Planned duration in minutes")
    is_active = models.BooleanField(default=True)
    notes = models.TextField(blank=True, default="")

    class Meta:
        ordering = ["-start_time"]

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
    def distraction_count(self):
        return self.distractions.count()


class Distraction(models.Model):
    """Records a distraction event during a focus session."""

    DISTRACTION_TYPES = [
        ("app_switch", "App Switch"),
        ("website", "Blocked Website"),
        ("inactivity", "Inactivity"),
        ("tab_switch", "Tab Switch"),
        ("manual", "Manual Report"),
    ]

    session = models.ForeignKey(
        FocusSession, on_delete=models.CASCADE, related_name="distractions"
    )
    app_name = models.CharField(max_length=255)
    distraction_type = models.CharField(
        max_length=20, choices=DISTRACTION_TYPES, default="app_switch"
    )
    timestamp = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-timestamp"]

    def __str__(self):
        return f"{self.session.user.username} - {self.app_name} ({self.distraction_type})"


class BlockedSite(models.Model):
    """Sites/apps that should be blocked during focus mode."""

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="blocked_sites")
    name = models.CharField(max_length=100)
    url = models.CharField(max_length=255)
    category = models.CharField(
        max_length=50,
        choices=[
            ("social_media", "Social Media"),
            ("entertainment", "Entertainment"),
            ("gaming", "Gaming"),
            ("news", "News"),
            ("shopping", "Shopping"),
            ("other", "Other"),
        ],
        default="social_media",
    )
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["category", "name"]

    def __str__(self):
        return f"{self.name} ({self.url})"


class StudyLog(models.Model):
    """Daily study log for tracking progress."""

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="study_logs")
    date = models.DateField(default=timezone.now)
    subject = models.CharField(max_length=100)
    duration_minutes = models.IntegerField(default=0)
    sessions_count = models.IntegerField(default=0)
    distractions_count = models.IntegerField(default=0)
    focus_score = models.IntegerField(default=100)
    notes = models.TextField(blank=True, default="")

    class Meta:
        ordering = ["-date"]
        unique_together = ["user", "date", "subject"]

    def __str__(self):
        return f"{self.user.username} - {self.subject} ({self.date})"


class Badge(models.Model):
    """Achievement badges for gamification."""

    BADGE_TYPES = [
        ("streak_3", "3 Day Streak"),
        ("streak_7", "Week Warrior"),
        ("streak_30", "Monthly Champion"),
        ("hours_5", "5 Hours Club"),
        ("hours_20", "20 Hours Club"),
        ("hours_50", "50 Hours Club"),
        ("hours_100", "Century Scholar"),
        ("no_distraction", "Zero Distraction Session"),
        ("early_bird", "Early Bird (Before 6 AM)"),
        ("night_owl", "Night Owl (After 10 PM)"),
        ("first_session", "First Session"),
        ("focus_master", "Focus Score 100"),
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="badges")
    badge_type = models.CharField(max_length=50, choices=BADGE_TYPES)
    earned_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        unique_together = ["user", "badge_type"]
        ordering = ["-earned_at"]

    def __str__(self):
        return f"{self.user.username} - {self.get_badge_type_display()}"

    @property
    def icon(self):
        icons = {
            "streak_3": "fire",
            "streak_7": "trophy",
            "streak_30": "crown",
            "hours_5": "clock",
            "hours_20": "star",
            "hours_50": "gem",
            "hours_100": "award",
            "no_distraction": "shield-check",
            "early_bird": "sunrise",
            "night_owl": "moon",
            "first_session": "play-circle",
            "focus_master": "target",
        }
        return icons.get(self.badge_type, "award")


class ChatMessage(models.Model):
    """Stores AI chat history."""

    ROLE_CHOICES = [
        ("user", "User"),
        ("assistant", "AI Assistant"),
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="chat_messages")
    role = models.CharField(max_length=10, choices=ROLE_CHOICES)
    content = models.TextField()
    timestamp = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["timestamp"]

    def __str__(self):
        return f"{self.user.username} [{self.role}]: {self.content[:50]}"

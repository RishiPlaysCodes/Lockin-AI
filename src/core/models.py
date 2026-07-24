"""
Core models for Focus Guardian AI.
Provides data models for user profiles, focus sessions, and distraction tracking.
"""

import uuid
from datetime import timedelta

from django.conf import settings
from django.core.validators import MaxValueValidator, MinValueValidator
from django.db import models


class TimeStampedModel(models.Model):
    """Abstract base model with created/updated timestamps."""

    created_at = models.DateTimeField(auto_now_add=True, db_index=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        abstract = True
        ordering = ["-created_at"]


class UserProfile(TimeStampedModel):
    """
    Extended user profile for focus tracking.
    Stores aggregate metrics like focus score and total study time.
    """

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="profile",
    )
    focus_score = models.IntegerField(
        default=100,
        validators=[
            MinValueValidator(0),
            MaxValueValidator(100),
        ],
        help_text="Current focus score (0-100). Decreases with distractions.",
    )
    total_study_time = models.DurationField(
        default=timedelta(0),
        help_text="Cumulative study time across all sessions.",
    )
    daily_goal_minutes = models.PositiveIntegerField(
        default=120,
        help_text="Daily study goal in minutes.",
    )
    streak_days = models.PositiveIntegerField(
        default=0,
        help_text="Consecutive days with at least one completed session.",
    )
    last_active_date = models.DateField(null=True, blank=True)

    class Meta:
        ordering = ["-created_at"]
        verbose_name = "User Profile"
        verbose_name_plural = "User Profiles"

    def __str__(self):
        return f"{self.user.username} (Score: {self.focus_score})"

    def decrease_focus_score(self, penalty: int = None):
        """Decrease focus score by penalty amount, clamping to minimum."""
        if penalty is None:
            penalty = settings.FOCUS_SCORE_DISTRACTION_PENALTY
        self.focus_score = max(settings.FOCUS_SCORE_MIN, self.focus_score - penalty)
        self.save(update_fields=["focus_score", "updated_at"])

    def add_study_time(self, duration: timedelta):
        """Add completed session duration to total study time."""
        self.total_study_time += duration
        self.save(update_fields=["total_study_time", "updated_at"])


class FocusSession(TimeStampedModel):
    """
    Represents a single focus/study session.
    Tracks start/end time, active state, and associated distractions.
    """

    class SessionType(models.TextChoices):
        POMODORO = "pomodoro", "Pomodoro (25 min)"
        SHORT = "short", "Short (15 min)"
        LONG = "long", "Long (50 min)"
        CUSTOM = "custom", "Custom"

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="focus_sessions",
        db_index=True,
    )
    start_time = models.DateTimeField(auto_now_add=True)
    end_time = models.DateTimeField(null=True, blank=True, db_index=True)
    is_active = models.BooleanField(default=True, db_index=True)
    session_type = models.CharField(
        max_length=20,
        choices=SessionType.choices,
        default=SessionType.POMODORO,
    )
    planned_duration_minutes = models.PositiveIntegerField(
        default=25,
        help_text="Planned duration in minutes.",
    )
    notes = models.TextField(blank=True, default="")

    class Meta:
        ordering = ["-start_time"]
        verbose_name = "Focus Session"
        verbose_name_plural = "Focus Sessions"
        indexes = [
            models.Index(fields=["user", "is_active"]),
            models.Index(fields=["user", "-start_time"]),
        ]
        constraints = [
            models.CheckConstraint(
                check=models.Q(end_time__isnull=True) | models.Q(end_time__gte=models.F("start_time")),
                name="end_time_after_start_time",
            ),
        ]

    def __str__(self):
        status = "Active" if self.is_active else "Completed"
        return f"{self.user.username} - {self.session_type} ({status}) - {self.start_time:%Y-%m-%d %H:%M}"

    @property
    def duration(self) -> timedelta | None:
        """Calculate session duration. Returns None if session is still active."""
        if self.end_time:
            return self.end_time - self.start_time
        return None

    @property
    def distraction_count(self) -> int:
        """Get the number of distractions in this session."""
        return self.distractions.count()


class Distraction(TimeStampedModel):
    """
    Records a distraction event during a focus session.
    Tracks what app/activity caused the distraction and its type.
    """

    class DistractionType(models.TextChoices):
        APP_SWITCH = "app_switch", "App Switch"
        VISIBILITY_CHANGE = "visibility_change", "Tab/Window Switch"
        NOTIFICATION = "notification", "Notification"
        MANUAL = "manual", "Self-reported"
        MOCK = "mock", "Simulated (Testing)"

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    session = models.ForeignKey(
        FocusSession,
        on_delete=models.CASCADE,
        related_name="distractions",
        db_index=True,
    )
    app_name = models.CharField(
        max_length=255,
        db_index=True,
        help_text="Name of the application or activity that caused the distraction.",
    )
    timestamp = models.DateTimeField(auto_now_add=True)
    distraction_type = models.CharField(
        max_length=50,
        choices=DistractionType.choices,
        default=DistractionType.APP_SWITCH,
    )
    duration_seconds = models.PositiveIntegerField(
        default=0,
        help_text="How long the user was distracted (in seconds).",
    )

    class Meta:
        ordering = ["-timestamp"]
        verbose_name = "Distraction"
        verbose_name_plural = "Distractions"
        indexes = [
            models.Index(fields=["session", "-timestamp"]),
        ]

    def __str__(self):
        return f"{self.session.user.username} - {self.app_name} ({self.distraction_type}) at {self.timestamp:%H:%M:%S}"

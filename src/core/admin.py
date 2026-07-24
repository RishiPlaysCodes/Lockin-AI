"""
Admin configuration for Focus Guardian models.
"""

from django.contrib import admin
from django.utils.html import format_html

from .models import Distraction, FocusSession, UserProfile


@admin.register(UserProfile)
class UserProfileAdmin(admin.ModelAdmin):
    """Admin interface for UserProfile model."""

    list_display = [
        "user",
        "focus_score_display",
        "total_study_time",
        "streak_days",
        "daily_goal_minutes",
        "last_active_date",
        "created_at",
    ]
    list_filter = ["last_active_date", "created_at"]
    search_fields = ["user__username", "user__email"]
    readonly_fields = ["id", "created_at", "updated_at"]
    ordering = ["-created_at"]

    def focus_score_display(self, obj):
        """Display focus score with color coding."""
        color = "green" if obj.focus_score >= 70 else ("orange" if obj.focus_score >= 40 else "red")
        return format_html(
            '<span style="color: {}; font-weight: bold;">{}/100</span>',
            color,
            obj.focus_score,
        )

    focus_score_display.short_description = "Focus Score"


class DistractionInline(admin.TabularInline):
    """Inline display of distractions within a session."""

    model = Distraction
    extra = 0
    readonly_fields = ["id", "timestamp", "created_at"]
    fields = ["app_name", "distraction_type", "duration_seconds", "timestamp"]


@admin.register(FocusSession)
class FocusSessionAdmin(admin.ModelAdmin):
    """Admin interface for FocusSession model."""

    list_display = [
        "user",
        "session_type",
        "is_active",
        "start_time",
        "end_time",
        "duration_display",
        "distraction_count",
    ]
    list_filter = ["is_active", "session_type", "start_time"]
    search_fields = ["user__username"]
    readonly_fields = ["id", "start_time", "created_at", "updated_at"]
    ordering = ["-start_time"]
    inlines = [DistractionInline]
    date_hierarchy = "start_time"

    def duration_display(self, obj):
        """Display session duration."""
        if obj.duration:
            total_seconds = int(obj.duration.total_seconds())
            minutes, seconds = divmod(total_seconds, 60)
            return f"{minutes}m {seconds}s"
        return "In Progress"

    duration_display.short_description = "Duration"

    def distraction_count(self, obj):
        """Display distraction count."""
        count = obj.distractions.count()
        return count

    distraction_count.short_description = "Distractions"


@admin.register(Distraction)
class DistractionAdmin(admin.ModelAdmin):
    """Admin interface for Distraction model."""

    list_display = [
        "session_user",
        "app_name",
        "distraction_type",
        "duration_seconds",
        "timestamp",
    ]
    list_filter = ["distraction_type", "timestamp"]
    search_fields = ["app_name", "session__user__username"]
    readonly_fields = ["id", "timestamp", "created_at", "updated_at"]
    ordering = ["-timestamp"]

    def session_user(self, obj):
        """Display the user from the associated session."""
        return obj.session.user.username

    session_user.short_description = "User"

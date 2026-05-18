from django.contrib import admin
from .models import (
    UserProfile,
    FocusSession,
    Distraction,
    BlockedSite,
    StudyLog,
    Badge,
    ChatMessage,
)


@admin.register(UserProfile)
class UserProfileAdmin(admin.ModelAdmin):
    list_display = ["user", "focus_score", "total_study_hours", "streak_days", "level"]
    search_fields = ["user__username"]


@admin.register(FocusSession)
class FocusSessionAdmin(admin.ModelAdmin):
    list_display = ["user", "subject", "start_time", "end_time", "is_active", "distraction_count"]
    list_filter = ["is_active", "subject"]
    search_fields = ["user__username", "subject"]


@admin.register(Distraction)
class DistractionAdmin(admin.ModelAdmin):
    list_display = ["session", "app_name", "distraction_type", "timestamp"]
    list_filter = ["distraction_type"]


@admin.register(BlockedSite)
class BlockedSiteAdmin(admin.ModelAdmin):
    list_display = ["user", "name", "url", "category", "is_active"]
    list_filter = ["category", "is_active"]


@admin.register(StudyLog)
class StudyLogAdmin(admin.ModelAdmin):
    list_display = ["user", "date", "subject", "duration_minutes", "focus_score"]
    list_filter = ["date", "subject"]


@admin.register(Badge)
class BadgeAdmin(admin.ModelAdmin):
    list_display = ["user", "badge_type", "earned_at"]
    list_filter = ["badge_type"]


@admin.register(ChatMessage)
class ChatMessageAdmin(admin.ModelAdmin):
    list_display = ["user", "role", "timestamp", "content_preview"]
    list_filter = ["role"]

    def content_preview(self, obj):
        return obj.content[:80]

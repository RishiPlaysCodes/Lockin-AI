from django.contrib import admin
from .models import (
    UserProfile,
    FocusSession,
    Distraction,
    BlockedSite,
    StudyLog,
    Badge,
    ChatMessage,
    DailyQuote,
)


@admin.register(UserProfile)
class UserProfileAdmin(admin.ModelAdmin):
    list_display = ["user", "focus_score", "total_study_hours", "streak_days", "longest_streak", "level"]
    search_fields = ["user__username", "user__email"]
    list_filter = ["theme"]
    readonly_fields = ["created_at", "updated_at"]


@admin.register(FocusSession)
class FocusSessionAdmin(admin.ModelAdmin):
    list_display = ["user", "subject", "session_type", "start_time", "duration_formatted", "is_active", "is_completed", "focus_score"]
    list_filter = ["is_active", "is_completed", "session_type", "subject"]
    search_fields = ["user__username", "subject"]
    date_hierarchy = "start_time"


@admin.register(Distraction)
class DistractionAdmin(admin.ModelAdmin):
    list_display = ["session", "app_name", "distraction_type", "severity", "timestamp"]
    list_filter = ["distraction_type", "severity"]
    search_fields = ["app_name", "session__user__username"]


@admin.register(BlockedSite)
class BlockedSiteAdmin(admin.ModelAdmin):
    list_display = ["user", "name", "url", "category", "is_active", "times_blocked"]
    list_filter = ["category", "is_active"]
    search_fields = ["name", "url", "user__username"]


@admin.register(StudyLog)
class StudyLogAdmin(admin.ModelAdmin):
    list_display = ["user", "date", "subject", "duration_minutes", "sessions_count", "focus_score"]
    list_filter = ["date", "subject"]
    search_fields = ["user__username", "subject"]
    date_hierarchy = "date"


@admin.register(Badge)
class BadgeAdmin(admin.ModelAdmin):
    list_display = ["user", "badge_type", "rarity", "earned_at", "is_new"]
    list_filter = ["badge_type", "is_new"]
    search_fields = ["user__username"]


@admin.register(ChatMessage)
class ChatMessageAdmin(admin.ModelAdmin):
    list_display = ["user", "role", "mode", "timestamp", "content_preview"]
    list_filter = ["role", "mode"]
    search_fields = ["user__username", "content"]

    def content_preview(self, obj):
        return obj.content[:80]


@admin.register(DailyQuote)
class DailyQuoteAdmin(admin.ModelAdmin):
    list_display = ["quote_preview", "author", "category"]
    list_filter = ["category"]
    search_fields = ["quote", "author"]

    def quote_preview(self, obj):
        return obj.quote[:60]

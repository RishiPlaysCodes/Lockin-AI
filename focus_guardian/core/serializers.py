from rest_framework import serializers
from django.contrib.auth.models import User
from .models import (
    UserProfile,
    FocusSession,
    Distraction,
    BlockedSite,
    StudyLog,
    Badge,
    ChatMessage,
)


class UserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = ["id", "username", "email", "password"]

    def create(self, validated_data):
        user = User.objects.create_user(
            username=validated_data["username"],
            email=validated_data.get("email", ""),
            password=validated_data["password"],
        )
        return user


class UserProfileSerializer(serializers.ModelSerializer):
    username = serializers.CharField(source="user.username", read_only=True)
    email = serializers.EmailField(source="user.email", read_only=True)
    level = serializers.CharField(read_only=True)
    level_progress = serializers.FloatField(read_only=True)
    total_study_hours = serializers.FloatField(read_only=True)
    xp_points = serializers.IntegerField(read_only=True)
    daily_goal_progress = serializers.FloatField(read_only=True)
    focus_grade = serializers.CharField(read_only=True)
    average_session_length = serializers.FloatField(read_only=True)

    class Meta:
        model = UserProfile
        fields = [
            "username", "email", "focus_score", "total_study_time",
            "total_study_hours", "streak_days", "longest_streak",
            "total_sessions_completed", "total_distractions",
            "level", "level_progress", "xp_points",
            "daily_goal_minutes", "daily_goal_progress",
            "focus_grade", "average_session_length",
            "bio", "avatar_color", "theme",
        ]


class DistractionSerializer(serializers.ModelSerializer):
    score_penalty = serializers.IntegerField(read_only=True)

    class Meta:
        model = Distraction
        fields = ["id", "session", "app_name", "distraction_type", "severity", "score_penalty", "timestamp"]


class FocusSessionSerializer(serializers.ModelSerializer):
    distractions = DistractionSerializer(many=True, read_only=True)
    duration_minutes = serializers.FloatField(read_only=True)
    duration_formatted = serializers.CharField(read_only=True)
    distraction_count = serializers.IntegerField(read_only=True)
    completion_percentage = serializers.FloatField(read_only=True)

    class Meta:
        model = FocusSession
        fields = [
            "id", "user", "subject", "session_type",
            "start_time", "end_time", "planned_duration",
            "is_active", "is_completed", "notes",
            "mood_before", "mood_after", "focus_score",
            "duration_minutes", "duration_formatted",
            "distraction_count", "completion_percentage",
            "distractions",
        ]
        read_only_fields = ["user", "start_time"]


class BlockedSiteSerializer(serializers.ModelSerializer):
    category_color = serializers.CharField(read_only=True)

    class Meta:
        model = BlockedSite
        fields = ["id", "name", "url", "category", "category_color", "is_active", "times_blocked", "created_at"]


class StudyLogSerializer(serializers.ModelSerializer):
    hours_studied = serializers.FloatField(read_only=True)

    class Meta:
        model = StudyLog
        fields = [
            "id", "date", "subject", "duration_minutes",
            "hours_studied", "sessions_count", "distractions_count",
            "focus_score", "notes", "mood",
        ]


class BadgeSerializer(serializers.ModelSerializer):
    display_name = serializers.CharField(source="get_badge_type_display", read_only=True)
    icon = serializers.CharField(read_only=True)
    color = serializers.CharField(read_only=True)
    rarity = serializers.CharField(read_only=True)
    description = serializers.CharField(read_only=True)

    class Meta:
        model = Badge
        fields = ["id", "badge_type", "display_name", "icon", "color", "rarity", "description", "earned_at", "is_new"]


class ChatMessageSerializer(serializers.ModelSerializer):
    class Meta:
        model = ChatMessage
        fields = ["id", "role", "content", "mode", "timestamp", "is_pinned"]

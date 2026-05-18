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
    level = serializers.CharField(read_only=True)
    total_study_hours = serializers.FloatField(read_only=True)

    class Meta:
        model = UserProfile
        fields = [
            "username",
            "focus_score",
            "total_study_time",
            "total_study_hours",
            "streak_days",
            "level",
        ]


class DistractionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Distraction
        fields = ["id", "session", "app_name", "distraction_type", "timestamp"]


class FocusSessionSerializer(serializers.ModelSerializer):
    distractions = DistractionSerializer(many=True, read_only=True)
    duration_minutes = serializers.FloatField(read_only=True)
    distraction_count = serializers.IntegerField(read_only=True)

    class Meta:
        model = FocusSession
        fields = [
            "id",
            "user",
            "subject",
            "start_time",
            "end_time",
            "planned_duration",
            "is_active",
            "notes",
            "duration_minutes",
            "distraction_count",
            "distractions",
        ]
        read_only_fields = ["user", "start_time"]


class BlockedSiteSerializer(serializers.ModelSerializer):
    class Meta:
        model = BlockedSite
        fields = ["id", "name", "url", "category", "is_active", "created_at"]


class StudyLogSerializer(serializers.ModelSerializer):
    class Meta:
        model = StudyLog
        fields = [
            "id",
            "date",
            "subject",
            "duration_minutes",
            "sessions_count",
            "distractions_count",
            "focus_score",
            "notes",
        ]


class BadgeSerializer(serializers.ModelSerializer):
    display_name = serializers.CharField(source="get_badge_type_display", read_only=True)
    icon = serializers.CharField(read_only=True)

    class Meta:
        model = Badge
        fields = ["id", "badge_type", "display_name", "icon", "earned_at"]


class ChatMessageSerializer(serializers.ModelSerializer):
    class Meta:
        model = ChatMessage
        fields = ["id", "role", "content", "timestamp"]

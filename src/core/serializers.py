"""
Serializers for the Focus Guardian API.
Handles validation, data transformation, and user creation logic.
"""

from django.contrib.auth import password_validation
from django.contrib.auth.models import User
from rest_framework import serializers

from .models import Distraction, FocusSession, UserProfile


class UserRegistrationSerializer(serializers.ModelSerializer):
    """Serializer for user registration with password validation."""

    password = serializers.CharField(
        write_only=True,
        min_length=10,
        style={"input_type": "password"},
        help_text="Must be at least 10 characters.",
    )
    password_confirm = serializers.CharField(
        write_only=True,
        style={"input_type": "password"},
    )
    email = serializers.EmailField(required=True)

    class Meta:
        model = User
        fields = ["id", "username", "email", "password", "password_confirm"]

    def validate_email(self, value):
        """Ensure email is unique."""
        if User.objects.filter(email__iexact=value).exists():
            raise serializers.ValidationError("A user with this email already exists.")
        return value.lower()

    def validate_username(self, value):
        """Ensure username meets requirements."""
        if len(value) < 3:
            raise serializers.ValidationError("Username must be at least 3 characters.")
        return value

    def validate(self, attrs):
        """Validate passwords match and meet requirements."""
        if attrs["password"] != attrs["password_confirm"]:
            raise serializers.ValidationError(
                {"password_confirm": "Passwords do not match."}
            )
        # Use Django's built-in password validators
        password_validation.validate_password(attrs["password"])
        return attrs

    def create(self, validated_data):
        """Create user and profile."""
        validated_data.pop("password_confirm")
        user = User.objects.create_user(
            username=validated_data["username"],
            email=validated_data["email"],
            password=validated_data["password"],
        )
        return user


class UserProfileSerializer(serializers.ModelSerializer):
    """Serializer for user profile data."""

    username = serializers.CharField(source="user.username", read_only=True)
    email = serializers.EmailField(source="user.email", read_only=True)
    total_study_time_formatted = serializers.SerializerMethodField()

    class Meta:
        model = UserProfile
        fields = [
            "id",
            "username",
            "email",
            "focus_score",
            "total_study_time",
            "total_study_time_formatted",
            "daily_goal_minutes",
            "streak_days",
            "last_active_date",
            "created_at",
            "updated_at",
        ]
        read_only_fields = [
            "id",
            "focus_score",
            "total_study_time",
            "streak_days",
            "created_at",
            "updated_at",
        ]

    def get_total_study_time_formatted(self, obj) -> str:
        """Format total study time as human-readable string."""
        total_seconds = int(obj.total_study_time.total_seconds())
        hours, remainder = divmod(total_seconds, 3600)
        minutes, _ = divmod(remainder, 60)
        return f"{hours}h {minutes}m"


class DistractionSerializer(serializers.ModelSerializer):
    """Serializer for distraction events."""

    class Meta:
        model = Distraction
        fields = [
            "id",
            "session",
            "app_name",
            "timestamp",
            "distraction_type",
            "duration_seconds",
            "created_at",
        ]
        read_only_fields = ["id", "timestamp", "created_at"]


class DistractionCreateSerializer(serializers.ModelSerializer):
    """Serializer for creating distraction events (session inferred from context)."""

    class Meta:
        model = Distraction
        fields = ["app_name", "distraction_type", "duration_seconds"]

    def validate_app_name(self, value):
        """Sanitize app name input."""
        return value.strip()[:255]


class FocusSessionSerializer(serializers.ModelSerializer):
    """Serializer for focus session data with nested distractions."""

    distractions = DistractionSerializer(many=True, read_only=True)
    duration_formatted = serializers.SerializerMethodField()
    distraction_count = serializers.IntegerField(read_only=True, source="distraction_count_annotation", default=0)

    class Meta:
        model = FocusSession
        fields = [
            "id",
            "user",
            "start_time",
            "end_time",
            "is_active",
            "session_type",
            "planned_duration_minutes",
            "notes",
            "distractions",
            "distraction_count",
            "duration_formatted",
            "created_at",
        ]
        read_only_fields = ["id", "user", "start_time", "is_active", "created_at"]

    def get_duration_formatted(self, obj) -> str:
        """Format session duration as human-readable string."""
        if obj.end_time:
            duration = obj.end_time - obj.start_time
            total_seconds = int(duration.total_seconds())
            minutes, seconds = divmod(total_seconds, 60)
            return f"{minutes}m {seconds}s"
        return "In Progress"


class FocusSessionCreateSerializer(serializers.ModelSerializer):
    """Serializer for starting a new focus session."""

    class Meta:
        model = FocusSession
        fields = ["session_type", "planned_duration_minutes", "notes"]

    def validate_planned_duration_minutes(self, value):
        """Ensure planned duration is reasonable."""
        if value < 5 or value > 240:
            raise serializers.ValidationError(
                "Planned duration must be between 5 and 240 minutes."
            )
        return value


class StudyReportSerializer(serializers.Serializer):
    """Serializer for study report entries."""

    id = serializers.UUIDField()
    start_time = serializers.DateTimeField()
    end_time = serializers.DateTimeField(allow_null=True)
    duration = serializers.CharField()
    session_type = serializers.CharField()
    distractions_count = serializers.IntegerField()
    planned_duration_minutes = serializers.IntegerField()


class AITeacherRequestSerializer(serializers.Serializer):
    """Serializer for AI teacher chat requests."""

    message = serializers.CharField(
        max_length=2000,
        min_length=1,
        help_text="The message to send to the AI teacher.",
    )

    def validate_message(self, value):
        """Sanitize message input."""
        return value.strip()


class AITeacherResponseSerializer(serializers.Serializer):
    """Serializer for AI teacher chat responses."""

    reply = serializers.CharField()
    model_used = serializers.CharField(required=False)

"""
API v1 Views for Focus Guardian.
Enterprise-grade views with proper validation, error handling, and documentation.
"""

import logging

from django.db.models import Count, Sum
from django.utils import timezone
from drf_spectacular.utils import extend_schema, extend_schema_view
from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.throttling import ScopedRateThrottle
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken

from ...models import FocusSession, UserProfile
from ...serializers import (
    AITeacherRequestSerializer,
    AITeacherResponseSerializer,
    DistractionCreateSerializer,
    DistractionSerializer,
    FocusSessionCreateSerializer,
    FocusSessionSerializer,
    StudyReportSerializer,
    UserProfileSerializer,
    UserRegistrationSerializer,
)
from ...services.ai_service import AITeacherService
from ...services.session_service import SessionService

logger = logging.getLogger(__name__)


@extend_schema(
    tags=["Authentication"],
    summary="Register a new user",
    description="Create a new user account. Returns JWT tokens on success.",
)
class UserRegistrationView(generics.CreateAPIView):
    """Register a new user and return JWT tokens."""

    permission_classes = [permissions.AllowAny]
    serializer_class = UserRegistrationSerializer

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()

        # Generate tokens
        refresh = RefreshToken.for_user(user)

        return Response(
            {
                "user": {
                    "id": user.id,
                    "username": user.username,
                    "email": user.email,
                },
                "tokens": {
                    "access": str(refresh.access_token),
                    "refresh": str(refresh),
                },
            },
            status=status.HTTP_201_CREATED,
        )


@extend_schema(
    tags=["Authentication"],
    summary="Logout (blacklist refresh token)",
)
class LogoutView(APIView):
    """Logout by blacklisting the refresh token."""

    def post(self, request):
        try:
            refresh_token = request.data.get("refresh")
            if not refresh_token:
                return Response(
                    {"error": {"code": "missing_token", "message": "Refresh token is required."}},
                    status=status.HTTP_400_BAD_REQUEST,
                )
            token = RefreshToken(refresh_token)
            token.blacklist()
            return Response({"message": "Successfully logged out."}, status=status.HTTP_200_OK)
        except Exception:
            return Response(
                {"error": {"code": "invalid_token", "message": "Invalid refresh token."}},
                status=status.HTTP_400_BAD_REQUEST,
            )


@extend_schema(
    tags=["Profile"],
    summary="Get or update user profile",
)
@extend_schema_view(
    get=extend_schema(description="Retrieve the authenticated user's profile."),
    patch=extend_schema(description="Partially update the user's profile settings."),
)
class UserProfileView(generics.RetrieveUpdateAPIView):
    """View and update user profile."""

    serializer_class = UserProfileSerializer
    http_method_names = ["get", "patch"]

    def get_object(self):
        profile, _ = UserProfile.objects.get_or_create(user=self.request.user)
        return profile


@extend_schema(
    tags=["Sessions"],
    summary="List user's focus sessions",
    description="Returns paginated list of all focus sessions for the authenticated user.",
)
class FocusSessionListView(generics.ListAPIView):
    """List all focus sessions for the authenticated user."""

    serializer_class = FocusSessionSerializer
    filterset_fields = ["is_active", "session_type"]
    ordering_fields = ["start_time", "end_time"]
    ordering = ["-start_time"]

    def get_queryset(self):
        return (
            FocusSession.objects.filter(user=self.request.user)
            .prefetch_related("distractions")
            .annotate(distraction_count_annotation=Count("distractions"))
        )


@extend_schema(
    tags=["Sessions"],
    summary="Get focus session details",
)
class FocusSessionDetailView(generics.RetrieveAPIView):
    """Retrieve a specific focus session."""

    serializer_class = FocusSessionSerializer

    def get_queryset(self):
        return (
            FocusSession.objects.filter(user=self.request.user)
            .prefetch_related("distractions")
            .annotate(distraction_count_annotation=Count("distractions"))
        )


@extend_schema(
    tags=["Sessions"],
    summary="Start a new focus session",
    request=FocusSessionCreateSerializer,
    responses={201: FocusSessionSerializer},
)
class StartFocusSessionView(APIView):
    """Start a new focus session. Ends any existing active sessions."""

    def post(self, request):
        serializer = FocusSessionCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        session = SessionService.start_session(
            user=request.user,
            session_type=serializer.validated_data.get("session_type", "pomodoro"),
            planned_duration_minutes=serializer.validated_data.get("planned_duration_minutes", 25),
            notes=serializer.validated_data.get("notes", ""),
        )

        return Response(
            FocusSessionSerializer(session).data,
            status=status.HTTP_201_CREATED,
        )


@extend_schema(
    tags=["Sessions"],
    summary="End active focus session",
    responses={200: FocusSessionSerializer},
)
class EndFocusSessionView(APIView):
    """End the user's currently active focus session."""

    def post(self, request):
        session = SessionService.end_session(user=request.user)
        if session is None:
            return Response(
                {"error": {"code": "no_active_session", "message": "No active focus session found."}},
                status=status.HTTP_404_NOT_FOUND,
            )
        return Response(FocusSessionSerializer(session).data)


@extend_schema(
    tags=["Distractions"],
    summary="Log a distraction event",
    request=DistractionCreateSerializer,
    responses={201: DistractionSerializer},
)
class LogDistractionView(APIView):
    """Log a distraction during an active focus session."""

    def post(self, request):
        serializer = DistractionCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        distraction = SessionService.log_distraction(
            user=request.user,
            app_name=serializer.validated_data["app_name"],
            distraction_type=serializer.validated_data.get("distraction_type", "app_switch"),
            duration_seconds=serializer.validated_data.get("duration_seconds", 0),
        )

        if distraction is None:
            return Response(
                {"error": {"code": "no_active_session", "message": "No active focus session found."}},
                status=status.HTTP_404_NOT_FOUND,
            )

        return Response(
            DistractionSerializer(distraction).data,
            status=status.HTTP_201_CREATED,
        )


@extend_schema(
    tags=["Reports"],
    summary="Get study session report",
    description="Returns the most recent study sessions with aggregated data.",
)
class StudyReportView(APIView):
    """Generate a study report for the authenticated user."""

    def get(self, request):
        sessions = (
            FocusSession.objects.filter(user=request.user)
            .annotate(distractions_count=Count("distractions"))
            .order_by("-start_time")[:20]
        )

        report = []
        for session in sessions:
            duration = "In Progress"
            if session.end_time:
                d = session.end_time - session.start_time
                total_secs = int(d.total_seconds())
                minutes, seconds = divmod(total_secs, 60)
                duration = f"{minutes}m {seconds}s"

            report.append(
                {
                    "id": session.id,
                    "start_time": session.start_time,
                    "end_time": session.end_time,
                    "duration": duration,
                    "session_type": session.session_type,
                    "distractions_count": session.distractions_count,
                    "planned_duration_minutes": session.planned_duration_minutes,
                }
            )

        serializer = StudyReportSerializer(report, many=True)
        return Response(serializer.data)


@extend_schema(
    tags=["Reports"],
    summary="Get user statistics",
    description="Returns aggregated statistics for the authenticated user.",
)
class UserStatsView(APIView):
    """Get aggregated study statistics."""

    def get(self, request):
        profile, _ = UserProfile.objects.get_or_create(user=request.user)
        sessions = FocusSession.objects.filter(user=request.user)

        total_sessions = sessions.count()
        completed_sessions = sessions.filter(is_active=False).count()
        total_distractions = sessions.aggregate(
            total=Count("distractions")
        )["total"] or 0

        today = timezone.now().date()
        today_sessions = sessions.filter(start_time__date=today)
        today_duration = sum(
            (s.end_time - s.start_time).total_seconds()
            for s in today_sessions.filter(end_time__isnull=False)
        )

        return Response(
            {
                "focus_score": profile.focus_score,
                "total_study_time": str(profile.total_study_time),
                "total_sessions": total_sessions,
                "completed_sessions": completed_sessions,
                "total_distractions": total_distractions,
                "streak_days": profile.streak_days,
                "daily_goal_minutes": profile.daily_goal_minutes,
                "today_study_minutes": round(today_duration / 60, 1),
                "avg_distractions_per_session": (
                    round(total_distractions / completed_sessions, 1)
                    if completed_sessions > 0
                    else 0
                ),
            }
        )


@extend_schema(
    tags=["AI Teacher"],
    summary="Chat with AI Teacher",
    request=AITeacherRequestSerializer,
    responses={200: AITeacherResponseSerializer},
)
class AITeacherView(APIView):
    """Chat with the AI study teacher. Rate-limited to prevent abuse."""

    throttle_classes = [ScopedRateThrottle]
    throttle_scope = "ai_teacher"

    def post(self, request):
        serializer = AITeacherRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        user_message = serializer.validated_data["message"]

        service = AITeacherService()
        result = service.get_response(user_message)

        if not result.success:
            return Response(
                {"error": {"code": "ai_error", "message": result.error}},
                status=status.HTTP_503_SERVICE_UNAVAILABLE,
            )

        return Response(
            AITeacherResponseSerializer(
                {"reply": result.reply, "model_used": result.model_used}
            ).data
        )

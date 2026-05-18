"""
Views for Focus Guardian AI.
Combines template views and API views for the complete application.
"""

from django.shortcuts import render, redirect
from django.contrib.auth import login, logout, authenticate
from django.contrib.auth.decorators import login_required
from django.contrib import messages
from django.utils import timezone
from django.db.models import Sum, Count, Avg
from datetime import timedelta

from rest_framework import status, permissions
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.decorators import api_view, permission_classes

from .models import (
    UserProfile,
    FocusSession,
    Distraction,
    BlockedSite,
    StudyLog,
    Badge,
    ChatMessage,
)
from .serializers import (
    UserProfileSerializer,
    FocusSessionSerializer,
    DistractionSerializer,
    BlockedSiteSerializer,
    StudyLogSerializer,
    BadgeSerializer,
)
from .forms import SignupForm, BlockedSiteForm
from .services import (
    check_and_award_badges,
    update_streak,
    calculate_session_score,
    update_study_log,
    get_ai_response,
)


# ============================================================
# Template Views (Pages)
# ============================================================


def landing_view(request):
    """Landing page - redirect to dashboard if logged in."""
    if request.user.is_authenticated:
        return redirect("dashboard")
    return render(request, "core/landing.html")


def signup_view(request):
    """User registration page."""
    if request.user.is_authenticated:
        return redirect("dashboard")

    if request.method == "POST":
        form = SignupForm(request.POST)
        if form.is_valid():
            user = form.save()
            login(request, user)
            messages.success(request, f"Welcome to Focus Guardian, {user.username}!")
            return redirect("dashboard")
    else:
        form = SignupForm()

    return render(request, "registration/signup.html", {"form": form})


def login_view(request):
    """User login page."""
    if request.user.is_authenticated:
        return redirect("dashboard")

    if request.method == "POST":
        username = request.POST.get("username")
        password = request.POST.get("password")
        user = authenticate(request, username=username, password=password)
        if user:
            login(request, user)
            next_url = request.GET.get("next", "dashboard")
            return redirect(next_url)
        else:
            messages.error(request, "Invalid username or password.")

    return render(request, "registration/login.html")


def logout_view(request):
    """Logout user."""
    logout(request)
    return redirect("login")


@login_required
def dashboard_view(request):
    """Main dashboard with stats overview."""
    profile, _ = UserProfile.objects.get_or_create(user=request.user)
    recent_sessions = FocusSession.objects.filter(user=request.user)[:5]
    badges = Badge.objects.filter(user=request.user)[:6]
    active_session = FocusSession.objects.filter(
        user=request.user, is_active=True
    ).first()

    # Weekly stats
    week_ago = timezone.now() - timedelta(days=7)
    weekly_sessions = FocusSession.objects.filter(
        user=request.user, start_time__gte=week_ago, is_active=False
    )
    weekly_minutes = sum(s.duration_minutes for s in weekly_sessions)
    weekly_distractions = Distraction.objects.filter(
        session__user=request.user, timestamp__gte=week_ago
    ).count()

    # Today's stats
    today = timezone.now().date()
    today_sessions = FocusSession.objects.filter(
        user=request.user, start_time__date=today, is_active=False
    )
    today_minutes = sum(s.duration_minutes for s in today_sessions)

    context = {
        "profile": profile,
        "recent_sessions": recent_sessions,
        "badges": badges,
        "active_session": active_session,
        "weekly_minutes": round(weekly_minutes, 1),
        "weekly_distractions": weekly_distractions,
        "today_minutes": round(today_minutes, 1),
        "today_sessions_count": today_sessions.count(),
    }
    return render(request, "core/dashboard.html", context)


@login_required
def timer_view(request):
    """Focus timer page."""
    active_session = FocusSession.objects.filter(
        user=request.user, is_active=True
    ).first()
    blocked_sites = BlockedSite.objects.filter(user=request.user, is_active=True)

    context = {
        "active_session": active_session,
        "blocked_sites": blocked_sites,
    }
    return render(request, "core/timer.html", context)


@login_required
def chat_view(request):
    """AI Teacher chat page."""
    chat_history = ChatMessage.objects.filter(user=request.user).order_by("-timestamp")[:50]
    # Reverse for display (oldest first)
    chat_history = list(reversed(chat_history))
    return render(request, "core/chat.html", {"chat_history": chat_history})


@login_required
def reports_view(request):
    """Study reports and analytics page."""
    # Get date range
    days = int(request.GET.get("days", 7))
    start_date = timezone.now() - timedelta(days=days)

    sessions = FocusSession.objects.filter(
        user=request.user, start_time__gte=start_date, is_active=False
    )
    study_logs = StudyLog.objects.filter(user=request.user, date__gte=start_date.date())

    # Aggregate stats
    total_minutes = sum(s.duration_minutes for s in sessions)
    total_distractions = sum(s.distraction_count for s in sessions)
    avg_score = study_logs.aggregate(avg=Avg("focus_score"))["avg"] or 0

    # Daily breakdown
    daily_data = []
    for i in range(days):
        date = (timezone.now() - timedelta(days=i)).date()
        day_sessions = sessions.filter(start_time__date=date)
        day_minutes = sum(s.duration_minutes for s in day_sessions)
        daily_data.append({
            "date": date,
            "minutes": round(day_minutes, 1),
            "sessions": day_sessions.count(),
        })

    # Subject breakdown
    subjects = (
        study_logs.values("subject")
        .annotate(total_min=Sum("duration_minutes"), count=Count("id"))
        .order_by("-total_min")
    )

    context = {
        "days": days,
        "total_minutes": round(total_minutes, 1),
        "total_hours": round(total_minutes / 60, 1),
        "total_sessions": sessions.count(),
        "total_distractions": total_distractions,
        "avg_score": round(avg_score, 1),
        "daily_data": daily_data,
        "subjects": subjects,
        "study_logs": study_logs[:20],
    }
    return render(request, "core/reports.html", context)


@login_required
def blocking_view(request):
    """App/site blocking management page."""
    blocked_sites = BlockedSite.objects.filter(user=request.user)

    if request.method == "POST":
        form = BlockedSiteForm(request.POST)
        if form.is_valid():
            site = form.save(commit=False)
            site.user = request.user
            site.save()
            messages.success(request, f"Added {site.name} to block list!")
            return redirect("blocking")
    else:
        form = BlockedSiteForm()

    context = {
        "blocked_sites": blocked_sites,
        "form": form,
    }
    return render(request, "core/blocking.html", context)


@login_required
def badges_view(request):
    """Badges and achievements page."""
    earned_badges = Badge.objects.filter(user=request.user)
    earned_types = set(earned_badges.values_list("badge_type", flat=True))

    # All possible badges
    all_badges = []
    for badge_type, badge_name in Badge.BADGE_TYPES:
        all_badges.append({
            "type": badge_type,
            "name": badge_name,
            "earned": badge_type in earned_types,
        })

    profile = UserProfile.objects.get(user=request.user)

    context = {
        "all_badges": all_badges,
        "earned_count": earned_badges.count(),
        "total_count": len(Badge.BADGE_TYPES),
        "profile": profile,
    }
    return render(request, "core/badges.html", context)


# ============================================================
# API Views (JSON endpoints for frontend JS)
# ============================================================


class UserProfileAPIView(APIView):
    """Get current user profile data."""

    def get(self, request):
        profile, _ = UserProfile.objects.get_or_create(user=request.user)
        serializer = UserProfileSerializer(profile)
        return Response(serializer.data)


class StartFocusSessionView(APIView):
    """Start a new focus session."""

    def post(self, request):
        # End any existing active sessions first
        active_sessions = FocusSession.objects.filter(user=request.user, is_active=True)
        for session in active_sessions:
            session.is_active = False
            session.end_time = timezone.now()
            session.save()

        # Create new session
        subject = request.data.get("subject", "General Study")
        planned_duration = request.data.get("planned_duration", 25)

        session = FocusSession.objects.create(
            user=request.user,
            subject=subject,
            planned_duration=planned_duration,
        )

        serializer = FocusSessionSerializer(session)
        return Response(serializer.data, status=status.HTTP_201_CREATED)


class EndFocusSessionView(APIView):
    """End the active focus session."""

    def post(self, request):
        try:
            session = FocusSession.objects.get(user=request.user, is_active=True)
            session.is_active = False
            session.end_time = timezone.now()
            session.save()

            # Update profile stats
            profile = UserProfile.objects.get(user=request.user)
            profile.total_study_time += session.duration
            profile.save()

            # Update study log
            update_study_log(session)

            # Update streak
            update_streak(request.user)

            # Check for new badges
            new_badges = check_and_award_badges(request.user)

            # Calculate session score
            score = calculate_session_score(session)

            serializer = FocusSessionSerializer(session)
            response_data = serializer.data
            response_data["session_score"] = score
            response_data["new_badges"] = [b.get_badge_type_display() for b in new_badges]

            return Response(response_data)

        except FocusSession.DoesNotExist:
            return Response(
                {"error": "No active session found"},
                status=status.HTTP_404_NOT_FOUND,
            )


class LogDistractionView(APIView):
    """Log a distraction event during active session."""

    def post(self, request):
        try:
            session = FocusSession.objects.get(user=request.user, is_active=True)
            app_name = request.data.get("app_name", "Unknown")
            distraction_type = request.data.get("distraction_type", "app_switch")

            distraction = Distraction.objects.create(
                session=session,
                app_name=app_name,
                distraction_type=distraction_type,
            )

            # Reduce focus score
            profile = UserProfile.objects.get(user=request.user)
            profile.focus_score = max(0, profile.focus_score - 5)
            profile.save()

            serializer = DistractionSerializer(distraction)
            return Response(serializer.data, status=status.HTTP_201_CREATED)

        except FocusSession.DoesNotExist:
            return Response(
                {"error": "No active session found"},
                status=status.HTTP_404_NOT_FOUND,
            )


class StudyReportAPIView(APIView):
    """Get study report data."""

    def get(self, request):
        days = int(request.query_params.get("days", 7))
        start_date = timezone.now() - timedelta(days=days)

        sessions = FocusSession.objects.filter(
            user=request.user, start_time__gte=start_date, is_active=False
        )

        report = []
        for session in sessions[:20]:
            report.append({
                "id": session.id,
                "subject": session.subject,
                "start_time": session.start_time,
                "end_time": session.end_time,
                "duration_minutes": session.duration_minutes,
                "distractions_count": session.distraction_count,
                "score": calculate_session_score(session),
            })

        return Response(report)


class AITeacherView(APIView):
    """AI Teacher chat endpoint."""

    def post(self, request):
        user_message = request.data.get("message", "").strip()
        if not user_message:
            return Response(
                {"error": "Message is required"},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # Save user message
        ChatMessage.objects.create(
            user=request.user, role="user", content=user_message
        )

        # Get chat history for context
        chat_history = ChatMessage.objects.filter(user=request.user).order_by(
            "-timestamp"
        )[:20]
        chat_history = list(reversed(chat_history))

        # Get AI response
        ai_response = get_ai_response(user_message, request.user, chat_history)

        # Save AI response
        ChatMessage.objects.create(
            user=request.user, role="assistant", content=ai_response
        )

        return Response({"reply": ai_response})


class BlockedSiteToggleView(APIView):
    """Toggle a blocked site's active status."""

    def post(self, request, pk):
        try:
            site = BlockedSite.objects.get(pk=pk, user=request.user)
            site.is_active = not site.is_active
            site.save()
            return Response({"is_active": site.is_active})
        except BlockedSite.DoesNotExist:
            return Response(
                {"error": "Site not found"}, status=status.HTTP_404_NOT_FOUND
            )


class BlockedSiteDeleteView(APIView):
    """Delete a blocked site."""

    def delete(self, request, pk):
        try:
            site = BlockedSite.objects.get(pk=pk, user=request.user)
            site.delete()
            return Response(status=status.HTTP_204_NO_CONTENT)
        except BlockedSite.DoesNotExist:
            return Response(
                {"error": "Site not found"}, status=status.HTTP_404_NOT_FOUND
            )


class ClearChatView(APIView):
    """Clear chat history."""

    def post(self, request):
        ChatMessage.objects.filter(user=request.user).delete()
        return Response({"message": "Chat history cleared"})

"""
Views for Focus Guardian AI.
Professional-grade views with proper error handling, validation, and security.
"""

import json
import logging
from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth import login, logout, authenticate, update_session_auth_hash
from django.contrib.auth.decorators import login_required
from django.contrib.auth.forms import PasswordChangeForm
from django.contrib import messages
from django.utils import timezone
from django.http import JsonResponse
from django.views.decorators.http import require_POST, require_GET
from django.views.decorators.csrf import csrf_protect
from django.db.models import Sum, Count, Avg, Q, F
from django.db import transaction
from datetime import timedelta

from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.throttling import UserRateThrottle

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
from .serializers import (
    UserProfileSerializer,
    FocusSessionSerializer,
    DistractionSerializer,
    BlockedSiteSerializer,
    StudyLogSerializer,
    BadgeSerializer,
)
from .forms import SignupForm, BlockedSiteForm, ProfileEditForm
from .services import (
    check_and_award_badges,
    update_streak,
    calculate_session_score,
    update_study_log,
    get_ai_response,
    get_motivational_quote,
    get_weekly_chart_data,
    get_subject_distribution,
)

logger = logging.getLogger(__name__)


# ============================================================
# Rate Throttling
# ============================================================

class ChatRateThrottle(UserRateThrottle):
    rate = '30/min'


class SessionRateThrottle(UserRateThrottle):
    rate = '10/min'


# ============================================================
# Template Views (Pages)
# ============================================================


def landing_view(request):
    """Landing page - redirect to dashboard if logged in."""
    if request.user.is_authenticated:
        return redirect("dashboard")
    return render(request, "core/landing.html")


@csrf_protect
def signup_view(request):
    """User registration page with validation."""
    if request.user.is_authenticated:
        return redirect("dashboard")

    if request.method == "POST":
        form = SignupForm(request.POST)
        if form.is_valid():
            try:
                with transaction.atomic():
                    user = form.save()
                    # Profile auto-created via signal
                    login(request, user)
                    messages.success(request, f"Welcome to Focus Guardian, {user.username}! Let's start your focus journey.")
                    return redirect("dashboard")
            except Exception as e:
                logger.error(f"Signup error: {e}")
                messages.error(request, "An error occurred during signup. Please try again.")
        else:
            for field, errors in form.errors.items():
                for error in errors:
                    messages.error(request, f"{error}")
    else:
        form = SignupForm()

    return render(request, "registration/signup.html", {"form": form})


@csrf_protect
def login_view(request):
    """User login page with rate limiting awareness."""
    if request.user.is_authenticated:
        return redirect("dashboard")

    if request.method == "POST":
        username = request.POST.get("username", "").strip()
        password = request.POST.get("password", "")
        
        if not username or not password:
            messages.error(request, "Please enter both username and password.")
        else:
            user = authenticate(request, username=username, password=password)
            if user:
                if user.is_active:
                    login(request, user)
                    next_url = request.GET.get("next", "dashboard")
                    return redirect(next_url)
                else:
                    messages.error(request, "Your account has been deactivated.")
            else:
                messages.error(request, "Invalid username or password. Please try again.")

    return render(request, "registration/login.html")


@require_POST
def logout_view(request):
    """Logout user - POST only for CSRF safety."""
    logout(request)
    messages.info(request, "You've been logged out. See you next study session!")
    return redirect("login")


@login_required
def dashboard_view(request):
    """Main dashboard with comprehensive stats."""
    profile, _ = UserProfile.objects.get_or_create(user=request.user)
    
    # Active session check
    active_session = FocusSession.objects.filter(
        user=request.user, is_active=True
    ).first()

    # Recent sessions (last 5 completed)
    recent_sessions = FocusSession.objects.filter(
        user=request.user, is_active=False
    ).select_related("user")[:5]
    
    # Badges (latest 8)
    badges = Badge.objects.filter(user=request.user)[:8]
    new_badges_count = Badge.objects.filter(user=request.user, is_new=True).count()

    # Weekly stats
    week_ago = timezone.now() - timedelta(days=7)
    weekly_sessions = FocusSession.objects.filter(
        user=request.user, start_time__gte=week_ago, is_active=False
    )
    weekly_minutes = sum(s.duration_minutes for s in weekly_sessions)
    weekly_distractions = Distraction.objects.filter(
        session__user=request.user, timestamp__gte=week_ago
    ).count()
    weekly_sessions_count = weekly_sessions.count()

    # Today's stats
    today = timezone.now().date()
    today_sessions = FocusSession.objects.filter(
        user=request.user, start_time__date=today, is_active=False
    )
    today_minutes = sum(s.duration_minutes for s in today_sessions)
    today_sessions_count = today_sessions.count()

    # Chart data (last 7 days)
    chart_data = get_weekly_chart_data(request.user)
    
    # Subject distribution
    subject_data = get_subject_distribution(request.user, days=7)

    # Quote
    quote = get_motivational_quote()

    context = {
        "profile": profile,
        "recent_sessions": recent_sessions,
        "badges": badges,
        "new_badges_count": new_badges_count,
        "active_session": active_session,
        "weekly_minutes": round(weekly_minutes, 1),
        "weekly_hours": round(weekly_minutes / 60, 1),
        "weekly_distractions": weekly_distractions,
        "weekly_sessions_count": weekly_sessions_count,
        "today_minutes": round(today_minutes, 1),
        "today_sessions_count": today_sessions_count,
        "chart_data": json.dumps(chart_data),
        "subject_data": json.dumps(subject_data),
        "quote": quote,
    }
    return render(request, "core/dashboard.html", context)


@login_required
def timer_view(request):
    """Focus timer page with full session management."""
    active_session = FocusSession.objects.filter(
        user=request.user, is_active=True
    ).first()
    blocked_sites = BlockedSite.objects.filter(user=request.user, is_active=True)
    profile = UserProfile.objects.get(user=request.user)
    
    # Recent completed sessions for history
    recent_completed = FocusSession.objects.filter(
        user=request.user, is_active=False
    )[:3]

    context = {
        "active_session": active_session,
        "blocked_sites": blocked_sites,
        "profile": profile,
        "recent_completed": recent_completed,
    }
    return render(request, "core/timer.html", context)


@login_required
def chat_view(request):
    """AI Teacher chat page."""
    chat_history = ChatMessage.objects.filter(
        user=request.user
    ).order_by("-timestamp")[:50]
    chat_history = list(reversed(chat_history))
    
    profile = UserProfile.objects.get(user=request.user)
    
    context = {
        "chat_history": chat_history,
        "profile": profile,
    }
    return render(request, "core/chat.html", context)


@login_required
def reports_view(request):
    """Study reports and analytics page with comprehensive data."""
    days = min(int(request.GET.get("days", 7)), 90)  # Cap at 90 days
    start_date = timezone.now() - timedelta(days=days)

    sessions = FocusSession.objects.filter(
        user=request.user, start_time__gte=start_date, is_active=False
    )
    study_logs = StudyLog.objects.filter(user=request.user, date__gte=start_date.date())

    # Aggregate stats
    total_minutes = sum(s.duration_minutes for s in sessions)
    total_distractions = sum(s.distraction_count for s in sessions)
    avg_score = study_logs.aggregate(avg=Avg("focus_score"))["avg"] or 0
    completed_sessions = sessions.filter(is_completed=True).count()
    total_sessions = sessions.count()
    completion_rate = round((completed_sessions / total_sessions * 100) if total_sessions > 0 else 0, 1)

    # Daily breakdown for chart
    daily_data = []
    for i in range(days):
        date = (timezone.now() - timedelta(days=i)).date()
        day_sessions = sessions.filter(start_time__date=date)
        day_minutes = sum(s.duration_minutes for s in day_sessions)
        day_distractions = sum(s.distraction_count for s in day_sessions)
        daily_data.append({
            "date": date.strftime("%b %d"),
            "date_full": date.strftime("%Y-%m-%d"),
            "minutes": round(day_minutes, 1),
            "sessions": day_sessions.count(),
            "distractions": day_distractions,
        })
    daily_data.reverse()  # Oldest first for charts

    # Subject breakdown
    subjects = (
        study_logs.values("subject")
        .annotate(
            total_min=Sum("duration_minutes"),
            count=Count("id"),
            avg_score=Avg("focus_score"),
        )
        .order_by("-total_min")
    )

    # Best day
    best_day = max(daily_data, key=lambda x: x["minutes"]) if daily_data else None

    # Average daily study time
    avg_daily = round(total_minutes / max(days, 1), 1)

    context = {
        "days": days,
        "total_minutes": round(total_minutes, 1),
        "total_hours": round(total_minutes / 60, 1),
        "total_sessions": total_sessions,
        "total_distractions": total_distractions,
        "avg_score": round(avg_score, 1),
        "completion_rate": completion_rate,
        "avg_daily": avg_daily,
        "best_day": best_day,
        "daily_data": daily_data,
        "daily_data_json": json.dumps(daily_data),
        "subjects": subjects,
        "study_logs": study_logs[:30],
    }
    return render(request, "core/reports.html", context)


@login_required
def blocking_view(request):
    """App/site blocking management page."""
    blocked_sites = BlockedSite.objects.filter(user=request.user)
    active_count = blocked_sites.filter(is_active=True).count()
    total_blocks = blocked_sites.aggregate(total=Sum("times_blocked"))["total"] or 0

    if request.method == "POST":
        form = BlockedSiteForm(request.POST)
        if form.is_valid():
            site = form.save(commit=False)
            site.user = request.user
            # Check for duplicates
            if BlockedSite.objects.filter(user=request.user, url=site.url).exists():
                messages.warning(request, f"{site.url} is already in your block list.")
            else:
                site.save()
                messages.success(request, f"Added {site.name} to block list!")
            return redirect("blocking")
        else:
            messages.error(request, "Please check the form and try again.")
    else:
        form = BlockedSiteForm()

    # Group by category
    categories = {}
    for site in blocked_sites:
        cat = site.get_category_display()
        if cat not in categories:
            categories[cat] = []
        categories[cat].append(site)

    context = {
        "blocked_sites": blocked_sites,
        "categories": categories,
        "active_count": active_count,
        "total_blocks": total_blocks,
        "form": form,
    }
    return render(request, "core/blocking.html", context)


@login_required
def badges_view(request):
    """Badges and achievements page."""
    earned_badges = Badge.objects.filter(user=request.user)
    earned_types = set(earned_badges.values_list("badge_type", flat=True))

    # Mark new badges as seen
    Badge.objects.filter(user=request.user, is_new=True).update(is_new=False)

    # All possible badges with details
    all_badges = []
    for badge_type, badge_name in Badge.BADGE_TYPES:
        badge_obj = earned_badges.filter(badge_type=badge_type).first()
        all_badges.append({
            "type": badge_type,
            "name": badge_name,
            "earned": badge_type in earned_types,
            "earned_at": badge_obj.earned_at if badge_obj else None,
            "icon": badge_obj.icon if badge_obj else Badge(badge_type=badge_type).icon,
            "color": badge_obj.color if badge_obj else "#6c757d",
            "rarity": badge_obj.rarity if badge_obj else Badge(badge_type=badge_type).rarity,
            "description": badge_obj.description if badge_obj else Badge(badge_type=badge_type).description,
        })

    profile = UserProfile.objects.get(user=request.user)

    context = {
        "all_badges": all_badges,
        "earned_count": earned_badges.count(),
        "total_count": len(Badge.BADGE_TYPES),
        "profile": profile,
    }
    return render(request, "core/badges.html", context)


@login_required
def settings_view(request):
    """User settings and profile page."""
    profile = UserProfile.objects.get(user=request.user)
    
    if request.method == "POST":
        action = request.POST.get("action", "")
        
        if action == "update_profile":
            form = ProfileEditForm(request.POST, instance=profile)
            if form.is_valid():
                form.save()
                # Update user email if provided
                new_email = request.POST.get("email", "").strip()
                if new_email and new_email != request.user.email:
                    request.user.email = new_email
                    request.user.save()
                messages.success(request, "Profile updated successfully!")
            else:
                messages.error(request, "Please check the form for errors.")
            return redirect("settings")
            
        elif action == "change_password":
            password_form = PasswordChangeForm(request.user, request.POST)
            if password_form.is_valid():
                user = password_form.save()
                update_session_auth_hash(request, user)
                messages.success(request, "Password changed successfully!")
            else:
                for error in password_form.errors.values():
                    messages.error(request, error[0])
            return redirect("settings")
            
        elif action == "reset_stats":
            # Confirm with a safety check
            confirm = request.POST.get("confirm_reset", "")
            if confirm == "RESET":
                with transaction.atomic():
                    profile.focus_score = 100
                    profile.total_study_time = timedelta(0)
                    profile.streak_days = 0
                    profile.longest_streak = 0
                    profile.total_sessions_completed = 0
                    profile.total_distractions = 0
                    profile.last_study_date = None
                    profile.save()
                    FocusSession.objects.filter(user=request.user).delete()
                    StudyLog.objects.filter(user=request.user).delete()
                    Distraction.objects.filter(session__user=request.user).delete()
                    Badge.objects.filter(user=request.user).delete()
                messages.success(request, "All stats have been reset.")
            else:
                messages.error(request, "Reset cancelled. Type RESET to confirm.")
            return redirect("settings")
            
        elif action == "export_data":
            # Return JSON export of all user data
            data = {
                "profile": {
                    "username": request.user.username,
                    "email": request.user.email,
                    "focus_score": profile.focus_score,
                    "total_study_hours": profile.total_study_hours,
                    "streak_days": profile.streak_days,
                    "level": profile.level,
                },
                "sessions": list(FocusSession.objects.filter(
                    user=request.user, is_active=False
                ).values("subject", "start_time", "end_time", "planned_duration", "focus_score")),
                "badges": list(Badge.objects.filter(user=request.user).values("badge_type", "earned_at")),
            }
            response = JsonResponse(data, json_dumps_params={"indent": 2, "default": str})
            response["Content-Disposition"] = 'attachment; filename="focus_guardian_export.json"'
            return response

    profile_form = ProfileEditForm(instance=profile)
    password_form = PasswordChangeForm(request.user)

    # Account stats
    total_sessions = FocusSession.objects.filter(user=request.user, is_active=False).count()
    total_messages = ChatMessage.objects.filter(user=request.user).count()
    member_since = request.user.date_joined

    context = {
        "profile": profile,
        "profile_form": profile_form,
        "password_form": password_form,
        "total_sessions": total_sessions,
        "total_messages": total_messages,
        "member_since": member_since,
    }
    return render(request, "core/settings.html", context)


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
    throttle_classes = [SessionRateThrottle]

    def post(self, request):
        # End any existing active sessions
        with transaction.atomic():
            active_sessions = FocusSession.objects.filter(user=request.user, is_active=True)
            for session in active_sessions:
                session.is_active = False
                session.end_time = timezone.now()
                session.save()

            # Validate input
            subject = request.data.get("subject", "General Study").strip()
            if not subject:
                subject = "General Study"
            if len(subject) > 100:
                return Response(
                    {"error": "Subject must be 100 characters or less"},
                    status=status.HTTP_400_BAD_REQUEST
                )

            planned_duration = request.data.get("planned_duration", 25)
            try:
                planned_duration = int(planned_duration)
                if planned_duration < 1 or planned_duration > 300:
                    raise ValueError
            except (ValueError, TypeError):
                return Response(
                    {"error": "Duration must be between 1 and 300 minutes"},
                    status=status.HTTP_400_BAD_REQUEST
                )

            session_type = request.data.get("session_type", "pomodoro")
            mood = request.data.get("mood", "")

            session = FocusSession.objects.create(
                user=request.user,
                subject=subject,
                planned_duration=planned_duration,
                session_type=session_type,
                mood_before=mood,
            )

        serializer = FocusSessionSerializer(session)
        return Response(serializer.data, status=status.HTTP_201_CREATED)


class EndFocusSessionView(APIView):
    """End the active focus session."""
    throttle_classes = [SessionRateThrottle]

    def post(self, request):
        try:
            with transaction.atomic():
                session = FocusSession.objects.select_for_update().get(
                    user=request.user, is_active=True
                )
                session.is_active = False
                session.end_time = timezone.now()
                
                # Check if user completed the planned duration
                if session.duration_minutes >= session.planned_duration * 0.9:
                    session.is_completed = True
                
                # Set mood after
                mood_after = request.data.get("mood_after", "")
                if mood_after:
                    session.mood_after = mood_after

                # Notes
                notes = request.data.get("notes", "")
                if notes:
                    session.notes = notes[:500]  # Cap notes length

                # Calculate and store focus score
                score = calculate_session_score(session)
                session.focus_score = score
                session.save()

                # Update profile stats
                profile = UserProfile.objects.select_for_update().get(user=request.user)
                profile.total_study_time += session.duration
                profile.total_sessions_completed += 1
                profile.total_distractions += session.distraction_count
                
                # Update focus score (weighted average)
                if profile.total_sessions_completed > 1:
                    profile.focus_score = round(
                        (profile.focus_score * 0.7) + (score * 0.3)
                    )
                else:
                    profile.focus_score = score
                profile.focus_score = max(0, min(100, profile.focus_score))
                profile.save()

                # Update study log
                update_study_log(session)

                # Update streak
                streak = update_streak(request.user)

                # Check for new badges
                new_badges = check_and_award_badges(request.user)

            serializer = FocusSessionSerializer(session)
            response_data = serializer.data
            response_data["session_score"] = score
            response_data["new_badges"] = [
                {"name": b.get_badge_type_display(), "icon": b.icon, "rarity": b.rarity}
                for b in new_badges
            ]
            response_data["streak_days"] = streak
            response_data["is_completed"] = session.is_completed

            return Response(response_data)

        except FocusSession.DoesNotExist:
            return Response(
                {"error": "No active session found"},
                status=status.HTTP_404_NOT_FOUND,
            )
        except Exception as e:
            logger.error(f"Error ending session for user {request.user}: {e}")
            return Response(
                {"error": "An error occurred. Please try again."},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR,
            )


class LogDistractionView(APIView):
    """Log a distraction event during active session."""
    throttle_classes = [SessionRateThrottle]

    def post(self, request):
        try:
            session = FocusSession.objects.get(user=request.user, is_active=True)
            
            app_name = request.data.get("app_name", "Unknown").strip()[:255]
            distraction_type = request.data.get("distraction_type", "app_switch")
            severity = request.data.get("severity", "medium")
            
            # Validate type
            valid_types = [t[0] for t in Distraction.DISTRACTION_TYPES]
            if distraction_type not in valid_types:
                distraction_type = "app_switch"
            
            valid_severities = [s[0] for s in Distraction.SEVERITY_CHOICES]
            if severity not in valid_severities:
                severity = "medium"

            distraction = Distraction.objects.create(
                session=session,
                app_name=app_name,
                distraction_type=distraction_type,
                severity=severity,
            )

            # Update blocked site counter if applicable
            blocked = BlockedSite.objects.filter(
                user=request.user, name__icontains=app_name, is_active=True
            ).first()
            if blocked:
                blocked.times_blocked = F("times_blocked") + 1
                blocked.save()

            # Reduce focus score based on severity
            penalty = distraction.score_penalty
            profile = UserProfile.objects.get(user=request.user)
            profile.focus_score = max(0, profile.focus_score - penalty)
            profile.save()

            return Response({
                "id": distraction.id,
                "app_name": distraction.app_name,
                "type": distraction.distraction_type,
                "severity": severity,
                "penalty": penalty,
                "new_score": profile.focus_score,
                "total_distractions": session.distraction_count,
            }, status=status.HTTP_201_CREATED)

        except FocusSession.DoesNotExist:
            return Response(
                {"error": "No active session found"},
                status=status.HTTP_404_NOT_FOUND,
            )


class ActiveSessionView(APIView):
    """Get active session data for timer sync."""
    
    def get(self, request):
        session = FocusSession.objects.filter(
            user=request.user, is_active=True
        ).first()
        
        if session:
            return Response({
                "active": True,
                "id": session.id,
                "subject": session.subject,
                "planned_duration": session.planned_duration,
                "start_time": session.start_time.isoformat(),
                "elapsed_seconds": int(session.duration.total_seconds()),
                "distraction_count": session.distraction_count,
            })
        return Response({"active": False})


class StudyReportAPIView(APIView):
    """Get study report data."""

    def get(self, request):
        days = min(int(request.query_params.get("days", 7)), 90)
        start_date = timezone.now() - timedelta(days=days)

        sessions = FocusSession.objects.filter(
            user=request.user, start_time__gte=start_date, is_active=False
        ).order_by("-start_time")

        report = []
        for session in sessions[:50]:
            report.append({
                "id": session.id,
                "subject": session.subject,
                "start_time": session.start_time.isoformat(),
                "end_time": session.end_time.isoformat() if session.end_time else None,
                "duration_minutes": session.duration_minutes,
                "duration_formatted": session.duration_formatted,
                "distractions_count": session.distraction_count,
                "score": session.focus_score,
                "is_completed": session.is_completed,
                "session_type": session.session_type,
            })

        return Response(report)


class AITeacherView(APIView):
    """AI Teacher chat endpoint."""
    throttle_classes = [ChatRateThrottle]

    def post(self, request):
        user_message = request.data.get("message", "").strip()
        if not user_message:
            return Response(
                {"error": "Message is required"},
                status=status.HTTP_400_BAD_REQUEST,
            )
        
        # Cap message length
        if len(user_message) > 2000:
            return Response(
                {"error": "Message too long. Please keep it under 2000 characters."},
                status=status.HTTP_400_BAD_REQUEST,
            )

        mode = request.data.get("mode", "general")
        valid_modes = [m[0] for m in ChatMessage.MODE_CHOICES]
        if mode not in valid_modes:
            mode = "general"

        # Save user message
        ChatMessage.objects.create(
            user=request.user, role="user", content=user_message, mode=mode
        )

        # Get chat history for context
        chat_history = ChatMessage.objects.filter(
            user=request.user
        ).order_by("-timestamp")[:20]
        chat_history = list(reversed(chat_history))

        # Get AI response
        try:
            ai_response = get_ai_response(user_message, request.user, chat_history, mode)
        except Exception as e:
            logger.error(f"AI response error for {request.user}: {e}")
            ai_response = "I'm having trouble processing that right now. Please try again in a moment."

        # Save AI response
        ChatMessage.objects.create(
            user=request.user, role="assistant", content=ai_response, mode=mode
        )

        return Response({
            "reply": ai_response,
            "mode": mode,
        })


class BlockedSiteToggleView(APIView):
    """Toggle a blocked site's active status."""

    def post(self, request, pk):
        try:
            site = BlockedSite.objects.get(pk=pk, user=request.user)
            site.is_active = not site.is_active
            site.save()
            return Response({
                "is_active": site.is_active,
                "name": site.name,
            })
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
            return Response({"message": "Site removed"}, status=status.HTTP_200_OK)
        except BlockedSite.DoesNotExist:
            return Response(
                {"error": "Site not found"}, status=status.HTTP_404_NOT_FOUND
            )


class ClearChatView(APIView):
    """Clear chat history."""

    def post(self, request):
        count = ChatMessage.objects.filter(user=request.user).count()
        ChatMessage.objects.filter(user=request.user).delete()
        return Response({"message": f"Cleared {count} messages"})


class QuoteAPIView(APIView):
    """Get a motivational quote."""
    
    def get(self, request):
        quote = get_motivational_quote()
        return Response(quote)

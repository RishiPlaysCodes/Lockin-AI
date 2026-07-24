"""
Session Service - Business logic for focus sessions.
Encapsulates session management with proper transaction handling.
"""

import logging
from datetime import date

from django.contrib.auth.models import User
from django.db import transaction
from django.utils import timezone

from ..models import Distraction, FocusSession, UserProfile

logger = logging.getLogger(__name__)


class SessionService:
    """Service for managing focus sessions."""

    @staticmethod
    @transaction.atomic
    def start_session(user: User, session_type: str = "pomodoro", planned_duration_minutes: int = 25, notes: str = "") -> FocusSession:
        """
        Start a new focus session for the user.
        Automatically ends any existing active sessions.

        Args:
            user: The user starting the session.
            session_type: Type of session (pomodoro, short, long, custom).
            planned_duration_minutes: Planned session duration.
            notes: Optional session notes.

        Returns:
            The newly created FocusSession.
        """
        # End any existing active sessions
        active_sessions = FocusSession.objects.select_for_update().filter(
            user=user, is_active=True
        )
        now = timezone.now()
        ended_count = active_sessions.update(is_active=False, end_time=now)

        if ended_count > 0:
            logger.info(
                f"Auto-ended {ended_count} active session(s) for user {user.username}"
            )

        # Create new session
        session = FocusSession.objects.create(
            user=user,
            session_type=session_type,
            planned_duration_minutes=planned_duration_minutes,
            notes=notes,
        )

        logger.info(
            f"Started {session_type} session for user {user.username}",
            extra={"session_id": str(session.id), "user_id": user.id},
        )

        return session

    @staticmethod
    @transaction.atomic
    def end_session(user: User) -> FocusSession | None:
        """
        End the user's active focus session.
        Updates user profile with session duration.

        Args:
            user: The user ending their session.

        Returns:
            The ended FocusSession, or None if no active session found.
        """
        try:
            session = FocusSession.objects.select_for_update().get(
                user=user, is_active=True
            )
        except FocusSession.DoesNotExist:
            return None

        session.is_active = False
        session.end_time = timezone.now()
        session.save(update_fields=["is_active", "end_time", "updated_at"])

        # Update user profile
        duration = session.end_time - session.start_time
        profile, _ = UserProfile.objects.get_or_create(user=user)
        profile.add_study_time(duration)

        # Update streak
        today = date.today()
        if profile.last_active_date != today:
            if profile.last_active_date and (today - profile.last_active_date).days == 1:
                profile.streak_days += 1
            elif profile.last_active_date and (today - profile.last_active_date).days > 1:
                profile.streak_days = 1
            else:
                profile.streak_days = 1
            profile.last_active_date = today
            profile.save(update_fields=["streak_days", "last_active_date", "updated_at"])

        logger.info(
            f"Ended session for user {user.username}, duration: {duration}",
            extra={"session_id": str(session.id), "duration_seconds": duration.total_seconds()},
        )

        return session

    @staticmethod
    @transaction.atomic
    def log_distraction(user: User, app_name: str, distraction_type: str = "app_switch", duration_seconds: int = 0) -> Distraction | None:
        """
        Log a distraction event for the user's active session.

        Args:
            user: The user who was distracted.
            app_name: Name of the distracting app/activity.
            distraction_type: Type of distraction.
            duration_seconds: How long the distraction lasted.

        Returns:
            The created Distraction, or None if no active session.
        """
        try:
            session = FocusSession.objects.get(user=user, is_active=True)
        except FocusSession.DoesNotExist:
            return None

        distraction = Distraction.objects.create(
            session=session,
            app_name=app_name,
            distraction_type=distraction_type,
            duration_seconds=duration_seconds,
        )

        # Update focus score
        profile, _ = UserProfile.objects.get_or_create(user=user)
        profile.decrease_focus_score()

        logger.info(
            f"Distraction logged for user {user.username}: {app_name}",
            extra={
                "session_id": str(session.id),
                "app_name": app_name,
                "distraction_type": distraction_type,
            },
        )

        return distraction

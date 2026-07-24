"""
Tests for core models.
"""

from datetime import timedelta

import pytest
from django.contrib.auth.models import User
from django.core.exceptions import ValidationError
from django.utils import timezone

from core.models import Distraction, FocusSession, UserProfile


@pytest.mark.django_db
class TestUserProfile:
    """Tests for the UserProfile model."""

    def test_profile_creation(self, user_profile):
        """Test profile is created with default values."""
        assert user_profile.focus_score == 100
        assert user_profile.total_study_time == timedelta(0)
        assert user_profile.daily_goal_minutes == 120
        assert user_profile.streak_days == 0

    def test_decrease_focus_score(self, user_profile):
        """Test focus score decreases correctly."""
        user_profile.decrease_focus_score(10)
        user_profile.refresh_from_db()
        assert user_profile.focus_score == 90

    def test_decrease_focus_score_minimum(self, user_profile):
        """Test focus score doesn't go below 0."""
        user_profile.focus_score = 3
        user_profile.save()
        user_profile.decrease_focus_score(10)
        user_profile.refresh_from_db()
        assert user_profile.focus_score == 0

    def test_add_study_time(self, user_profile):
        """Test adding study time to profile."""
        user_profile.add_study_time(timedelta(minutes=25))
        user_profile.refresh_from_db()
        assert user_profile.total_study_time == timedelta(minutes=25)

    def test_str_representation(self, user_profile):
        """Test string representation."""
        assert "testuser" in str(user_profile)
        assert "100" in str(user_profile)


@pytest.mark.django_db
class TestFocusSession:
    """Tests for the FocusSession model."""

    def test_session_creation(self, active_session):
        """Test session is created with correct defaults."""
        assert active_session.is_active is True
        assert active_session.end_time is None
        assert active_session.session_type == "pomodoro"
        assert active_session.planned_duration_minutes == 25

    def test_session_duration_active(self, active_session):
        """Test duration is None for active sessions."""
        assert active_session.duration is None

    def test_session_duration_completed(self, active_session):
        """Test duration calculation for completed sessions."""
        active_session.end_time = active_session.start_time + timedelta(minutes=25)
        active_session.is_active = False
        active_session.save()
        assert active_session.duration == timedelta(minutes=25)

    def test_distraction_count(self, active_session):
        """Test distraction count property."""
        Distraction.objects.create(session=active_session, app_name="App1")
        Distraction.objects.create(session=active_session, app_name="App2")
        assert active_session.distraction_count == 2

    def test_session_ordering(self, user):
        """Test sessions are ordered by newest first."""
        s1 = FocusSession.objects.create(user=user)
        s2 = FocusSession.objects.create(user=user)
        sessions = list(FocusSession.objects.filter(user=user))
        assert sessions[0] == s2
        assert sessions[1] == s1


@pytest.mark.django_db
class TestDistraction:
    """Tests for the Distraction model."""

    def test_distraction_creation(self, active_session):
        """Test distraction is created correctly."""
        distraction = Distraction.objects.create(
            session=active_session,
            app_name="YouTube",
            distraction_type="app_switch",
            duration_seconds=30,
        )
        assert distraction.app_name == "YouTube"
        assert distraction.distraction_type == "app_switch"
        assert distraction.duration_seconds == 30

    def test_distraction_default_type(self, active_session):
        """Test default distraction type."""
        distraction = Distraction.objects.create(
            session=active_session, app_name="Test"
        )
        assert distraction.distraction_type == "app_switch"

    def test_str_representation(self, active_session):
        """Test string representation."""
        distraction = Distraction.objects.create(
            session=active_session, app_name="YouTube"
        )
        assert "YouTube" in str(distraction)
        assert "testuser" in str(distraction)

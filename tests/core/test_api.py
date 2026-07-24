"""
Tests for API v1 endpoints.
"""

import pytest
from django.contrib.auth.models import User
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APIClient

from core.models import Distraction, FocusSession, UserProfile


@pytest.mark.django_db
class TestUserRegistration:
    """Tests for user registration endpoint."""

    def test_successful_registration(self, api_client):
        """Test successful user registration."""
        data = {
            "username": "newuser",
            "email": "new@example.com",
            "password": "SecurePass123!",
            "password_confirm": "SecurePass123!",
        }
        response = api_client.post(reverse("api-v1:register"), data, format="json")
        assert response.status_code == status.HTTP_201_CREATED
        assert "tokens" in response.data
        assert "access" in response.data["tokens"]
        assert "refresh" in response.data["tokens"]
        assert User.objects.filter(username="newuser").exists()

    def test_registration_password_mismatch(self, api_client):
        """Test registration fails with mismatched passwords."""
        data = {
            "username": "newuser",
            "email": "new@example.com",
            "password": "SecurePass123!",
            "password_confirm": "DifferentPass456!",
        }
        response = api_client.post(reverse("api-v1:register"), data, format="json")
        assert response.status_code == status.HTTP_400_BAD_REQUEST

    def test_registration_duplicate_email(self, api_client, user):
        """Test registration fails with duplicate email."""
        data = {
            "username": "newuser2",
            "email": "test@example.com",  # Same as fixture user
            "password": "SecurePass123!",
            "password_confirm": "SecurePass123!",
        }
        response = api_client.post(reverse("api-v1:register"), data, format="json")
        assert response.status_code == status.HTTP_400_BAD_REQUEST

    def test_registration_short_password(self, api_client):
        """Test registration fails with short password."""
        data = {
            "username": "newuser",
            "email": "new@example.com",
            "password": "short",
            "password_confirm": "short",
        }
        response = api_client.post(reverse("api-v1:register"), data, format="json")
        assert response.status_code == status.HTTP_400_BAD_REQUEST


@pytest.mark.django_db
class TestUserProfile:
    """Tests for user profile endpoint."""

    def test_get_profile(self, authenticated_client, user_profile):
        """Test retrieving user profile."""
        response = authenticated_client.get(reverse("api-v1:profile"))
        assert response.status_code == status.HTTP_200_OK
        assert response.data["username"] == "testuser"
        assert response.data["focus_score"] == 100

    def test_profile_unauthenticated(self, api_client):
        """Test profile requires authentication."""
        response = api_client.get(reverse("api-v1:profile"))
        assert response.status_code == status.HTTP_401_UNAUTHORIZED

    def test_update_daily_goal(self, authenticated_client, user_profile):
        """Test updating daily goal."""
        response = authenticated_client.patch(
            reverse("api-v1:profile"),
            {"daily_goal_minutes": 90},
            format="json",
        )
        assert response.status_code == status.HTTP_200_OK
        user_profile.refresh_from_db()
        assert user_profile.daily_goal_minutes == 90


@pytest.mark.django_db
class TestFocusSession:
    """Tests for focus session endpoints."""

    def test_start_session(self, authenticated_client):
        """Test starting a new focus session."""
        response = authenticated_client.post(
            reverse("api-v1:session-start"),
            {"session_type": "pomodoro", "planned_duration_minutes": 25},
            format="json",
        )
        assert response.status_code == status.HTTP_201_CREATED
        assert response.data["is_active"] is True
        assert response.data["session_type"] == "pomodoro"

    def test_start_session_ends_previous(self, authenticated_client, active_session):
        """Test starting a session ends existing active session."""
        response = authenticated_client.post(
            reverse("api-v1:session-start"),
            {"session_type": "short", "planned_duration_minutes": 15},
            format="json",
        )
        assert response.status_code == status.HTTP_201_CREATED
        active_session.refresh_from_db()
        assert active_session.is_active is False
        assert active_session.end_time is not None

    def test_end_session(self, authenticated_client, active_session, user_profile):
        """Test ending an active session."""
        response = authenticated_client.post(reverse("api-v1:session-end"))
        assert response.status_code == status.HTTP_200_OK
        assert response.data["is_active"] is False
        assert response.data["end_time"] is not None
        # Check study time was added
        user_profile.refresh_from_db()
        assert user_profile.total_study_time.total_seconds() > 0

    def test_end_session_no_active(self, authenticated_client):
        """Test ending session when none active."""
        response = authenticated_client.post(reverse("api-v1:session-end"))
        assert response.status_code == status.HTTP_404_NOT_FOUND

    def test_list_sessions(self, authenticated_client, active_session):
        """Test listing focus sessions."""
        response = authenticated_client.get(reverse("api-v1:session-list"))
        assert response.status_code == status.HTTP_200_OK
        assert response.data["count"] == 1

    def test_session_isolation(self, authenticated_client, second_user):
        """Test users can only see their own sessions."""
        FocusSession.objects.create(user=second_user)
        response = authenticated_client.get(reverse("api-v1:session-list"))
        # Should not include second_user's session
        assert response.data["count"] == 0

    def test_invalid_duration(self, authenticated_client):
        """Test validation for invalid planned duration."""
        response = authenticated_client.post(
            reverse("api-v1:session-start"),
            {"session_type": "custom", "planned_duration_minutes": 500},
            format="json",
        )
        assert response.status_code == status.HTTP_400_BAD_REQUEST


@pytest.mark.django_db
class TestDistraction:
    """Tests for distraction logging endpoint."""

    def test_log_distraction(self, authenticated_client, active_session, user_profile):
        """Test logging a distraction."""
        response = authenticated_client.post(
            reverse("api-v1:log-distraction"),
            {"app_name": "YouTube", "distraction_type": "app_switch"},
            format="json",
        )
        assert response.status_code == status.HTTP_201_CREATED
        assert response.data["app_name"] == "YouTube"
        # Check focus score decreased
        user_profile.refresh_from_db()
        assert user_profile.focus_score == 95

    def test_log_distraction_no_active_session(self, authenticated_client):
        """Test logging distraction without active session."""
        response = authenticated_client.post(
            reverse("api-v1:log-distraction"),
            {"app_name": "YouTube", "distraction_type": "app_switch"},
            format="json",
        )
        assert response.status_code == status.HTTP_404_NOT_FOUND

    def test_log_distraction_missing_app_name(self, authenticated_client, active_session):
        """Test validation for missing app_name."""
        response = authenticated_client.post(
            reverse("api-v1:log-distraction"),
            {"distraction_type": "app_switch"},
            format="json",
        )
        assert response.status_code == status.HTTP_400_BAD_REQUEST


@pytest.mark.django_db
class TestStudyReport:
    """Tests for study report endpoint."""

    def test_get_report(self, authenticated_client, active_session):
        """Test getting study report."""
        response = authenticated_client.get(reverse("api-v1:study-report"))
        assert response.status_code == status.HTTP_200_OK
        assert len(response.data) == 1

    def test_report_unauthenticated(self, api_client):
        """Test report requires auth."""
        response = api_client.get(reverse("api-v1:study-report"))
        assert response.status_code == status.HTTP_401_UNAUTHORIZED


@pytest.mark.django_db
class TestAITeacher:
    """Tests for AI teacher endpoint."""

    def test_ai_teacher_mock_response(self, authenticated_client):
        """Test AI teacher returns a mock response when API key not set."""
        response = authenticated_client.post(
            reverse("api-v1:ai-teacher"),
            {"message": "Explain photosynthesis"},
            format="json",
        )
        assert response.status_code == status.HTTP_200_OK
        assert "reply" in response.data

    def test_ai_teacher_empty_message(self, authenticated_client):
        """Test AI teacher rejects empty message."""
        response = authenticated_client.post(
            reverse("api-v1:ai-teacher"),
            {"message": ""},
            format="json",
        )
        assert response.status_code == status.HTTP_400_BAD_REQUEST

    def test_ai_teacher_missing_message(self, authenticated_client):
        """Test AI teacher rejects missing message field."""
        response = authenticated_client.post(
            reverse("api-v1:ai-teacher"),
            {},
            format="json",
        )
        assert response.status_code == status.HTTP_400_BAD_REQUEST


@pytest.mark.django_db
class TestUserStats:
    """Tests for user statistics endpoint."""

    def test_get_stats(self, authenticated_client, user_profile):
        """Test getting user statistics."""
        response = authenticated_client.get(reverse("api-v1:user-stats"))
        assert response.status_code == status.HTTP_200_OK
        assert "focus_score" in response.data
        assert "total_sessions" in response.data
        assert "streak_days" in response.data

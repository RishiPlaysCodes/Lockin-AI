"""
Tests for service layer.
"""

from datetime import timedelta
from unittest.mock import MagicMock, patch

import pytest
from django.utils import timezone

from core.models import Distraction, FocusSession, UserProfile
from core.services.ai_service import AITeacherService
from core.services.session_service import SessionService


@pytest.mark.django_db
class TestSessionService:
    """Tests for SessionService."""

    def test_start_session(self, user):
        """Test starting a session."""
        session = SessionService.start_session(user, "pomodoro", 25)
        assert session.is_active is True
        assert session.user == user
        assert session.session_type == "pomodoro"

    def test_start_session_ends_previous(self, user):
        """Test starting a session ends any active ones."""
        first_session = SessionService.start_session(user, "pomodoro", 25)
        second_session = SessionService.start_session(user, "short", 15)

        first_session.refresh_from_db()
        assert first_session.is_active is False
        assert first_session.end_time is not None
        assert second_session.is_active is True

    def test_end_session(self, user, user_profile):
        """Test ending a session."""
        SessionService.start_session(user, "pomodoro", 25)
        session = SessionService.end_session(user)

        assert session is not None
        assert session.is_active is False
        assert session.end_time is not None

    def test_end_session_no_active(self, user):
        """Test ending when no active session exists."""
        result = SessionService.end_session(user)
        assert result is None

    def test_end_session_updates_study_time(self, user, user_profile):
        """Test ending a session updates total study time."""
        SessionService.start_session(user, "pomodoro", 25)
        SessionService.end_session(user)

        user_profile.refresh_from_db()
        assert user_profile.total_study_time.total_seconds() > 0

    def test_log_distraction(self, user, active_session, user_profile):
        """Test logging a distraction."""
        distraction = SessionService.log_distraction(user, "YouTube", "app_switch")

        assert distraction is not None
        assert distraction.app_name == "YouTube"
        user_profile.refresh_from_db()
        assert user_profile.focus_score == 95

    def test_log_distraction_no_session(self, user):
        """Test logging distraction without active session."""
        result = SessionService.log_distraction(user, "YouTube", "app_switch")
        assert result is None


class TestAITeacherService:
    """Tests for AITeacherService."""

    def test_is_not_configured_without_key(self, settings):
        """Test service reports not configured without any API key."""
        settings.GEMINI_API_KEY = ""
        settings.OPENAI_API_KEY = ""
        service = AITeacherService()
        assert service.is_configured() is False

    def test_mock_response_without_key(self, settings):
        """Test mock response when no API key is set."""
        settings.GEMINI_API_KEY = ""
        settings.OPENAI_API_KEY = ""
        service = AITeacherService()
        result = service.get_response("Hello")
        assert result.success is True
        assert "mock" in result.model_used
        assert "Focus Guardian" in result.reply

    @patch("core.services.ai_service.openai")
    def test_successful_openai_call(self, mock_openai, settings):
        """Test successful OpenAI API call (when only OpenAI key is set)."""
        settings.GEMINI_API_KEY = ""
        settings.OPENAI_API_KEY = "test-key"

        mock_response = MagicMock()
        mock_response.choices = [MagicMock()]
        mock_response.choices[0].message.content = "Test AI response"
        mock_response.model = "gpt-4o-mini"

        mock_client = MagicMock()
        mock_client.chat.completions.create.return_value = mock_response
        mock_openai.OpenAI.return_value = mock_client

        service = AITeacherService()
        result = service.get_response("What is Python?")

        assert result.success is True
        assert result.reply == "Test AI response"
        assert result.model_used == "gpt-4o-mini"

    @patch("core.services.ai_service.openai")
    def test_gemini_takes_priority(self, mock_openai, settings):
        """Test Gemini is used when both keys are set (free tier priority)."""
        settings.GEMINI_API_KEY = "gemini-test-key"
        settings.OPENAI_API_KEY = "openai-test-key"

        mock_response = MagicMock()
        mock_response.choices = [MagicMock()]
        mock_response.choices[0].message.content = "Gemini reply"
        mock_response.model = "gemini-2.0-flash"

        mock_client = MagicMock()
        mock_client.chat.completions.create.return_value = mock_response
        mock_openai.OpenAI.return_value = mock_client

        service = AITeacherService()
        assert service.provider == "gemini"

        result = service.get_response("What is Python?")
        assert result.success is True
        assert result.reply == "Gemini reply"

        # Verify the client was created with Gemini's base_url
        _, kwargs = mock_openai.OpenAI.call_args
        assert kwargs["api_key"] == "gemini-test-key"
        assert "base_url" in kwargs

"""
Integration tests for complete user workflows.
"""

import pytest
from django.contrib.auth.models import User
from django.urls import reverse
from rest_framework import status
from rest_framework.test import APIClient

from core.models import FocusSession, UserProfile


@pytest.mark.django_db
class TestCompleteWorkflow:
    """Tests simulating real user workflows end-to-end."""

    def test_full_user_journey(self):
        """Test: Register -> Start Session -> Log Distraction -> End Session -> Check Report."""
        client = APIClient()

        # 1. Register
        register_data = {
            "username": "workflow_user",
            "email": "workflow@example.com",
            "password": "SecurePass123!",
            "password_confirm": "SecurePass123!",
        }
        response = client.post(reverse("api-v1:register"), register_data, format="json")
        assert response.status_code == status.HTTP_201_CREATED
        access_token = response.data["tokens"]["access"]
        client.credentials(HTTP_AUTHORIZATION=f"Bearer {access_token}")

        # 2. Check profile
        response = client.get(reverse("api-v1:profile"))
        assert response.status_code == status.HTTP_200_OK
        assert response.data["focus_score"] == 100

        # 3. Start focus session
        response = client.post(
            reverse("api-v1:session-start"),
            {"session_type": "pomodoro", "planned_duration_minutes": 25},
            format="json",
        )
        assert response.status_code == status.HTTP_201_CREATED
        session_id = response.data["id"]

        # 4. Log distraction
        response = client.post(
            reverse("api-v1:log-distraction"),
            {"app_name": "Instagram", "distraction_type": "app_switch"},
            format="json",
        )
        assert response.status_code == status.HTTP_201_CREATED

        # 5. Verify focus score decreased
        response = client.get(reverse("api-v1:profile"))
        assert response.data["focus_score"] == 95

        # 6. End session
        response = client.post(reverse("api-v1:session-end"))
        assert response.status_code == status.HTTP_200_OK
        assert response.data["is_active"] is False

        # 7. Check report
        response = client.get(reverse("api-v1:study-report"))
        assert response.status_code == status.HTTP_200_OK
        assert len(response.data) == 1
        assert response.data[0]["distractions_count"] == 1

        # 8. Check stats
        response = client.get(reverse("api-v1:user-stats"))
        assert response.status_code == status.HTTP_200_OK
        assert response.data["total_sessions"] == 1
        assert response.data["completed_sessions"] == 1
        assert response.data["total_distractions"] == 1

    def test_multiple_sessions_workflow(self):
        """Test user completing multiple sessions."""
        client = APIClient()

        # Register
        register_data = {
            "username": "multi_session_user",
            "email": "multi@example.com",
            "password": "SecurePass123!",
            "password_confirm": "SecurePass123!",
        }
        response = client.post(reverse("api-v1:register"), register_data, format="json")
        access_token = response.data["tokens"]["access"]
        client.credentials(HTTP_AUTHORIZATION=f"Bearer {access_token}")

        # Complete 3 sessions
        for i in range(3):
            client.post(
                reverse("api-v1:session-start"),
                {"session_type": "pomodoro"},
                format="json",
            )
            client.post(reverse("api-v1:session-end"))

        # Verify stats
        response = client.get(reverse("api-v1:user-stats"))
        assert response.data["completed_sessions"] == 3
        assert response.data["total_sessions"] == 3

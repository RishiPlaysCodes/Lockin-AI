"""
Pytest configuration and shared fixtures.
"""

import pytest
from django.contrib.auth.models import User
from rest_framework.test import APIClient
from rest_framework_simplejwt.tokens import RefreshToken

from core.models import FocusSession, UserProfile


@pytest.fixture
def api_client():
    """Return an unauthenticated API client."""
    return APIClient()


@pytest.fixture
def user(db):
    """Create and return a test user."""
    user = User.objects.create_user(
        username="testuser",
        email="test@example.com",
        password="SecureTestPass123!",
    )
    return user


@pytest.fixture
def user_profile(user):
    """Get or create a UserProfile for the test user."""
    profile, _ = UserProfile.objects.get_or_create(user=user)
    return profile


@pytest.fixture
def authenticated_client(user):
    """Return an API client authenticated with JWT."""
    client = APIClient()
    refresh = RefreshToken.for_user(user)
    client.credentials(HTTP_AUTHORIZATION=f"Bearer {refresh.access_token}")
    return client


@pytest.fixture
def active_session(user):
    """Create and return an active focus session."""
    return FocusSession.objects.create(
        user=user,
        session_type="pomodoro",
        planned_duration_minutes=25,
    )


@pytest.fixture
def second_user(db):
    """Create a second test user for isolation tests."""
    return User.objects.create_user(
        username="seconduser",
        email="second@example.com",
        password="SecureTestPass456!",
    )

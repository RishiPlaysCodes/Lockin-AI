"""
API v1 URL configuration.
"""

from django.urls import path
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

from . import views

app_name = "api-v1"

urlpatterns = [
    # Authentication
    path("auth/register/", views.UserRegistrationView.as_view(), name="register"),
    path("auth/token/", TokenObtainPairView.as_view(), name="token-obtain"),
    path("auth/token/refresh/", TokenRefreshView.as_view(), name="token-refresh"),
    path("auth/logout/", views.LogoutView.as_view(), name="logout"),
    # User Profile
    path("profile/", views.UserProfileView.as_view(), name="profile"),
    # Focus Sessions
    path("sessions/", views.FocusSessionListView.as_view(), name="session-list"),
    path("sessions/start/", views.StartFocusSessionView.as_view(), name="session-start"),
    path("sessions/end/", views.EndFocusSessionView.as_view(), name="session-end"),
    path("sessions/<uuid:pk>/", views.FocusSessionDetailView.as_view(), name="session-detail"),
    # Distractions
    path("distractions/", views.LogDistractionView.as_view(), name="log-distraction"),
    # Reports
    path("reports/study/", views.StudyReportView.as_view(), name="study-report"),
    path("reports/stats/", views.UserStatsView.as_view(), name="user-stats"),
    # AI Teacher
    path("ai-teacher/", views.AITeacherView.as_view(), name="ai-teacher"),
]

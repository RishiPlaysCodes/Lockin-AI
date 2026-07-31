from django.urls import path
from . import views

urlpatterns = [
    # Pages
    path("", views.landing_view, name="landing"),
    path("signup/", views.signup_view, name="signup"),
    path("login/", views.login_view, name="login"),
    path("logout/", views.logout_view, name="logout"),
    path("dashboard/", views.dashboard_view, name="dashboard"),
    path("timer/", views.timer_view, name="timer"),
    path("chat/", views.chat_view, name="chat"),
    path("reports/", views.reports_view, name="reports"),
    path("blocking/", views.blocking_view, name="blocking"),
    path("badges/", views.badges_view, name="badges"),
    path("settings/", views.settings_view, name="settings"),

    # API Endpoints
    path("api/profile/", views.UserProfileAPIView.as_view(), name="api-profile"),
    path("api/session/start/", views.StartFocusSessionView.as_view(), name="api-session-start"),
    path("api/session/end/", views.EndFocusSessionView.as_view(), name="api-session-end"),
    path("api/session/active/", views.ActiveSessionView.as_view(), name="api-session-active"),
    path("api/distraction/", views.LogDistractionView.as_view(), name="api-log-distraction"),
    path("api/report/", views.StudyReportAPIView.as_view(), name="api-study-report"),
    path("api/ai-teacher/", views.AITeacherView.as_view(), name="api-ai-teacher"),
    path("api/chat/clear/", views.ClearChatView.as_view(), name="api-clear-chat"),
    path("api/quote/", views.QuoteAPIView.as_view(), name="api-quote"),
    path("api/blocked-site/<int:pk>/toggle/", views.BlockedSiteToggleView.as_view(), name="api-toggle-site"),
    path("api/blocked-site/<int:pk>/delete/", views.BlockedSiteDeleteView.as_view(), name="api-delete-site"),
]

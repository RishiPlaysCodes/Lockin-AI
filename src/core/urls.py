"""
URL patterns for template-based views (legacy frontend).
"""

from django.urls import path

from .views import chat_view, dashboard_view, timer_view

urlpatterns = [
    path("dashboard/", dashboard_view, name="dashboard"),
    path("timer/", timer_view, name="timer"),
    path("chat/", chat_view, name="chat"),
]

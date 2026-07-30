"""
URL patterns for the web frontend (template-based pages).
"""

from django.urls import path

from .views import chat_view, dashboard_view, home_view, timer_view

urlpatterns = [
    path("", home_view, name="home"),
    path("dashboard/", dashboard_view, name="dashboard"),
    path("timer/", timer_view, name="timer"),
    path("chat/", chat_view, name="chat"),
]

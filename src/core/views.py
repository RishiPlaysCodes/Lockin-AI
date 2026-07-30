"""
Template views for the web frontend.

Authentication is handled client-side via JWT tokens stored in the browser.
Each page's JavaScript checks for a token and redirects to the login page
(home) if missing, so these views themselves are public.
"""

from django.shortcuts import render


def home_view(request):
    """Render the landing/login/signup page."""
    return render(request, "core/home.html")


def dashboard_view(request):
    """Render the user dashboard page."""
    return render(request, "core/dashboard.html")


def timer_view(request):
    """Render the focus timer page."""
    return render(request, "core/timer.html")


def chat_view(request):
    """Render the AI teacher chat page."""
    return render(request, "core/chat.html")

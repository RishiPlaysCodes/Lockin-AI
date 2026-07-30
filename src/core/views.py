"""
Template views for the legacy frontend.
These serve the HTML templates for dashboard, timer, and chat.
"""

from django.contrib.auth.decorators import login_required
from django.shortcuts import render


@login_required
def dashboard_view(request):
    """Render the user dashboard page."""
    return render(request, "core/dashboard.html")


@login_required
def timer_view(request):
    """Render the focus timer page."""
    return render(request, "core/timer.html")


@login_required
def chat_view(request):
    """Render the AI teacher chat page."""
    return render(request, "core/chat.html")

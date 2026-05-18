"""
Business logic services for Focus Guardian AI.
Handles badge awarding, score calculation, and AI integration.
"""

import os
from datetime import timedelta
from django.utils import timezone
from .models import Badge, UserProfile, FocusSession, StudyLog


def check_and_award_badges(user):
    """Check if user qualifies for any new badges and award them."""
    profile = UserProfile.objects.get(user=user)
    awarded = []

    # First session badge
    if FocusSession.objects.filter(user=user, is_active=False).exists():
        badge, created = Badge.objects.get_or_create(
            user=user, badge_type="first_session"
        )
        if created:
            awarded.append(badge)

    # Streak badges
    if profile.streak_days >= 3:
        badge, created = Badge.objects.get_or_create(user=user, badge_type="streak_3")
        if created:
            awarded.append(badge)

    if profile.streak_days >= 7:
        badge, created = Badge.objects.get_or_create(user=user, badge_type="streak_7")
        if created:
            awarded.append(badge)

    if profile.streak_days >= 30:
        badge, created = Badge.objects.get_or_create(user=user, badge_type="streak_30")
        if created:
            awarded.append(badge)

    # Hours badges
    hours = profile.total_study_hours
    if hours >= 5:
        badge, created = Badge.objects.get_or_create(user=user, badge_type="hours_5")
        if created:
            awarded.append(badge)

    if hours >= 20:
        badge, created = Badge.objects.get_or_create(user=user, badge_type="hours_20")
        if created:
            awarded.append(badge)

    if hours >= 50:
        badge, created = Badge.objects.get_or_create(user=user, badge_type="hours_50")
        if created:
            awarded.append(badge)

    if hours >= 100:
        badge, created = Badge.objects.get_or_create(user=user, badge_type="hours_100")
        if created:
            awarded.append(badge)

    # Focus master badge
    if profile.focus_score >= 100:
        badge, created = Badge.objects.get_or_create(
            user=user, badge_type="focus_master"
        )
        if created:
            awarded.append(badge)

    # Zero distraction session badge
    zero_distraction_sessions = FocusSession.objects.filter(
        user=user, is_active=False
    ).exclude(distractions__isnull=False)
    # Check for sessions with no distractions and at least 15 min duration
    for session in FocusSession.objects.filter(user=user, is_active=False):
        if session.distractions.count() == 0 and session.duration_minutes >= 15:
            badge, created = Badge.objects.get_or_create(
                user=user, badge_type="no_distraction"
            )
            if created:
                awarded.append(badge)
            break

    return awarded


def update_streak(user):
    """Update the user's study streak."""
    profile = UserProfile.objects.get(user=user)
    today = timezone.now().date()

    if profile.last_study_date is None:
        profile.streak_days = 1
    elif profile.last_study_date == today:
        # Already studied today, no change
        return profile.streak_days
    elif profile.last_study_date == today - timedelta(days=1):
        # Continued streak
        profile.streak_days += 1
    else:
        # Streak broken
        profile.streak_days = 1

    profile.last_study_date = today
    profile.save()
    return profile.streak_days


def calculate_session_score(session):
    """Calculate focus score for a completed session."""
    if not session.end_time:
        return 100

    duration_minutes = session.duration_minutes
    distraction_count = session.distraction_count

    # Base score
    score = 100

    # Penalize for distractions (-5 per distraction)
    score -= distraction_count * 5

    # Bonus for completing planned duration
    if duration_minutes >= session.planned_duration:
        score += 10

    # Cap between 0 and 100
    return max(0, min(100, score))


def update_study_log(session):
    """Update or create daily study log after session ends."""
    if not session.end_time:
        return None

    today = session.end_time.date()
    log, created = StudyLog.objects.get_or_create(
        user=session.user,
        date=today,
        subject=session.subject,
        defaults={
            "duration_minutes": 0,
            "sessions_count": 0,
            "distractions_count": 0,
            "focus_score": 100,
        },
    )

    log.duration_minutes += int(session.duration_minutes)
    log.sessions_count += 1
    log.distractions_count += session.distraction_count
    log.focus_score = calculate_session_score(session)
    log.save()

    return log


def get_ai_response(user_message, user, chat_history=None):
    """Get AI response from OpenAI API or return mock response."""
    api_key = os.getenv("OPENAI_API_KEY", "")

    if not api_key:
        # Mock response when API key not configured
        mock_responses = {
            "help": "I'm your Focus Guardian AI Teacher! I can help you with:\n\n"
                    "1. Explaining difficult concepts\n"
                    "2. Creating study plans\n"
                    "3. Providing focus tips\n"
                    "4. Answering academic questions\n"
                    "5. Motivating you during study sessions\n\n"
                    "What would you like help with?",
            "focus": "Here are some focus tips:\n\n"
                     "1. Use the Pomodoro technique (25 min focus, 5 min break)\n"
                     "2. Remove all distractions from your workspace\n"
                     "3. Set clear goals before each session\n"
                     "4. Stay hydrated and take regular breaks\n"
                     "5. Use the blocking feature to avoid tempting websites",
        }

        # Simple keyword matching for mock
        message_lower = user_message.lower()
        if any(word in message_lower for word in ["focus", "concentrate", "distract"]):
            return mock_responses["focus"]

        return (
            f"I'm your Focus Guardian AI Teacher. You asked: '{user_message}'\n\n"
            f"I'd love to help you with that! Keep up the great work with your studies. "
            f"(Note: Configure OPENAI_API_KEY in .env for full AI responses.)"
        )

    try:
        import openai

        client = openai.OpenAI(api_key=api_key)

        messages = [
            {
                "role": "system",
                "content": (
                    "You are Focus Guardian AI, a helpful study assistant and teacher. "
                    "Your goals are to:\n"
                    "1. Help students stay focused and motivated\n"
                    "2. Explain concepts clearly and concisely\n"
                    "3. Provide study tips and strategies\n"
                    "4. Answer academic questions across all subjects\n"
                    "5. Identify mistakes in student explanations and correct them\n"
                    "6. Encourage disciplined study habits\n\n"
                    "Be encouraging but honest. Keep responses helpful and concise."
                ),
            }
        ]

        # Add recent chat history for context
        if chat_history:
            for msg in chat_history[-10:]:  # Last 10 messages
                messages.append({"role": msg.role, "content": msg.content})

        messages.append({"role": "user", "content": user_message})

        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=messages,
            max_tokens=500,
            temperature=0.7,
        )
        return response.choices[0].message.content

    except Exception as e:
        return f"I'm having trouble connecting right now. Error: {str(e)}. Please try again later."

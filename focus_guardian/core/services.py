"""
Business logic services for Focus Guardian AI.
Handles badge awarding, score calculation, AI integration, analytics, and utilities.
"""

import os
import random
import logging
from datetime import timedelta
from django.utils import timezone
from django.db.models import Sum, Count, Avg
from .models import Badge, UserProfile, FocusSession, StudyLog, Distraction, DailyQuote

logger = logging.getLogger(__name__)


# ============================================================
# Motivational Quotes
# ============================================================

BUILT_IN_QUOTES = [
    {"quote": "The secret of getting ahead is getting started.", "author": "Mark Twain"},
    {"quote": "It's not that I'm so smart, it's just that I stay with problems longer.", "author": "Albert Einstein"},
    {"quote": "Focus is the art of knowing what to ignore.", "author": "James Clear"},
    {"quote": "The successful warrior is the average man, with laser-like focus.", "author": "Bruce Lee"},
    {"quote": "Concentrate all your thoughts upon the work at hand.", "author": "Alexander Graham Bell"},
    {"quote": "Where focus goes, energy flows.", "author": "Tony Robbins"},
    {"quote": "You don't have to be great to start, but you have to start to be great.", "author": "Zig Ziglar"},
    {"quote": "The only way to do great work is to love what you do.", "author": "Steve Jobs"},
    {"quote": "Success is the sum of small efforts repeated day in and day out.", "author": "Robert Collier"},
    {"quote": "Discipline is the bridge between goals and accomplishment.", "author": "Jim Rohn"},
    {"quote": "Your future is created by what you do today, not tomorrow.", "author": "Robert Kiyosaki"},
    {"quote": "Don't watch the clock; do what it does. Keep going.", "author": "Sam Levenson"},
    {"quote": "The harder you work for something, the greater you'll feel when you achieve it.", "author": "Unknown"},
    {"quote": "Push yourself, because no one else is going to do it for you.", "author": "Unknown"},
    {"quote": "Great things never come from comfort zones.", "author": "Unknown"},
    {"quote": "Dream it. Wish it. Do it.", "author": "Unknown"},
    {"quote": "Stay focused, go after your dreams and keep moving toward your goals.", "author": "LL Cool J"},
    {"quote": "Education is the most powerful weapon which you can use to change the world.", "author": "Nelson Mandela"},
    {"quote": "The mind is everything. What you think you become.", "author": "Buddha"},
    {"quote": "It does not matter how slowly you go as long as you do not stop.", "author": "Confucius"},
    {"quote": "Believe you can and you're halfway there.", "author": "Theodore Roosevelt"},
    {"quote": "Start where you are. Use what you have. Do what you can.", "author": "Arthur Ashe"},
    {"quote": "A little progress each day adds up to big results.", "author": "Satya Nani"},
    {"quote": "The expert in anything was once a beginner.", "author": "Helen Hayes"},
    {"quote": "Consistency is what transforms average into excellence.", "author": "Unknown"},
]


def get_motivational_quote():
    """Get a random motivational quote."""
    try:
        db_quotes = DailyQuote.objects.all()
        if db_quotes.exists():
            quote_obj = db_quotes.order_by("?").first()
            return {"quote": quote_obj.quote, "author": quote_obj.author}
    except Exception:
        pass
    return random.choice(BUILT_IN_QUOTES)


# ============================================================
# Badge System
# ============================================================


def check_and_award_badges(user):
    """Comprehensive badge checking and awarding system."""
    profile = UserProfile.objects.get(user=user)
    awarded = []

    def try_award(badge_type):
        badge, created = Badge.objects.get_or_create(user=user, badge_type=badge_type)
        if created:
            awarded.append(badge)
            return True
        return False

    # === First Session ===
    completed_sessions = FocusSession.objects.filter(user=user, is_active=False)
    if completed_sessions.exists():
        try_award("first_session")

    # === Streak Badges ===
    streak = profile.streak_days
    if streak >= 3:
        try_award("streak_3")
    if streak >= 7:
        try_award("streak_7")
    if streak >= 14:
        try_award("streak_14")
    if streak >= 30:
        try_award("streak_30")
    if streak >= 60:
        try_award("streak_60")
    if streak >= 100:
        try_award("streak_100")

    # === Hours Badges ===
    hours = profile.total_study_hours
    if hours >= 1:
        try_award("hours_1")
    if hours >= 5:
        try_award("hours_5")
    if hours >= 10:
        try_award("hours_10")
    if hours >= 20:
        try_award("hours_20")
    if hours >= 50:
        try_award("hours_50")
    if hours >= 100:
        try_award("hours_100")
    if hours >= 200:
        try_award("hours_200")

    # === Focus Master (score == 100) ===
    if profile.focus_score >= 100:
        try_award("focus_master")

    # === Zero Distraction Session (15+ min, 0 distractions) ===
    for session in completed_sessions.filter(is_completed=True)[:20]:
        if session.distractions.count() == 0 and session.duration_minutes >= 15:
            try_award("no_distraction")
            break

    # === 5 Perfect Sessions ===
    perfect_count = 0
    for session in completed_sessions[:50]:
        if session.distractions.count() == 0 and session.duration_minutes >= 15:
            perfect_count += 1
    if perfect_count >= 5:
        try_award("no_distraction_5")

    # === Early Bird (session started before 6 AM) ===
    early_sessions = completed_sessions.filter(start_time__hour__lt=6)
    if early_sessions.exists():
        try_award("early_bird")

    # === Night Owl (session started after 11 PM) ===
    night_sessions = completed_sessions.filter(start_time__hour__gte=23)
    if night_sessions.exists():
        try_award("night_owl")

    # === Marathon (90+ min session without stopping) ===
    for session in completed_sessions:
        if session.duration_minutes >= 90 and session.is_completed:
            try_award("marathon")
            break

    # === Consistent (5+ sessions in one day) ===
    today = timezone.now().date()
    today_count = completed_sessions.filter(start_time__date=today).count()
    if today_count >= 5:
        try_award("consistent")

    # === Comeback Kid (return after 3+ days break) ===
    if profile.last_study_date and profile.streak_days == 1:
        # Check if there was a gap before
        recent_sessions = completed_sessions.order_by("-start_time")[:2]
        if recent_sessions.count() >= 2:
            sessions_list = list(recent_sessions)
            if sessions_list[0].start_time and sessions_list[1].end_time:
                gap = sessions_list[0].start_time.date() - sessions_list[1].end_time.date()
                if gap.days >= 3:
                    try_award("comeback")

    # === Speed Learner (3 sessions in under 2 hours) ===
    two_hours_ago = timezone.now() - timedelta(hours=2)
    recent_quick = completed_sessions.filter(start_time__gte=two_hours_ago)
    if recent_quick.count() >= 3:
        try_award("speed_learner")

    # === Deep Thinker (60+ min on single subject in one session) ===
    for session in completed_sessions:
        if session.duration_minutes >= 60 and session.is_completed:
            try_award("deep_thinker")
            break

    return awarded


# ============================================================
# Streak Management
# ============================================================


def update_streak(user):
    """Update the user's study streak with longest streak tracking."""
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
        # Streak broken - reset
        profile.streak_days = 1

    # Track longest streak
    if profile.streak_days > profile.longest_streak:
        profile.longest_streak = profile.streak_days

    profile.last_study_date = today
    profile.save()
    return profile.streak_days


# ============================================================
# Score Calculation
# ============================================================


def calculate_session_score(session):
    """Calculate focus score for a completed session. Returns 0-100."""
    if not session.end_time:
        return 100

    duration_minutes = session.duration_minutes
    distractions = session.distractions.all()
    distraction_count = distractions.count()

    # Base score
    score = 100.0

    # Penalty for each distraction based on severity
    for d in distractions:
        if d.severity == "high":
            score -= 10
        elif d.severity == "medium":
            score -= 5
        else:
            score -= 3

    # Bonus for completing planned duration
    if duration_minutes >= session.planned_duration:
        score += 10
    elif duration_minutes >= session.planned_duration * 0.75:
        score += 5

    # Bonus for long uninterrupted focus (no distractions for 30+ min)
    if distraction_count == 0 and duration_minutes >= 30:
        score += 5

    # Slight penalty for very short sessions (< 5 min)
    if duration_minutes < 5:
        score -= 10

    # Cap between 0 and 100
    return max(0, min(100, int(round(score))))


# ============================================================
# Study Log Management
# ============================================================


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
    
    if session.mood_after:
        log.mood = session.mood_after
    
    log.save()
    return log


# ============================================================
# Analytics & Chart Data
# ============================================================


def get_weekly_chart_data(user, days=7):
    """Get daily study minutes for the last N days (for Chart.js)."""
    data = {"labels": [], "study_minutes": [], "distractions": [], "scores": []}
    
    for i in range(days - 1, -1, -1):  # Oldest to newest
        date = (timezone.now() - timedelta(days=i)).date()
        day_sessions = FocusSession.objects.filter(
            user=user, start_time__date=date, is_active=False
        )
        day_minutes = sum(s.duration_minutes for s in day_sessions)
        day_distractions = Distraction.objects.filter(
            session__user=user, session__start_time__date=date
        ).count()
        
        # Average score for the day
        logs = StudyLog.objects.filter(user=user, date=date)
        avg_score = logs.aggregate(avg=Avg("focus_score"))["avg"] or 0

        data["labels"].append(date.strftime("%a"))
        data["study_minutes"].append(round(day_minutes, 1))
        data["distractions"].append(day_distractions)
        data["scores"].append(round(avg_score, 1))

    return data


def get_subject_distribution(user, days=7):
    """Get subject-wise time distribution for pie/doughnut chart."""
    start_date = timezone.now() - timedelta(days=days)
    logs = StudyLog.objects.filter(
        user=user, date__gte=start_date.date()
    ).values("subject").annotate(
        total_min=Sum("duration_minutes")
    ).order_by("-total_min")[:8]  # Top 8 subjects

    colors = [
        "#6c63ff", "#4ecdc4", "#ff6b6b", "#feca57",
        "#a855f7", "#06d6a0", "#ff9f43", "#54a0ff"
    ]

    data = {"labels": [], "values": [], "colors": []}
    for i, log in enumerate(logs):
        data["labels"].append(log["subject"])
        data["values"].append(log["total_min"])
        data["colors"].append(colors[i % len(colors)])

    return data


# ============================================================
# AI Teacher Integration
# ============================================================


# Comprehensive mock responses by mode and topic
MOCK_RESPONSES = {
    "general": {
        "default": (
            "I'm your Focus Guardian AI Teacher! I can help you with:\n\n"
            "**Study Help:**\n"
            "- Explain difficult concepts in simple language\n"
            "- Create study plans and schedules\n"
            "- Generate practice questions and quizzes\n\n"
            "**Focus & Productivity:**\n"
            "- Personalized focus tips based on your patterns\n"
            "- Pomodoro technique guidance\n"
            "- Motivation and accountability\n\n"
            "**Academic Support:**\n"
            "- Help with any subject (Math, Science, Languages, etc.)\n"
            "- Check your understanding of topics\n"
            "- Provide study resources and strategies\n\n"
            "What would you like help with today?"
        ),
        "focus": (
            "Here are some proven focus strategies:\n\n"
            "**1. The 2-Minute Rule:**\n"
            "If you find yourself wanting to check social media, tell yourself 'just 2 more minutes of focus.' "
            "Usually, you'll get back into flow.\n\n"
            "**2. Environment Design:**\n"
            "- Put your phone in another room\n"
            "- Use website blockers (check the Blocking tab!)\n"
            "- Clear your desk of distractions\n"
            "- Use noise-canceling headphones\n\n"
            "**3. The Pomodoro Technique:**\n"
            "- 25 min focused work\n"
            "- 5 min break\n"
            "- After 4 rounds, take a 15-30 min break\n\n"
            "**4. Body Doubling:**\n"
            "Study with a friend (even virtually) - accountability helps!\n\n"
            "**5. Start Small:**\n"
            "Commit to just 5 minutes. Often that's all it takes to get into flow."
        ),
        "motivation": (
            "You've got this! Here's your motivation boost:\n\n"
            "**Remember WHY you started:**\n"
            "Think about your goals. Every minute you study brings you closer.\n\n"
            "**Progress over perfection:**\n"
            "You don't need a perfect study session. Even 15 focused minutes is better than 0.\n\n"
            "**The compound effect:**\n"
            "1 hour daily = 365 hours/year = that's like 9 full work weeks of focused learning!\n\n"
            "**Your stats don't lie:**\n"
            "Look at your dashboard - every session you've completed was you showing up for yourself.\n\n"
            "Now take a deep breath, set your timer, and let's get after it! What subject shall we tackle?"
        ),
        "study_plan": (
            "Let me help you create an effective study plan!\n\n"
            "**The ideal study session structure:**\n\n"
            "1. **Warm-up (5 min):** Review what you learned last time\n"
            "2. **Deep Work (25-45 min):** Focus on new/challenging material\n"
            "3. **Active Recall (10 min):** Test yourself without looking at notes\n"
            "4. **Break (5-10 min):** Walk, stretch, hydrate\n"
            "5. **Review (5 min):** Quick summary of what you learned\n\n"
            "**Weekly structure suggestion:**\n"
            "- Mon-Fri: 2-3 focused sessions per day\n"
            "- Saturday: Review week's material + practice problems\n"
            "- Sunday: Light review + plan next week\n\n"
            "Would you like me to help you plan for a specific subject or exam?"
        ),
    },
    "teacher": {
        "default": (
            "I'm in Teacher Mode! I'll act as your personal tutor.\n\n"
            "I can:\n"
            "- Explain any concept step by step\n"
            "- Check if your understanding is correct\n"
            "- Point out mistakes and misconceptions\n"
            "- Give you practice problems\n"
            "- Simplify complex topics\n\n"
            "Try explaining a concept to me, and I'll tell you if you've got it right. "
            "Or ask me to explain something you're struggling with!"
        ),
    },
    "quiz": {
        "default": (
            "Quiz Mode activated! I'll test your knowledge.\n\n"
            "Tell me:\n"
            "1. What subject/topic?\n"
            "2. Difficulty level (Easy/Medium/Hard)?\n"
            "3. How many questions?\n\n"
            "I'll generate questions and check your answers. Let's see what you know!"
        ),
    },
    "study_plan": {
        "default": (
            "Study Plan Mode! Let me help you organize.\n\n"
            "To create your personalized plan, tell me:\n"
            "1. What subjects are you studying?\n"
            "2. Any upcoming exams or deadlines?\n"
            "3. How many hours per day can you study?\n"
            "4. Which subjects do you find hardest?\n\n"
            "I'll create a balanced, realistic study schedule for you!"
        ),
    },
    "motivation": {
        "default": (
            "Motivation Mode activated! I'm your hype squad.\n\n"
            "Remember: **You're already ahead** of most people just by being here and wanting to improve.\n\n"
            "Every expert was once a beginner. Every master was once a disaster. "
            "The difference? They kept showing up.\n\n"
            "You showed up today. That counts. Now let's make it count even more.\n\n"
            "What's your biggest challenge right now? Let me help you push through it!"
        ),
    },
}


def get_ai_response(user_message, user, chat_history=None, mode="general"):
    """Get AI response - tries OpenAI first, falls back to smart mock responses."""
    api_key = os.getenv("OPENAI_API_KEY", "")

    if api_key:
        response = _get_openai_response(user_message, user, chat_history, mode, api_key)
        if response:
            return response

    # Smart mock response system
    return _get_mock_response(user_message, mode)


def _get_openai_response(user_message, user, chat_history, mode, api_key):
    """Try to get response from OpenAI."""
    try:
        import openai
        client = openai.OpenAI(api_key=api_key)

        system_prompts = {
            "general": (
                "You are Focus Guardian AI, a helpful study assistant. "
                "Help students stay focused, explain concepts clearly, provide study tips, "
                "answer academic questions, and encourage disciplined study habits. "
                "Be encouraging, concise, and use markdown formatting."
            ),
            "teacher": (
                "You are Focus Guardian AI in Teacher Mode. Act as a strict but caring teacher. "
                "When students explain concepts, check for accuracy and correct mistakes. "
                "Ask probing questions. Give clear explanations with examples. "
                "Use the Socratic method when appropriate."
            ),
            "quiz": (
                "You are Focus Guardian AI in Quiz Mode. Generate questions based on the topic "
                "the student mentions. Vary difficulty. After they answer, provide detailed "
                "feedback explaining why answers are correct or incorrect. Keep score."
            ),
            "study_plan": (
                "You are Focus Guardian AI in Study Plan Mode. Help create effective, "
                "realistic study schedules. Consider spaced repetition, active recall, "
                "and interleaving. Ask about their goals, available time, and subjects."
            ),
            "motivation": (
                "You are Focus Guardian AI in Motivation Mode. Be an encouraging coach. "
                "Provide motivational messages, remind them of their progress, share "
                "productivity tips, and help them overcome procrastination. Be energetic!"
            ),
        }

        system_content = system_prompts.get(mode, system_prompts["general"])
        
        # Add user context
        profile = UserProfile.objects.get(user=user)
        system_content += (
            f"\n\nUser context: {user.username}, Level: {profile.level}, "
            f"Streak: {profile.streak_days} days, Focus Score: {profile.focus_score}/100, "
            f"Total Study: {profile.total_study_hours}h"
        )

        messages = [{"role": "system", "content": system_content}]

        if chat_history:
            for msg in chat_history[-10:]:
                if msg.role in ("user", "assistant"):
                    messages.append({"role": msg.role, "content": msg.content})

        messages.append({"role": "user", "content": user_message})

        response = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=messages,
            max_tokens=800,
            temperature=0.7,
        )
        return response.choices[0].message.content

    except Exception as e:
        logger.warning(f"OpenAI API error: {e}")
        return None


def _get_mock_response(user_message, mode="general"):
    """Smart mock response based on keywords and mode."""
    message_lower = user_message.lower()

    # Check mode-specific responses first
    mode_responses = MOCK_RESPONSES.get(mode, MOCK_RESPONSES["general"])

    # Keyword-based matching for general mode
    if mode == "general":
        focus_keywords = ["focus", "concentrate", "distract", "attention", "procrastin"]
        motivation_keywords = ["motivat", "tired", "give up", "can't", "hard", "difficult", "stressed", "lazy"]
        plan_keywords = ["plan", "schedule", "organize", "routine", "timetable"]
        help_keywords = ["help", "what can you", "how to use", "features"]
        
        if any(kw in message_lower for kw in focus_keywords):
            return mode_responses.get("focus", mode_responses["default"])
        elif any(kw in message_lower for kw in motivation_keywords):
            return mode_responses.get("motivation", mode_responses["default"])
        elif any(kw in message_lower for kw in plan_keywords):
            return mode_responses.get("study_plan", mode_responses["default"])
        elif any(kw in message_lower for kw in help_keywords):
            return mode_responses["default"]

    # Math/Science questions
    if any(kw in message_lower for kw in ["math", "equation", "formula", "calculate", "solve"]):
        return (
            "Great question about math! Here's how I'd approach this:\n\n"
            "**Step 1:** Identify what type of problem this is\n"
            "**Step 2:** Write down what you know and what you need to find\n"
            "**Step 3:** Apply the relevant formula or method\n"
            "**Step 4:** Check your answer\n\n"
            "Could you share the specific problem? I'll walk you through it step by step!\n\n"
            "*Note: For full AI-powered explanations, configure your OPENAI_API_KEY in the .env file.*"
        )

    if any(kw in message_lower for kw in ["physics", "chemistry", "biology", "science"]):
        return (
            "Science questions are my favorite! Here's my approach:\n\n"
            "**For understanding concepts:**\n"
            "1. Start with the basic definition\n"
            "2. Understand the 'why' behind it\n"
            "3. Connect it to real-world examples\n"
            "4. Practice with problems\n\n"
            "Tell me the specific topic or concept you need help with, "
            "and I'll break it down for you!\n\n"
            "*Note: For full AI-powered explanations, configure your OPENAI_API_KEY in the .env file.*"
        )

    # Greeting
    if any(kw in message_lower for kw in ["hello", "hi", "hey", "good morning", "good evening"]):
        greetings = [
            "Hey there! Ready to crush some study goals today? What can I help you with?",
            "Hello! Great to see you here. What subject shall we tackle?",
            "Hi! I'm your AI study buddy. Ready when you are - what's on the agenda?",
        ]
        return random.choice(greetings)

    # Thank you
    if any(kw in message_lower for kw in ["thank", "thanks", "thx"]):
        return (
            "You're welcome! Keep up the great work with your studies. "
            "Remember, consistency beats intensity. See you at the next session! "
        )

    # Default response for the mode
    return mode_responses.get("default", MOCK_RESPONSES["general"]["default"])

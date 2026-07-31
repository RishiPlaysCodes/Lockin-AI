# Focus Guardian AI

AI-Powered Focus, Study Discipline, and Digital Distraction Management System.

## Features (Phase 1 MVP)

- **User Authentication** - Login/Signup with secure password handling
- **Focus Timer** - Configurable Pomodoro-style timer with subject tracking
- **Dashboard** - Stats overview with focus score, study time, streaks, and badges
- **Study Tracking** - Daily study logs, session history, and progress analytics
- **App/Site Blocking** - Simulated blocking list management during focus mode
- **AI Chatbot** - GPT-powered study assistant for doubts, notes, and study help
- **Focus Scoring** - Dynamic scoring based on session quality and distractions
- **Badges & Achievements** - Gamification with streak, hours, and special badges
- **Study Reports** - Daily/weekly analytics with subject breakdown
- **Distraction Detection** - Tab switch detection and manual distraction logging

## Tech Stack

- **Backend**: Django 4.2 + Django REST Framework
- **Database**: SQLite (development) / PostgreSQL (production)
- **Frontend**: Bootstrap 5 + Vanilla JavaScript
- **AI**: OpenAI GPT-3.5-turbo (with mock fallback)
- **Styling**: Custom dark theme with gradient accents

## Setup

```bash
# Clone the repository
git clone https://github.com/RishiPlaysCodes/Lockin-AI.git
cd Lockin-AI/focus_guardian

# Create virtual environment
python -m venv venv
source venv/bin/activate  # Linux/Mac
# venv\Scripts\activate   # Windows

# Install dependencies
pip install -r requirements.txt

# Create .env file
cp .env.example .env
# Edit .env with your settings (optional: add OPENAI_API_KEY)

# Run migrations
python manage.py makemigrations
python manage.py migrate

# Create superuser (optional)
python manage.py createsuperuser

# Run development server
python manage.py runserver
```

## Project Structure

```
focus_guardian/
├── manage.py
├── requirements.txt
├── .env.example
├── .gitignore
├── README.md
├── focus_guardian/          # Django project settings
│   ├── settings.py
│   ├── urls.py
│   ├── wsgi.py
│   └── asgi.py
└── core/                   # Main application
    ├── models.py           # UserProfile, FocusSession, Distraction, BlockedSite, StudyLog, Badge, ChatMessage
    ├── views.py            # Template views + API endpoints
    ├── urls.py             # URL routing
    ├── forms.py            # Django forms for signup & blocking
    ├── serializers.py      # DRF serializers
    ├── services.py         # Business logic (badges, scoring, AI)
    ├── signals.py          # Auto-create UserProfile on signup
    ├── admin.py            # Django admin configuration
    ├── templatetags/       # Custom template filters
    └── templates/          # HTML templates
        ├── core/           # App pages (dashboard, timer, chat, reports, blocking, badges)
        └── registration/   # Auth pages (login, signup)
```

## Pages

| Page | URL | Description |
|------|-----|-------------|
| Landing | `/` | Welcome page with features overview |
| Login | `/login/` | User login |
| Signup | `/signup/` | User registration |
| Dashboard | `/dashboard/` | Main stats & overview |
| Focus Timer | `/timer/` | Start/manage focus sessions |
| AI Teacher | `/chat/` | Chat with AI study assistant |
| Reports | `/reports/` | Study analytics & reports |
| Blocking | `/blocking/` | Manage blocked sites |
| Badges | `/badges/` | View achievements |

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/profile/` | Get user profile data |
| POST | `/api/session/start/` | Start a focus session |
| POST | `/api/session/end/` | End active session |
| POST | `/api/distraction/` | Log a distraction |
| GET | `/api/report/` | Get study report |
| POST | `/api/ai-teacher/` | Send message to AI |
| POST | `/api/chat/clear/` | Clear chat history |
| POST | `/api/blocked-site/<id>/toggle/` | Toggle blocked site |
| DELETE | `/api/blocked-site/<id>/delete/` | Delete blocked site |

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DJANGO_SECRET_KEY` | Django secret key | Dev key (change in production) |
| `DJANGO_DEBUG` | Debug mode | `True` |
| `OPENAI_API_KEY` | OpenAI API key for AI features | Empty (uses mock responses) |

## Future Phases

- **Phase 2**: Full GPT integration, AI teacher mode, advanced scoring
- **Phase 3**: Mobile app, background monitoring, real app blocking
- **Phase 4**: Group study rooms, video/audio, camera-based focus detection

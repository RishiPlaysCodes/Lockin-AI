# Focus Guardian AI (LockIn AI)

**Enterprise-grade focus & study session tracking with AI-powered coaching.**

Focus Guardian AI helps students and professionals stay focused during study/work sessions by tracking distractions, providing AI-powered coaching, and generating insights about focus patterns.

---

## Features

- **JWT Authentication** - Secure token-based authentication with refresh tokens
- **Focus Sessions** - Start, track, and analyze study/work sessions (Pomodoro, Short, Long, Custom)
- **Distraction Tracking** - Automatic and manual distraction logging with focus score impact
- **AI Teacher** - OpenAI-powered study companion for explanations, tips, and motivation
- **Study Reports** - Detailed analytics on sessions, distractions, and streaks
- **Health Monitoring** - Built-in health check endpoints for infrastructure monitoring
- **API Documentation** - Auto-generated OpenAPI/Swagger docs at `/api/docs/`

---

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Backend | Django 5.1+ / Django REST Framework |
| Authentication | JWT (Simple JWT) |
| Database | PostgreSQL 16 (SQLite for dev) |
| Cache | Redis 7 |
| AI | OpenAI GPT-4o-mini |
| API Docs | drf-spectacular (OpenAPI 3.0) |
| Deployment | Google Cloud Run (Free Tier) |
| CI/CD | GitHub Actions |
| Monitoring | django-health-check, structured JSON logging |

---

## Quick Start (VS Code)

> **Full detailed guide with screenshots:** [docs/LOCAL_SETUP.md](docs/LOCAL_SETUP.md)

```bash
# 1. Clone
git clone https://github.com/RishiPlaysCodes/Lockin-AI.git
cd Lockin-AI

# 2. Virtual Environment
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 3. Install
pip install -r requirements/development.txt

# 4. Configure
cp .env.example .env
# Edit .env file (DJANGO_SETTINGS_MODULE=focus_guardian.settings.development)

# 5. Migrate & Seed
cd src
python manage.py migrate
python manage.py seed_data   # Creates demo user: demo / DemoPass123!
python manage.py createsuperuser

# 6. Run
python manage.py runserver
```

Then open:
- **API Docs:** http://127.0.0.1:8000/api/docs/
- **Admin:** http://127.0.0.1:8000/admin/
- **Health:** http://127.0.0.1:8000/health/

---

## Running Tests

```bash
# All tests
pytest

# With coverage
pytest --cov=core --cov-report=term-missing

# Specific tests
pytest tests/core/test_api.py -v
pytest tests/integration/test_workflows.py -v
```

---

## Deploy to Google Cloud (FREE)

> **Full step-by-step guide:** [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)

Google Cloud Run **Always Free Tier** gives you:
- 2 Million requests/month
- 180,000 vCPU-seconds
- 360,000 GiB-seconds memory

**Quick Deploy:**
```bash
# Install gcloud CLI, then:
gcloud init
gcloud services enable run.googleapis.com cloudbuild.googleapis.com

gcloud run deploy focus-guardian \
  --source=. \
  --region=us-central1 \
  --allow-unauthenticated \
  --memory=512Mi \
  --set-env-vars="DJANGO_SETTINGS_MODULE=focus_guardian.settings.production"
```

Your app will be live at `https://focus-guardian-xxxxx-uc.a.run.app`

---

## Test on Phone

1. Run `python manage.py runserver 0.0.0.0:8000`
2. Find your PC's IP (e.g., `192.168.1.5`)
3. On phone: open `http://192.168.1.5:8000/api/docs/`

---

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/auth/register/` | Register new user |
| POST | `/api/v1/auth/token/` | Get JWT tokens (login) |
| POST | `/api/v1/auth/token/refresh/` | Refresh access token |
| POST | `/api/v1/auth/logout/` | Logout (blacklist token) |
| GET | `/api/v1/profile/` | Get user profile |
| PATCH | `/api/v1/profile/` | Update profile settings |
| POST | `/api/v1/sessions/start/` | Start focus session |
| POST | `/api/v1/sessions/end/` | End active session |
| GET | `/api/v1/sessions/` | List all sessions |
| POST | `/api/v1/distractions/` | Log distraction |
| GET | `/api/v1/reports/study/` | Get study report |
| GET | `/api/v1/reports/stats/` | Get user statistics |
| POST | `/api/v1/ai-teacher/` | Chat with AI teacher |

---

## Project Structure

```
Lockin-AI/
├── src/                          # Application source code
│   ├── manage.py                 # Django management script
│   ├── focus_guardian/           # Project configuration
│   │   └── settings/            # Environment-specific settings
│   │       ├── base.py          # Shared settings
│   │       ├── development.py   # Dev (SQLite, DEBUG=True)
│   │       ├── production.py    # Production (PostgreSQL, security)
│   │       └── testing.py       # Test (in-memory SQLite, fast)
│   └── core/                    # Main application
│       ├── api/v1/              # API views and URL routing
│       ├── services/            # Business logic (session, AI)
│       ├── exceptions/          # Custom error handling
│       ├── middleware/          # Request logging, JSON formatter
│       ├── management/commands/ # seed_data command
│       ├── models.py            # Data models
│       ├── serializers.py       # API serializers
│       └── admin.py             # Admin panel config
├── tests/                       # Test suite (40+ tests)
├── docs/                        # Documentation
│   ├── LOCAL_SETUP.md           # VS Code testing guide
│   └── DEPLOYMENT.md            # Google Cloud deployment guide
├── config/nginx/                # Nginx config (Docker deploy)
├── requirements/                # Dependencies (base/dev/prod)
├── Dockerfile                   # Production container
├── docker-compose.yml           # Full stack (Docker)
├── Makefile                     # Developer commands
├── pyproject.toml               # Linting/testing config
└── .github/workflows/ci.yml    # CI/CD pipeline
```

---

## Using Makefile

```bash
make help           # Show all commands
make install        # Install dependencies
make dev            # Start dev server
make test           # Run tests
make test-cov       # Tests with coverage
make lint           # Run linters
make format         # Auto-format code
make migrate        # Run migrations
make docker-up      # Start with Docker
```

---

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Run tests (`pytest`)
4. Commit your changes
5. Push and open a Pull Request

---

## License

This project is private. All rights reserved.

---

Built with Django + DRF + OpenAI | Deployed on Google Cloud Run

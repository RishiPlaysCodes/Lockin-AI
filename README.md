# Focus Guardian AI

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
- **API Documentation** - Auto-generated OpenAPI/Swagger docs

---

## Tech Stack

| Component | Technology |
|-----------|-----------|
| Backend | Django 5.1+ / Django REST Framework |
| Authentication | JWT (Simple JWT) |
| Database | PostgreSQL 16 |
| Cache | Redis 7 |
| AI | OpenAI GPT-4o-mini |
| API Docs | drf-spectacular (OpenAPI 3.0) |
| Deployment | Docker, Docker Compose, Gunicorn, Nginx |
| CI/CD | GitHub Actions |
| Monitoring | django-health-check, structured JSON logging |

---

## Quick Start

### Prerequisites

- Python 3.11+
- PostgreSQL 16+ (or SQLite for development)
- Redis 7+ (optional for development)
- OpenAI API key (optional - works with mock responses)

### Local Development

```bash
# Clone the repository
git clone https://github.com/RishiPlaysCodes/Lockin-AI.git
cd Lockin-AI

# Create virtual environment
python -m venv venv
source venv/bin/activate  # Linux/Mac
# venv\Scripts\activate  # Windows

# Install dependencies
pip install -r requirements/development.txt

# Configure environment
cp .env.example .env
# Edit .env with your settings

# Run migrations
python src/manage.py migrate

# Seed sample data (optional)
python src/manage.py seed_data

# Run development server
python src/manage.py runserver
```

### Using Docker

```bash
# Development
docker compose -f docker-compose.dev.yml up

# Production
cp .env.example .env  # Edit with real values
docker compose up -d
```

### Using Makefile

```bash
make install        # Install dependencies
make migrate        # Run migrations
make dev            # Start dev server
make test           # Run tests
make lint           # Run linters
make docker-up      # Start with Docker
make help           # Show all commands
```

---

## API Documentation

Once running, access the interactive API docs at:

- **Swagger UI**: `http://localhost:8000/api/docs/`
- **OpenAPI Schema**: `http://localhost:8000/api/schema/`
- **Health Check**: `http://localhost:8000/health/`

### Key Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/auth/register/` | Register new user |
| POST | `/api/v1/auth/token/` | Get JWT tokens |
| POST | `/api/v1/auth/token/refresh/` | Refresh access token |
| GET | `/api/v1/profile/` | Get user profile |
| POST | `/api/v1/sessions/start/` | Start focus session |
| POST | `/api/v1/sessions/end/` | End active session |
| POST | `/api/v1/distractions/` | Log distraction |
| GET | `/api/v1/reports/study/` | Get study report |
| GET | `/api/v1/reports/stats/` | Get aggregated stats |
| POST | `/api/v1/ai-teacher/` | Chat with AI teacher |

---

## Project Structure

```
Lockin-AI/
├── src/                          # Application source code
│   ├── manage.py                 # Django management script
│   ├── focus_guardian/           # Project configuration
│   │   ├── settings/            # Environment-specific settings
│   │   │   ├── base.py          # Shared settings
│   │   │   ├── development.py   # Dev settings
│   │   │   ├── production.py    # Production settings
│   │   │   └── testing.py       # Test settings
│   │   ├── urls.py              # Root URL configuration
│   │   ├── wsgi.py              # WSGI entry point
│   │   └── asgi.py              # ASGI entry point
│   └── core/                    # Main application
│       ├── api/v1/              # API v1 views and URLs
│       ├── exceptions/          # Custom exception handlers
│       ├── management/commands/ # Management commands
│       ├── middleware/          # Custom middleware
│       ├── services/            # Business logic layer
│       ├── templates/           # HTML templates
│       ├── models.py            # Data models
│       ├── serializers.py       # DRF serializers
│       └── admin.py             # Admin configuration
├── tests/                       # Test suite
│   ├── conftest.py              # Shared fixtures
│   ├── core/                    # Unit tests
│   └── integration/             # Integration tests
├── config/nginx/                # Nginx configuration
├── requirements/                # Python dependencies
│   ├── base.txt                 # Core dependencies
│   ├── development.txt          # Dev tools
│   └── production.txt           # Production extras
├── docker-compose.yml           # Production Docker setup
├── docker-compose.dev.yml       # Development Docker setup
├── Dockerfile                   # Multi-stage production build
├── Makefile                     # Common commands
├── pyproject.toml               # Project config (ruff, mypy, coverage)
├── pytest.ini                   # Test configuration
├── .env.example                 # Environment template
└── .github/workflows/ci.yml    # CI/CD pipeline
```

---

## Testing

```bash
# Run all tests
make test

# Run with coverage
make test-cov

# Run specific test file
pytest tests/core/test_api.py -v

# Run specific test class
pytest tests/core/test_api.py::TestFocusSession -v
```

---

## Deployment

### Production Checklist

1. Set all environment variables (see `.env.example`)
2. Use a strong, unique `DJANGO_SECRET_KEY`
3. Set `DJANGO_DEBUG=False`
4. Configure `DJANGO_ALLOWED_HOSTS`
5. Set up PostgreSQL database
6. Configure Redis for caching
7. Enable HTTPS with proper SSL certificates
8. Set `CORS_ALLOWED_ORIGINS` to your frontend domain(s)
9. Configure email settings for notifications
10. Set up monitoring (Sentry DSN, log aggregation)

### Health Monitoring

The `/health/` endpoint checks:
- Database connectivity
- Cache availability

Returns HTTP 200 when healthy, 503 when degraded.

---

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Run tests and linting (`make test && make lint`)
4. Commit your changes
5. Push to the branch
6. Open a Pull Request

---

## License

This project is private. All rights reserved.

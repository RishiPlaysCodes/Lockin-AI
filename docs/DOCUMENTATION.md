# Focus Guardian AI — Complete Technical Documentation

> Every file, every feature, every design decision — explained.

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Architecture & Design Decisions](#2-architecture--design-decisions)
3. [Directory Structure (Every File Explained)](#3-directory-structure-every-file-explained)
4. [Backend — Django Application](#4-backend--django-application)
5. [Frontend — Templates & Design System](#5-frontend--templates--design-system)
6. [Authentication & Security](#6-authentication--security)
7. [API Reference (All Endpoints)](#7-api-reference-all-endpoints)
8. [Services Layer (Business Logic)](#8-services-layer-business-logic)
9. [Database Models](#9-database-models)
10. [AI Integration (Gemini + OpenAI)](#10-ai-integration-gemini--openai)
11. [Deployment Pipeline](#11-deployment-pipeline)
12. [Testing](#12-testing)
13. [Configuration & Environment Variables](#13-configuration--environment-variables)
14. [Security Measures](#14-security-measures)

---

## 1. Project Overview

**Focus Guardian AI** is an enterprise-grade, AI-powered focus and study session tracker. It helps students:

- Start timed focus sessions (Pomodoro, Short, Long, Custom)
- Automatically detect distractions (browser tab switches)
- Manually log distractions
- Track focus score, study streaks, and total study time
- Chat with an AI teacher for explanations, tips, and motivation
- View reports and analytics of past sessions

**Tech Stack:**
| Layer | Technology |
|-------|-----------|
| Backend | Python 3.12, Django 5.2 LTS, Django REST Framework |
| Authentication | JWT via djangorestframework-simplejwt |
| Database | PostgreSQL 16 (production), SQLite (development) |
| AI | Google Gemini (free tier) or OpenAI GPT-4o-mini |
| Frontend | Custom glassmorphism design system, vanilla JS, PWA manifest |
| Deployment | Render.com (free tier), Docker (alternative) |
| CI/CD | GitHub Actions |

---

## 2. Architecture & Design Decisions

### Layered Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  FRONTEND (Templates + JS)                                   │
│  - HTML templates with {% static %} assets                   │
│  - Shared app.js utility (auth, API calls, toasts)          │
│  - Custom CSS design system                                  │
├─────────────────────────────────────────────────────────────┤
│  API LAYER (Django REST Framework)                           │
│  - Versioned at /api/v1/                                     │
│  - Serializers for validation + response shaping            │
│  - Custom exception handler for consistent error format     │
├─────────────────────────────────────────────────────────────┤
│  SERVICE LAYER (Business Logic)                              │
│  - SessionService: start/end sessions, log distractions     │
│  - AITeacherService: Gemini/OpenAI communication            │
│  - All DB writes wrapped in @transaction.atomic             │
├─────────────────────────────────────────────────────────────┤
│  DATA LAYER (Django ORM + PostgreSQL)                        │
│  - Models: UserProfile, FocusSession, Distraction           │
│  - UUID primary keys, indexed fields, check constraints     │
│  - Auto-created audit timestamps (created_at, updated_at)   │
└─────────────────────────────────────────────────────────────┘
```

### Key Design Decisions

| Decision | Reason |
|----------|--------|
| **JWT (not session cookies)** | Works from any client (browser, mobile, Postman). Stateless. |
| **Service layer** | Keeps views thin. Business logic testable independently. |
| **API versioning (/api/v1/)** | Future-proof. Can add v2 without breaking existing clients. |
| **UUID primary keys** | Not guessable (security), no sequential enumeration. |
| **Django 5.2 LTS** | Long-term support, stable, avoids 6.x breaking changes. |
| **Gemini priority over OpenAI** | Gemini has a generous free tier. Saves money. |
| **PWA manifest** | Allows "Add to Home Screen" on phones without a native app. |
| **Glassmorphism UI** | Unique, premium aesthetic. Not generic Bootstrap. |

---

## 3. Directory Structure (Every File Explained)

```
Lockin-AI/
├── src/                                    # All application source code
│   ├── manage.py                           # Django CLI entry point (runserver, migrate, etc.)
│   │
│   ├── focus_guardian/                     # Django project config package
│   │   ├── __init__.py                     # Package marker
│   │   ├── urls.py                         # Root URL routing (admin, api, health, templates)
│   │   ├── wsgi.py                         # WSGI entry point (production: gunicorn)
│   │   ├── asgi.py                         # ASGI entry point (for future WebSocket support)
│   │   └── settings/                       # Environment-split settings
│   │       ├── __init__.py                 # Package marker
│   │       ├── base.py                     # Shared settings (apps, middleware, REST config, logging)
│   │       ├── development.py              # Dev overrides (DEBUG=True, SQLite, no throttle)
│   │       ├── production.py               # Prod (PostgreSQL, Redis optional, security headers)
│   │       └── testing.py                  # Test (in-memory SQLite, fast hashers, no throttle)
│   │
│   └── core/                               # Main application (all features live here)
│       ├── __init__.py                     # Package marker
│       ├── apps.py                         # AppConfig — registers the app with Django
│       ├── models.py                       # Data models: UserProfile, FocusSession, Distraction
│       ├── serializers.py                  # DRF serializers for validation & response shaping
│       ├── admin.py                        # Django admin panel configuration
│       ├── signals.py                      # Auto-create UserProfile on new User registration
│       ├── urls.py                         # Template view URL routes (/, /dashboard, /timer, /chat)
│       ├── views.py                        # Template view functions (render HTML pages)
│       │
│       ├── api/                            # REST API package
│       │   ├── __init__.py
│       │   └── v1/                         # Version 1 of the API
│       │       ├── __init__.py
│       │       ├── urls.py                 # All API URL routes under /api/v1/
│       │       └── views.py               # API view classes (registration, sessions, AI, reports)
│       │
│       ├── services/                       # Business logic (separated from views)
│       │   ├── __init__.py
│       │   ├── session_service.py          # Start/end sessions, log distractions, update scores
│       │   └── ai_service.py              # Gemini/OpenAI communication, mock fallback
│       │
│       ├── exceptions/                     # Custom error handling
│       │   ├── __init__.py
│       │   └── handlers.py                # DRF custom exception handler (consistent error format)
│       │
│       ├── middleware/                     # Custom middleware
│       │   ├── __init__.py
│       │   ├── request_logging.py          # Logs every request (method, path, duration, user)
│       │   ├── logging_formatter.py        # JSON log formatter for production
│       │   └── security_headers.py         # CSP, Referrer-Policy, Permissions-Policy headers
│       │
│       ├── management/                     # Custom management commands
│       │   ├── __init__.py
│       │   └── commands/
│       │       ├── __init__.py
│       │       └── seed_data.py            # Seeds demo data for development/testing
│       │
│       ├── migrations/                     # Database migrations (version-controlled schema)
│       │   ├── __init__.py
│       │   └── 0001_initial.py            # Creates all tables, indexes, constraints
│       │
│       ├── templates/core/                 # HTML templates (Jinja-like Django templates)
│       │   ├── home.html                   # Login/signup page (landing)
│       │   ├── dashboard.html              # Dashboard with stats + session list
│       │   ├── timer.html                  # Focus timer with circular progress
│       │   └── chat.html                   # AI teacher chat interface
│       │
│       ├── templatetags/                   # Custom template tags (currently empty)
│       │   └── __init__.py
│       │
│       └── static/core/                    # Static assets (CSS, JS, icons)
│           ├── css/app.css                 # Design system (glassmorphism, all UI styles)
│           ├── js/app.js                   # Shared JS: auth, token refresh, API calls, toasts
│           ├── manifest.json               # PWA manifest (for phone "Add to Home Screen")
│           └── icons/
│               └── icon-192.svg            # App icon (SVG)
│
├── tests/                                  # Test suite
│   ├── __init__.py
│   ├── conftest.py                         # Shared pytest fixtures (user, client, session)
│   ├── core/
│   │   ├── __init__.py
│   │   ├── test_models.py                  # Model unit tests (profile, session, distraction)
│   │   ├── test_api.py                     # API endpoint tests (register, login, CRUD)
│   │   └── test_services.py                # Service layer tests (session, AI)
│   └── integration/
│       ├── __init__.py
│       └── test_workflows.py               # End-to-end workflow tests (full user journey)
│
├── docs/                                   # Documentation
│   ├── DOCUMENTATION.md                    # This file — comprehensive docs
│   ├── LOCAL_SETUP.md                      # VS Code testing guide
│   ├── CROSS_PLATFORM.md                   # Windows/Mac/Linux/Android setup
│   ├── DEPLOYMENT.md                       # Google Cloud Run guide
│   ├── DEPLOY_RENDER.md                    # Render.com free deploy guide
│   └── PHONE_GUIDE.md                      # Phone usage guide (PWA + APK wrapper)
│
├── config/nginx/nginx.conf                 # Nginx reverse proxy config (Docker deploy)
├── requirements/                           # Python dependencies (split by environment)
│   ├── base.txt                            # Core deps (Django, DRF, JWT, OpenAI, etc.)
│   ├── development.txt                     # Dev tools (debug toolbar, pytest, ruff)
│   └── production.txt                      # Production extras (sentry, celery)
│
├── .github/workflows/ci.yml               # CI/CD pipeline (lint, test, security, Docker)
├── Dockerfile                              # Multi-stage production Docker image
├── docker-compose.yml                      # Production: web + postgres + redis + nginx
├── docker-compose.dev.yml                  # Development Docker setup
├── render.yaml                             # Render.com blueprint (one-click deploy)
├── build.sh                                # Render build script (install, collectstatic, migrate)
├── Procfile                                # Process command for Render/Heroku
├── cloudrun.yaml                           # Google Cloud Run service config
├── run.py                                  # Universal cross-platform launcher (python run.py)
├── run.sh                                  # Mac/Linux/Termux launcher
├── run.bat                                 # Windows CMD launcher
├── run.ps1                                 # Windows PowerShell launcher
├── Makefile                                # Developer shortcut commands
├── pyproject.toml                          # Ruff/mypy/coverage configuration
├── pytest.ini                              # Pytest configuration
├── .env.example                            # Environment variable template
├── .gitignore                              # Git ignore rules
├── .cloudignore                            # Files to skip during gcloud deploy
└── README.md                               # Main project README
```

---

## 4. Backend — Django Application

### `manage.py`
Django's CLI tool. Commands run through this:
```bash
python manage.py runserver      # Start dev server
python manage.py migrate        # Apply database changes
python manage.py createsuperuser # Create admin user
python manage.py seed_data      # Load demo data
```

### Settings Split (`focus_guardian/settings/`)

| File | Purpose | When used |
|------|---------|-----------|
| `base.py` | All shared config: apps, middleware, REST framework, JWT, logging, AI keys | Always (imported by others) |
| `development.py` | DEBUG=True, SQLite, no throttling, Django Debug Toolbar | `python manage.py runserver` |
| `production.py` | PostgreSQL (via DATABASE_URL), security headers, Redis optional | Render / Docker deploy |
| `testing.py` | In-memory SQLite, fast password hasher, no throttling | `pytest` |

### Root URL Router (`focus_guardian/urls.py`)

```python
path("admin/", admin.site.urls)           # Django admin panel
path("api/v1/", include("core.api.v1"))   # All API endpoints
path("api/schema/", ...)                   # OpenAPI schema (JSON)
path("api/docs/", ...)                     # Swagger UI
path("health/", ...)                       # Health check endpoint
path("", include("core.urls"))            # Template pages (/, /dashboard, /timer, /chat)
```

---

## 5. Frontend — Templates & Design System

### Design Philosophy
- **Glassmorphism**: Frosted glass cards (`backdrop-filter: blur()`) over animated gradient backgrounds
- **Neon accents**: Cyan (#00f5d4), Purple (#9b5de5), Pink (#f15bb5), Blue (#00bbf9)
- **Dark base**: Deep navy/black (#050510) — easy on eyes for studying
- **Animated mesh gradients**: Subtle background movement for life
- **Responsive**: Works on phones (320px) to desktops (1440px+)

### `app.css` — Design System CSS
All UI styles in one file. Key sections:
- **CSS Variables**: All colors, spacing, radius defined in `:root`
- **Body::before**: Animated radial gradient mesh background
- **`.glass`**: Glassmorphism card class (blur + transparent bg + subtle border)
- **`.btn-glow`**: Neon gradient button with box-shadow glow
- **`.stat-card`**: Dashboard stat cards with per-card color glow
- **`.timer-ring`**: SVG-based circular timer with gradient stroke
- **`.msg-user` / `.msg-ai`**: Chat bubble styles

### `app.js` — Shared Frontend JavaScript
One utility file used by all pages. Provides:

| Feature | Function | What it does |
|---------|----------|-------------|
| Token storage | `FG.Auth.setTokens()` | Store JWT in localStorage |
| Auth check | `FG.Auth.requireAuth()` | Redirect to `/` if not logged in |
| Logout | `FG.Auth.logout()` | Blacklist token + clear + redirect |
| API calls | `FG.apiFetch(path, opts)` | Fetch wrapper with auth header |
| Auto-refresh | (internal) | On 401, silently refresh token + retry once |
| Error extract | `FG.extractError(data)` | Parse error from API response format |
| Toasts | `FG.toast(msg, type)` | Show slide-in notification |
| XSS safety | `FG.escapeHtml(str)` | Escape user content for safe rendering |

### Template Pages

| Page | URL | Purpose |
|------|-----|---------|
| `home.html` | `/` | Login + Signup (pill tabs). Redirects to `/dashboard/` on success. |
| `dashboard.html` | `/dashboard/` | 4 stat cards + actions + session list with loading/empty states |
| `timer.html` | `/timer/` | SVG circular timer ring, start/stop, distraction counter |
| `chat.html` | `/chat/` | AI chat with bubbles, typing indicator, rate-limit handling |

---

## 6. Authentication & Security

### JWT Flow
```
1. User signs up → POST /api/v1/auth/register/
   ← Returns: { tokens: { access, refresh } }

2. User logs in → POST /api/v1/auth/token/
   ← Returns: { access, refresh }

3. Frontend stores tokens in localStorage (fg_access_token, fg_refresh_token)

4. Every API call sends: Authorization: Bearer <access_token>

5. When access expires (30 min):
   - API returns 401
   - app.js auto-calls POST /api/v1/auth/token/refresh/
   - Gets new access token silently
   - Retries the original request

6. Logout → POST /api/v1/auth/logout/ (blacklists refresh token)
```

### Security Headers (SecurityHeadersMiddleware)
Every response gets:
- **Content-Security-Policy**: Prevents XSS (restricts script/style/font sources)
- **Referrer-Policy**: `strict-origin-when-cross-origin`
- **Permissions-Policy**: Disables camera, microphone, geolocation, payment
- **Cross-Origin-Opener-Policy**: `same-origin`
- **X-Content-Type-Options**: `nosniff`
- **X-Frame-Options**: `DENY` (prevents clickjacking)

### XSS Prevention
- All user-generated content rendered via `textContent` (not `innerHTML`)
- `FG.escapeHtml()` available for any dynamic HTML insertion
- CSP blocks inline scripts from other origins

### Rate Limiting
- Anonymous: 20 requests/minute
- Authenticated: 100 requests/minute
- AI Teacher: 10 requests/minute (prevents abuse of expensive AI calls)

---

## 7. API Reference (All Endpoints)

Base URL: `https://your-app.onrender.com/api/v1/`

### Authentication

| Method | Endpoint | Body | Response |
|--------|----------|------|----------|
| POST | `/auth/register/` | `{username, email, password, password_confirm}` | `{user, tokens: {access, refresh}}` |
| POST | `/auth/token/` | `{username, password}` | `{access, refresh}` |
| POST | `/auth/token/refresh/` | `{refresh}` | `{access}` |
| POST | `/auth/logout/` | `{refresh}` | `{message}` |

### User Profile

| Method | Endpoint | Response |
|--------|----------|----------|
| GET | `/profile/` | `{id, username, email, focus_score, total_study_time_formatted, streak_days, daily_goal_minutes}` |
| PATCH | `/profile/` | Update `daily_goal_minutes` |

### Focus Sessions

| Method | Endpoint | Body | Response |
|--------|----------|------|----------|
| GET | `/sessions/` | — | Paginated list of user's sessions |
| POST | `/sessions/start/` | `{session_type, planned_duration_minutes}` | New session object |
| POST | `/sessions/end/` | — | Ended session object |
| GET | `/sessions/<uuid>/` | — | Single session detail |

### Distractions

| Method | Endpoint | Body | Response |
|--------|----------|------|----------|
| POST | `/distractions/` | `{app_name, distraction_type}` | Created distraction |

### Reports

| Method | Endpoint | Response |
|--------|----------|----------|
| GET | `/reports/study/` | Last 20 sessions with duration + distraction count |
| GET | `/reports/stats/` | Aggregated stats (total sessions, avg distractions, etc.) |

### AI Teacher

| Method | Endpoint | Body | Response |
|--------|----------|------|----------|
| POST | `/ai-teacher/` | `{message}` | `{reply, model_used}` |

### Error Response Format (all errors)
```json
{
    "error": {
        "code": "validation_error",
        "message": "Human-readable message",
        "details": { "field_name": ["specific errors"] }
    }
}
```

---

## 8. Services Layer (Business Logic)

### `session_service.py` — SessionService

| Method | What it does |
|--------|-------------|
| `start_session(user, type, duration, notes)` | Ends any active sessions, creates new one. Uses `select_for_update()` for concurrency safety. |
| `end_session(user)` | Ends active session, adds duration to user's total study time, updates streak. |
| `log_distraction(user, app_name, type, duration)` | Creates Distraction record, decreases user's focus score by 5 points. |

All methods use `@transaction.atomic` — if anything fails mid-way, nothing changes (no partial state).

### `ai_service.py` — AITeacherService

Priority logic:
1. If `GEMINI_API_KEY` is set → use Google Gemini (free tier)
2. Else if `OPENAI_API_KEY` is set → use OpenAI
3. Else → return mock response (app still works)

Uses the **OpenAI Python SDK** for both providers because Gemini has an OpenAI-compatible endpoint:
```python
# For Gemini:
client = openai.OpenAI(api_key=gemini_key, base_url="https://generativelanguage.googleapis.com/v1beta/openai/")

# For OpenAI:
client = openai.OpenAI(api_key=openai_key)  # default base_url
```

This means one codebase supports both providers with zero conditional logic in the actual API call.

---

## 9. Database Models

### UserProfile
| Field | Type | Purpose |
|-------|------|---------|
| id | UUID | Primary key (not guessable) |
| user | OneToOne → User | Link to Django's built-in User model |
| focus_score | Integer (0-100) | Current focus rating. Decreases with distractions. |
| total_study_time | Duration | Cumulative across all sessions |
| daily_goal_minutes | Integer | User-configurable daily target |
| streak_days | Integer | Consecutive days with completed sessions |
| last_active_date | Date | For streak calculation |
| created_at / updated_at | DateTime | Audit timestamps |

### FocusSession
| Field | Type | Purpose |
|-------|------|---------|
| id | UUID | Primary key |
| user | FK → User | Session owner |
| start_time | DateTime | Auto-set on creation |
| end_time | DateTime (nullable) | Set when session ends |
| is_active | Boolean | True while running |
| session_type | Choice | pomodoro/short/long/custom |
| planned_duration_minutes | Integer | Target duration |
| notes | Text | Optional session notes |

**Indexes**: `(user, is_active)`, `(user, -start_time)` for fast lookups.
**Constraint**: `end_time >= start_time` (database-level integrity).

### Distraction
| Field | Type | Purpose |
|-------|------|---------|
| id | UUID | Primary key |
| session | FK → FocusSession | Which session it belongs to |
| app_name | String | What caused the distraction |
| timestamp | DateTime | When it happened |
| distraction_type | Choice | app_switch/visibility_change/notification/manual/mock |
| duration_seconds | Integer | How long (optional) |

**Index**: `(session, -timestamp)` for efficient session-level queries.

---

## 10. AI Integration (Gemini + OpenAI)

### System Prompt
The AI acts as a "Focus Guardian AI Teacher" — supportive, concise, educational. It:
- Explains concepts simply
- Shares study tips and memory techniques
- Provides motivation
- Acknowledges frustration

### Free Tier Limits (Gemini)
- 15 requests/minute
- 1500 requests/day
- More than enough for personal/student use

### Rate Limiting in App
- Server-side: 10 requests/minute per user (DRF throttle)
- Client-side: Button disables during request, toast on 429

---

## 11. Deployment Pipeline

### Render.com (Primary — Free)
1. `render.yaml` blueprint creates web service + PostgreSQL
2. `build.sh` runs: pip install → collectstatic → migrate
3. `Procfile` runs: gunicorn with 2 workers
4. Auto-deploys on every push to `main`

### Docker (Alternative)
- Multi-stage Dockerfile (builder → production image)
- docker-compose.yml: web + postgres + redis + nginx
- Non-root user in container
- Health check endpoint

### CI/CD (GitHub Actions)
- **Lint**: ruff check
- **Test**: pytest with coverage
- **Security**: pip-audit
- **Docker**: Build + health check (on main only)

---

## 12. Testing

### Test Structure
- **Unit tests** (`test_models.py`): Model methods, validators, relationships
- **API tests** (`test_api.py`): Every endpoint, auth, validation, isolation
- **Service tests** (`test_services.py`): Business logic, mock AI
- **Integration tests** (`test_workflows.py`): Full user journey end-to-end

### Running Tests
```bash
pytest                                    # All tests
pytest -v                                 # Verbose
pytest --cov=core --cov-report=term       # With coverage
pytest tests/core/test_api.py -v          # Specific file
```

### Test Fixtures (conftest.py)
- `user`: Creates test user
- `user_profile`: Creates profile for test user
- `authenticated_client`: API client with valid JWT
- `active_session`: Creates an active focus session
- `second_user`: For data isolation tests

---

## 13. Configuration & Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `DJANGO_SETTINGS_MODULE` | Yes | (development) | Which settings to use |
| `DJANGO_SECRET_KEY` | Prod only | generated | Cryptographic signing key |
| `DJANGO_DEBUG` | No | True | Enable debug mode |
| `DATABASE_URL` | Prod only | — | PostgreSQL connection string (Render provides this) |
| `GEMINI_API_KEY` | No | — | Google Gemini API key (FREE AI) |
| `OPENAI_API_KEY` | No | — | OpenAI key (paid, fallback) |
| `REDIS_URL` | No | — | Redis for caching (optional) |
| `CORS_ALLOWED_ORIGINS` | No | — | Comma-separated allowed origins |

---

## 14. Security Measures

| Measure | Where | What it prevents |
|---------|-------|-----------------|
| JWT with refresh rotation | base.py | Token replay attacks |
| Token blacklisting | simplejwt | Stolen refresh tokens can be revoked |
| Password validation (10+ chars) | serializers.py | Weak passwords |
| Rate limiting (20/100/10 rpm) | base.py | Brute force, DoS, API abuse |
| CSP headers | security_headers.py | XSS, code injection |
| X-Frame-Options: DENY | security_headers.py | Clickjacking |
| UUID primary keys | models.py | IDOR (sequential ID enumeration) |
| select_for_update() | session_service.py | Race conditions on concurrent writes |
| @transaction.atomic | session_service.py | Partial state corruption |
| XSS-safe rendering | Templates (textContent) | Cross-site scripting |
| HTTPS only (prod) | production.py | Man-in-the-middle |
| HTTPOnly cookies | base.py | JavaScript cookie theft |
| Input validation | serializers.py | SQL injection, invalid data |
| Request size limits | base.py | Large payload DoS |
| Non-root Docker user | Dockerfile | Container escape privilege escalation |
| pip-audit in CI | ci.yml | Known vulnerable dependencies |

---

## Summary

This is a **production-ready, enterprise-grade** application with:
- Clean architecture (service layer, proper separation of concerns)
- Modern, unique UI (glassmorphism + neon, responsive PWA)
- Robust security (CSP, JWT rotation, rate limiting, XSS prevention)
- Comprehensive testing (40+ tests, 80%+ coverage target)
- Free deployment (Render.com, no credit card needed)
- AI integration (Gemini free tier)
- Cross-platform support (Windows, Mac, Linux, Android)

Every design choice prioritizes: **security → reliability → developer experience → user experience**.

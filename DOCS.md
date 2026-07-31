# FOCUS GUARDIAN AI - COMPLETE PROJECT DOCUMENTATION

> **Language:** Hinglish + English Mix (Hindi transliteration + English technical terms)
> **Purpose:** Complete project documentation - rebuild karne ke liye sufficient detail
> **Last Updated:** 2024

---

## TABLE OF CONTENTS

1. [Project Overview](#1-project-overview)
2. [Complete Architecture](#2-complete-architecture)
3. [File-by-File Explanation](#3-file-by-file-explanation)
4. [Code Explanation (Important Functions)](#4-code-explanation-important-functions)
5. [Feature Implementation](#5-feature-implementation-each-feature-detailed)
6. [Commands Documentation](#6-commands-documentation)
7. [Git Documentation](#7-git-documentation)
8. [Learning Roadmap](#8-learning-roadmap)
9. [Architecture Diagrams (Text-Based)](#9-architecture-diagrams-text-based)
10. [Developer Guide](#10-developer-guide)
11. [Professional README Content](#11-professional-readme-content)

---

## 1. PROJECT OVERVIEW

### 1.1 Kya Hai Ye App? (What Is This App?)

Focus Guardian AI ek **AI-powered study discipline app** hai jo students ko unki padhai mein focused rehne mein help karti hai. Socho ek intelligent study buddy jo:

- Tumhare study time ko **track** karta hai
- Jab tum distract ho jaate ho tab **detect** karta hai
- AI ke through **personalized study help** deta hai
- Badges aur scores ke through tumhe **motivated** rakhta hai
- Sites ko **block** karke distractions kam karta hai

Ye app **do platforms** par available hai:
1. **Django Web App** - Browser mein chalti hai (laptop/desktop)
2. **Flutter Mobile App** - Phone mein chalti hai (Android/iOS)

### 1.2 Main Objective

> "Social media addiction aur constant distractions se students ki padhai barbaad ho rahi hai. Focus Guardian AI unhe accountability, motivation, aur AI-powered assistance deta hai taaki wo apni study goals achieve kar sakein."

### 1.3 Real-World Use Case

**Scenario:** Rahul IIT-JEE ki preparation kar raha hai. Uska problem:
- Pomodoro start karta hai → 5 min mein Instagram khol leta hai
- Kitna padha track nahi hota → guilt feel karta hai
- Akele padh raha hai → motivation nahi milta
- Schedule nahi follow kar pata → consistency nahi hai

**Focus Guardian AI se:**
- Timer start karo → distraction detect hoga → score girega → accountability
- Dashboard pe daily/weekly stats → "Aaj 2 hours padha, kal se zyada!"
- AI Teacher se doubt pucho → instant explanation
- Badges milte hain → gamification se motivation
- Sites block karo → Instagram/YouTube khulega hi nahi study ke time

### 1.4 Target Users

| User Type | Kaise Use Karega |
|-----------|-----------------|
| School Students (14-18) | Daily homework, exam prep |
| Competitive Exam Aspirants (JEE/NEET/UPSC) | Long study hours, need accountability |
| College Students | Assignment deadlines, project work |
| Self-learners | Online courses, skill building |
| Working Professionals | Focused skill upgradation |

### 1.5 Problem It Solves

| Problem | Solution |
|---------|----------|
| Social media addiction during study | Site blocking + distraction detection |
| No accountability when studying alone | Focus score + streak system |
| Don't know how much studied | Timer + dashboard analytics |
| No motivation to continue | Badge system + AI motivation |
| Doubts while studying, no one to ask | AI Teacher chat (5 modes) |
| Inconsistent study habits | Streak system + daily goals |
| Can't track progress over time | Reports with charts (7/14/30/90 days) |

### 1.6 Why Each Feature Exists

| Feature | Kyun Zaroori Hai |
|---------|-----------------|
| Focus Timer | Study time accurately track karne ke liye |
| Distraction Detection | Awareness create karta hai ki kitna distract hue |
| AI Teacher | 24/7 available tutor, koi bhi doubt pucho |
| Site Blocking | Temptation hi hatao, willpower pe depend mat karo |
| Badges/Gamification | Dopamine hit - padhai ko game banao |
| Focus Score | Single number se progress samjho (A+, B, C grade) |
| Streak System | Daily consistency build karo |
| Reports | Data-driven decisions - kab zyada productive ho |
| Settings | Personalization - har student ki needs alag |

---

## 2. COMPLETE ARCHITECTURE

### 2.1 Dual-Platform Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   FOCUS GUARDIAN AI                       │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────────┐        ┌──────────────────────┐   │
│  │  Django Web App   │        │  Flutter Mobile App   │   │
│  │  (Browser-based)  │        │  (Android/iOS)        │   │
│  │                   │        │                       │   │
│  │  - HTML/CSS/JS    │        │  - Dart/Flutter       │   │
│  │  - Bootstrap 5    │        │  - Provider Pattern   │   │
│  │  - Chart.js       │        │  - fl_chart           │   │
│  │  - Fetch API      │        │  - SharedPreferences  │   │
│  │                   │        │                       │   │
│  │  Server: Django   │        │  Storage: Local       │   │
│  │  DB: SQLite       │        │  (Offline-first)      │   │
│  │  Auth: Sessions   │        │  Auth: Local prefs    │   │
│  └──────────────────┘        └──────────────────────┘   │
│           │                                              │
│           ▼                                              │
│  ┌──────────────────┐                                   │
│  │    Django REST    │  ◄── Optional API connection      │
│  │    Framework      │       from Flutter                │
│  └──────────────────┘                                   │
│           │                                              │
│           ▼                                              │
│  ┌──────────────────┐                                   │
│  │  OpenAI API      │  ◄── AI chat responses            │
│  │  (gpt-3.5-turbo) │       (with mock fallback)        │
│  └──────────────────┘                                   │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### 2.2 Django MVT Pattern Explanation

Django **MVT (Model-View-Template)** pattern follow karta hai:

```
User Request → URL Router → View → Model (DB) → Template → Response
```

**Detailed breakdown:**

| Component | Role | Hamara Code |
|-----------|------|-------------|
| **Model** | Database tables define karta hai | `core/models.py` (8 models) |
| **View** | Business logic + request handling | `core/views.py` (8 pages + 11 APIs) |
| **Template** | HTML pages with dynamic data | `core/templates/` (11 files) |
| **URL** | Which URL → which view | `core/urls.py` (22 patterns) |
| **Form** | Input validation | `core/forms.py` (3 forms) |
| **Signal** | Auto-triggered actions | `core/signals.py` (auto profile) |
| **Service** | Reusable business logic | `core/services.py` (AI, badges, etc.) |
| **Serializer** | JSON formatting (API) | `core/serializers.py` (7 serializers) |

### 2.3 Flutter Provider Pattern Explanation

Flutter mein **Provider** pattern state management ke liye use hota hai:

```
UI Widget ← watches ← Provider (ChangeNotifier) → manages → Data/State
```

**Hamare 3 Providers:**

| Provider | Responsibility |
|----------|---------------|
| `AuthProvider` | Login/logout state, user info |
| `AppProvider` | Sessions, badges, chat, blocked sites, scoring |
| `TimerProvider` | Countdown timer logic, pause/resume |

**Kaise kaam karta hai:**

```dart
// Provider define karte ho (data + logic)
class TimerProvider extends ChangeNotifier {
  int _remainingSeconds = 25 * 60;
  
  void startTimer() {
    // Logic...
    notifyListeners(); // UI ko bolo "update ho jao!"
  }
}

// UI mein use karte ho
Consumer<TimerProvider>(
  builder: (context, timer, child) {
    return Text(timer.displayTime); // Auto-update hoga
  }
)
```

### 2.4 Database (SQLite with 8 Tables)

```
┌─────────────────────────────────────────────────────────┐
│                    SQLite Database                        │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────┐     ┌──────────────────┐              │
│  │     User     │────▶│   UserProfile    │              │
│  │  (Django's)  │     │  (1-to-1)        │              │
│  └──────┬───────┘     └──────────────────┘              │
│         │                                                │
│    ┌────┼────────┬──────────┬──────────┐                │
│    ▼    ▼        ▼          ▼          ▼                │
│  Focus  Blocked  Study     Badge     ChatMessage         │
│ Session  Site     Log                                    │
│    │                                                     │
│    ▼                                                     │
│ Distraction                                              │
│                                                          │
│  DailyQuote (standalone - no user relation)              │
└─────────────────────────────────────────────────────────┘
```

**8 Tables:**

| # | Table | Relations | Purpose |
|---|-------|-----------|---------|
| 1 | User (built-in) | - | Django ka default user |
| 2 | UserProfile | User → 1:1 | Extended profile with stats |
| 3 | FocusSession | User → 1:Many | Each study session |
| 4 | Distraction | FocusSession → 1:Many | Distractions during session |
| 5 | BlockedSite | User → 1:Many | Sites to block |
| 6 | StudyLog | User → 1:Many | Daily study summary |
| 7 | Badge | User → 1:Many | Earned achievements |
| 8 | ChatMessage | User → 1:Many | AI chat history |
| 9 | DailyQuote | None | Motivational quotes |

### 2.5 API Flow

**Web App (Session Auth + CSRF):**
```
Browser → POST /api/session/start/
         Headers: Cookie: sessionid=xxx; csrftoken=xxx
         Body: {subject: "Physics", planned_duration: 25}
         
Server → Validates session → Creates FocusSession → Returns JSON
```

**Flutter App (Offline-First):**
```
App → User taps "Start" → AppProvider.startSession()
    → Creates local FocusSession object
    → Saves to SharedPreferences (JSON)
    → Optionally syncs with Django API (if connected)
```

### 2.6 Authentication Flow

**Django Web (Server-side Sessions):**
```
1. User submits login form (username + password)
2. Django authenticate() checks credentials
3. Django creates session in DB
4. Sets sessionid cookie in browser
5. Every subsequent request includes this cookie
6. Django validates session on each request (@login_required)
```

**Flutter Mobile (SharedPreferences):**
```
1. User enters credentials
2. AuthProvider.login() validates locally (non-empty + length check)
3. Saves isLoggedIn=true + username to SharedPreferences
4. On app restart: checkAuth() reads SharedPreferences
5. If isLoggedIn=true → show HomeScreen
6. If false → show LoginScreen
```

### 2.7 AI Integration Flow

```
User sends message
       │
       ▼
get_ai_response(message, user, history, mode)
       │
       ├── OPENAI_API_KEY set hai?
       │         │
       │    YES  │
       │         ▼
       │   _get_openai_response()
       │         │
       │         ├── System prompt (mode-specific)
       │         ├── User context (level, streak, score)
       │         ├── Chat history (last 10 messages)
       │         ├── User message
       │         │
       │         ▼
       │   OpenAI API call (gpt-3.5-turbo)
       │         │
       │         ├── Success → Return AI response
       │         └── Fail → Return None → fallback
       │
       └── NO key / API failed
                 │
                 ▼
          _get_mock_response(message, mode)
                 │
                 ├── Keyword matching
                 │     - "focus" → focus tips
                 │     - "motivat" → motivation response
                 │     - "plan" → study plan
                 │     - "hello" → greeting
                 │
                 └── Default mode response
```

### 2.8 Complete Folder Structure

```
Lockin-AI/
├── focus_guardian/                    # Django Web App
│   ├── manage.py                     # Django CLI entry point
│   ├── requirements.txt              # Python dependencies
│   ├── .env.example                  # Environment variables template
│   ├── .gitignore                    # Git ignore rules
│   ├── README.md                     # Django-specific readme
│   │
│   ├── focus_guardian/               # Django project config
│   │   ├── __init__.py              # Package marker
│   │   ├── settings.py             # All Django settings
│   │   ├── urls.py                 # Root URL config
│   │   ├── wsgi.py                 # WSGI deployment
│   │   └── asgi.py                 # ASGI deployment
│   │
│   └── core/                         # Main app (all features)
│       ├── __init__.py              # Package marker
│       ├── models.py                # 8 database models
│       ├── views.py                 # 8 template views + 11 API views
│       ├── services.py              # Business logic layer
│       ├── urls.py                  # 22 URL patterns
│       ├── forms.py                 # 3 Django forms
│       ├── serializers.py           # 7 DRF serializers
│       ├── signals.py               # Auto-create profile
│       ├── admin.py                 # Admin panel config
│       ├── apps.py                  # App config
│       ├── tests.py                 # Tests (placeholder)
│       │
│       ├── templates/
│       │   ├── core/
│       │   │   ├── base.html        # Base template (sidebar, nav)
│       │   │   ├── landing.html     # Home/marketing page
│       │   │   ├── dashboard.html   # Main dashboard
│       │   │   ├── timer.html       # Focus timer page
│       │   │   ├── chat.html        # AI chat page
│       │   │   ├── reports.html     # Analytics page
│       │   │   ├── blocking.html    # Site blocking page
│       │   │   ├── badges.html      # Badges page
│       │   │   └── settings.html    # Settings page
│       │   └── registration/
│       │       ├── login.html       # Login page
│       │       └── signup.html      # Signup page
│       │
│       ├── templatetags/
│       │   ├── __init__.py
│       │   └── custom_filters.py    # Custom template filters
│       │
│       └── static/
│           └── core/
│               ├── css/             # Custom CSS
│               └── js/              # Custom JavaScript
│
└── focus_guardian_app/               # Flutter Mobile App
    ├── pubspec.yaml                  # Flutter dependencies
    ├── assets/                       # Static assets
    │
    └── lib/                          # Dart source code
        ├── main.dart                 # App entry point
        │
        ├── models/
        │   ├── user_model.dart       # UserProfile class
        │   └── session_model.dart    # Session, Distraction, BlockedSite, ChatMessage, Badge
        │
        ├── providers/
        │   ├── auth_provider.dart    # Authentication state
        │   ├── app_provider.dart     # Main app state (everything)
        │   └── timer_provider.dart   # Timer countdown state
        │
        ├── screens/
        │   ├── splash_screen.dart    # Loading/splash screen
        │   ├── login_screen.dart     # Login UI
        │   ├── signup_screen.dart    # Signup UI
        │   ├── home_screen.dart      # Bottom nav container
        │   ├── dashboard_screen.dart # Dashboard UI
        │   ├── timer_screen.dart     # Timer UI
        │   ├── chat_screen.dart      # AI chat UI
        │   ├── reports_screen.dart   # Analytics UI
        │   ├── blocking_screen.dart  # Site blocking UI
        │   ├── badges_screen.dart    # Badges UI
        │   ├── settings_screen.dart  # Settings UI
        │   └── profile_tab.dart      # Profile tab UI
        │
        ├── utils/
        │   ├── theme.dart            # AppColors + AppTheme
        │   └── constants.dart        # URLs, keys, badge defs, quotes
        │
        ├── services/                 # (API service layer - placeholder)
        └── widgets/                  # (Reusable widgets - placeholder)
```

---


## 3. FILE-BY-FILE EXPLANATION

### 3.1 Django Web App Files

#### `focus_guardian/manage.py`
- **Path:** `focus_guardian/manage.py`
- **Purpose:** Django ka command-line tool. Ye file Django project ka entry point hai.
- **Why it exists:** Bina iske Django ka koi bhi command nahi chalega (runserver, migrate, etc.)
- **Key Logic:** `django.core.management.execute_from_command_line()` call karta hai
- **Dependencies:** `focus_guardian.settings` pe depend karta hai
- **Commands Example:**
```bash
python manage.py runserver          # Server start karo
python manage.py makemigrations     # Model changes detect karo
python manage.py migrate            # Database update karo
python manage.py createsuperuser    # Admin user banao
```

---

#### `focus_guardian/focus_guardian/settings.py`
- **Path:** `focus_guardian/focus_guardian/settings.py`
- **Purpose:** Poore Django project ki configuration. Database, apps, middleware, sab yahan define hai.
- **Why it exists:** Django ko batata hai "project kaise configure hai"
- **Key Configurations:**

| Setting | Value | Kyun |
|---------|-------|------|
| `SECRET_KEY` | env variable | Security ke liye |
| `DEBUG` | True (dev) | Error details dikhata hai |
| `DATABASES` | SQLite | Simple, file-based DB |
| `TIME_ZONE` | Asia/Kolkata | IST time zone |
| `INSTALLED_APPS` | core, rest_framework, corsheaders | Features enable karta hai |
| `REST_FRAMEWORK` | SessionAuthentication | API auth via cookies |
| `CORS_ALLOW_ALL_ORIGINS` | True | Flutter app se connect karne ke liye |
| `OPENAI_API_KEY` | env variable | AI chat ke liye |

- **Depends on:** `.env` file (environment variables ke liye)
- **Used by:** Har Django file implicitly isko use karti hai

---

#### `focus_guardian/focus_guardian/urls.py`
- **Path:** `focus_guardian/focus_guardian/urls.py`
- **Purpose:** Root URL configuration - saare URLs yahan se start hote hain
- **Why it exists:** Django ko batata hai "kaunsi URL kahan jaaye"
- **Key Logic:**
```python
urlpatterns = [
    path("admin/", admin.site.urls),     # /admin/ → Django admin panel
    path("", include("core.urls")),       # Baaki sab → core app
]
```
- **Depends on:** `core/urls.py`

---

#### `focus_guardian/core/models.py`
- **Path:** `focus_guardian/core/models.py`
- **Purpose:** Database schema define karta hai - 8 tables, unke fields, relationships, aur computed properties
- **Why it exists:** Bina models ke koi data store nahi hoga
- **Key Models:**

| Model | Fields Count | Properties | Purpose |
|-------|-------------|------------|---------|
| UserProfile | 15 fields | 8 properties | User stats + preferences |
| FocusSession | 12 fields | 5 properties | Study sessions |
| Distraction | 6 fields | 1 property | Distraction events |
| BlockedSite | 7 fields | 1 property | Blocked sites list |
| StudyLog | 8 fields | 1 property | Daily study summary |
| Badge | 4 fields | 4 properties | Achievements |
| ChatMessage | 6 fields | 0 properties | AI chat history |
| DailyQuote | 3 fields | 0 properties | Motivational quotes |

- **Depends on:** Django ORM, django.contrib.auth.models.User
- **Used by:** views.py, services.py, serializers.py, admin.py, signals.py

---

#### `focus_guardian/core/views.py`
- **Path:** `focus_guardian/core/views.py`
- **Purpose:** Request handling - har URL ko yahan ek function/class handle karti hai
- **Why it exists:** Users ki requests ka response generate karna
- **Contains:**
  - 8 Template Views (HTML pages return karte hain)
  - 11 API Views (JSON data return karte hain)
  - 2 Rate Throttle classes

**Template Views:**

| View Function | URL | Purpose |
|---------------|-----|---------|
| `landing_view` | `/` | Marketing/home page |
| `signup_view` | `/signup/` | User registration |
| `login_view` | `/login/` | User login |
| `logout_view` | `/logout/` | User logout (POST only) |
| `dashboard_view` | `/dashboard/` | Main stats dashboard |
| `timer_view` | `/timer/` | Focus timer page |
| `chat_view` | `/chat/` | AI chat interface |
| `reports_view` | `/reports/` | Study analytics |
| `blocking_view` | `/blocking/` | Site blocking |
| `badges_view` | `/badges/` | Achievements gallery |
| `settings_view` | `/settings/` | Profile + preferences |

**API Views:**

| View Class | Method | URL | Purpose |
|------------|--------|-----|---------|
| `UserProfileAPIView` | GET | `/api/profile/` | Profile data |
| `StartFocusSessionView` | POST | `/api/session/start/` | New session |
| `EndFocusSessionView` | POST | `/api/session/end/` | End session |
| `ActiveSessionView` | GET | `/api/session/active/` | Current session |
| `LogDistractionView` | POST | `/api/distraction/` | Log distraction |
| `StudyReportAPIView` | GET | `/api/report/` | Report data |
| `AITeacherView` | POST | `/api/ai-teacher/` | AI chat |
| `ClearChatView` | POST | `/api/chat/clear/` | Clear history |
| `QuoteAPIView` | GET | `/api/quote/` | Random quote |
| `BlockedSiteToggleView` | POST | `/api/blocked-site/{id}/toggle/` | Toggle site |
| `BlockedSiteDeleteView` | DELETE | `/api/blocked-site/{id}/delete/` | Delete site |

- **Depends on:** models.py, forms.py, services.py, serializers.py, templates
- **Used by:** urls.py (URL routing)

---

#### `focus_guardian/core/services.py`
- **Path:** `focus_guardian/core/services.py`
- **Purpose:** Business logic layer - complex calculations aur third-party integrations
- **Why it exists:** Views ko clean rakhne ke liye. Reusable logic separate karo.
- **Key Functions:**

| Function | Purpose | Called By |
|----------|---------|-----------|
| `check_and_award_badges(user)` | 24 badges check karta hai | EndFocusSessionView |
| `update_streak(user)` | Streak increment/reset logic | EndFocusSessionView |
| `calculate_session_score(session)` | 0-100 score calculate karta hai | EndFocusSessionView |
| `update_study_log(session)` | Daily log update karta hai | EndFocusSessionView |
| `get_ai_response(msg, user, history, mode)` | AI response (OpenAI + mock) | AITeacherView |
| `get_motivational_quote()` | Random quote deta hai | dashboard_view, QuoteAPIView |
| `get_weekly_chart_data(user, days)` | Chart.js ke liye data | dashboard_view |
| `get_subject_distribution(user, days)` | Pie chart data | dashboard_view |

- **Depends on:** models.py, OpenAI library, os.getenv
- **Used by:** views.py

---

#### `focus_guardian/core/forms.py`
- **Path:** `focus_guardian/core/forms.py`
- **Purpose:** HTML form validation aur rendering
- **Why it exists:** User input ko safely validate karna
- **Contains:**

| Form | Based On | Fields | Validation |
|------|----------|--------|------------|
| `SignupForm` | UserCreationForm | username, email, password1, password2 | Email unique check |
| `BlockedSiteForm` | ModelForm (BlockedSite) | name, url, category | URL cleanup (remove http://) |
| `ProfileEditForm` | ModelForm (UserProfile) | bio, avatar_color, daily_goal, preferences | Field-level validation |

- **Depends on:** models.py, django.forms
- **Used by:** views.py (signup_view, blocking_view, settings_view)

---

#### `focus_guardian/core/serializers.py`
- **Path:** `focus_guardian/core/serializers.py`
- **Purpose:** Python objects ko JSON mein convert karta hai (API responses ke liye)
- **Why it exists:** REST API mein data structured format mein bhejna zaroori hai
- **Contains:** 7 serializers + computed field mapping

| Serializer | Model | Extra Fields |
|------------|-------|--------------|
| `UserSerializer` | User | password (write-only) |
| `UserProfileSerializer` | UserProfile | level, xp_points, focus_grade, etc. |
| `DistractionSerializer` | Distraction | score_penalty |
| `FocusSessionSerializer` | FocusSession | duration_minutes, distraction_count, distractions (nested) |
| `BlockedSiteSerializer` | BlockedSite | category_color |
| `StudyLogSerializer` | StudyLog | hours_studied |
| `BadgeSerializer` | Badge | display_name, icon, color, rarity, description |

- **Depends on:** models.py, rest_framework
- **Used by:** views.py (API views)

---

#### `focus_guardian/core/signals.py`
- **Path:** `focus_guardian/core/signals.py`
- **Purpose:** Automatic actions jab koi event hota hai
- **Why it exists:** Jab naya User create ho, automatically UserProfile bhi ban jaaye
- **Key Logic:**
```python
@receiver(post_save, sender=User)
def create_user_profile(sender, instance, created, **kwargs):
    if created:
        UserProfile.objects.create(user=instance)
```
- **Depends on:** models.py, django.db.models.signals
- **Used by:** Django signal system (auto-triggered)

---

#### `focus_guardian/core/admin.py`
- **Path:** `focus_guardian/core/admin.py`
- **Purpose:** Django admin panel customization
- **Why it exists:** `/admin/` pe jaake data directly manage kar sako
- **Key Logic:** 8 models registered with custom `list_display`, `list_filter`, `search_fields`
- **Depends on:** models.py
- **Used by:** Django admin system

---

#### `focus_guardian/core/urls.py`
- **Path:** `focus_guardian/core/urls.py`
- **Purpose:** URL → View mapping (22 patterns)
- **Why it exists:** Har URL ke liye correct view call ho
- **Contains:** 11 page URLs + 11 API URLs
- **Depends on:** views.py
- **Used by:** root urls.py (`include("core.urls")`)

---

#### `focus_guardian/core/templatetags/custom_filters.py`
- **Path:** `focus_guardian/core/templatetags/custom_filters.py`
- **Purpose:** Custom Django template filters for data formatting
- **Why it exists:** Templates mein complex calculations nahi kar sakte, filters use karo
- **Contains:**

| Filter | Usage | Example |
|--------|-------|---------|
| `duration_format` | timedelta → "2h 30m" | `{{ profile.total_study_time\|duration_format }}` |
| `percentage` | Value/Total → % | `{{ completed\|percentage:total }}` |
| `subtract` | value - arg | `{{ total\|subtract:used }}` |
| `multiply` | value * arg | `{{ minutes\|multiply:60 }}` |
| `divide` | value / arg | `{{ seconds\|divide:60 }}` |

- **Depends on:** django.template
- **Used by:** HTML templates

---

#### `focus_guardian/core/apps.py`
- **Path:** `focus_guardian/core/apps.py`
- **Purpose:** App configuration + signals import
- **Why it exists:** Django app registration, signals ready() mein import hote hain
- **Depends on:** signals.py

---

#### Templates (11 HTML files)

| Template | Path | Purpose |
|----------|------|---------|
| `base.html` | `templates/core/base.html` | Master layout - sidebar, nav, toast, shared CSS/JS |
| `landing.html` | `templates/core/landing.html` | Public homepage (non-logged in users) |
| `login.html` | `templates/registration/login.html` | Login form |
| `signup.html` | `templates/registration/signup.html` | Registration form |
| `dashboard.html` | `templates/core/dashboard.html` | Stats cards, charts, recent sessions |
| `timer.html` | `templates/core/timer.html` | SVG circular timer, session controls |
| `chat.html` | `templates/core/chat.html` | Chat interface, mode selector |
| `reports.html` | `templates/core/reports.html` | Period selector, charts, tables |
| `blocking.html` | `templates/core/blocking.html` | Add/remove blocked sites |
| `badges.html` | `templates/core/badges.html` | Badge grid with locked/unlocked state |
| `settings.html` | `templates/core/settings.html` | Forms for profile, password, reset |

---

### 3.2 Flutter Mobile App Files

#### `focus_guardian_app/pubspec.yaml`
- **Path:** `focus_guardian_app/pubspec.yaml`
- **Purpose:** Flutter project configuration + dependencies
- **Why it exists:** Flutter ko batata hai "konse packages install karne hain"
- **Key Dependencies:**

| Package | Version | Purpose |
|---------|---------|---------|
| `provider` | ^6.1.1 | State management |
| `shared_preferences` | ^2.2.2 | Local storage (key-value) |
| `http` | ^1.1.2 | API calls (optional) |
| `fl_chart` | ^0.66.0 | Charts (bar, line, pie) |
| `google_fonts` | ^6.1.0 | Custom fonts (Inter) |
| `flutter_animate` | ^4.3.0 | Smooth animations |
| `percent_indicator` | ^4.2.3 | Circular/linear progress |
| `intl` | ^0.19.0 | Date formatting |
| `uuid` | ^4.2.1 | Unique ID generation |

---

#### `focus_guardian_app/lib/main.dart`
- **Path:** `lib/main.dart`
- **Purpose:** App entry point - providers setup + MaterialApp config
- **Why it exists:** Flutter app ka starting point, yehi `main()` function run hota hai
- **Key Logic:**
```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const FocusGuardianApp());
}

// MultiProvider setup - 3 providers
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => AppProvider()),
    ChangeNotifierProvider(create: (_) => TimerProvider()),
  ],
  child: MaterialApp(theme: AppTheme.darkTheme, home: SplashScreen()),
)
```
- **Depends on:** providers/, utils/theme.dart, screens/splash_screen.dart

---

#### `focus_guardian_app/lib/utils/theme.dart`
- **Path:** `lib/utils/theme.dart`
- **Purpose:** App ka complete visual theme define karta hai
- **Why it exists:** Consistent colors, fonts, spacing across all screens
- **Key Logic:**

| Class | Contains |
|-------|----------|
| `AppColors` | 13 color constants (primary, secondary, accent, dark, card, etc.) |
| `AppTheme` | `darkTheme` getter with complete ThemeData |

**Color Palette:**
```dart
primary = #6C63FF     // Purple (main brand color)
secondary = #4ECDC4   // Teal (success, secondary actions)
accent = #FF6B6B      // Red (errors, warnings)
warning = #FECA57     // Yellow (alerts)
success = #06D6A0     // Green (achievements)
dark = #0A0E1A        // Background
card = #0F172A        // Card background
```

- **Depends on:** google_fonts package
- **Used by:** main.dart, all screens

---

#### `focus_guardian_app/lib/utils/constants.dart`
- **Path:** `lib/utils/constants.dart`
- **Purpose:** App-wide constants - API URLs, storage keys, badge definitions, quotes
- **Why it exists:** Magic strings avoid karo, ek jagah define karo
- **Contains:**
  - `baseUrl` - Django server URL (10.0.2.2:8000 for emulator)
  - 11 API endpoint URLs
  - 13 SharedPreferences keys
  - 17 badge type definitions (type, name, icon, description)
  - 10 motivational quotes with authors
- **Depends on:** Nothing
- **Used by:** auth_provider.dart, app_provider.dart, screens

---

#### `focus_guardian_app/lib/models/user_model.dart`
- **Path:** `lib/models/user_model.dart`
- **Purpose:** User profile data class with computed properties
- **Why it exists:** Type-safe user data representation
- **Key Properties:**

| Property | Type | Default | Purpose |
|----------|------|---------|---------|
| username | String | 'Student' | Display name |
| focusScore | int | 100 | Current focus score |
| totalStudyMinutes | int | 0 | Lifetime study time |
| streakDays | int | 0 | Current streak |
| longestStreak | int | 0 | Best streak ever |
| dailyGoalMinutes | int | 120 | Daily target |
| level | String | 'Beginner' | Computed level |

**Computed Properties:**
- `totalStudyHours` → minutes / 60
- `focusGrade` → A+/A/B+/B/C/D/F based on score
- `computeLevel()` → Beginner → Apprentice → Intermediate → Advanced → Expert → Master → Grandmaster

- **Depends on:** Nothing
- **Used by:** auth_provider.dart, app_provider.dart, screens

---

#### `focus_guardian_app/lib/models/session_model.dart`
- **Path:** `lib/models/session_model.dart`
- **Purpose:** Data classes for sessions, distractions, blocked sites, chat, badges
- **Why it exists:** Structured data representation + JSON serialization
- **Contains 5 Classes:**

| Class | Fields | JSON Support |
|-------|--------|--------------|
| `FocusSession` | id, subject, startTime, endTime, plannedDuration, isActive, isCompleted, focusScore, distractionCount, moods | toJson + fromJson |
| `Distraction` | id, appName, type, severity, timestamp | toJson |
| `BlockedSite` | id, name, url, category, isActive, timesBlocked | toJson + fromJson |
| `ChatMessage` | id, role, content, mode, timestamp | toJson + fromJson |
| `Badge` | type, name, icon, description, rarity, earnedAt, isEarned | toJson |

- **Depends on:** Nothing
- **Used by:** app_provider.dart, screens

---

#### `focus_guardian_app/lib/providers/auth_provider.dart`
- **Path:** `lib/providers/auth_provider.dart`
- **Purpose:** Authentication state management
- **Why it exists:** Login/logout state ko manage karna across app
- **Key Methods:**

| Method | Logic | Returns |
|--------|-------|---------|
| `checkAuth()` | SharedPreferences se isLoggedIn read karo | void (sets state) |
| `login(username, password)` | Validate + save to prefs | bool (success/fail) |
| `signup(username, email, password)` | Validate + save to prefs | bool |
| `logout()` | Clear isLoggedIn from prefs | void |

**Important:** Flutter app **offline-first** hai. Login locally validate hota hai (non-empty username + password ≥ 4 chars). Django server optional hai.

- **Depends on:** user_model.dart, constants.dart, shared_preferences
- **Used by:** splash_screen.dart, login_screen.dart, signup_screen.dart

---

#### `focus_guardian_app/lib/providers/app_provider.dart`
- **Path:** `lib/providers/app_provider.dart`
- **Purpose:** Main state manager - sessions, badges, chat, blocked sites, scoring, EVERYTHING
- **Why it exists:** Central data store for the entire app
- **Key Methods:**

| Method | Purpose |
|--------|---------|
| `loadData()` | App start pe SharedPreferences se sab load karo |
| `_saveData()` | State change ke baad SharedPreferences mein save karo |
| `startSession(subject, duration, mood)` | New session create karo |
| `endSession(sessionId)` | Session end + score + badges check |
| `logDistraction(sessionId, appName, type)` | Distraction log karo |
| `_updateStreak()` | Streak increment logic |
| `_checkBadges(session)` | Badge conditions check karo |
| `addBlockedSite(name, url, category)` | New site add karo |
| `toggleBlockedSite(id)` | Site on/off toggle |
| `removeBlockedSite(id)` | Site delete karo |
| `addChatMessage(role, content, mode)` | Chat message save |
| `clearChat()` | Chat history clear |
| `updateDailyGoal(minutes)` | Daily goal change |
| `resetAllData()` | Full data reset |

- **Depends on:** models/, constants.dart, shared_preferences
- **Used by:** Almost every screen

---

#### `focus_guardian_app/lib/providers/timer_provider.dart`
- **Path:** `lib/providers/timer_provider.dart`
- **Purpose:** Countdown timer logic with pause/resume
- **Why it exists:** Timer ko dedicated provider mein rakhna (separation of concerns)
- **Key Properties:**

| Property | Type | Purpose |
|----------|------|---------|
| `_totalSeconds` | int | Total time set by user |
| `_remainingSeconds` | int | Countdown value |
| `_isRunning` | bool | Timer active? |
| `_isPaused` | bool | Timer paused? |
| `_activeSessionId` | String? | Which session this timer belongs to |

**Key Methods:**
- `startTimer(durationMinutes, sessionId)` → Timer.periodic start karta hai (1 sec interval)
- `pauseTimer()` → _isPaused = true
- `resumeTimer()` → _isPaused = false
- `togglePause()` → Pause/resume toggle
- `stopTimer()` → Timer cancel + cleanup
- `reset()` → Full reset to initial state

**Computed Properties:**
- `progress` → 0.0 to 1.0 (for circular indicator)
- `displayTime` → "25:00" format
- `elapsedFormatted` → "5:30" format

- **Depends on:** dart:async (Timer)
- **Used by:** timer_screen.dart

---

#### Flutter Screens (12 files)

| Screen | Path | Purpose | Key Widgets |
|--------|------|---------|-------------|
| `splash_screen.dart` | `screens/` | App loading + auth check | AnimatedOpacity, Timer |
| `login_screen.dart` | `screens/` | Login form | TextFormField, ElevatedButton |
| `signup_screen.dart` | `screens/` | Registration form | Form, validators |
| `home_screen.dart` | `screens/` | Bottom navigation container | BottomNavigationBar, IndexedStack |
| `dashboard_screen.dart` | `screens/` | Stats overview | Cards, charts, progress |
| `timer_screen.dart` | `screens/` | Focus timer UI | CircularPercentIndicator, Consumer |
| `chat_screen.dart` | `screens/` | AI chat interface | ListView, TextField, mode chips |
| `reports_screen.dart` | `screens/` | Analytics & charts | fl_chart, period selector |
| `blocking_screen.dart` | `screens/` | Site blocking management | ListView, switches, add dialog |
| `badges_screen.dart` | `screens/` | Badge gallery | GridView, badge cards |
| `settings_screen.dart` | `screens/` | App settings | Sliders, toggles, buttons |
| `profile_tab.dart` | `screens/` | User profile display | Avatar, stats, level |

---


## 4. CODE EXPLANATION (Important Functions)

### 4.1 UserProfile Model (Django)

**Location:** `focus_guardian/core/models.py`

UserProfile Django ke built-in User model ko **extend** karta hai. One-to-One relationship hai:

```python
class UserProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name="profile")
```

**Core Fields:**

| Field | Type | Default | Validation | Purpose |
|-------|------|---------|------------|---------|
| `focus_score` | IntegerField | 100 | 0-100 | Overall focus rating |
| `total_study_time` | DurationField | 0:00:00 | - | Lifetime study time |
| `streak_days` | IntegerField | 0 | ≥0 | Current streak |
| `longest_streak` | IntegerField | 0 | ≥0 | Best streak ever |
| `last_study_date` | DateField | null | - | Last session date |
| `total_sessions_completed` | IntegerField | 0 | ≥0 | Session count |
| `total_distractions` | IntegerField | 0 | ≥0 | Lifetime distractions |
| `daily_goal_minutes` | IntegerField | 120 | 15-720 | Daily target |
| `avatar_color` | CharField | "#6c63ff" | - | Profile color |
| `theme` | CharField | "dark" | choices | UI theme |
| `timer_sound` | CharField | "bell" | choices | Timer alert sound |
| `break_duration` | IntegerField | 5 | 1-30 | Break length |

**Properties (Computed at runtime, DB mein store nahi hote):**

```python
@property
def level(self):
    """Study hours ke basis pe level calculate karo."""
    hours = self.total_study_hours  # timedelta → hours conversion
    if hours >= 500: return "Grandmaster"
    elif hours >= 200: return "Master"
    elif hours >= 100: return "Expert"
    elif hours >= 50: return "Advanced"
    elif hours >= 20: return "Intermediate"
    elif hours >= 5: return "Apprentice"
    return "Beginner"

@property
def xp_points(self):
    """XP = study minutes + badge bonus + streak bonus"""
    base_xp = int(self.total_study_time.total_seconds() / 60)  # 1 XP per minute
    badge_xp = self.user.badges.count() * 50                    # 50 XP per badge
    streak_xp = self.streak_days * 10                            # 10 XP per streak day
    return base_xp + badge_xp + streak_xp

@property
def focus_grade(self):
    """Letter grade - school-style grading"""
    score = self.focus_score
    if score >= 95: return "A+"
    elif score >= 90: return "A"
    elif score >= 85: return "B+"
    elif score >= 80: return "B"
    elif score >= 70: return "C"
    elif score >= 60: return "D"
    return "F"

@property
def daily_goal_progress(self):
    """Aaj kitna percent goal complete hua"""
    today = timezone.now().date()
    today_sessions = FocusSession.objects.filter(
        user=self.user, start_time__date=today, is_active=False
    )
    today_minutes = sum(s.duration_minutes for s in today_sessions)
    return min(round((today_minutes / self.daily_goal_minutes) * 100, 1), 100)
```

**Level Progression System:**
```
0-5 hours    → Beginner
5-20 hours   → Apprentice  
20-50 hours  → Intermediate
50-100 hours → Advanced
100-200 hrs  → Expert
200-500 hrs  → Master
500+ hours   → Grandmaster
```

---

### 4.2 FocusSession Model

**Location:** `focus_guardian/core/models.py`

Har ek study session ka record. Session start hoti hai (is_active=True), phir end hoti hai (is_active=False).

```python
class FocusSession(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="focus_sessions")
    subject = models.CharField(max_length=100, default="General Study")
    session_type = models.CharField(max_length=20, choices=SESSION_TYPES, default="pomodoro")
    start_time = models.DateTimeField(auto_now_add=True)  # Auto-set on creation
    end_time = models.DateTimeField(null=True, blank=True)
    planned_duration = models.IntegerField(default=25)    # Minutes
    is_active = models.BooleanField(default=True)
    is_completed = models.BooleanField(default=False)
    focus_score = models.IntegerField(default=100)
```

**Session Types:**
| Type | Display Name | Duration |
|------|-------------|----------|
| pomodoro | Pomodoro | 25 min |
| deep_work | Deep Work | 50 min |
| short | Short Session | 15 min |
| custom | Custom Duration | User defined |
| marathon | Marathon | 90 min |

**Key Properties:**
```python
@property
def duration(self):
    """Session kitni der chali"""
    if self.end_time:
        return self.end_time - self.start_time
    if self.is_active:
        return timezone.now() - self.start_time  # Still running
    return timedelta(0)

@property
def completion_percentage(self):
    """Planned duration ka kitna % complete hua"""
    return min(round((self.duration_minutes / self.planned_duration) * 100, 1), 100)

@property
def distraction_count(self):
    """Is session mein kitni distractions hui"""
    return self.distractions.count()  # Reverse relation use karke
```

**Database Indexes (Performance ke liye):**
```python
class Meta:
    ordering = ["-start_time"]  # Newest first
    indexes = [
        models.Index(fields=["user", "-start_time"]),  # User ki sessions jaldi find ho
        models.Index(fields=["user", "is_active"]),    # Active session quickly find ho
        models.Index(fields=["start_time"]),            # Date-based queries fast
    ]
```

---

### 4.3 Badge Model

**Location:** `focus_guardian/core/models.py`

24 badge types hain with 4 rarity levels:

```python
class Badge(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="badges")
    badge_type = models.CharField(max_length=50, choices=BADGE_TYPES)
    earned_at = models.DateTimeField(auto_now_add=True)
    is_new = models.BooleanField(default=True)  # Unseen badge indicator

    class Meta:
        unique_together = ["user", "badge_type"]  # Ek user ko ek badge ek hi baar mile
```

**Rarity Classification (property-based):**
```python
@property
def rarity(self):
    # Legendary (Red) - hardest to earn
    legendary_badges = ["marathon"]  # 90+ min session
    
    # Rare (Gold) - very difficult
    rare_badges = ["streak_100", "hours_200", "hours_100", "streak_60"]
    
    # Epic (Purple) - challenging
    epic_badges = ["streak_30", "hours_50", "no_distraction_5", "focus_master", "deep_thinker"]
    
    # Common (Teal) - easier milestones
    # Everything else

    if self.badge_type in legendary_badges: return "Legendary"
    elif self.badge_type in rare_badges: return "Rare"
    elif self.badge_type in epic_badges: return "Epic"
    return "Common"
```

**Icon Mapping (Bootstrap Icons names):**
```python
@property
def icon(self):
    icons = {
        "first_session": "play-circle-fill",
        "streak_3": "fire",
        "streak_7": "trophy-fill",
        "streak_14": "stars",
        "streak_30": "gem",
        "streak_60": "diamond-fill",
        "streak_100": "crown",
        "hours_1": "hourglass-split",
        "hours_5": "clock-fill",
        # ... etc
    }
```

---

### 4.4 check_and_award_badges() - Badge Awarding Logic

**Location:** `focus_guardian/core/services.py`

Ye function har session end hone pe call hota hai. **24 conditions** check karta hai:

```python
def check_and_award_badges(user):
    profile = UserProfile.objects.get(user=user)
    awarded = []

    def try_award(badge_type):
        """Badge create karo agar pehle se nahi mila hai"""
        badge, created = Badge.objects.get_or_create(user=user, badge_type=badge_type)
        if created:  # Naya badge mila!
            awarded.append(badge)
            return True
        return False
```

**Badge Conditions Table:**

| Badge | Condition | Category |
|-------|-----------|----------|
| first_session | 1 completed session | Milestone |
| streak_3 | 3 day streak | Streak |
| streak_7 | 7 day streak | Streak |
| streak_14 | 14 day streak | Streak |
| streak_30 | 30 day streak | Streak |
| streak_60 | 60 day streak | Streak |
| streak_100 | 100 day streak | Streak |
| hours_1 | 1 hour total study | Hours |
| hours_5 | 5 hours total study | Hours |
| hours_10 | 10 hours total study | Hours |
| hours_20 | 20 hours total study | Hours |
| hours_50 | 50 hours total study | Hours |
| hours_100 | 100 hours total study | Hours |
| hours_200 | 200 hours total study | Hours |
| no_distraction | 15+ min session, 0 distractions | Performance |
| no_distraction_5 | 5 such perfect sessions | Performance |
| focus_master | Focus score = 100 | Performance |
| early_bird | Session started before 6 AM | Time-based |
| night_owl | Session started after 11 PM | Time-based |
| marathon | 90+ min completed session | Duration |
| consistent | 5+ sessions in one day | Consistency |
| comeback | Return after 3+ days break | Resilience |
| speed_learner | 3 sessions in under 2 hours | Speed |
| deep_thinker | 60+ min on single subject | Depth |

**How it works internally:**
```python
# Streak badges - simple threshold check
streak = profile.streak_days
if streak >= 3: try_award("streak_3")
if streak >= 7: try_award("streak_7")
# ...

# Hours badges - cumulative check
hours = profile.total_study_hours
if hours >= 1: try_award("hours_1")
if hours >= 5: try_award("hours_5")
# ...

# Zero distraction - loop through recent sessions
for session in completed_sessions.filter(is_completed=True)[:20]:
    if session.distractions.count() == 0 and session.duration_minutes >= 15:
        try_award("no_distraction")
        break

# Comeback - gap detection
if profile.last_study_date and profile.streak_days == 1:
    sessions_list = list(recent_sessions)
    gap = sessions_list[0].start_time.date() - sessions_list[1].end_time.date()
    if gap.days >= 3:
        try_award("comeback")
```

---

### 4.5 calculate_session_score() - Scoring Algorithm

**Location:** `focus_guardian/core/services.py`

```python
def calculate_session_score(session):
    """0-100 score based on distractions, completion, duration"""
    
    score = 100.0  # Start with perfect score

    # PENALTY: Each distraction reduces score based on severity
    for d in session.distractions.all():
        if d.severity == "high":
            score -= 10    # Instagram 10 min ke liye khola → HIGH
        elif d.severity == "medium":
            score -= 5     # Tab switch for 30 sec → MEDIUM
        else:
            score -= 3     # Quick notification check → LOW

    # BONUS: Completed planned duration
    if session.duration_minutes >= session.planned_duration:
        score += 10       # Full duration complete!
    elif session.duration_minutes >= session.planned_duration * 0.75:
        score += 5        # At least 75% complete

    # BONUS: No distractions + 30+ min focus
    if distraction_count == 0 and duration_minutes >= 30:
        score += 5        # Pure focus reward

    # PENALTY: Very short sessions
    if duration_minutes < 5:
        score -= 10       # Too short to be meaningful

    return max(0, min(100, int(round(score))))  # Clamp 0-100
```

**Score Examples:**

| Scenario | Calculation | Final Score |
|----------|-------------|-------------|
| 25 min, 0 distractions, completed | 100 + 10 + 5 = 115 → clamped | 100 |
| 25 min, 2 medium distractions | 100 - 5 - 5 + 10 = 100 | 100 |
| 25 min, 1 high + 2 medium | 100 - 10 - 5 - 5 + 10 = 90 | 90 |
| 15 min (of 25 planned), 3 high | 100 - 30 + 0 = 70 | 70 |
| 3 min, 0 distractions | 100 - 10 (too short) = 90 | 90 |
| 30 min, 5 high distractions | 100 - 50 + 10 = 60 | 60 |

---

### 4.6 update_streak() - Streak Logic

**Location:** `focus_guardian/core/services.py`

```python
def update_streak(user):
    profile = UserProfile.objects.get(user=user)
    today = timezone.now().date()

    if profile.last_study_date is None:
        # First ever session
        profile.streak_days = 1
    
    elif profile.last_study_date == today:
        # Already studied today - no change
        return profile.streak_days
    
    elif profile.last_study_date == today - timedelta(days=1):
        # Kal bhi padha tha → Streak continues!
        profile.streak_days += 1
    
    else:
        # Ek din ya zyada miss kiya → Streak broken!
        profile.streak_days = 1

    # Track longest streak ever
    if profile.streak_days > profile.longest_streak:
        profile.longest_streak = profile.streak_days

    profile.last_study_date = today
    profile.save()
    return profile.streak_days
```

**Streak Logic Visualization:**
```
Day 1: Study → streak = 1, last_study = Day 1
Day 2: Study → streak = 2, last_study = Day 2 (consecutive!)
Day 3: Study → streak = 3, last_study = Day 3
Day 4: NO STUDY (skip)
Day 5: Study → streak = 1 (RESET!), last_study = Day 5
```

---

### 4.7 get_ai_response() - AI Flow

**Location:** `focus_guardian/core/services.py`

```python
def get_ai_response(user_message, user, chat_history=None, mode="general"):
    """Two-tier approach: OpenAI first, mock fallback"""
    
    api_key = os.getenv("OPENAI_API_KEY", "")

    if api_key:
        # TRY OpenAI
        response = _get_openai_response(user_message, user, chat_history, mode, api_key)
        if response:
            return response  # OpenAI worked!

    # FALLBACK: Smart mock responses (keyword-based)
    return _get_mock_response(user_message, mode)
```

**OpenAI Call Structure:**
```python
def _get_openai_response(user_message, user, chat_history, mode, api_key):
    client = openai.OpenAI(api_key=api_key)
    
    # 1. System prompt (mode ke according)
    system_content = system_prompts[mode]
    
    # 2. User context add karo
    system_content += f"\nUser: {user.username}, Level: {profile.level}, Streak: {profile.streak_days}"
    
    # 3. Chat history (last 10 messages)
    messages = [{"role": "system", "content": system_content}]
    for msg in chat_history[-10:]:
        messages.append({"role": msg.role, "content": msg.content})
    messages.append({"role": "user", "content": user_message})
    
    # 4. API call
    response = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=messages,
        max_tokens=800,
        temperature=0.7,
    )
    return response.choices[0].message.content
```

**Mock Response System (No API key ke case mein):**
- Keyword matching se relevant response deta hai
- "focus" → focus tips
- "motivat" → motivational message
- "plan" → study plan advice
- "hello" → friendly greeting
- Default → mode-specific default response

---

### 4.8 get_weekly_chart_data() - Analytics

**Location:** `focus_guardian/core/services.py`

```python
def get_weekly_chart_data(user, days=7):
    """Last 7 days ka data - Chart.js ke liye"""
    data = {"labels": [], "study_minutes": [], "distractions": [], "scores": []}
    
    for i in range(days - 1, -1, -1):  # 6, 5, 4, 3, 2, 1, 0 (oldest → newest)
        date = (timezone.now() - timedelta(days=i)).date()
        
        # Us din ki sessions
        day_sessions = FocusSession.objects.filter(
            user=user, start_time__date=date, is_active=False
        )
        day_minutes = sum(s.duration_minutes for s in day_sessions)
        
        # Us din ki distractions
        day_distractions = Distraction.objects.filter(
            session__user=user, session__start_time__date=date
        ).count()
        
        data["labels"].append(date.strftime("%a"))  # "Mon", "Tue", etc.
        data["study_minutes"].append(round(day_minutes, 1))
        data["distractions"].append(day_distractions)
        data["scores"].append(round(avg_score, 1))

    return data
```

**Output Example:**
```json
{
  "labels": ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"],
  "study_minutes": [45, 60, 30, 90, 75, 120, 55],
  "distractions": [3, 1, 5, 2, 0, 1, 4],
  "scores": [85, 92, 70, 88, 100, 95, 78]
}
```

---

### 4.9 StartFocusSessionView.post() - Session Creation

**Location:** `focus_guardian/core/views.py`

```python
class StartFocusSessionView(APIView):
    throttle_classes = [SessionRateThrottle]  # Max 10/min

    def post(self, request):
        with transaction.atomic():
            # 1. CANCEL any existing active sessions
            active_sessions = FocusSession.objects.filter(user=request.user, is_active=True)
            for session in active_sessions:
                session.is_active = False
                session.end_time = timezone.now()
                session.save()

            # 2. VALIDATE input
            subject = request.data.get("subject", "General Study").strip()
            if len(subject) > 100:
                return Response({"error": "Subject must be 100 characters or less"}, 400)

            planned_duration = request.data.get("planned_duration", 25)
            planned_duration = int(planned_duration)
            if planned_duration < 1 or planned_duration > 300:
                return Response({"error": "Duration must be between 1 and 300 minutes"}, 400)

            # 3. CREATE new session
            session = FocusSession.objects.create(
                user=request.user,
                subject=subject,
                planned_duration=planned_duration,
                session_type=request.data.get("session_type", "pomodoro"),
                mood_before=request.data.get("mood", ""),
            )

        # 4. RETURN serialized response
        return Response(FocusSessionSerializer(session).data, status=201)
```

**Key Points:**
- `transaction.atomic()` → Ya toh sab hoga, ya kuch nahi (database safety)
- Purani active sessions auto-close hoti hain
- Rate limiting: Max 10 sessions/minute (spam protection)
- Input validation: subject max 100 chars, duration 1-300 min

---

### 4.10 EndFocusSessionView.post() - Session End with Atomic Transaction

**Location:** `focus_guardian/core/views.py`

```python
class EndFocusSessionView(APIView):
    def post(self, request):
        with transaction.atomic():
            # 1. FIND active session (lock row for update)
            session = FocusSession.objects.select_for_update().get(
                user=request.user, is_active=True
            )
            
            # 2. END session
            session.is_active = False
            session.end_time = timezone.now()
            
            # 3. CHECK completion (90% of planned = completed)
            if session.duration_minutes >= session.planned_duration * 0.9:
                session.is_completed = True
            
            # 4. CALCULATE score
            score = calculate_session_score(session)
            session.focus_score = score
            session.save()

            # 5. UPDATE profile (weighted average)
            profile = UserProfile.objects.select_for_update().get(user=request.user)
            profile.total_study_time += session.duration
            profile.total_sessions_completed += 1
            
            # Focus score = 70% old + 30% new (weighted average)
            profile.focus_score = round((profile.focus_score * 0.7) + (score * 0.3))
            profile.focus_score = max(0, min(100, profile.focus_score))
            profile.save()

            # 6. UPDATE study log
            update_study_log(session)

            # 7. UPDATE streak
            streak = update_streak(request.user)

            # 8. CHECK badges
            new_badges = check_and_award_badges(request.user)

        # 9. RETURN response with all results
        return Response({
            "session_score": score,
            "new_badges": [...],
            "streak_days": streak,
            "is_completed": session.is_completed,
        })
```

**Important concepts:**
- `select_for_update()` → Database row ko lock karta hai (concurrent access safe)
- `transaction.atomic()` → Agar beech mein error aaye toh sab rollback
- Weighted average: `new_score = old * 0.7 + session_score * 0.3`
- 90% rule: 25 min session mein 22.5+ min padha = "completed"

---

### 4.11 LogDistractionView.post()

**Location:** `focus_guardian/core/views.py`

```python
class LogDistractionView(APIView):
    def post(self, request):
        # 1. Find active session
        session = FocusSession.objects.get(user=request.user, is_active=True)
        
        # 2. Validate inputs
        app_name = request.data.get("app_name", "Unknown").strip()[:255]
        distraction_type = request.data.get("distraction_type", "app_switch")
        severity = request.data.get("severity", "medium")
        
        # 3. Create distraction record
        distraction = Distraction.objects.create(
            session=session,
            app_name=app_name,
            distraction_type=distraction_type,
            severity=severity,
        )

        # 4. Update blocked site counter (if site is in block list)
        blocked = BlockedSite.objects.filter(
            user=request.user, name__icontains=app_name, is_active=True
        ).first()
        if blocked:
            blocked.times_blocked = F("times_blocked") + 1  # Atomic increment
            blocked.save()

        # 5. Apply real-time score penalty
        penalty = distraction.score_penalty  # 3/5/10 based on severity
        profile = UserProfile.objects.get(user=request.user)
        profile.focus_score = max(0, profile.focus_score - penalty)
        profile.save()

        return Response({
            "penalty": penalty,
            "new_score": profile.focus_score,
            "total_distractions": session.distraction_count,
        }, status=201)
```

**Severity Penalties:**
| Severity | Penalty | Example |
|----------|---------|---------|
| low | -3 points | Quick notification glance |
| medium | -5 points | Tab switch for 30 sec |
| high | -10 points | Opening Instagram for 5+ min |

---

### 4.12 AppProvider (Flutter) - Full State Management

**Location:** `focus_guardian_app/lib/providers/app_provider.dart`

Ye Flutter app ka **brain** hai. Saara data yahan manage hota hai:

```dart
class AppProvider extends ChangeNotifier {
  // State
  UserProfile _profile = UserProfile();
  List<FocusSession> _sessions = [];
  List<BlockedSite> _blockedSites = [];
  List<ChatMessage> _chatHistory = [];
  List<String> _earnedBadges = [];
```

**Data Persistence Strategy:**
```dart
Future<void> _saveData() async {
  final prefs = await SharedPreferences.getInstance();
  // Save each piece of state
  await prefs.setInt('focus_score', _profile.focusScore);
  await prefs.setString('sessions', json.encode(_sessions.map((e) => e.toJson()).toList()));
  await prefs.setStringList('badges', _earnedBadges);
  // ... etc
}
```

**Session End Logic (Mirror of Django):**
```dart
Map<String, dynamic> endSession(String sessionId) {
  final session = _sessions.firstWhere((s) => s.id == sessionId);
  session.isActive = false;
  session.endTime = DateTime.now();

  // Completion check (90% rule)
  if (session.durationMinutes >= session.plannedDuration * 0.9) {
    session.isCompleted = true;
  }

  // Score calculation
  int score = 100;
  score -= session.distractionCount * 5;
  if (session.isCompleted) score += 10;
  if (session.distractionCount == 0 && session.durationMinutes >= 30) score += 5;
  score = score.clamp(0, 100);

  // Profile update (weighted average)
  _profile.focusScore = ((_profile.focusScore * 0.7) + (score * 0.3)).round().clamp(0, 100);
  
  // Streak + Badges
  _updateStreak();
  final newBadges = _checkBadges(session);
  
  _saveData();
  notifyListeners();  // UI ko update karo!
  
  return {'score': score, 'new_badges': newBadges, ...};
}
```

---

### 4.13 TimerProvider (Flutter) - Countdown Logic

**Location:** `focus_guardian_app/lib/providers/timer_provider.dart`

```dart
class TimerProvider extends ChangeNotifier {
  Timer? _timer;           // Dart's periodic timer
  int _totalSeconds;       // Full duration (e.g., 25 * 60 = 1500)
  int _remainingSeconds;   // Countdown value
  bool _isRunning;
  bool _isPaused;

  void startTimer(int durationMinutes, String sessionId) {
    _totalSeconds = durationMinutes * 60;
    _remainingSeconds = _totalSeconds;
    _isRunning = true;
    _isPaused = false;
    _activeSessionId = sessionId;

    _timer?.cancel();  // Cancel any existing timer
    
    // Create new timer - fires every 1 second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
          notifyListeners();  // UI update karo (every second!)
        } else {
          stopTimer();  // Time's up!
        }
      }
    });
    notifyListeners();
  }

  // Progress for CircularPercentIndicator (0.0 to 1.0)
  double get progress {
    if (_totalSeconds == 0) return 0;
    return 1.0 - (_remainingSeconds / _totalSeconds);
  }

  // Display format: "25:00" or "04:30"
  String get displayTime {
    int mins = _remainingSeconds ~/ 60;
    int secs = _remainingSeconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
```

**Timer Lifecycle:**
```
User taps "Start" → startTimer(25, sessionId)
                         │
                         ▼
              Timer.periodic(1 second)
                         │
                    ┌────┴────┐
                    │ Running  │ ← _remainingSeconds-- every second
                    └────┬────┘
                         │
            ┌────────────┼────────────┐
            │            │            │
     Tap "Pause"    Time = 0    Tap "Stop"
            │            │            │
            ▼            ▼            ▼
      _isPaused=true  stopTimer()  stopTimer()
            │                        │
     Tap "Resume"                    ▼
            │                 Session ends
            ▼
      _isPaused=false
```

---


## 5. FEATURE IMPLEMENTATION (Each Feature Detailed)

### Feature 1: User Authentication

**Objective:** Users apna account create karein, login karein, aur securely access karein.

**User Flow:**
```
1. User opens app/website
2. Landing page dikhti hai (not logged in)
3. "Sign Up" click karta hai
4. Form fill karta hai: username, email, password
5. Submit → Profile auto-created → Dashboard pe redirect
6. Next time: Login with username + password
7. Session maintained (web: cookie, mobile: SharedPreferences)
```

**Backend Implementation (Django):**
```python
# Signup (views.py)
def signup_view(request):
    form = SignupForm(request.POST)
    if form.is_valid():
        with transaction.atomic():
            user = form.save()        # User create
            # Profile auto-created via signal!
            login(request, user)      # Auto-login
            return redirect("dashboard")

# Signal (signals.py) - auto UserProfile creation
@receiver(post_save, sender=User)
def create_user_profile(sender, instance, created, **kwargs):
    if created:
        UserProfile.objects.create(user=instance)
```

**Frontend Implementation:**
- **Web:** Django forms with Bootstrap styling, CSRF protection, error messages via Django messages framework
- **Mobile (Flutter):** TextFormField widgets, AuthProvider.login() / signup(), SharedPreferences storage

**Database Tables:** User (Django built-in) + UserProfile (our model)

**APIs:** N/A (web uses Django sessions, mobile uses local auth)

**Edge Cases Handled:**
- Duplicate email check in SignupForm.clean_email()
- Empty username/password validation
- Redirect if already logged in
- POST-only logout (CSRF protection)
- `@login_required` on all protected views
- Inactive account detection (`user.is_active`)

**Possible Improvements:**
- JWT tokens for proper mobile API auth
- OAuth (Google/GitHub login)
- Email verification
- Password reset via email
- Two-factor authentication

---

### Feature 2: Focus Timer

**Objective:** Users apna study time track karein with countdown timer, subject selection, aur mood tracking.

**User Flow:**
```
1. User goes to Timer page
2. Selects subject (dropdown or type)
3. Sets duration (5-300 minutes)
4. Selects mood (before studying)
5. Clicks "Start Focus Session"
6. Timer countdown starts (SVG circle web / CircularIndicator mobile)
7. During session: can pause, resume, or stop
8. Timer reaches 0 OR user clicks "End Session"
9. Results shown: score, duration, distractions, new badges
```

**Backend Implementation:**
```python
# Start: creates FocusSession record
session = FocusSession.objects.create(
    user=request.user,
    subject=subject,
    planned_duration=planned_duration,
    session_type=session_type,
    mood_before=mood,
)
# is_active=True by default, start_time=auto_now_add

# End: closes session + calculates everything
session.is_active = False
session.end_time = timezone.now()
score = calculate_session_score(session)
update_study_log(session)
update_streak(request.user)
new_badges = check_and_award_badges(request.user)
```

**Frontend Implementation:**
- **Web (timer.html):** SVG circular progress, JavaScript fetch API for start/end/distraction, real-time countdown
- **Mobile (timer_screen.dart):** `Consumer<TimerProvider>` + `CircularPercentIndicator`, provider-based state

**Database Tables:** FocusSession, Distraction (created during session)

**APIs:**
- `POST /api/session/start/` → {subject, planned_duration, mood}
- `POST /api/session/end/` → {mood_after, notes}
- `GET /api/session/active/` → current session data
- `POST /api/distraction/` → {app_name, type, severity}

**Edge Cases Handled:**
- Multiple active sessions → auto-close old ones on new start
- Duration validation: 1-300 minutes only
- Rate throttling: max 10 session operations/minute
- `select_for_update()` prevents race conditions
- 90% completion rule (22.5 min of 25 = completed)

**Possible Improvements:**
- Sound notification when timer ends
- Browser notification (Web Notifications API)
- Background timer (mobile foreground service)
- Auto-break suggestion after session
- Pomodoro cycle tracking (4 sessions → long break)

---

### Feature 3: AI Teacher Chat

**Objective:** Students ko 24/7 AI tutor milna chahiye - doubts, motivation, quiz, study plans sab ke liye.

**User Flow:**
```
1. User goes to Chat page
2. Selects mode: General / Teacher / Quiz / Study Plan / Motivation
3. Types message and sends
4. User message saved to DB/local storage
5. Backend processes: OpenAI API call (or mock fallback)
6. AI response saved and displayed
7. Chat history maintained (scrollable)
8. Can clear chat history
```

**Backend Implementation:**
```python
class AITeacherView(APIView):
    throttle_classes = [ChatRateThrottle]  # 30/min

    def post(self, request):
        message = request.data.get("message", "").strip()
        mode = request.data.get("mode", "general")
        
        # Save user message
        ChatMessage.objects.create(user=request.user, role="user", content=message, mode=mode)
        
        # Get AI response (OpenAI → mock fallback)
        ai_response = get_ai_response(message, request.user, chat_history, mode)
        
        # Save AI response
        ChatMessage.objects.create(user=request.user, role="assistant", content=ai_response, mode=mode)
        
        return Response({"reply": ai_response, "mode": mode})
```

**5 Chat Modes:**

| Mode | System Prompt Focus | Use Case |
|------|-------------------|----------|
| general | Helpful study assistant | General questions |
| teacher | Strict tutor, Socratic method | Concept verification |
| quiz | Question generator + feedback | Self-testing |
| study_plan | Schedule creator | Planning |
| motivation | Energetic coach | When feeling low |

**Database Tables:** ChatMessage (user, role, content, mode, timestamp)

**APIs:**
- `POST /api/ai-teacher/` → {message, mode} → {reply, mode}
- `POST /api/chat/clear/` → clears all chat history

**Edge Cases Handled:**
- Message length cap: 2000 characters max
- Rate limiting: 30 messages/minute
- API key missing → graceful mock fallback
- OpenAI error → mock fallback
- Mode validation (invalid mode → "general")

**Possible Improvements:**
- Image/file upload for problem solving
- Voice input (speech-to-text)
- Message pinning for important answers
- Export chat as PDF
- GPT-4 upgrade option
- RAG (Retrieval Augmented Generation) with study materials

---

### Feature 4: Distraction Detection

**Objective:** Jab user distract ho (tab switch, app open), detect karo aur log karo for accountability.

**User Flow:**
```
1. User starts focus session
2. DURING session:
   a. Web: Tab visibility API detects tab switch → auto-log
   b. Web: User clicks "I got distracted" → manual log
   c. Mobile: User self-reports distraction
3. Distraction logged with severity
4. Real-time score penalty applied
5. Toast notification: "-5 points! Stay focused!"
6. Session end: total distractions shown in results
```

**Backend Implementation:**
```python
# Distraction model
class Distraction(models.Model):
    session = models.ForeignKey(FocusSession, related_name="distractions")
    app_name = models.CharField(max_length=255)
    distraction_type = models.CharField(choices=DISTRACTION_TYPES)
    severity = models.CharField(choices=SEVERITY_CHOICES)
    
    @property
    def score_penalty(self):
        penalties = {"low": 3, "medium": 5, "high": 10}
        return penalties.get(self.severity, 5)
```

**Distraction Types:**
| Type | Detection Method | Severity |
|------|-----------------|----------|
| tab_switch | Document.hidden API (web) | low-medium |
| app_switch | Manual/system (mobile) | medium |
| website | Blocked site accessed | high |
| inactivity | No interaction for X min | low |
| notification | System notification | low |
| phone | Phone usage detected | medium |
| manual | User self-reported | varies |

**Database Tables:** Distraction (linked to FocusSession)

**APIs:** `POST /api/distraction/` → {app_name, distraction_type, severity}

**Edge Cases Handled:**
- No active session → 404 response
- BlockedSite counter increment (F expression for atomic update)
- Severity validation (invalid → default "medium")
- Real-time profile score update

**Possible Improvements:**
- Browser extension for actual site detection
- Phone usage detection (Android accessibility service)
- Automatic severity classification
- Distraction patterns analysis
- "Focus mode" that blocks at OS level

---

### Feature 5: Site Blocking

**Objective:** Users un sites/apps ko block karein jo unhe distract karti hain.

**User Flow:**
```
1. User goes to Blocking page
2. Sees current blocked sites (grouped by category)
3. Adds new site: name, URL, category
4. Site appears in block list (active by default)
5. Can toggle site active/inactive
6. Can delete site permanently
7. times_blocked counter increments when distraction matches
```

**Backend Implementation:**
```python
# BlockedSite model
class BlockedSite(models.Model):
    user = models.ForeignKey(User, related_name="blocked_sites")
    name = models.CharField(max_length=100)
    url = models.CharField(max_length=255)
    category = models.CharField(choices=CATEGORY_CHOICES)
    is_active = models.BooleanField(default=True)
    times_blocked = models.IntegerField(default=0)

    class Meta:
        unique_together = ["user", "url"]  # No duplicate URLs per user
```

**8 Categories:**
| Category | Color | Examples |
|----------|-------|----------|
| social_media | Red | Instagram, Twitter, Facebook |
| entertainment | Orange | Reddit, 9GAG |
| gaming | Purple | Steam, Discord (gaming) |
| news | Blue | Times, CNN |
| shopping | Green | Amazon, Flipkart |
| messaging | Teal | WhatsApp Web, Telegram |
| video | Dark Orange | YouTube, Netflix |
| other | Gray | Everything else |

**Frontend Implementation:**
- **Web:** Form (BlockedSiteForm) + AJAX toggle/delete
- **Mobile:** Dialog for adding, Slidable for delete, Switch for toggle

**Database Tables:** BlockedSite

**APIs:**
- `POST /api/blocked-site/{id}/toggle/` → toggles is_active
- `DELETE /api/blocked-site/{id}/delete/` → removes site

**Edge Cases Handled:**
- Duplicate URL detection
- URL cleanup (remove http://, www., trailing slash)
- Category grouping in UI
- times_blocked counter (atomic increment with F())

**Possible Improvements:**
- Browser extension that actually blocks the site
- Schedule-based blocking (only during study hours)
- Preset templates (JEE student, UPSC aspirant)
- Whitelist mode (block everything except allowed)
- Cooldown period (can't unblock for X minutes)

---

### Feature 6: Study Reports & Analytics

**Objective:** Users ko dikhao kitna padha, kab padha, kismein padha - data-driven insights.

**User Flow:**
```
1. User goes to Reports page
2. Selects time period: 7 / 14 / 30 / 90 days
3. Sees overview: total hours, sessions, avg score, completion rate
4. Bar chart: daily study minutes
5. Line chart: focus score trend
6. Pie chart: subject distribution
7. Table: individual session details
8. "Best day" highlight
```

**Backend Implementation:**
```python
def reports_view(request):
    days = min(int(request.GET.get("days", 7)), 90)  # Cap at 90
    start_date = timezone.now() - timedelta(days=days)
    
    sessions = FocusSession.objects.filter(
        user=request.user, start_time__gte=start_date, is_active=False
    )
    
    # Aggregate stats
    total_minutes = sum(s.duration_minutes for s in sessions)
    total_distractions = sum(s.distraction_count for s in sessions)
    avg_score = study_logs.aggregate(avg=Avg("focus_score"))["avg"] or 0
    
    # Daily breakdown for chart
    daily_data = []
    for i in range(days):
        date = (timezone.now() - timedelta(days=i)).date()
        day_sessions = sessions.filter(start_time__date=date)
        daily_data.append({
            "date": date.strftime("%b %d"),
            "minutes": sum(s.duration_minutes for s in day_sessions),
            "sessions": day_sessions.count(),
        })
    
    # Subject breakdown
    subjects = study_logs.values("subject").annotate(
        total_min=Sum("duration_minutes"),
        avg_score=Avg("focus_score"),
    ).order_by("-total_min")
```

**Charts (Web - Chart.js):**
- Bar chart: Daily minutes
- Line chart: Daily focus scores
- Doughnut chart: Subject time distribution

**Charts (Mobile - fl_chart):**
- BarChart: Weekly/monthly study time
- LineChart: Score trend
- PieChart: Subject breakdown

**Database Tables:** FocusSession, StudyLog, Distraction

**APIs:** `GET /api/report/?days=7` → list of sessions with stats

**Edge Cases Handled:**
- No data → empty state with encouraging message
- Large date ranges → capped at 90 days
- Zero division protection (completion rate, averages)
- Top 8 subjects only (pie chart readability)

**Possible Improvements:**
- PDF export of reports
- Comparison with previous period
- Goal achievement tracking
- Heatmap (like GitHub contribution graph)
- Weekly email summary
- Peer comparison (anonymous)

---

### Feature 7: Badge/Gamification System

**Objective:** Padhai ko game banao - achievements, progress milestones, dopamine hits!

**User Flow:**
```
1. User completes a session
2. check_and_award_badges() runs automatically
3. If new badge earned → shown in session end popup
4. User goes to Badges page → sees all 24 badges
5. Earned badges: colorful with earned date
6. Locked badges: grayed out with description (what to do)
7. Rarity labels: Common / Epic / Rare / Legendary
```

**Complete Badge List (24 badges):**

| # | Badge | Condition | Rarity |
|---|-------|-----------|--------|
| 1 | First Session | Complete 1 session | Common |
| 2 | 3 Day Streak | 3 consecutive days | Common |
| 3 | Week Warrior | 7 day streak | Common |
| 4 | Two Week Champion | 14 day streak | Common |
| 5 | Monthly Master | 30 day streak | Epic |
| 6 | 60 Day Legend | 60 day streak | Rare |
| 7 | 100 Day Titan | 100 day streak | Rare |
| 8 | 1 Hour Club | 1 hour total | Common |
| 9 | 5 Hours Club | 5 hours total | Common |
| 10 | 10 Hours Club | 10 hours total | Common |
| 11 | 20 Hours Club | 20 hours total | Common |
| 12 | 50 Hours Club | 50 hours total | Epic |
| 13 | Century Scholar | 100 hours total | Rare |
| 14 | 200 Hour Hero | 200 hours total | Rare |
| 15 | Zero Distraction | 15+ min, 0 distractions | Common |
| 16 | 5 Perfect Sessions | 5 zero-distraction sessions | Epic |
| 17 | Early Bird | Session before 6 AM | Common |
| 18 | Night Owl | Session after 11 PM | Common |
| 19 | Focus Master | Focus score = 100 | Epic |
| 20 | Marathon Runner | 90+ min session | Legendary |
| 21 | Consistency King | 5+ sessions in one day | Common |
| 22 | Comeback Kid | Return after 3+ day break | Common |
| 23 | Speed Learner | 3 sessions in 2 hours | Common |
| 24 | Deep Thinker | 60+ min single subject | Epic |

**Database Tables:** Badge (unique_together: user + badge_type)

**Edge Cases Handled:**
- `get_or_create` prevents duplicate badges
- `is_new` flag for "new badge!" notification
- Badge page marks all as seen (is_new=False)

**Possible Improvements:**
- Badge tiers (Bronze → Silver → Gold for same achievement)
- Weekly challenges (earn 3 badges this week)
- Badge sharing on social media
- Leaderboard (compare with friends)
- Sound effect when badge earned

---

### Feature 8: Focus Scoring

**Objective:** Single 0-100 score jo user ki focus quality represent kare.

**User Flow:**
```
1. User starts with 100 score
2. During session: each distraction reduces score (3/5/10 penalty)
3. Session end: final session score calculated
4. Profile score updated: weighted average (70% old + 30% new)
5. Focus Grade assigned: A+, A, B+, B, C, D, F
6. Dashboard shows current score + grade prominently
```

**Scoring Formula:**
```
Session Score = 100
              - (low_distractions × 3)
              - (medium_distractions × 5)
              - (high_distractions × 10)
              + (completed_bonus: 10 or 5)
              + (perfect_focus_bonus: 5 if 0 distractions + 30min)
              - (too_short_penalty: 10 if < 5min)
              
Clamped to [0, 100]

Profile Score = old_score × 0.7 + session_score × 0.3
```

**Grade Scale:**
| Score Range | Grade |
|-------------|-------|
| 95-100 | A+ |
| 90-94 | A |
| 85-89 | B+ |
| 80-84 | B |
| 70-79 | C |
| 60-69 | D |
| 0-59 | F |

**Possible Improvements:**
- Score recovery mechanism (good sessions restore faster)
- Daily score cap (max drop per day)
- Subject-wise scores
- Historical score graph
- Score-based recommendations

---

### Feature 9: Streak System

**Objective:** Daily padhai ki consistency track karo - miss mat karo!

**User Flow:**
```
1. User completes first session → streak = 1
2. Next day completes a session → streak = 2
3. Continues daily → streak keeps incrementing
4. Misses a day → streak resets to 1
5. Dashboard shows: "🔥 7 day streak!"
6. Longest streak tracked separately
```

**Logic:**
```python
if last_study_date == None:       streak = 1   # First time
elif last_study_date == today:     no change    # Already counted today
elif last_study_date == yesterday: streak += 1  # Consecutive!
else:                              streak = 1   # Broken :(
```

**Database Fields:** `streak_days`, `longest_streak`, `last_study_date` (on UserProfile)

**Possible Improvements:**
- Streak freeze (1 free day per week)
- Streak milestones with rewards
- Streak recovery (study 2x next day to restore)
- Push notifications ("Don't break your streak!")
- Visual streak calendar (like Duolingo)

---

### Feature 10: Settings & Profile

**Objective:** User ko apna experience customize karne do.

**User Flow:**
```
1. User goes to Settings page
2. Can edit: bio, avatar color, daily goal, timer preferences
3. Can change password (old + new + confirm)
4. Can export all data as JSON
5. Can reset all stats (requires typing "RESET")
6. All changes save immediately
```

**Settings Available:**

| Setting | Field | Range | Default |
|---------|-------|-------|---------|
| Bio | CharField | max 200 | "" |
| Avatar Color | Color picker | Any hex | #6c63ff |
| Daily Goal | Minutes | 15-720 | 120 |
| Theme | Select | dark/light/midnight | dark |
| Timer Sound | Select | bell/chime/digital/none | bell |
| Break Duration | Minutes | 1-30 | 5 |
| Auto-start Breaks | Boolean | - | True |
| Show Quotes | Boolean | - | True |
| Distraction Alerts | Boolean | - | True |

**Special Actions:**
- **Change Password:** Django's PasswordChangeForm with session update
- **Export Data:** JSON download with profile, sessions, badges
- **Reset Stats:** Deletes all sessions, logs, badges, resets profile (requires "RESET" confirmation)

**Backend Implementation:**
```python
elif action == "reset_stats":
    confirm = request.POST.get("confirm_reset", "")
    if confirm == "RESET":
        with transaction.atomic():
            profile.focus_score = 100
            profile.total_study_time = timedelta(0)
            # ... reset all fields
            FocusSession.objects.filter(user=request.user).delete()
            StudyLog.objects.filter(user=request.user).delete()
            Badge.objects.filter(user=request.user).delete()
```

**Possible Improvements:**
- Theme preview before applying
- Custom timer sounds (upload)
- Notification preferences
- Language selection
- Account deletion
- Data import from JSON backup

---


## 6. COMMANDS DOCUMENTATION

### 6.1 Django Setup (Web App)

**Prerequisites:**
- Python 3.10+ installed
- pip (Python package manager)
- Git

**Step-by-step setup:**

```bash
# 1. Navigate to Django project
cd focus_guardian/

# 2. Create virtual environment (Python packages isolated rakhne ke liye)
python -m venv venv

# 3. Activate virtual environment
# Windows:
venv\Scripts\activate
# Mac/Linux:
source venv/bin/activate

# 4. Install dependencies
pip install -r requirements.txt

# 5. Create .env file (environment variables)
cp .env.example .env
# Edit .env and add:
# DJANGO_SECRET_KEY=your-secret-key-here
# DJANGO_DEBUG=True
# OPENAI_API_KEY=sk-your-openai-key  (optional)

# 6. Create database tables
python manage.py makemigrations
python manage.py migrate

# 7. Create admin user (optional but recommended)
python manage.py createsuperuser
# Username: admin
# Email: admin@example.com
# Password: (choose strong password)

# 8. Run development server
python manage.py runserver

# Server starts at: http://127.0.0.1:8000/
# Admin panel at: http://127.0.0.1:8000/admin/
```

**Common Django Commands:**

| Command | Purpose |
|---------|---------|
| `python manage.py runserver` | Start dev server (port 8000) |
| `python manage.py runserver 0.0.0.0:8000` | Start server (network accessible) |
| `python manage.py makemigrations` | Detect model changes |
| `python manage.py migrate` | Apply DB changes |
| `python manage.py createsuperuser` | Create admin user |
| `python manage.py shell` | Python shell with Django loaded |
| `python manage.py dbshell` | SQLite shell |
| `python manage.py flush` | Delete ALL data from DB |
| `python manage.py collectstatic` | Collect static files (production) |
| `python manage.py test` | Run tests |
| `pip freeze > requirements.txt` | Update dependencies file |

**Troubleshooting:**

```bash
# "No module named 'rest_framework'" error:
pip install djangorestframework

# "ModuleNotFoundError: No module named 'dotenv'" error:
pip install python-dotenv

# Database locked error (SQLite):
# Close all other connections (admin panel, another terminal)
# Or delete db.sqlite3 and re-migrate

# Port already in use:
python manage.py runserver 8001  # Use different port

# Migration conflicts:
python manage.py makemigrations --merge
```

---

### 6.2 Flutter Setup (Mobile App)

**Prerequisites:**
- Flutter SDK 3.0+ installed
- Android Studio or VS Code with Flutter extension
- Android emulator or physical device

**Step-by-step setup:**

```bash
# 1. Navigate to Flutter project
cd focus_guardian_app/

# 2. Get dependencies
flutter pub get

# 3. Check for issues
flutter doctor

# 4. Run on connected device/emulator
flutter run

# 5. Build APK (Android release)
flutter build apk --release

# 6. Build iOS (requires Mac + Xcode)
flutter build ios --release
```

**Common Flutter Commands:**

| Command | Purpose |
|---------|---------|
| `flutter pub get` | Install/update dependencies |
| `flutter pub upgrade` | Upgrade all packages |
| `flutter run` | Run on connected device |
| `flutter run -d chrome` | Run as web app |
| `flutter run -d windows` | Run as desktop app |
| `flutter build apk` | Build Android APK |
| `flutter build apk --split-per-abi` | Smaller APKs per architecture |
| `flutter build ios` | Build iOS (Mac only) |
| `flutter clean` | Clear build cache |
| `flutter analyze` | Check code for issues |
| `flutter test` | Run unit tests |
| `flutter devices` | List connected devices |
| `flutter doctor` | Check environment setup |

**Connecting to Django Backend (Optional):**

```dart
// In lib/utils/constants.dart, change baseUrl:

// For Android Emulator (10.0.2.2 = host machine's localhost):
static const String baseUrl = 'http://10.0.2.2:8000';

// For iOS Simulator:
static const String baseUrl = 'http://localhost:8000';

// For Physical Device (same WiFi):
static const String baseUrl = 'http://192.168.1.XXX:8000';
// (Replace XXX with your computer's local IP)

// For Production:
static const String baseUrl = 'https://your-domain.com';
```

**Troubleshooting:**

```bash
# "Gradle build failed" (Android):
cd android && ./gradlew clean && cd ..
flutter clean
flutter pub get
flutter run

# "CocoaPods not installed" (iOS):
sudo gem install cocoapods
cd ios && pod install && cd ..

# Hot reload not working:
# Press 'r' in terminal for hot reload
# Press 'R' for hot restart (full restart)

# "Pub get failed":
flutter pub cache repair
flutter pub get

# Build too slow:
flutter run --debug  # Debug mode (faster builds)
```

---

### 6.3 Database Management

```bash
# --- Django SQLite Database ---

# View database file:
ls -la focus_guardian/db.sqlite3

# Open SQLite shell:
python manage.py dbshell
# Inside SQLite:
.tables                          # List all tables
.schema core_userprofile         # Show table structure
SELECT * FROM core_focussession LIMIT 5;  # Query data
.quit                            # Exit

# Reset database completely:
rm db.sqlite3
python manage.py makemigrations
python manage.py migrate
python manage.py createsuperuser

# Backup database:
cp db.sqlite3 db_backup_$(date +%Y%m%d).sqlite3

# Django shell for data manipulation:
python manage.py shell
>>> from core.models import *
>>> UserProfile.objects.all()
>>> FocusSession.objects.filter(user__username="admin").count()
>>> Badge.objects.filter(user__username="admin").values_list("badge_type", flat=True)
```

**Flutter Local Storage (SharedPreferences):**
```dart
// SharedPreferences is key-value storage
// Data stored in:
//   Android: /data/data/com.example.focus_guardian_app/shared_prefs/
//   iOS: NSUserDefaults

// To view stored data (debug):
final prefs = await SharedPreferences.getInstance();
print(prefs.getKeys());  // All stored keys
print(prefs.getString('sessions'));  // Sessions JSON

// To clear all data:
final prefs = await SharedPreferences.getInstance();
await prefs.clear();  // Nuclear option!
```

---

### 6.4 Environment Variables (.env)

**File:** `focus_guardian/.env`

```env
# Django Secret Key (REQUIRED for production)
# Generate: python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
DJANGO_SECRET_KEY=your-50-char-random-string-here

# Debug Mode (set False in production!)
DJANGO_DEBUG=True

# OpenAI API Key (OPTIONAL - for AI chat)
# Get from: https://platform.openai.com/api-keys
OPENAI_API_KEY=sk-your-openai-api-key-here
```

**Important Notes:**
- `.env` file NEVER commit karo git mein (it's in .gitignore)
- `.env.example` commit karo (template without real values)
- Production mein environment variables system level pe set karo
- OpenAI key ke bina bhi app work karega (mock responses milenge)

---

### 6.5 Production Deployment Tips

```bash
# 1. Security changes in settings.py:
DEBUG = False
SECRET_KEY = os.getenv("DJANGO_SECRET_KEY")  # From environment
ALLOWED_HOSTS = ["your-domain.com"]

# 2. Static files:
python manage.py collectstatic

# 3. Use PostgreSQL instead of SQLite:
pip install psycopg2-binary
# Update DATABASES in settings.py

# 4. Use Gunicorn as WSGI server:
pip install gunicorn
gunicorn focus_guardian.wsgi:application --bind 0.0.0.0:8000

# 5. Nginx reverse proxy (recommended)
# 6. HTTPS with Let's Encrypt
# 7. Set up proper CORS (not allow all)

# Deployment platforms:
# - Railway.app (easiest, free tier)
# - Render.com (free tier available)
# - DigitalOcean App Platform
# - AWS EC2 + RDS
# - Heroku (paid now)
```

---

## 7. GIT DOCUMENTATION

### 7.1 Repository Structure

```
Lockin-AI/                          # Root repository
├── .git/                           # Git internals (don't touch)
├── focus_guardian/                  # Django app (subdirectory)
│   ├── .gitignore                  # Django-specific ignores
│   └── ...
├── focus_guardian_app/             # Flutter app (subdirectory)
│   └── ...
└── DOCS.md                        # This documentation file
```

### 7.2 Clone, Branch, Commit, Push Workflow

```bash
# 1. Clone repository
git clone https://github.com/YOUR_USERNAME/Lockin-AI.git
cd Lockin-AI

# 2. Create feature branch (NEVER work directly on main!)
git checkout -b feature/add-timer-sound
# Branch naming convention:
# feature/description - new features
# fix/description - bug fixes
# docs/description - documentation
# refactor/description - code improvements

# 3. Make your changes
# ... edit files ...

# 4. Stage changes
git add focus_guardian/core/models.py    # Specific file
git add .                                  # All changes (careful!)

# 5. Commit with good message
git commit -m "feat: add timer completion sound with volume control"

# 6. Push to remote
git push origin feature/add-timer-sound

# 7. Create Pull Request on GitHub
# Go to GitHub → "Compare & Pull Request"

# 8. After PR merged, update local main
git checkout main
git pull origin main

# 9. Delete feature branch (cleanup)
git branch -d feature/add-timer-sound
```

### 7.3 Good Commit Message Format

**Convention: Conventional Commits**

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types:**

| Type | When to Use | Example |
|------|------------|---------|
| `feat` | New feature | `feat(timer): add pause/resume functionality` |
| `fix` | Bug fix | `fix(auth): handle duplicate email on signup` |
| `docs` | Documentation | `docs: add API endpoint reference` |
| `style` | Formatting only | `style: fix indentation in models.py` |
| `refactor` | Code restructuring | `refactor(services): extract badge logic` |
| `test` | Adding tests | `test: add unit tests for scoring` |
| `chore` | Maintenance | `chore: update requirements.txt` |

**Examples:**
```bash
git commit -m "feat(badges): add Marathon Runner badge for 90+ min sessions"
git commit -m "fix(timer): prevent multiple active sessions for same user"
git commit -m "docs: update API documentation with new endpoints"
git commit -m "refactor(views): split settings_view into smaller functions"
git commit -m "chore: upgrade Django to 4.2.8"
```

### 7.4 .gitignore Explanation

```gitignore
# Python
__pycache__/          # Compiled Python files (auto-generated)
*.py[cod]             # .pyc, .pyo, .pyd files
*.so                  # Compiled C extensions
venv/                 # Virtual environment (large, reproducible)
.env                  # SECRET keys! Never commit!

# Django
db.sqlite3            # Database file (has user data)
*.log                 # Log files
staticfiles/          # Collected static (generated)
media/                # User uploads

# Flutter
.dart_tool/           # Dart analysis cache
build/                # Build output (large)
.flutter-plugins      # Auto-generated
.packages             # Auto-generated

# IDE
.idea/                # IntelliJ/Android Studio
.vscode/              # VS Code settings
*.iml                 # IntelliJ module files
```

**Important rule:** Agar file `.gitignore` mein hai, toh wo git track nahi karega. Matlab:
- `db.sqlite3` → Database with user data, never share
- `.env` → API keys, secrets, never share  
- `venv/` → 500MB+ folder, anyone can recreate with `pip install`
- `build/` → Generated files, recreatable

---


## 8. LEARNING ROADMAP

Ye section un students ke liye hai jo is project ko **samajhna** aur **scratch se rebuild** karna chahte hain.

### 8.1 Python & Django

**Why needed:** Backend server, database management, API creation, business logic
**Where used:** Entire `focus_guardian/` folder

| Subtopic | Priority | Where Used | Learn This |
|----------|----------|------------|------------|
| Python basics | 🔴 Critical | Everywhere | Variables, functions, classes, lists, dicts |
| Django installation | 🔴 Critical | Setup | pip, venv, django-admin startproject |
| Django Models | 🔴 Critical | models.py | Fields, relationships, Meta, properties |
| Django Views | 🔴 Critical | views.py | Function views, class views, request/response |
| Django Templates | 🟡 Important | templates/ | Variables, tags, filters, inheritance |
| Django Forms | 🟡 Important | forms.py | ModelForm, validation, clean methods |
| Django Admin | 🟢 Optional | admin.py | ModelAdmin, list_display, filters |
| Django Signals | 🟡 Important | signals.py | post_save, receivers |
| Django ORM | 🔴 Critical | views.py, services.py | filter, annotate, aggregate, F(), Q() |
| Django REST Framework | 🔴 Critical | serializers.py, views.py | Serializers, APIView, Response |
| Django Middleware | 🟡 Important | settings.py | CORS, CSRF, session |
| Django Auth | 🔴 Critical | views.py | login, logout, authenticate, decorators |
| Django Migrations | 🔴 Critical | manage.py | makemigrations, migrate |
| Python OOP | 🔴 Critical | models.py, views.py | Classes, inheritance, properties |
| Python decorators | 🟡 Important | views.py | @login_required, @property |
| Error handling | 🟡 Important | services.py | try/except, logging |

**Learning Order:**
```
1. Python basics (2 weeks)
2. Django tutorial (official - 1 week)
3. Django models & ORM (1 week)
4. Django views & templates (1 week)
5. Django forms & auth (3 days)
6. Django REST Framework (1 week)
7. Signals, middleware, advanced (3 days)
```

**Recommended Resources:**
- Python: "Automate the Boring Stuff" (free online)
- Django: Official Tutorial (docs.djangoproject.com)
- DRF: Django REST Framework official docs
- ORM: Django ORM Cookbook

---

### 8.2 HTML/CSS/JavaScript

**Why needed:** Web frontend - user interface, charts, interactive features
**Where used:** `templates/`, `static/`

| Subtopic | Priority | Where Used | Learn This |
|----------|----------|------------|------------|
| HTML5 structure | 🔴 Critical | All templates | Tags, forms, semantic HTML |
| CSS basics | 🔴 Critical | Styling | Selectors, box model, flexbox, grid |
| Bootstrap 5 | 🔴 Critical | All templates | Grid, cards, buttons, utilities, components |
| JavaScript basics | 🔴 Critical | timer.html, chat.html | Variables, functions, DOM, events |
| Fetch API | 🔴 Critical | API calls | fetch(), async/await, JSON parsing |
| Chart.js | 🟡 Important | dashboard.html, reports.html | Bar, line, doughnut charts |
| CSS animations | 🟢 Optional | UI polish | @keyframes, transitions |
| Responsive design | 🟡 Important | All pages | Media queries, mobile-first |
| DOM manipulation | 🔴 Critical | All JS | getElementById, querySelector, createElement |
| Local Storage | 🟢 Optional | Client-side cache | localStorage API |

**Learning Order:**
```
1. HTML basics (3 days)
2. CSS + Flexbox + Grid (1 week)
3. Bootstrap 5 (3 days - just learn by using)
4. JavaScript basics (1 week)
5. DOM manipulation (3 days)
6. Fetch API + async/await (3 days)
7. Chart.js (1 day - docs are great)
```

---

### 8.3 Flutter & Dart

**Why needed:** Cross-platform mobile app (Android + iOS from single codebase)
**Where used:** Entire `focus_guardian_app/` folder

| Subtopic | Priority | Where Used | Learn This |
|----------|----------|------------|------------|
| Dart language | 🔴 Critical | Everywhere | Types, null safety, async, collections |
| Flutter widgets | 🔴 Critical | All screens | StatelessWidget, StatefulWidget |
| Layout widgets | 🔴 Critical | All screens | Column, Row, Stack, Container, Padding |
| Navigation | 🔴 Critical | home_screen.dart | Navigator.push, BottomNavigationBar |
| Provider package | 🔴 Critical | providers/ | ChangeNotifier, Consumer, Provider.of |
| SharedPreferences | 🟡 Important | providers/ | Read/write key-value locally |
| State management | 🔴 Critical | providers/ | notifyListeners, MultiProvider |
| Forms & validation | 🟡 Important | login, signup | TextFormField, GlobalKey<FormState> |
| Lists & scrolling | 🟡 Important | chat, reports | ListView.builder, ScrollController |
| Custom painting | 🟢 Optional | charts | CustomPainter, Canvas |
| fl_chart package | 🟡 Important | reports_screen | BarChart, PieChart, LineChart |
| Animations | 🟢 Optional | splash, transitions | AnimatedContainer, flutter_animate |
| HTTP package | 🟢 Optional | API sync | http.get, http.post |
| Google Fonts | 🟢 Optional | theme.dart | GoogleFonts.inter() |
| Timer class | 🟡 Important | timer_provider | Timer.periodic, Duration |

**Learning Order:**
```
1. Dart language basics (3 days)
2. Flutter installation + first app (1 day)
3. Widget basics (Column, Row, Text, Button) (3 days)
4. Navigation + routing (2 days)
5. State management with Provider (1 week)
6. Forms + input (2 days)
7. SharedPreferences (1 day)
8. Charts + animations (3 days)
```

**Recommended Resources:**
- Dart: dart.dev/guides
- Flutter: flutter.dev/docs (excellent!)
- Provider: Official package docs + Reso Coder YouTube
- fl_chart: pub.dev/packages/fl_chart

---

### 8.4 Database Concepts

**Why needed:** Data persistence - user data save hona chahiye
**Where used:** models.py, migrations, ORM queries

| Subtopic | Where Used |
|----------|------------|
| Tables, rows, columns | models.py → each class = table |
| Primary keys | Auto-generated ID field |
| Foreign keys | FocusSession → User relationship |
| One-to-One | User → UserProfile |
| One-to-Many | User → FocusSession (multiple) |
| Indexes | Meta.indexes (performance) |
| Unique constraints | unique_together on Badge |
| Migrations | manage.py makemigrations/migrate |
| ORM (Object-Relational Mapping) | Django QuerySet API |
| CRUD operations | create(), filter(), update(), delete() |
| Aggregation | Sum, Count, Avg |
| Transactions | transaction.atomic() |

---

### 8.5 REST API Design

**Why needed:** Frontend-backend communication in structured way
**Where used:** views.py (API views), serializers.py, Flutter HTTP calls

| Concept | Our Implementation |
|---------|-------------------|
| HTTP Methods | GET (read), POST (create), DELETE (remove) |
| Status Codes | 200 (OK), 201 (Created), 400 (Bad Request), 404 (Not Found) |
| JSON format | All API responses are JSON |
| Authentication | Session cookies (web), optional token (mobile) |
| Rate Limiting | ChatRateThrottle (30/min), SessionRateThrottle (10/min) |
| Error handling | Consistent error response format |
| Serialization | Python objects → JSON (DRF serializers) |
| Validation | Input validation in view + serializer |

---

### 8.6 AI/OpenAI Integration

**Why needed:** AI-powered chat responses
**Where used:** services.py → get_ai_response()

| Concept | Where Used |
|---------|------------|
| OpenAI API | _get_openai_response() |
| API keys & security | .env file, os.getenv() |
| System prompts | Mode-specific instructions |
| Chat context | Last 10 messages as history |
| Token limits | max_tokens=800 |
| Temperature | 0.7 (balanced creativity) |
| Fallback systems | Mock responses when API fails |
| Error handling | try/except with logging |

---

### 8.7 Authentication & Security

**Why needed:** Protect user data, prevent unauthorized access
**Where used:** views.py, settings.py, middleware

| Concept | Implementation |
|---------|---------------|
| Password hashing | Django auto (PBKDF2 by default) |
| CSRF protection | @csrf_protect, {% csrf_token %} |
| Session management | SessionAuthentication |
| Login required | @login_required decorator |
| Input validation | Forms, serializers, manual checks |
| Rate limiting | UserRateThrottle classes |
| SQL injection prevention | Django ORM (parameterized queries) |
| XSS prevention | Django template auto-escaping |
| CORS | django-cors-headers |
| Secret key management | Environment variables |

---

### 8.8 Git/GitHub

**Why needed:** Version control, collaboration, code backup
**Where used:** Entire project

| Concept | Usage |
|---------|-------|
| git init | Initialize repository |
| git clone | Download repository |
| git add | Stage changes |
| git commit | Save snapshot |
| git push | Upload to GitHub |
| git pull | Download updates |
| git branch | Create feature branches |
| git merge | Combine branches |
| .gitignore | Exclude files from tracking |
| Pull Requests | Code review workflow |
| Issues | Bug/feature tracking |

---


## 9. ARCHITECTURE DIAGRAMS (Text-Based)

### 9.1 System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        FOCUS GUARDIAN AI                          │
│                     System Architecture                           │
└─────────────────────────────────────────────────────────────────┘

         ┌─────────────────────────────────────────┐
         │              CLIENT LAYER                 │
         ├──────────────────┬──────────────────────┤
         │                  │                       │
    ┌────▼────┐       ┌────▼─────┐          ┌─────▼────┐
    │  Web    │       │  Mobile  │          │  Admin   │
    │ Browser │       │ (Flutter)│          │  Panel   │
    │         │       │          │          │ /admin/  │
    │ HTML/JS │       │ Dart/UI  │          │          │
    │ Chart.js│       │ fl_chart │          │ Django   │
    │ Fetch   │       │ Provider │          │ Built-in │
    └────┬────┘       └────┬─────┘          └─────┬────┘
         │                  │                       │
         │  HTTP/HTTPS      │  HTTP (optional)      │
         │  + Cookies       │  + Local storage      │
         │                  │                       │
    ┌────▼──────────────────▼───────────────────────▼────┐
    │                  SERVER LAYER                        │
    │                                                     │
    │  ┌──────────┐  ┌──────────┐  ┌──────────────────┐  │
    │  │   URL    │  │ Middle-  │  │   Django REST    │  │
    │  │  Router  │→ │  ware    │→ │   Framework      │  │
    │  │(urls.py) │  │(CORS,    │  │  (Serializers)   │  │
    │  │          │  │ CSRF,    │  │                   │  │
    │  │          │  │ Session) │  │                   │  │
    │  └──────────┘  └──────────┘  └──────────────────┘  │
    │                                                     │
    │  ┌──────────────────────────────────────────────┐  │
    │  │              BUSINESS LOGIC                    │  │
    │  │                                               │  │
    │  │  views.py ──→ services.py                     │  │
    │  │    │              │                            │  │
    │  │    │     ┌────────┼────────────┐              │  │
    │  │    │     │        │            │              │  │
    │  │    │  Badges   Scoring     AI Chat            │  │
    │  │    │  System   Algorithm   Handler            │  │
    │  │    │                          │               │  │
    │  │    │                          ▼               │  │
    │  │    │                    ┌──────────┐          │  │
    │  │    │                    │ OpenAI   │          │  │
    │  │    │                    │   API    │          │  │
    │  │    │                    │(external)│          │  │
    │  │    │                    └──────────┘          │  │
    │  └────┼──────────────────────────────────────────┘  │
    │       │                                              │
    │  ┌────▼──────────────────────────────────────────┐  │
    │  │              DATA LAYER                        │  │
    │  │                                               │  │
    │  │  ┌──────────┐  ┌─────────────────────────┐   │  │
    │  │  │  Django   │  │      SQLite DB           │   │  │
    │  │  │   ORM     │──│                          │   │  │
    │  │  │(models.py)│  │  8 tables:               │   │  │
    │  │  │           │  │  UserProfile             │   │  │
    │  │  │  filter() │  │  FocusSession            │   │  │
    │  │  │  create() │  │  Distraction             │   │  │
    │  │  │  save()   │  │  BlockedSite             │   │  │
    │  │  │           │  │  StudyLog                │   │  │
    │  │  │           │  │  Badge                   │   │  │
    │  │  │           │  │  ChatMessage             │   │  │
    │  │  │           │  │  DailyQuote              │   │  │
    │  │  └──────────┘  └─────────────────────────┘   │  │
    │  └───────────────────────────────────────────────┘  │
    └─────────────────────────────────────────────────────┘
```

---

### 9.2 Request Flow Diagram

```
                    USER ACTION
                        │
                        ▼
┌───────────────────────────────────────────────────┐
│  1. HTTP REQUEST                                   │
│     POST /api/session/start/                       │
│     Headers: Cookie (sessionid), X-CSRFToken       │
│     Body: {"subject": "Physics", "planned_duration": 25}  │
└───────────────────┬───────────────────────────────┘
                    │
                    ▼
┌───────────────────────────────────────────────────┐
│  2. MIDDLEWARE CHAIN                               │
│     CORSMiddleware → SecurityMiddleware →          │
│     SessionMiddleware → CsrfViewMiddleware →       │
│     AuthenticationMiddleware                        │
│                                                    │
│     Result: request.user = authenticated User obj  │
└───────────────────┬───────────────────────────────┘
                    │
                    ▼
┌───────────────────────────────────────────────────┐
│  3. URL ROUTING                                    │
│     urls.py matches: "api/session/start/"          │
│     → StartFocusSessionView.as_view()              │
└───────────────────┬───────────────────────────────┘
                    │
                    ▼
┌───────────────────────────────────────────────────┐
│  4. VIEW PROCESSING                                │
│     StartFocusSessionView.post(request)            │
│     a. Rate throttle check (10/min)                │
│     b. Close any existing active sessions          │
│     c. Validate input (subject, duration)          │
│     d. FocusSession.objects.create(...)            │
│     e. Serialize response                          │
└───────────────────┬───────────────────────────────┘
                    │
                    ▼
┌───────────────────────────────────────────────────┐
│  5. HTTP RESPONSE                                  │
│     Status: 201 Created                            │
│     Body: {"id": 42, "subject": "Physics",         │
│            "start_time": "2024-01-15T10:30:00Z",   │
│            "is_active": true, ...}                  │
└───────────────────┬───────────────────────────────┘
                    │
                    ▼
                FRONTEND UPDATES UI
                (Timer starts, subject shown)
```

---

### 9.3 Database ER Diagram

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        ENTITY RELATIONSHIP DIAGRAM                        │
└─────────────────────────────────────────────────────────────────────────┘

┌───────────────┐         ┌───────────────────────┐
│     User      │         │     UserProfile       │
│  (built-in)   │────────▶│                       │
│               │  1 : 1  │  focus_score          │
│  id (PK)      │         │  total_study_time     │
│  username     │         │  streak_days          │
│  email        │         │  longest_streak       │
│  password     │         │  last_study_date      │
│  is_active    │         │  total_sessions       │
│  date_joined  │         │  total_distractions   │
│               │         │  daily_goal_minutes   │
│               │         │  avatar_color         │
│               │         │  theme                │
│               │         │  timer_sound          │
│               │         │  break_duration       │
│               │         │  bio                  │
└───────┬───────┘         └───────────────────────┘
        │
        │ 1 : Many (ForeignKey)
        │
        ├──────────────────────┐
        │                      │
        ▼                      ▼
┌──────────────────┐   ┌──────────────────┐
│   FocusSession   │   │   BlockedSite    │
│                  │   │                  │
│  id (PK)         │   │  id (PK)         │
│  user (FK)       │   │  user (FK)       │
│  subject         │   │  name            │
│  session_type    │   │  url             │
│  start_time      │   │  category        │
│  end_time        │   │  is_active       │
│  planned_duration│   │  times_blocked   │
│  is_active       │   │  icon            │
│  is_completed    │   │  created_at      │
│  mood_before     │   │                  │
│  mood_after      │   │  UNIQUE(user,url) │
│  focus_score     │   └──────────────────┘
│  notes           │
└───────┬──────────┘   ┌──────────────────┐
        │              │    StudyLog       │
        │ 1 : Many     │                  │
        │              │  id (PK)         │
        ▼              │  user (FK)       │
┌──────────────────┐   │  date            │
│   Distraction    │   │  subject         │
│                  │   │  duration_minutes│
│  id (PK)         │   │  sessions_count  │
│  session (FK)    │   │  distractions_cnt│
│  app_name        │   │  focus_score     │
│  distraction_type│   │  notes           │
│  severity        │   │  mood            │
│  duration_seconds│   │                  │
│  timestamp       │   │UNIQUE(user,date, │
└──────────────────┘   │       subject)   │
                       └──────────────────┘

┌──────────────────┐   ┌──────────────────┐   ┌───────────────┐
│     Badge        │   │  ChatMessage     │   │  DailyQuote   │
│                  │   │                  │   │  (standalone) │
│  id (PK)         │   │  id (PK)         │   │               │
│  user (FK)       │   │  user (FK)       │   │  id (PK)      │
│  badge_type      │   │  role            │   │  quote        │
│  earned_at       │   │  content         │   │  author       │
│  is_new          │   │  mode            │   │  category     │
│                  │   │  timestamp       │   │               │
│UNIQUE(user,      │   │  is_pinned       │   └───────────────┘
│    badge_type)   │   │                  │
└──────────────────┘   └──────────────────┘
```

---

### 9.4 Timer Session Lifecycle

```
┌─────────────────────────────────────────────────────────────┐
│                  TIMER SESSION LIFECYCLE                      │
└─────────────────────────────────────────────────────────────┘

    User selects:
    - Subject: "Physics"
    - Duration: 25 min
    - Mood: "Good"
          │
          ▼
┌──────────────────┐
│  SESSION START   │  POST /api/session/start/
│                  │  → FocusSession created
│  is_active=True  │  → start_time = now()
│  focus_score=100 │  → Timer countdown begins
└────────┬─────────┘
         │
         ▼
┌──────────────────────────────────────────────────────────┐
│                    SESSION ACTIVE                          │
│                                                           │
│  Timer counting down: 25:00 → 24:59 → ... → 00:00       │
│                                                           │
│  ┌─────────────────────────────────────────────────┐     │
│  │  EVENTS DURING SESSION:                          │     │
│  │                                                  │     │
│  │  Event: DISTRACTION DETECTED                     │     │
│  │  → POST /api/distraction/                        │     │
│  │  → score penalty applied (3/5/10)                │     │
│  │  → toast notification shown                      │     │
│  │                                                  │     │
│  │  Event: PAUSE                                    │     │
│  │  → Timer stops counting                          │     │
│  │  → Session remains active                        │     │
│  │                                                  │     │
│  │  Event: RESUME                                   │     │
│  │  → Timer resumes counting                        │     │
│  └─────────────────────────────────────────────────┘     │
└────────────────────────┬─────────────────────────────────┘
                         │
              ┌──────────┴──────────┐
              │                     │
        Timer = 0            User clicks "End"
              │                     │
              ▼                     ▼
┌──────────────────────────────────────────────┐
│              SESSION END                      │
│                                              │
│  POST /api/session/end/                      │
│                                              │
│  1. is_active = False                        │
│  2. end_time = now()                         │
│  3. Check completion (≥90% planned = done)   │
│  4. calculate_session_score()                │
│  5. Update profile:                          │
│     - total_study_time += duration           │
│     - total_sessions += 1                    │
│     - focus_score = old*0.7 + new*0.3        │
│  6. update_study_log()                       │
│  7. update_streak()                          │
│  8. check_and_award_badges()                 │
└────────────────────────┬─────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────┐
│           SESSION RESULTS SHOWN               │
│                                              │
│  ┌────────────────────────────┐              │
│  │  Session Score: 85/100     │              │
│  │  Duration: 23m             │              │
│  │  Distractions: 2           │              │
│  │  Status: Completed ✓       │              │
│  │  Streak: 5 days 🔥         │              │
│  │  New Badge: "Week Warrior" │              │
│  └────────────────────────────┘              │
└──────────────────────────────────────────────┘
```

---

### 9.5 Badge Awarding Flow

```
┌─────────────────────────────────────────────────────────────┐
│                   BADGE AWARDING FLOW                         │
└─────────────────────────────────────────────────────────────┘

    Session ends successfully
           │
           ▼
    check_and_award_badges(user)
           │
           ▼
    ┌──────────────────────────────────────────────────────┐
    │              CHECK ALL CONDITIONS                      │
    │                                                       │
    │  ┌─── MILESTONE BADGES ───┐                          │
    │  │ first_session: completed_sessions.exists()?       │
    │  └────────────────────────┘                          │
    │                                                       │
    │  ┌─── STREAK BADGES ──────┐                          │
    │  │ streak ≥ 3?  → streak_3                           │
    │  │ streak ≥ 7?  → streak_7                           │
    │  │ streak ≥ 14? → streak_14                          │
    │  │ streak ≥ 30? → streak_30                          │
    │  │ streak ≥ 60? → streak_60                          │
    │  │ streak ≥ 100?→ streak_100                         │
    │  └────────────────────────┘                          │
    │                                                       │
    │  ┌─── HOURS BADGES ───────┐                          │
    │  │ hours ≥ 1?   → hours_1                            │
    │  │ hours ≥ 5?   → hours_5                            │
    │  │ hours ≥ 10?  → hours_10                           │
    │  │ hours ≥ 20?  → hours_20                           │
    │  │ hours ≥ 50?  → hours_50                           │
    │  │ hours ≥ 100? → hours_100                          │
    │  │ hours ≥ 200? → hours_200                          │
    │  └────────────────────────┘                          │
    │                                                       │
    │  ┌─── PERFORMANCE BADGES ─┐                          │
    │  │ 0 distractions + 15min?→ no_distraction           │
    │  │ 5 perfect sessions?    → no_distraction_5         │
    │  │ focus_score == 100?    → focus_master             │
    │  └────────────────────────┘                          │
    │                                                       │
    │  ┌─── TIME-BASED BADGES ──┐                          │
    │  │ session hour < 6?      → early_bird               │
    │  │ session hour >= 23?    → night_owl                │
    │  └────────────────────────┘                          │
    │                                                       │
    │  ┌─── SPECIAL BADGES ─────┐                          │
    │  │ duration ≥ 90min?      → marathon                 │
    │  │ 5+ sessions today?     → consistent               │
    │  │ 3+ day gap + return?   → comeback                 │
    │  │ 3 sessions in 2 hrs?   → speed_learner            │
    │  │ 60+ min on subject?    → deep_thinker             │
    │  └────────────────────────┘                          │
    └──────────────────────────────────────────────────────┘
           │
           ▼
    ┌──────────────────────────────────────────┐
    │  For each condition met:                  │
    │                                          │
    │  Badge.objects.get_or_create(             │
    │      user=user,                          │
    │      badge_type=badge_type               │
    │  )                                       │
    │                                          │
    │  If created (new badge!):                │
    │    → Add to awarded list                 │
    │    → is_new = True (show notification)   │
    └──────────────────────┬───────────────────┘
                           │
                           ▼
    Return list of newly awarded badges
    → Shown in session end popup
    → Shown as notification on Badges page
```

---

### 9.6 AI Chat Flow

```
┌─────────────────────────────────────────────────────────────┐
│                      AI CHAT FLOW                             │
└─────────────────────────────────────────────────────────────┘

    User types: "Explain Newton's 3rd law"
    Mode: "teacher"
           │
           ▼
┌──────────────────────────┐
│  FRONTEND                 │
│  - Validate message       │
│  - Show user message      │
│  - Show loading indicator │
│  - Send to backend        │
└────────────┬─────────────┘
             │
             ▼
┌──────────────────────────────────────────────────────┐
│  BACKEND: AITeacherView.post()                        │
│                                                       │
│  1. Validate message (non-empty, < 2000 chars)       │
│  2. Validate mode (general/teacher/quiz/plan/motiv)  │
│  3. Save user message to DB:                          │
│     ChatMessage(role="user", content=msg, mode=mode) │
│  4. Get chat history (last 20 messages)              │
│  5. Call get_ai_response()                           │
└────────────┬─────────────────────────────────────────┘
             │
             ▼
┌──────────────────────────────────────────────────────┐
│  get_ai_response(message, user, history, mode)        │
│                                                       │
│  ┌─── Has OPENAI_API_KEY? ───┐                       │
│  │                           │                       │
│  │  YES                      │  NO                   │
│  │   │                       │   │                   │
│  │   ▼                       │   │                   │
│  │  _get_openai_response()   │   │                   │
│  │   │                       │   │                   │
│  │   ├── Build system prompt │   │                   │
│  │   │   (mode-specific +    │   │                   │
│  │   │    user context)      │   │                   │
│  │   │                       │   │                   │
│  │   ├── Add chat history    │   │                   │
│  │   │   (last 10 msgs)     │   │                   │
│  │   │                       │   │                   │
│  │   ├── OpenAI API call     │   │                   │
│  │   │   model: gpt-3.5     │   │                   │
│  │   │   max_tokens: 800    │   │                   │
│  │   │   temp: 0.7          │   │                   │
│  │   │                       │   │                   │
│  │   ├── Success?            │   │                   │
│  │   │   YES → return resp   │   │                   │
│  │   │   NO  → return None   │   │                   │
│  │   │          │            │   │                   │
│  │   │          ▼            │   │                   │
│  │   └──── FALLBACK ─────────┼───┘                   │
│  │              │             │                       │
│  │              ▼             │                       │
│  │    _get_mock_response()   │                       │
│  │              │             │                       │
│  │    ┌─────────┴──────┐     │                       │
│  │    │ Keyword match  │     │                       │
│  │    │                │     │                       │
│  │    │ "focus" → tips │     │                       │
│  │    │ "motivat"→ msg │     │                       │
│  │    │ "plan" → plan  │     │                       │
│  │    │ "hello" → hi   │     │                       │
│  │    │ default → mode │     │                       │
│  │    │         default│     │                       │
│  │    └────────────────┘     │                       │
│  └───────────────────────────┘                       │
└────────────┬─────────────────────────────────────────┘
             │
             ▼
┌──────────────────────────────────────────────────────┐
│  6. Save AI response to DB:                           │
│     ChatMessage(role="assistant", content=resp)       │
│  7. Return JSON: {"reply": "...", "mode": "teacher"} │
└────────────┬─────────────────────────────────────────┘
             │
             ▼
┌──────────────────────────┐
│  FRONTEND                 │
│  - Hide loading           │
│  - Show AI response       │
│  - Scroll to bottom       │
│  - Ready for next message │
└──────────────────────────┘
```

---


## 10. DEVELOPER GUIDE

### 10.1 How to Add a New Model

**Scenario:** Tum ek "StudyGroup" feature add karna chahte ho.

**Step 1: Define model in `core/models.py`**
```python
class StudyGroup(models.Model):
    """Study groups for collaborative learning."""
    
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True, default="")
    created_by = models.ForeignKey(User, on_delete=models.CASCADE, related_name="created_groups")
    members = models.ManyToManyField(User, related_name="study_groups", blank=True)
    subject = models.CharField(max_length=100)
    is_active = models.BooleanField(default=True)
    max_members = models.IntegerField(default=10)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        ordering = ["-created_at"]
    
    def __str__(self):
        return f"{self.name} ({self.members.count()} members)"
    
    @property
    def member_count(self):
        return self.members.count()
```

**Step 2: Create and run migration**
```bash
python manage.py makemigrations
# Output: Migrations for 'core': core/migrations/0002_studygroup.py

python manage.py migrate
# Output: Applying core.0002_studygroup... OK
```

**Step 3: Register in admin (`core/admin.py`)**
```python
@admin.register(StudyGroup)
class StudyGroupAdmin(admin.ModelAdmin):
    list_display = ["name", "created_by", "subject", "member_count", "is_active"]
    list_filter = ["subject", "is_active"]
    search_fields = ["name", "created_by__username"]
```

**Step 4: Create serializer (`core/serializers.py`)**
```python
class StudyGroupSerializer(serializers.ModelSerializer):
    created_by_username = serializers.CharField(source="created_by.username", read_only=True)
    member_count = serializers.IntegerField(read_only=True)
    
    class Meta:
        model = StudyGroup
        fields = ["id", "name", "description", "created_by_username", "subject", 
                  "member_count", "max_members", "is_active", "created_at"]
```

**Step 5: Add Flutter model (`lib/models/group_model.dart`)**
```dart
class StudyGroup {
  final String id;
  final String name;
  final String subject;
  final int memberCount;
  final bool isActive;
  
  StudyGroup({required this.id, required this.name, ...});
  
  factory StudyGroup.fromJson(Map<String, dynamic> json) { ... }
  Map<String, dynamic> toJson() { ... }
}
```

---

### 10.2 How to Add a New API Endpoint

**Scenario:** GET /api/study-groups/ endpoint add karna hai.

**Step 1: Create view in `core/views.py`**
```python
class StudyGroupListView(APIView):
    """List user's study groups."""
    
    def get(self, request):
        groups = StudyGroup.objects.filter(
            members=request.user, is_active=True
        )
        serializer = StudyGroupSerializer(groups, many=True)
        return Response(serializer.data)
    
    def post(self, request):
        """Create a new study group."""
        name = request.data.get("name", "").strip()
        if not name:
            return Response({"error": "Name is required"}, status=400)
        
        group = StudyGroup.objects.create(
            name=name,
            created_by=request.user,
            subject=request.data.get("subject", "General"),
        )
        group.members.add(request.user)  # Creator is first member
        
        return Response(StudyGroupSerializer(group).data, status=201)
```

**Step 2: Add URL pattern in `core/urls.py`**
```python
urlpatterns = [
    # ... existing patterns ...
    path("api/study-groups/", views.StudyGroupListView.as_view(), name="api-study-groups"),
]
```

**Step 3: Add endpoint constant in Flutter (`constants.dart`)**
```dart
static const String studyGroupsUrl = '/api/study-groups/';
```

**Step 4: Test the endpoint**
```bash
# Start server
python manage.py runserver

# Test with curl:
curl -X GET http://localhost:8000/api/study-groups/ \
  -H "Cookie: sessionid=your-session-id"

# Or use browser: login first, then visit /api/study-groups/
```

---

### 10.3 How to Add a New Page/Screen

**Web (Django Template):**

**Step 1: Create view function in `core/views.py`**
```python
@login_required
def study_groups_view(request):
    """Study groups page."""
    groups = StudyGroup.objects.filter(members=request.user)
    context = {"groups": groups}
    return render(request, "core/study_groups.html", context)
```

**Step 2: Create template `templates/core/study_groups.html`**
```html
{% extends "core/base.html" %}
{% block title %}Study Groups{% endblock %}
{% block content %}
<div class="container-fluid">
    <h2>My Study Groups</h2>
    {% for group in groups %}
        <div class="card mb-3">
            <div class="card-body">
                <h5>{{ group.name }}</h5>
                <p>Subject: {{ group.subject }}</p>
                <p>Members: {{ group.member_count }}</p>
            </div>
        </div>
    {% empty %}
        <p>No study groups yet. Create one!</p>
    {% endfor %}
</div>
{% endblock %}
```

**Step 3: Add URL in `core/urls.py`**
```python
path("study-groups/", views.study_groups_view, name="study-groups"),
```

**Step 4: Add link in sidebar (`base.html`)**
```html
<a href="{% url 'study-groups' %}" class="nav-link">
    <i class="bi bi-people"></i> Study Groups
</a>
```

---

**Mobile (Flutter Screen):**

**Step 1: Create screen file `lib/screens/groups_screen.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../utils/theme.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Study Groups')),
      body: Consumer<AppProvider>(
        builder: (context, app, child) {
          // Use app.studyGroups or similar
          return ListView.builder(
            itemCount: 0, // Replace with actual data
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  title: Text('Group Name'),
                  subtitle: Text('Subject'),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
  
  void _showCreateDialog(BuildContext context) {
    // Show dialog to create group
  }
}
```

**Step 2: Add to navigation in `home_screen.dart`**
```dart
// Add to bottom nav items or drawer
BottomNavigationBarItem(
  icon: Icon(Icons.people),
  label: 'Groups',
),

// Add to IndexedStack or pages list
const GroupsScreen(),
```

---

### 10.4 How to Add a New Badge Type

**Step 1: Add to BADGE_TYPES in `core/models.py`**
```python
class Badge(models.Model):
    BADGE_TYPES = [
        # ... existing badges ...
        ("social_learner", "Social Learner"),  # NEW!
    ]
```

**Step 2: Add icon, color, rarity, description properties**
```python
@property
def icon(self):
    icons = {
        # ... existing ...
        "social_learner": "people-fill",
    }

@property
def rarity(self):
    # Add to appropriate category
    epic_badges = [..., "social_learner"]

@property
def description(self):
    descriptions = {
        # ... existing ...
        "social_learner": "Join 3 study groups and complete sessions with each",
    }
```

**Step 3: Add awarding condition in `core/services.py`**
```python
def check_and_award_badges(user):
    # ... existing checks ...
    
    # Social Learner - joined 3+ groups with sessions
    groups_with_sessions = StudyGroup.objects.filter(
        members=user
    ).count()
    if groups_with_sessions >= 3:
        try_award("social_learner")
```

**Step 4: Run migration (BADGE_TYPES changes need it)**
```bash
python manage.py makemigrations
python manage.py migrate
```

**Step 5: Add to Flutter constants (`constants.dart`)**
```dart
static const List<Map<String, String>> badgeTypes = [
  // ... existing ...
  {'type': 'social_learner', 'name': 'Social Learner', 'icon': 'people', 'desc': 'Join 3 study groups'},
];
```

---

### 10.5 How to Add a New AI Mode

**Step 1: Add to MODE_CHOICES in `core/models.py`**
```python
class ChatMessage(models.Model):
    MODE_CHOICES = [
        ("general", "General Chat"),
        ("teacher", "Teacher Mode"),
        ("quiz", "Quiz Mode"),
        ("study_plan", "Study Plan"),
        ("motivation", "Motivation"),
        ("exam_prep", "Exam Preparation"),  # NEW!
    ]
```

**Step 2: Add system prompt in `core/services.py`**
```python
def _get_openai_response(...):
    system_prompts = {
        # ... existing ...
        "exam_prep": (
            "You are Focus Guardian AI in Exam Preparation Mode. "
            "Help students prepare for specific exams. Create practice papers, "
            "identify weak areas, suggest revision strategies, and provide "
            "time management tips for the exam day."
        ),
    }
```

**Step 3: Add mock responses for the mode**
```python
MOCK_RESPONSES = {
    # ... existing ...
    "exam_prep": {
        "default": (
            "Exam Prep Mode activated! I'll help you prepare.\n\n"
            "Tell me:\n"
            "1. Which exam? (JEE/NEET/UPSC/Board/etc.)\n"
            "2. When is it?\n"
            "3. Which subjects need most work?\n\n"
            "I'll create a customized prep strategy!"
        ),
    },
}
```

**Step 4: Add mode chip in UI (Web chat.html)**
```html
<button class="mode-chip" data-mode="exam_prep">
    <i class="bi bi-journal-check"></i> Exam Prep
</button>
```

**Step 5: Add mode chip in Flutter (chat_screen.dart)**
```dart
ChoiceChip(
  label: Text('Exam Prep'),
  selected: currentMode == 'exam_prep',
  onSelected: (selected) => setState(() => currentMode = 'exam_prep'),
)
```

**Step 6: Run migration**
```bash
python manage.py makemigrations
python manage.py migrate
```

---

### 10.6 How to Debug Common Issues

#### Issue 1: "Server Error 500" on any page

```bash
# Check Django logs:
python manage.py runserver  # Look at terminal output

# Enable detailed errors:
# In settings.py: DEBUG = True

# Check if database needs migration:
python manage.py showmigrations
python manage.py migrate

# Check for import errors:
python manage.py check
```

#### Issue 2: "No active session found" error

```bash
# In Django shell:
python manage.py shell
>>> from core.models import FocusSession
>>> FocusSession.objects.filter(user__username="testuser", is_active=True)
# If empty, no active session exists - user needs to start one first
```

#### Issue 3: Flutter "setState() called after dispose()"

```dart
// Problem: Timer still running after screen closed
// Solution: Cancel timer in dispose()

@override
void dispose() {
  _timer?.cancel();  // Always cancel timers!
  super.dispose();
}
```

#### Issue 4: CORS error in browser console

```bash
# Check settings.py:
CORS_ALLOW_ALL_ORIGINS = True  # For development

# Or specific origins:
CORS_ALLOWED_ORIGINS = [
    "http://localhost:3000",
    "http://localhost:8080",
]
```

#### Issue 5: "Bad state: Stream has already been listened to"

```dart
// In Flutter, SharedPreferences is async
// Make sure you await it:
Future<void> loadData() async {
  final prefs = await SharedPreferences.getInstance();  // AWAIT!
  // ...
}
```

#### Issue 6: "CSRF verification failed"

```python
# For API views using DRF's SessionAuthentication,
# include X-CSRFToken header in AJAX requests:

# In JavaScript:
fetch('/api/session/start/', {
    method: 'POST',
    headers: {
        'Content-Type': 'application/json',
        'X-CSRFToken': getCookie('csrftoken'),  // Get from cookie
    },
    body: JSON.stringify(data),
});

// For Flutter (if using API):
// SessionAuthentication might not work well with mobile
// Consider switching to TokenAuthentication for mobile
```

#### Issue 7: Badge not being awarded

```bash
python manage.py shell
>>> from core.models import *
>>> from core.services import check_and_award_badges
>>> user = User.objects.get(username="testuser")
>>> profile = user.profile
>>> print(f"Streak: {profile.streak_days}, Hours: {profile.total_study_hours}")
>>> badges = check_and_award_badges(user)
>>> print(f"New badges: {badges}")
```

#### Issue 8: Flutter app crash on startup

```bash
# Clean and rebuild:
flutter clean
flutter pub get
flutter run

# Check for null safety issues:
flutter analyze

# Check for version conflicts:
flutter pub deps
```

---


## 11. PROFESSIONAL README CONTENT

### Project Header

```markdown
<div align="center">
  
# 🎯 Focus Guardian AI

### AI-Powered Study Discipline & Distraction Management System

[![Python](https://img.shields.io/badge/Python-3.10+-3776AB?logo=python&logoColor=white)](https://python.org)
[![Django](https://img.shields.io/badge/Django-4.2-092E20?logo=django&logoColor=white)](https://djangoproject.com)
[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![DRF](https://img.shields.io/badge/DRF-3.14-red?logo=django&logoColor=white)](https://django-rest-framework.org)
[![OpenAI](https://img.shields.io/badge/OpenAI-GPT--3.5-412991?logo=openai&logoColor=white)](https://openai.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

*Padhai mein focus rakhna ab easy hai — AI-powered accountability, gamification, aur smart analytics ke saath!*

[Web Demo](#) · [Download APK](#) · [Report Bug](../../issues) · [Request Feature](../../issues)

</div>
```

---

### Description

Focus Guardian AI ek dual-platform (Web + Mobile) study management system hai jo students ko:

- **Focus track** karta hai with precision timer & distraction detection
- **AI tutor** provide karta hai 5 modes mein (General, Teacher, Quiz, Study Plan, Motivation)
- **Gamify** karta hai padhai ko 24 badges & scoring system ke through
- **Block** karta hai distracting sites & apps ko
- **Analyze** karta hai study patterns ko detailed reports & charts se
- **Motivate** karta hai daily streaks, quotes, & achievement system se

---

### Features

| Feature | Description |
|---------|-------------|
| 🎯 Focus Timer | Configurable countdown timer with subject tracking |
| 🤖 AI Teacher | 5 chat modes powered by OpenAI (with offline fallback) |
| 📊 Smart Reports | 7/14/30/90 day analytics with interactive charts |
| 🏆 Badge System | 24 unique badges across 4 rarity tiers |
| 🚫 Site Blocking | Category-based blocking with usage tracking |
| 📈 Focus Scoring | Weighted algorithm (0-100) with letter grades |
| 🔥 Streak System | Daily consistency tracking with longest streak record |
| ⚡ Distraction Detection | Real-time detection with severity-based penalties |
| ⚙️ Customization | Theme, sounds, goals, timer preferences |
| 📤 Data Export | Full JSON export of all study data |

---

### Tech Stack

**Backend (Django):**
| Technology | Purpose |
|------------|---------|
| Python 3.10+ | Core language |
| Django 4.2 | Web framework |
| Django REST Framework | API layer |
| SQLite | Database |
| OpenAI API | AI chat responses |
| Bootstrap 5 | Frontend UI |
| Chart.js | Interactive charts |

**Mobile (Flutter):**
| Technology | Purpose |
|------------|---------|
| Dart/Flutter 3.0+ | Cross-platform framework |
| Provider | State management |
| SharedPreferences | Local data persistence |
| fl_chart | Mobile charts |
| Google Fonts | Typography |
| flutter_animate | UI animations |

---

### Installation

**Django Web App:**
```bash
# Clone repository
git clone https://github.com/YOUR_USERNAME/Lockin-AI.git
cd Lockin-AI/focus_guardian

# Setup virtual environment
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# Edit .env: add DJANGO_SECRET_KEY and optionally OPENAI_API_KEY

# Setup database
python manage.py migrate

# Create admin user (optional)
python manage.py createsuperuser

# Run server
python manage.py runserver
# Visit: http://localhost:8000
```

**Flutter Mobile App:**
```bash
cd Lockin-AI/focus_guardian_app

# Install dependencies
flutter pub get

# Run on device/emulator
flutter run

# Build APK
flutter build apk --release
```

---

### Usage

1. **Sign up** with username, email, password
2. **Dashboard** shows your stats at a glance
3. **Start a session**: choose subject → set timer → focus!
4. **During session**: distractions are tracked, score updates live
5. **End session**: see your score, new badges, streak update
6. **AI Chat**: ask questions, get study plans, take quizzes
7. **Reports**: analyze your patterns over 7/14/30/90 days
8. **Block sites**: add distracting sites to your block list
9. **Earn badges**: complete milestones to unlock 24 achievements

---

### API Reference Summary

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/profile/` | GET | Get user profile |
| `/api/session/start/` | POST | Start focus session |
| `/api/session/end/` | POST | End focus session |
| `/api/session/active/` | GET | Get active session |
| `/api/distraction/` | POST | Log distraction |
| `/api/report/?days=N` | GET | Get study report |
| `/api/ai-teacher/` | POST | AI chat message |
| `/api/chat/clear/` | POST | Clear chat history |
| `/api/quote/` | GET | Get motivational quote |
| `/api/blocked-site/{id}/toggle/` | POST | Toggle blocked site |
| `/api/blocked-site/{id}/delete/` | DELETE | Delete blocked site |

---

### Roadmap

**Phase 2 - Enhanced Features:**
- [ ] Browser extension for actual site blocking
- [ ] Push notifications ("Don't break your streak!")
- [ ] Voice-to-text for AI chat
- [ ] Pomodoro cycle tracking (4 sessions → long break)
- [ ] Weekly email progress reports

**Phase 3 - Social Features:**
- [ ] Study groups (collaborative sessions)
- [ ] Leaderboard (anonymous comparison)
- [ ] Friend system & accountability partners
- [ ] Shared challenges & competitions
- [ ] Public profile pages

**Phase 4 - Advanced AI:**
- [ ] RAG with uploaded study materials
- [ ] AI-generated practice papers
- [ ] Personalized study schedule generation
- [ ] Weak topic identification
- [ ] Learning style adaptation
- [ ] OCR for handwritten notes

**Phase 5 - Platform Expansion:**
- [ ] Desktop app (Windows/Mac via Flutter)
- [ ] Chrome extension
- [ ] Apple Watch / WearOS companion
- [ ] Notion/Google Calendar integration
- [ ] Anki flashcard sync

---

### Contributing

Contributions are welcome! Here's how:

1. Fork the repo
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m "feat: add amazing feature"`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

**Guidelines:**
- Follow existing code style
- Add comments for complex logic
- Update documentation for new features
- Test your changes before PR
- Keep PRs focused (one feature per PR)

---

### Project Stats

```
Django Backend:
  - 8 database models
  - 8 template views + 11 API views
  - 22 URL patterns
  - 3 forms, 7 serializers
  - 24 badge types, 5 chat modes
  - 25+ motivational quotes

Flutter Mobile:
  - 3 providers (state managers)
  - 12 screens
  - 5 model classes
  - Offline-first architecture
  - Dark theme with custom design
  - 9 Flutter packages
```

---

## APPENDIX A: Quick Reference Card

### Django Commands Cheatsheet

```bash
python manage.py runserver             # Start server
python manage.py makemigrations        # Create migration files
python manage.py migrate               # Apply migrations
python manage.py createsuperuser       # Create admin
python manage.py shell                 # Python shell
python manage.py dbshell               # Database shell
python manage.py collectstatic         # Collect static files
python manage.py flush                 # Clear all data
python manage.py test                  # Run tests
python manage.py showmigrations        # List migrations
```

### Flutter Commands Cheatsheet

```bash
flutter pub get                        # Install packages
flutter run                            # Run app
flutter build apk                      # Build Android
flutter build ios                      # Build iOS
flutter clean                          # Clear cache
flutter analyze                        # Check code
flutter test                           # Run tests
flutter doctor                         # Check setup
flutter devices                        # List devices
```

### Key File Locations

| What You Need | Django File | Flutter File |
|--------------|-------------|--------------|
| Database tables | `core/models.py` | `lib/models/` |
| Business logic | `core/services.py` | `lib/providers/app_provider.dart` |
| API endpoints | `core/views.py` | N/A (local-first) |
| URL routing | `core/urls.py` | Navigator in screens |
| Configuration | `settings.py` | `lib/utils/constants.dart` |
| UI theme | Bootstrap 5 | `lib/utils/theme.dart` |
| Authentication | `views.py` (login/signup) | `lib/providers/auth_provider.dart` |
| Timer logic | JavaScript in `timer.html` | `lib/providers/timer_provider.dart` |

### API Quick Test

```bash
# Login first (get session cookie):
curl -c cookies.txt -X POST http://localhost:8000/login/ \
  -d "username=admin&password=admin123&csrfmiddlewaretoken=TOKEN"

# Then use the session:
curl -b cookies.txt http://localhost:8000/api/profile/

# Start a session:
curl -b cookies.txt -X POST http://localhost:8000/api/session/start/ \
  -H "Content-Type: application/json" \
  -H "X-CSRFToken: TOKEN" \
  -d '{"subject":"Physics","planned_duration":25}'
```

---

## APPENDIX B: Glossary

| Term | Hindi Meaning | Technical Meaning |
|------|---------------|-------------------|
| MVT | - | Model-View-Template (Django pattern) |
| ORM | - | Object-Relational Mapping (Python → SQL) |
| API | - | Application Programming Interface (data exchange) |
| REST | - | Representational State Transfer (API style) |
| CSRF | - | Cross-Site Request Forgery (security attack) |
| CORS | - | Cross-Origin Resource Sharing (browser security) |
| DRF | - | Django REST Framework (API library) |
| Provider | - | Flutter state management pattern |
| Widget | - | Flutter UI component |
| Migration | - | Database schema change script |
| Serializer | - | Object → JSON converter |
| Middleware | - | Request/response processor (pipeline) |
| Throttling | - | Rate limiting (spam prevention) |
| Atomic | - | All-or-nothing database operation |
| Webhook | - | URL that gets called when event happens |
| CI/CD | - | Continuous Integration/Deployment |
| JWT | - | JSON Web Token (auth token) |
| WebSocket | - | Real-time two-way communication |
| SQLite | - | File-based database (no server needed) |
| SharedPreferences | - | Key-value local storage (mobile) |

---

## APPENDIX C: Common Patterns Used

### 1. Django Signal Pattern
```python
# "Jab X ho, toh automatically Y karo"
@receiver(post_save, sender=User)
def create_profile(sender, instance, created, **kwargs):
    if created:
        UserProfile.objects.create(user=instance)
```

### 2. Django Atomic Transaction Pattern
```python
# "Ya toh sab hoga, ya kuch nahi" (rollback on error)
with transaction.atomic():
    session.save()
    profile.save()
    # If any save fails, BOTH are rolled back
```

### 3. Flutter Consumer Pattern
```dart
// "Jab data change ho, toh UI automatically rebuild ho"
Consumer<TimerProvider>(
  builder: (context, timer, child) {
    return Text(timer.displayTime);  // Auto-updates!
  },
)
```

### 4. Property Pattern (Computed Field)
```python
# "Database mein store mat karo, calculate karo on-the-fly"
@property
def level(self):
    hours = self.total_study_hours
    if hours >= 500: return "Grandmaster"
    # ... (computed from stored data)
```

### 5. Fallback Pattern
```python
# "Pehle best option try karo, fail ho toh backup use karo"
def get_ai_response(message, ...):
    if api_key:
        result = call_openai(message)  # Try best option
        if result:
            return result
    return mock_response(message)  # Fallback
```

### 6. Rate Limiting Pattern
```python
# "Spam prevent karo - max X requests per minute"
class ChatRateThrottle(UserRateThrottle):
    rate = '30/min'

class AITeacherView(APIView):
    throttle_classes = [ChatRateThrottle]
```

### 7. Weighted Average Pattern
```python
# "Naya score = 70% purana + 30% latest" (gradual change, not sudden)
profile.focus_score = round((profile.focus_score * 0.7) + (session_score * 0.3))
```

### 8. Offline-First Pattern (Flutter)
```dart
// "Data locally save karo, optionally server se sync karo"
Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sessions', json.encode(sessions));
    // No internet needed - works fully offline!
}
```

---

## APPENDIX D: Environment Setup Checklist

### Django Setup Checklist
- [ ] Python 3.10+ installed
- [ ] pip working (`pip --version`)
- [ ] Virtual environment created (`python -m venv venv`)
- [ ] Virtual environment activated
- [ ] `pip install -r requirements.txt` successful
- [ ] `.env` file created with SECRET_KEY
- [ ] `python manage.py migrate` successful
- [ ] `python manage.py runserver` starts without errors
- [ ] Can access http://localhost:8000/
- [ ] Can create account and login
- [ ] (Optional) OPENAI_API_KEY set for AI chat

### Flutter Setup Checklist
- [ ] Flutter SDK installed (`flutter --version`)
- [ ] `flutter doctor` shows no critical issues
- [ ] Android Studio / Xcode installed
- [ ] Emulator/device connected (`flutter devices`)
- [ ] `flutter pub get` successful
- [ ] `flutter run` launches app
- [ ] Can login and navigate
- [ ] Timer works correctly
- [ ] Data persists after app restart

---

## APPENDIX E: File Dependencies Map

```
                        settings.py
                            │
                    ┌───────┼───────┐
                    │       │       │
                urls.py   wsgi.py  asgi.py
                    │
              core/urls.py
                    │
              core/views.py
              /     |     \
    core/forms.py  core/services.py  core/serializers.py
         |              |                    |
    core/models.py ─────┘────────────────────┘
         |
    core/signals.py
    core/admin.py
    core/templatetags/custom_filters.py
         |
    templates/ (all HTML files depend on models via views context)


Flutter:
                    main.dart
                   /    |    \
    auth_provider  app_provider  timer_provider
         |              |              |
    user_model     session_model      |
         |              |              |
    constants.dart  constants.dart     |
         |              |              |
    theme.dart     theme.dart     theme.dart
         
    All screens depend on providers + models + utils
```

---

*Document End - Total comprehensive coverage of Focus Guardian AI project.*
*Ye document padh ke koi bhi developer is project ko samajh sakta hai aur scratch se rebuild kar sakta hai.*

**Created with 💜 for the Focus Guardian AI project**

# Focus Guardian AI - Local Development Setup (VS Code)

## Step-by-Step Guide to Run & Test in VS Code

Ye guide follow karo apne laptop/PC pe project chalane ke liye.

---

### Prerequisites

- **Python 3.11+** installed ([Download](https://www.python.org/downloads/))
- **VS Code** installed ([Download](https://code.visualstudio.com/))
- **Git** installed

---

### Step 1: Clone the Repository

Open **Terminal** (VS Code mein `Ctrl + \`` press karo) aur run karo:

```bash
git clone https://github.com/RishiPlaysCodes/Lockin-AI.git
cd Lockin-AI
```

---

### Step 2: Create Virtual Environment

```bash
# Windows (PowerShell)
python -m venv venv
.\venv\Scripts\Activate.ps1

# Windows (CMD)
python -m venv venv
venv\Scripts\activate

# Mac/Linux
python3 -m venv venv
source venv/bin/activate
```

> **VS Code Tip:** Jab virtual environment activate ho jaye, neeche left mein `Python 3.12 ('venv')` dikhega. Agar nahi dikhta toh `Ctrl+Shift+P` → "Python: Select Interpreter" → venv wala choose karo.

---

### Step 3: Install Dependencies

```bash
pip install -r requirements/development.txt
```

> Agar error aaye `psycopg` wala, toh ignore karo - development mein SQLite use hota hai, PostgreSQL ki zaroorat nahi.
> Quick fix: `pip install -r requirements/base.txt` minus psycopg:
> ```bash
> pip install Django djangorestframework djangorestframework-simplejwt django-cors-headers django-filter drf-spectacular django-health-check whitenoise python-dotenv openai gunicorn django-debug-toolbar pytest pytest-django factory-boy
> ```

---

### Step 4: Configure Environment

```bash
# Copy example env file
cp .env.example .env
```

Now `.env` file edit karo (VS Code mein open karo):
```env
# Ye change karo:
DJANGO_SETTINGS_MODULE=focus_guardian.settings.development
DJANGO_DEBUG=True
DJANGO_SECRET_KEY=any-random-string-for-development-only

# OpenAI key optional hai - bina key ke mock response milega
OPENAI_API_KEY=
```

---

### Step 5: Run Database Migrations

```bash
cd src
python manage.py migrate
```

Expected output:
```
Operations to perform:
  Apply all migrations: admin, auth, contenttypes, core, sessions, token_blacklist
Running migrations:
  Applying contenttypes.0001_initial... OK
  Applying auth.0001_initial... OK
  ...
```

---

### Step 6: Create Sample Data (Optional)

```bash
python manage.py seed_data
```

This creates a demo user: `demo` / `DemoPass123!`

---

### Step 7: Create Your Admin Account

```bash
python manage.py createsuperuser
# Username, email, password enter karo
```

---

### Step 8: Run the Development Server

```bash
python manage.py runserver
```

Output:
```
Starting development server at http://127.0.0.1:8000/
```

---

### Step 9: Test in Browser

Open these URLs:

| URL | What it shows |
|-----|--------------|
| http://127.0.0.1:8000/api/docs/ | **Swagger API Documentation** (try all endpoints here!) |
| http://127.0.0.1:8000/admin/ | **Django Admin Panel** (login with superuser) |
| http://127.0.0.1:8000/health/ | **Health Check** (should show "OK") |
| http://127.0.0.1:8000/dashboard/ | **Dashboard** (needs login) |

---

### Step 10: Test API with Swagger UI

1. Go to `http://127.0.0.1:8000/api/docs/`
2. Click **POST /api/v1/auth/register/** → Try it out
3. Enter username, email, password, password_confirm → Execute
4. Copy the `access` token from response
5. Click the **Authorize** button (top right, lock icon)
6. Enter: `Bearer YOUR_ACCESS_TOKEN`
7. Now you can test all other endpoints!

---

## Running Tests

### All tests:
```bash
# From project root (not src/)
cd ..  # go back to Lockin-AI root
pytest
```

### With verbose output:
```bash
pytest -v
```

### With coverage report:
```bash
pytest --cov=core --cov-report=term-missing
```

### Specific test file:
```bash
pytest tests/core/test_api.py -v
```

### Specific test class:
```bash
pytest tests/core/test_api.py::TestFocusSession -v
```

---

## Testing with cURL (Terminal)

### Register:
```bash
curl -X POST http://127.0.0.1:8000/api/v1/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{"username":"rishi", "email":"rishi@test.com", "password":"MySecure123!", "password_confirm":"MySecure123!"}'
```

### Login (Get Token):
```bash
curl -X POST http://127.0.0.1:8000/api/v1/auth/token/ \
  -H "Content-Type: application/json" \
  -d '{"username":"rishi", "password":"MySecure123!"}'
```

### Start Session (use your token):
```bash
curl -X POST http://127.0.0.1:8000/api/v1/sessions/start/ \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -d '{"session_type":"pomodoro", "planned_duration_minutes": 25}'
```

### Ask AI Teacher:
```bash
curl -X POST http://127.0.0.1:8000/api/v1/ai-teacher/ \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -d '{"message":"Explain Newton laws simply"}'
```

---

## Testing on Phone (Same WiFi)

1. Find your computer's local IP:
   ```bash
   # Windows
   ipconfig
   # Mac/Linux
   ifconfig | grep "inet "
   ```
   Look for something like `192.168.1.X`

2. Run server on all interfaces:
   ```bash
   python manage.py runserver 0.0.0.0:8000
   ```

3. On phone browser, open: `http://192.168.1.X:8000/api/docs/`

---

## VS Code Recommended Extensions

Install these for best experience:
- **Python** (Microsoft)
- **Pylance** (Microsoft)
- **REST Client** (Huachao Mao) - test API directly from VS Code
- **Thunder Client** (Ranga Vadhineni) - like Postman in VS Code
- **Django** (Baptiste Darthenay)

---

## Common Issues

| Issue | Fix |
|-------|-----|
| `ModuleNotFoundError: No module named 'django'` | Activate venv: `source venv/bin/activate` |
| `port 8000 already in use` | Kill it: `lsof -ti:8000 \| xargs kill` (Mac/Linux) or use port 8001 |
| `no such table: core_userprofile` | Run `python manage.py migrate` |
| `CSRF verification failed` | Use API endpoints with JWT, not session auth |
| `debug_toolbar` import error | `pip install django-debug-toolbar` or remove from dev settings |

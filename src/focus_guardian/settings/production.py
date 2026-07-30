"""
Production settings for Focus Guardian project.
"""

import os
from .base import *  # noqa: F401, F403

# Security
SECRET_KEY = os.environ["DJANGO_SECRET_KEY"]  # Will raise if not set

DEBUG = False

ALLOWED_HOSTS = [h for h in os.getenv("DJANGO_ALLOWED_HOSTS", "").split(",") if h]

# Render.com automatically provides the external hostname.
RENDER_EXTERNAL_HOSTNAME = os.getenv("RENDER_EXTERNAL_HOSTNAME")
if RENDER_EXTERNAL_HOSTNAME:
    ALLOWED_HOSTS.append(RENDER_EXTERNAL_HOSTNAME)
    CSRF_TRUSTED_ORIGINS = [f"https://{RENDER_EXTERNAL_HOSTNAME}"]

# Fallback so the app never crashes with an empty ALLOWED_HOSTS in a
# managed platform (Render/Cloud Run both terminate TLS in front of us).
if not ALLOWED_HOSTS:
    ALLOWED_HOSTS = [".onrender.com", ".run.app"]

# HTTPS / Security Headers
SECURE_SSL_REDIRECT = os.getenv("DJANGO_SECURE_SSL_REDIRECT", "True") == "True"
SECURE_HSTS_SECONDS = 31536000  # 1 year
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True
SECURE_PROXY_SSL_HEADER = ("HTTP_X_FORWARDED_PROTO", "https")
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
SECURE_BROWSER_XSS_FILTER = True
SECURE_CONTENT_TYPE_NOSNIFF = True
X_FRAME_OPTIONS = "DENY"

# CORS - Restrict to specific origins
CORS_ALLOW_ALL_ORIGINS = False
CORS_ALLOWED_ORIGINS = os.getenv("CORS_ALLOWED_ORIGINS", "").split(",")

# Database configuration
# Priority 1: DATABASE_URL (used by Render.com, Heroku, Railway, etc.)
# Priority 2: Individual DB_* env vars (Docker / Cloud SQL Unix socket)
DATABASE_URL = os.environ.get("DATABASE_URL")
DB_HOST = os.environ.get("DB_HOST", "db")

if DATABASE_URL:
    # Parse the connection URL provided by the hosting platform.
    import dj_database_url

    DATABASES = {
        "default": dj_database_url.parse(
            DATABASE_URL,
            conn_max_age=600,
            conn_health_checks=True,
            ssl_require=os.getenv("DB_SSL_REQUIRE", "True") == "True",
        )
    }
elif DB_HOST.startswith("/"):
    # Cloud SQL Unix socket connection
    DATABASES = {
        "default": {
            "ENGINE": "django.db.backends.postgresql",
            "NAME": os.environ.get("DB_NAME", "focus_guardian"),
            "USER": os.environ.get("DB_USER", "postgres"),
            "PASSWORD": os.environ.get("DB_PASSWORD"),
            "HOST": DB_HOST,
            "CONN_MAX_AGE": 600,
            "CONN_HEALTH_CHECKS": True,
        }
    }
else:
    # Standard TCP connection (Docker / local PostgreSQL)
    DATABASES = {
        "default": {
            "ENGINE": "django.db.backends.postgresql",
            "NAME": os.environ.get("DB_NAME", "focus_guardian"),
            "USER": os.environ.get("DB_USER", "focus_guardian"),
            "PASSWORD": os.environ.get("DB_PASSWORD"),
            "HOST": DB_HOST,
            "PORT": os.environ.get("DB_PORT", "5432"),
            "CONN_MAX_AGE": 600,
            "CONN_HEALTH_CHECKS": True,
            "OPTIONS": {
                "connect_timeout": 10,
                "options": "-c statement_timeout=30000",
            },
        }
    }

# Cache - Redis for production
CACHES = {
    "default": {
        "BACKEND": "django.core.cache.backends.redis.RedisCache",
        "LOCATION": os.getenv("REDIS_URL", "redis://redis:6379/0"),
        "OPTIONS": {
            "CLIENT_CLASS": "django_redis.client.DefaultClient",
        },
    }
}

# Session backend using cache
SESSION_ENGINE = "django.contrib.sessions.backends.cache"
SESSION_CACHE_ALIAS = "default"

# Email Configuration
EMAIL_BACKEND = "django.core.mail.backends.smtp.EmailBackend"
EMAIL_HOST = os.getenv("EMAIL_HOST", "smtp.gmail.com")
EMAIL_PORT = int(os.getenv("EMAIL_PORT", "587"))
EMAIL_USE_TLS = True
EMAIL_HOST_USER = os.getenv("EMAIL_HOST_USER", "")
EMAIL_HOST_PASSWORD = os.getenv("EMAIL_HOST_PASSWORD", "")
DEFAULT_FROM_EMAIL = os.getenv("DEFAULT_FROM_EMAIL", "noreply@focusguardian.ai")

# Logging - JSON format in production
LOGGING["handlers"]["console"]["formatter"] = "json"  # noqa: F405
LOGGING["handlers"]["console"]["level"] = "INFO"  # noqa: F405

# ADMINS for error notifications
ADMINS = [
    (
        os.getenv("ADMIN_NAME", "Admin"),
        os.getenv("ADMIN_EMAIL", "admin@focusguardian.ai"),
    )
]

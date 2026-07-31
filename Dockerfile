# ============================================================
# Focus Guardian AI - Production Dockerfile
# Multi-stage build for minimal image size
# ============================================================

# Stage 1: Builder
FROM python:3.12-slim AS builder

WORKDIR /build

# Install system dependencies for building
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements/base.txt requirements/base.txt
COPY requirements/production.txt requirements/production.txt
RUN pip install --no-cache-dir --prefix=/install -r requirements/production.txt

# Stage 2: Production
FROM python:3.12-slim AS production

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DJANGO_SETTINGS_MODULE=focus_guardian.settings.production \
    PORT=8000

WORKDIR /app

# Install runtime system dependencies only
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq5 \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && addgroup --system app \
    && adduser --system --ingroup app app

# Copy Python packages from builder
COPY --from=builder /install /usr/local

# Copy application code
COPY src/ /app/

# Create necessary directories
RUN mkdir -p /app/staticfiles /app/logs \
    && chown -R app:app /app

# Collect static files
RUN python manage.py collectstatic --noinput 2>/dev/null || true

# Switch to non-root user
USER app

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:${PORT}/health/ || exit 1

# Run with gunicorn
EXPOSE ${PORT}
CMD exec gunicorn focus_guardian.wsgi:application \
     --bind 0.0.0.0:${PORT} \
     --workers 2 \
     --worker-class gthread \
     --threads 2 \
     --worker-tmp-dir /dev/shm \
     --access-logfile - \
     --error-logfile - \
     --timeout 120 \
     --graceful-timeout 30 \
     --max-requests 1000 \
     --max-requests-jitter 50

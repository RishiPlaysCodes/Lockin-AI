#!/usr/bin/env bash
# ============================================================
# Focus Guardian AI - Render.com Build Script
# ============================================================
# Runs automatically during deployment on Render.
# ============================================================

set -o errexit  # Exit on any error

echo "=== Installing dependencies ==="
pip install --upgrade pip
pip install -r requirements/production.txt

echo "=== Collecting static files ==="
cd src
python manage.py collectstatic --no-input

echo "=== Running database migrations ==="
python manage.py migrate

echo "=== Creating superuser (if configured) ==="
# Only creates if DJANGO_SUPERUSER_* env vars are set in Render dashboard
python manage.py createsuperuser --no-input 2>/dev/null || echo "Skipping superuser (not configured or already exists)"

echo "=== Build complete ==="

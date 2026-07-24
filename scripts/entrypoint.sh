#!/bin/bash
# ============================================================
# Focus Guardian AI - Docker Entrypoint Script
# ============================================================

set -e

echo "=== Focus Guardian AI - Starting ==="

# Wait for database to be ready
echo "Waiting for database..."
while ! python -c "
import os, psycopg
conn = psycopg.connect(
    host=os.environ.get('DB_HOST', 'db'),
    port=os.environ.get('DB_PORT', '5432'),
    user=os.environ.get('DB_USER', 'focus_guardian'),
    password=os.environ.get('DB_PASSWORD', ''),
    dbname=os.environ.get('DB_NAME', 'focus_guardian'),
)
conn.close()
" 2>/dev/null; do
    echo "Database not ready, waiting 2 seconds..."
    sleep 2
done
echo "Database is ready!"

# Run migrations
echo "Running migrations..."
python manage.py migrate --noinput

# Collect static files
echo "Collecting static files..."
python manage.py collectstatic --noinput

echo "=== Starting Gunicorn ==="
exec "$@"

# Focus Guardian AI - Deployment Guide

## Google Cloud Run (FREE Deployment)

This guide will take you from zero to a live production app on Google Cloud — **completely free**.

### Why Cloud Run?

Google Cloud Run ka **Always Free Tier** milta hai:
- **2 Million requests/month** free
- **180,000 vCPU-seconds** free
- **360,000 GiB-seconds** memory free
- **1 GB** network egress (North America) free

Matlab agar tere app pe zyada traffic nahi hai (student project ya personal use), toh **$0/month** lagega.

---

### Prerequisites

1. **Google Account** (Gmail wala hi chalega)
2. **Google Cloud Console** access - [console.cloud.google.com](https://console.cloud.google.com)
3. **gcloud CLI** installed on your computer

---

### Step 0: Check Your Student Benefits

Agar tune **Google Developer Student Club** join kiya tha:
1. Go to [cloud.google.com/edu/students](https://cloud.google.com/edu/students)
2. Sign in with your student email
3. Check if you have any education credits available
4. Also check [Google Cloud Skills Boost](https://www.cloudskillsboost.google/) for free learning labs

Even without student benefits, you get:
- **$300 free credits** for 90 days (new Google Cloud accounts)
- **Always Free tier** (never expires, no credit card needed for these limits)

---

### Step 1: Install gcloud CLI

#### Windows:
```powershell
# Download and run the installer from:
# https://cloud.google.com/sdk/docs/install#windows
# OR use winget:
winget install Google.CloudSDK
```

#### Mac:
```bash
brew install --cask google-cloud-sdk
```

#### Linux:
```bash
curl https://sdk.cloud.google.com | bash
exec -l $SHELL
```

After installation:
```bash
gcloud init
# Browser open hoga - apna Google account select karo
# Project select/create karo (naam: focus-guardian-ai)
```

---

### Step 2: Create Google Cloud Project

```bash
# Create a new project
gcloud projects create focus-guardian-ai --name="Focus Guardian AI"

# Set it as active
gcloud config set project focus-guardian-ai

# Enable billing (free trial will be activated)
# This will open browser - follow prompts
gcloud billing accounts list

# Enable required APIs
gcloud services enable \
  run.googleapis.com \
  cloudbuild.googleapis.com \
  sqladmin.googleapis.com \
  secretmanager.googleapis.com
```

---

### Step 3: Set Up Cloud SQL (PostgreSQL) - Free Trial

```bash
# Create a FREE trial PostgreSQL instance
gcloud sql instances create focus-guardian-db \
  --database-version=POSTGRES_16 \
  --tier=db-f1-micro \
  --region=us-central1 \
  --edition=enterprise \
  --enable-google-private-path

# Set root password
gcloud sql users set-password postgres \
  --instance=focus-guardian-db \
  --password=YOUR_SECURE_PASSWORD_HERE

# Create the database
gcloud sql databases create focus_guardian \
  --instance=focus-guardian-db
```

> **Note:** Cloud SQL has a free trial instance. After that, db-f1-micro is the cheapest (~$7/month). If you want 100% free, you can use SQLite in the container (not recommended for production but works for personal projects).

---

### Step 4: Store Secrets in Secret Manager

```bash
# Generate a Django secret key
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"

# Store secrets
echo -n "YOUR_GENERATED_SECRET_KEY" | gcloud secrets create django-secret-key --data-file=-
echo -n "YOUR_DB_PASSWORD" | gcloud secrets create db-password --data-file=-
echo -n "sk-your-openai-key" | gcloud secrets create openai-api-key --data-file=-
```

---

### Step 5: Deploy to Cloud Run

```bash
# Navigate to project root
cd Lockin-AI

# Deploy (Cloud Build will build your Dockerfile automatically)
gcloud run deploy focus-guardian \
  --source=. \
  --region=us-central1 \
  --platform=managed \
  --allow-unauthenticated \
  --set-env-vars="DJANGO_SETTINGS_MODULE=focus_guardian.settings.production" \
  --set-env-vars="DJANGO_ALLOWED_HOSTS=*.run.app" \
  --set-env-vars="CORS_ALLOWED_ORIGINS=https://focus-guardian-XXXXX-uc.a.run.app" \
  --set-env-vars="DB_NAME=focus_guardian" \
  --set-env-vars="DB_USER=postgres" \
  --set-env-vars="DB_HOST=/cloudsql/focus-guardian-ai:us-central1:focus-guardian-db" \
  --set-secrets="DJANGO_SECRET_KEY=django-secret-key:latest" \
  --set-secrets="DB_PASSWORD=db-password:latest" \
  --set-secrets="OPENAI_API_KEY=openai-api-key:latest" \
  --add-cloudsql-instances=focus-guardian-ai:us-central1:focus-guardian-db \
  --memory=512Mi \
  --cpu=1 \
  --min-instances=0 \
  --max-instances=2 \
  --port=8000
```

After deployment, you'll get a URL like:
```
https://focus-guardian-xxxxx-uc.a.run.app
```

---

### Step 6: Run Migrations

```bash
# Connect to Cloud Run and run migrations
gcloud run jobs create migrate-job \
  --image=gcr.io/focus-guardian-ai/focus-guardian \
  --region=us-central1 \
  --set-env-vars="DJANGO_SETTINGS_MODULE=focus_guardian.settings.production" \
  --set-env-vars="DB_NAME=focus_guardian" \
  --set-env-vars="DB_USER=postgres" \
  --set-env-vars="DB_HOST=/cloudsql/focus-guardian-ai:us-central1:focus-guardian-db" \
  --set-secrets="DJANGO_SECRET_KEY=django-secret-key:latest" \
  --set-secrets="DB_PASSWORD=db-password:latest" \
  --add-cloudsql-instances=focus-guardian-ai:us-central1:focus-guardian-db \
  --command="python" \
  --args="manage.py,migrate"

gcloud run jobs execute migrate-job --region=us-central1
```

---

### Step 7: Create Superuser

```bash
# Create admin superuser
gcloud run jobs create create-superuser \
  --image=gcr.io/focus-guardian-ai/focus-guardian \
  --region=us-central1 \
  --set-env-vars="DJANGO_SETTINGS_MODULE=focus_guardian.settings.production" \
  --set-env-vars="DB_NAME=focus_guardian" \
  --set-env-vars="DB_USER=postgres" \
  --set-env-vars="DB_HOST=/cloudsql/focus-guardian-ai:us-central1:focus-guardian-db" \
  --set-env-vars="DJANGO_SUPERUSER_USERNAME=admin" \
  --set-env-vars="DJANGO_SUPERUSER_EMAIL=your-email@gmail.com" \
  --set-env-vars="DJANGO_SUPERUSER_PASSWORD=YourAdminPass123!" \
  --set-secrets="DJANGO_SECRET_KEY=django-secret-key:latest" \
  --set-secrets="DB_PASSWORD=db-password:latest" \
  --add-cloudsql-instances=focus-guardian-ai:us-central1:focus-guardian-db \
  --command="python" \
  --args="manage.py,createsuperuser,--noinput"

gcloud run jobs execute create-superuser --region=us-central1
```

---

### Step 8: Verify Deployment

Open your browser and check:
- **Health Check:** `https://YOUR-URL.run.app/health/`
- **API Docs:** `https://YOUR-URL.run.app/api/docs/`
- **Admin Panel:** `https://YOUR-URL.run.app/admin/`

---

### Updating Your App

Jab bhi code change kare, redeploy:
```bash
gcloud run deploy focus-guardian --source=. --region=us-central1
```

---

### Cost Monitoring

```bash
# Check your billing
gcloud billing accounts list

# Set a budget alert (so you never get surprised)
# Go to: https://console.cloud.google.com/billing/budgets
# Set budget to $1 with email alerts
```

---

### 100% FREE Alternative (No Database Cost)

If you want to avoid ANY charges, use **SQLite inside Cloud Run** (for personal/demo use only):

In `settings/production.py`, change database to:
```python
DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.sqlite3",
        "NAME": "/tmp/db.sqlite3",
    }
}
```

> **Warning:** Data resets when the container restarts. Only good for demos.

---

### Troubleshooting

| Problem | Solution |
|---------|----------|
| "Permission denied" | Run `gcloud auth login` again |
| "Billing not enabled" | Enable billing at console.cloud.google.com/billing |
| "Cloud SQL connection failed" | Check `--add-cloudsql-instances` flag matches your instance |
| "502 Bad Gateway" | Check logs: `gcloud run services logs read focus-guardian` |
| "Module not found" | Rebuild: `gcloud run deploy focus-guardian --source=.` |

### View Logs
```bash
gcloud run services logs read focus-guardian --region=us-central1 --limit=50
```

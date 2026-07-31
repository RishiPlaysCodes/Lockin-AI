import datetime
import uuid

import django.core.validators
import django.db.models.deletion
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name="FocusSession",
            fields=[
                ("created_at", models.DateTimeField(auto_now_add=True, db_index=True)),
                ("updated_at", models.DateTimeField(auto_now=True)),
                (
                    "id",
                    models.UUIDField(
                        default=uuid.uuid4,
                        editable=False,
                        primary_key=True,
                        serialize=False,
                    ),
                ),
                ("start_time", models.DateTimeField(auto_now_add=True)),
                ("end_time", models.DateTimeField(blank=True, db_index=True, null=True)),
                ("is_active", models.BooleanField(db_index=True, default=True)),
                (
                    "session_type",
                    models.CharField(
                        choices=[
                            ("pomodoro", "Pomodoro (25 min)"),
                            ("short", "Short (15 min)"),
                            ("long", "Long (50 min)"),
                            ("custom", "Custom"),
                        ],
                        default="pomodoro",
                        max_length=20,
                    ),
                ),
                (
                    "planned_duration_minutes",
                    models.PositiveIntegerField(
                        default=25, help_text="Planned duration in minutes."
                    ),
                ),
                ("notes", models.TextField(blank=True, default="")),
                (
                    "user",
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.CASCADE,
                        related_name="focus_sessions",
                        to=settings.AUTH_USER_MODEL,
                    ),
                ),
            ],
            options={
                "verbose_name": "Focus Session",
                "verbose_name_plural": "Focus Sessions",
                "ordering": ["-start_time"],
            },
        ),
        migrations.CreateModel(
            name="UserProfile",
            fields=[
                ("created_at", models.DateTimeField(auto_now_add=True, db_index=True)),
                ("updated_at", models.DateTimeField(auto_now=True)),
                (
                    "id",
                    models.UUIDField(
                        default=uuid.uuid4,
                        editable=False,
                        primary_key=True,
                        serialize=False,
                    ),
                ),
                (
                    "focus_score",
                    models.IntegerField(
                        default=100,
                        help_text="Current focus score (0-100). Decreases with distractions.",
                        validators=[
                            django.core.validators.MinValueValidator(0),
                            django.core.validators.MaxValueValidator(100),
                        ],
                    ),
                ),
                (
                    "total_study_time",
                    models.DurationField(
                        default=datetime.timedelta(0),
                        help_text="Cumulative study time across all sessions.",
                    ),
                ),
                (
                    "daily_goal_minutes",
                    models.PositiveIntegerField(
                        default=120, help_text="Daily study goal in minutes."
                    ),
                ),
                (
                    "streak_days",
                    models.PositiveIntegerField(
                        default=0,
                        help_text="Consecutive days with at least one completed session.",
                    ),
                ),
                ("last_active_date", models.DateField(blank=True, null=True)),
                (
                    "user",
                    models.OneToOneField(
                        on_delete=django.db.models.deletion.CASCADE,
                        related_name="profile",
                        to=settings.AUTH_USER_MODEL,
                    ),
                ),
            ],
            options={
                "verbose_name": "User Profile",
                "verbose_name_plural": "User Profiles",
                "ordering": ["-created_at"],
            },
        ),
        migrations.CreateModel(
            name="Distraction",
            fields=[
                ("created_at", models.DateTimeField(auto_now_add=True, db_index=True)),
                ("updated_at", models.DateTimeField(auto_now=True)),
                (
                    "id",
                    models.UUIDField(
                        default=uuid.uuid4,
                        editable=False,
                        primary_key=True,
                        serialize=False,
                    ),
                ),
                (
                    "app_name",
                    models.CharField(
                        db_index=True,
                        help_text="Name of the application or activity that caused the distraction.",
                        max_length=255,
                    ),
                ),
                ("timestamp", models.DateTimeField(auto_now_add=True)),
                (
                    "distraction_type",
                    models.CharField(
                        choices=[
                            ("app_switch", "App Switch"),
                            ("visibility_change", "Tab/Window Switch"),
                            ("notification", "Notification"),
                            ("manual", "Self-reported"),
                            ("mock", "Simulated (Testing)"),
                        ],
                        default="app_switch",
                        max_length=50,
                    ),
                ),
                (
                    "duration_seconds",
                    models.PositiveIntegerField(
                        default=0,
                        help_text="How long the user was distracted (in seconds).",
                    ),
                ),
                (
                    "session",
                    models.ForeignKey(
                        on_delete=django.db.models.deletion.CASCADE,
                        related_name="distractions",
                        to="core.focussession",
                    ),
                ),
            ],
            options={
                "verbose_name": "Distraction",
                "verbose_name_plural": "Distractions",
                "ordering": ["-timestamp"],
            },
        ),
        migrations.AddConstraint(
            model_name="focussession",
            constraint=models.CheckConstraint(
                condition=models.Q(
                    ("end_time__isnull", True),
                    ("end_time__gte", models.F("start_time")),
                    _connector="OR",
                ),
                name="end_time_after_start_time",
            ),
        ),
        migrations.AddIndex(
            model_name="focussession",
            index=models.Index(
                fields=["user", "is_active"], name="fs_user_active_idx"
            ),
        ),
        migrations.AddIndex(
            model_name="focussession",
            index=models.Index(
                fields=["user", "-start_time"], name="fs_user_start_idx"
            ),
        ),
        migrations.AddIndex(
            model_name="distraction",
            index=models.Index(
                fields=["session", "-timestamp"], name="distr_sess_ts_idx"
            ),
        ),
    ]

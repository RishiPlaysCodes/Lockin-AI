"""
Management command to seed the database with sample data for development.
"""

from datetime import timedelta

from django.contrib.auth.models import User
from django.core.management.base import BaseCommand
from django.utils import timezone

from core.models import Distraction, FocusSession, UserProfile


class Command(BaseCommand):
    help = "Seed the database with sample data for development/testing"

    def add_arguments(self, parser):
        parser.add_argument(
            "--clear",
            action="store_true",
            help="Clear existing data before seeding",
        )

    def handle(self, *args, **options):
        if options["clear"]:
            self.stdout.write("Clearing existing data...")
            Distraction.objects.all().delete()
            FocusSession.objects.all().delete()
            UserProfile.objects.all().delete()
            User.objects.filter(is_superuser=False).delete()

        self.stdout.write("Creating sample users...")

        # Create demo user
        demo_user, created = User.objects.get_or_create(
            username="demo",
            defaults={"email": "demo@focusguardian.ai"},
        )
        if created:
            demo_user.set_password("DemoPass123!")
            demo_user.save()
            self.stdout.write(self.style.SUCCESS(f"Created user: demo / DemoPass123!"))

        profile, _ = UserProfile.objects.get_or_create(user=demo_user)
        profile.focus_score = 85
        profile.streak_days = 7
        profile.daily_goal_minutes = 120
        profile.save()

        # Create sample sessions
        self.stdout.write("Creating sample sessions...")
        now = timezone.now()

        for i in range(5):
            start = now - timedelta(days=i, hours=2)
            session = FocusSession.objects.create(
                user=demo_user,
                session_type="pomodoro",
                planned_duration_minutes=25,
                is_active=False,
                notes=f"Study session day {i + 1}",
            )
            # Override auto_now_add
            FocusSession.objects.filter(pk=session.pk).update(
                start_time=start,
                end_time=start + timedelta(minutes=25),
            )

            # Add some distractions
            if i % 2 == 0:
                Distraction.objects.create(
                    session=session,
                    app_name="YouTube",
                    distraction_type="app_switch",
                    duration_seconds=30,
                )

        # Update total study time
        profile.total_study_time = timedelta(hours=2, minutes=5)
        profile.save()

        self.stdout.write(
            self.style.SUCCESS(
                f"Successfully seeded database with demo data.\n"
                f"  Login: demo / DemoPass123!\n"
                f"  Sessions: 5, Distractions: 3"
            )
        )

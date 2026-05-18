from django.db import models
from django.contrib.auth.models import User
from datetime import timedelta

class UserProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    focus_score = models.IntegerField(default=100)
    total_study_time = models.DurationField(default=timedelta(0))

    def __str__(self):
        return self.user.username

class FocusSession(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    start_time = models.DateTimeField(auto_now_add=True)
    end_time = models.DateTimeField(null=True, blank=True)
    is_active = models.BooleanField(default=True)

    def __str__(self):
        return f"{self.user.username} - {self.start_time}"

class Distraction(models.Model):
    session = models.ForeignKey(FocusSession, related_name='distractions', on_delete=models.CASCADE)
    app_name = models.CharField(max_length=255)
    timestamp = models.DateTimeField(auto_now_add=True)
    distraction_type = models.CharField(max_length=50, default='app_switch')

    def __str__(self):
        return f"{self.session.user.username} - {self.app_name} at {self.timestamp}"

from django.test import TestCase
from django.contrib.auth.models import User
from django.urls import reverse
from rest_framework.test import APIClient
from rest_framework import status
from core.models import FocusSession, UserProfile

class FocusGuardianTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.user = User.objects.create_user(username='testuser', password='testpassword123')
        self.client.force_authenticate(user=self.user)
        self.profile = UserProfile.objects.create(user=self.user)

    def test_start_session(self):
        response = self.client.post(reverse('session-start'))
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertEqual(FocusSession.objects.count(), 1)
        self.assertTrue(FocusSession.objects.first().is_active)

    def test_log_distraction(self):
        self.client.post(reverse('session-start'))
        response = self.client.post(reverse('log-distraction'), {'app_name': 'YouTube', 'distraction_type': 'app_switch'})
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        
        self.profile.refresh_from_db()
        self.assertEqual(self.profile.focus_score, 95)

    def test_end_session(self):
        self.client.post(reverse('session-start'))
        response = self.client.post(reverse('session-end'))
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        session = FocusSession.objects.first()
        self.assertFalse(session.is_active)
        self.assertIsNotNone(session.end_time)

    def test_ai_teacher_mock(self):
        response = self.client.post(reverse('ai-teacher'), {'message': 'Hello'})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIn('reply', response.data)

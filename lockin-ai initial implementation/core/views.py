from rest_framework import status, permissions
from rest_framework.response import Response
from rest_framework.views import APIView
from django.contrib.auth import authenticate, login, logout
from .serializers import UserSerializer, UserProfileSerializer, FocusSessionSerializer, DistractionSerializer
from .models import UserProfile, FocusSession, Distraction
from django.utils import timezone
from django.shortcuts import render
from django.contrib.auth.decorators import login_required
from django.utils.decorators import method_decorator
import openai
import os
from dotenv import load_dotenv

load_dotenv()
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")

class SignupView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        serializer = UserSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class LoginView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        username = request.data.get('username')
        password = request.data.get('password')
        user = authenticate(username=username, password=password)
        if user:
            login(request, user)
            return Response({'message': 'Login successful'})
        return Response({'error': 'Invalid credentials'}, status=status.HTTP_401_UNAUTHORIZED)

class LogoutView(APIView):
    def post(self, request):
        logout(request)
        return Response({'message': 'Logout successful'})

class UserProfileView(APIView):
    def get(self, request):
        profile, created = UserProfile.objects.get_or_create(user=request.user)
        serializer = UserProfileSerializer(profile)
        return Response(serializer.data)

def dashboard_view(request):
    return render(request, 'core/dashboard.html')

def timer_view(request):
    return render(request, 'core/timer.html')

def chat_view(request):
    return render(request, 'core/chat.html')

class StudyReportView(APIView):
    def get(self, request):
        sessions = FocusSession.objects.filter(user=request.user).order_by('-start_time')[:10]
        report = []
        for session in sessions:
            report.append({
                'start_time': session.start_time,
                'end_time': session.end_time,
                'duration': str(session.end_time - session.start_time) if session.end_time else 'Active',
                'distractions_count': session.distractions.count()
            })
        return Response(report)

class StartFocusSessionView(APIView):
    def post(self, request):
        # End any existing active sessions
        FocusSession.objects.filter(user=request.user, is_active=True).update(
            is_active=False, end_time=timezone.now()
        )
        session = FocusSession.objects.create(user=request.user)
        serializer = FocusSessionSerializer(session)
        return Response(serializer.data, status=status.HTTP_201_CREATED)

class EndFocusSessionView(APIView):
    def post(self, request):
        try:
            session = FocusSession.objects.get(user=request.user, is_active=True)
            session.is_active = False
            session.end_time = timezone.now()
            session.save()
            
            # Update total study time
            duration = session.end_time - session.start_time
            profile = UserProfile.objects.get(user=request.user)
            profile.total_study_time += duration
            profile.save()

            serializer = FocusSessionSerializer(session)
            return Response(serializer.data)
        except FocusSession.DoesNotExist:
            return Response({'error': 'No active session found'}, status=status.HTTP_404_NOT_FOUND)

class LogDistractionView(APIView):
    def post(self, request):
        try:
            session = FocusSession.objects.get(user=request.user, is_active=True)
            data = request.data.copy()
            data['session'] = session.id
            serializer = DistractionSerializer(data=data)
            if serializer.is_valid():
                serializer.save()
                
                # Reduce focus score
                profile = UserProfile.objects.get(user=request.user)
                profile.focus_score = max(0, profile.focus_score - 5)
                profile.save()
                
                return Response(serializer.data, status=status.HTTP_201_CREATED)
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        except FocusSession.DoesNotExist:
            return Response({'error': 'No active session found'}, status=status.HTTP_404_NOT_FOUND)

class AITeacherView(APIView):
    def post(self, request):
        user_message = request.data.get('message')
        if not user_message:
            return Response({'error': 'Message is required'}, status=status.HTTP_400_BAD_REQUEST)
        
        if not OPENAI_API_KEY:
             return Response({
                'reply': f"I'm your Focus Guardian AI Teacher. You said: '{user_message}'. Keep focusing on your studies! (Note: OpenAI API key not configured, this is a mock response.)"
            })

        try:
            client = openai.OpenAI(api_key=OPENAI_API_KEY)
            response = client.chat.completions.create(
                model="gpt-3.5-turbo",
                messages=[
                    {"role": "system", "content": "You are a helpful AI study guardian and teacher. Your goal is to help students stay focused, explain concepts, and provide encouragement."},
                    {"role": "user", "content": user_message}
                ]
            )
            return Response({'reply': response.choices[0].message.content})
        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

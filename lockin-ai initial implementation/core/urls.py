from django.urls import path
from .views import (
    SignupView, LoginView, LogoutView, UserProfileView,
    StartFocusSessionView, EndFocusSessionView, LogDistractionView,
    AITeacherView,
    dashboard_view, timer_view, chat_view, StudyReportView
)

urlpatterns = [
    path('dashboard/', dashboard_view, name='dashboard'),
    path('timer/', timer_view, name='timer'),
    path('chat/', chat_view, name='chat'),
    path('api/report/', StudyReportView.as_view(), name='study-report'),
    path('api/signup/', SignupView.as_view(), name='signup'),
    path('api/login/', LoginView.as_view(), name='login'),
    path('api/logout/', LogoutView.as_view(), name='logout'),
    path('api/profile/', UserProfileView.as_view(), name='profile'),
    path('api/session/start/', StartFocusSessionView.as_view(), name='session-start'),
    path('api/session/end/', EndFocusSessionView.as_view(), name='session-end'),
    path('api/distraction/', LogDistractionView.as_view(), name='log-distraction'),
    path('api/ai-teacher/', AITeacherView.as_view(), name='ai-teacher'),
]

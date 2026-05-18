from rest_framework import serializers
from django.contrib.auth.models import User
from .models import UserProfile, FocusSession, Distraction

class UserSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'password']

    def create(self, validated_data):
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data.get('email', ''),
            password=validated_data['password']
        )
        UserProfile.objects.create(user=user)
        return user

class UserProfileSerializer(serializers.ModelSerializer):
    username = serializers.CharField(source='user.username', read_only=True)

    class Meta:
        model = UserProfile
        fields = ['username', 'focus_score', 'total_study_time']

class DistractionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Distraction
        fields = ['id', 'session', 'app_name', 'timestamp', 'distraction_type']

class FocusSessionSerializer(serializers.ModelSerializer):
    distractions = DistractionSerializer(many=True, read_only=True)

    class Meta:
        model = FocusSession
        fields = ['id', 'user', 'start_time', 'end_time', 'is_active', 'distractions']
        read_only_fields = ['user', 'start_time']

from django import forms
from django.contrib.auth.models import User
from django.contrib.auth.forms import UserCreationForm
from .models import BlockedSite, UserProfile


class SignupForm(UserCreationForm):
    email = forms.EmailField(required=True)

    class Meta:
        model = User
        fields = ["username", "email", "password1", "password2"]

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        for field_name, field in self.fields.items():
            field.widget.attrs.update({
                "class": "form-control",
                "placeholder": field.label,
            })
        self.fields["username"].widget.attrs["autofocus"] = True

    def clean_email(self):
        email = self.cleaned_data.get("email")
        if User.objects.filter(email=email).exists():
            raise forms.ValidationError("An account with this email already exists.")
        return email


class BlockedSiteForm(forms.ModelForm):
    class Meta:
        model = BlockedSite
        fields = ["name", "url", "category"]
        widgets = {
            "name": forms.TextInput(attrs={
                "class": "form-control",
                "placeholder": "e.g., Instagram",
                "maxlength": "100",
            }),
            "url": forms.TextInput(attrs={
                "class": "form-control",
                "placeholder": "e.g., instagram.com",
                "maxlength": "255",
            }),
            "category": forms.Select(attrs={"class": "form-select"}),
        }

    def clean_url(self):
        url = self.cleaned_data.get("url", "").strip().lower()
        # Remove protocol if user included it
        for prefix in ["https://", "http://", "www."]:
            if url.startswith(prefix):
                url = url[len(prefix):]
        # Remove trailing slash
        url = url.rstrip("/")
        if not url:
            raise forms.ValidationError("Please enter a valid URL.")
        return url


class ProfileEditForm(forms.ModelForm):
    class Meta:
        model = UserProfile
        fields = [
            "bio", "avatar_color", "daily_goal_minutes",
            "theme", "timer_sound", "break_duration",
            "auto_start_breaks", "show_motivational_quotes",
            "distraction_alerts",
        ]
        widgets = {
            "bio": forms.TextInput(attrs={
                "class": "form-control",
                "placeholder": "A short bio about yourself...",
                "maxlength": "200",
            }),
            "avatar_color": forms.TextInput(attrs={
                "class": "form-control form-control-color",
                "type": "color",
            }),
            "daily_goal_minutes": forms.NumberInput(attrs={
                "class": "form-control",
                "min": "15",
                "max": "720",
            }),
            "theme": forms.Select(attrs={"class": "form-select"}),
            "timer_sound": forms.Select(attrs={"class": "form-select"}),
            "break_duration": forms.NumberInput(attrs={
                "class": "form-control",
                "min": "1",
                "max": "30",
            }),
            "auto_start_breaks": forms.CheckboxInput(attrs={"class": "form-check-input"}),
            "show_motivational_quotes": forms.CheckboxInput(attrs={"class": "form-check-input"}),
            "distraction_alerts": forms.CheckboxInput(attrs={"class": "form-check-input"}),
        }

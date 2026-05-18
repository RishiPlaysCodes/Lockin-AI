from django import forms
from django.contrib.auth.models import User
from django.contrib.auth.forms import UserCreationForm
from .models import BlockedSite


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


class BlockedSiteForm(forms.ModelForm):
    class Meta:
        model = BlockedSite
        fields = ["name", "url", "category"]
        widgets = {
            "name": forms.TextInput(attrs={"class": "form-control", "placeholder": "e.g., Instagram"}),
            "url": forms.TextInput(attrs={"class": "form-control", "placeholder": "e.g., instagram.com"}),
            "category": forms.Select(attrs={"class": "form-select"}),
        }

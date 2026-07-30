"""
WSGI config for Focus Guardian project.
"""

import os

from django.core.wsgi import get_wsgi_application

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "focus_guardian.settings.production")

application = get_wsgi_application()

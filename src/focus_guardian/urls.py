"""
URL configuration for Focus Guardian project.
"""

from django.conf import settings
from django.contrib import admin
from django.urls import include, path
from django.views.generic import RedirectView
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView

urlpatterns = [
    # Redirect the bare domain to the API docs so it's not a 404.
    path("", RedirectView.as_view(url="/api/docs/", permanent=False), name="home"),
    path("admin/", admin.site.urls),
    path("api/v1/", include("core.api.v1.urls")),
    path("api/schema/", SpectacularAPIView.as_view(), name="schema"),
    path("api/docs/", SpectacularSwaggerView.as_view(url_name="schema"), name="swagger-ui"),
    path("health/", include("health_check.urls")),
    # Template views (dashboard, timer, chat)
    path("", include("core.urls")),
]

if settings.DEBUG:
    import debug_toolbar

    urlpatterns = [
        path("__debug__/", include(debug_toolbar.urls)),
    ] + urlpatterns

"""
Security headers middleware.

Adds defense-in-depth HTTP response headers that Django's built-in
SecurityMiddleware does not cover (CSP, Referrer-Policy, Permissions-Policy,
COOP). Works on any host (Render, Cloud Run, etc.) without needing nginx.
"""

from django.conf import settings

# Content-Security-Policy.
# The frontend uses Google Fonts (CDN) and small inline <script>/<style>
# blocks in templates, so 'unsafe-inline' is permitted for script/style only.
# Everything else is locked down to 'self'.
_CSP_DIRECTIVES = {
    "default-src": ["'self'"],
    "script-src": ["'self'", "'unsafe-inline'"],
    "style-src": ["'self'", "'unsafe-inline'", "https://fonts.googleapis.com"],
    "font-src": ["'self'", "https://fonts.gstatic.com"],
    "img-src": ["'self'", "data:"],
    "connect-src": ["'self'"],
    "frame-ancestors": ["'none'"],
    "base-uri": ["'self'"],
    "form-action": ["'self'"],
    "object-src": ["'none'"],
}


def _build_csp() -> str:
    return "; ".join(f"{key} {' '.join(values)}" for key, values in _CSP_DIRECTIVES.items())


_CSP_VALUE = _build_csp()

_PERMISSIONS_POLICY = (
    "geolocation=(), microphone=(), camera=(), payment=(), usb=(), "
    "magnetometer=(), gyroscope=(), accelerometer=()"
)


class SecurityHeadersMiddleware:
    """Attach hardened security headers to every response."""

    def __init__(self, get_response):
        self.get_response = get_response
        # Swagger UI needs to load its own inline assets; relax CSP only there.
        self._relaxed_paths = ("/api/docs/", "/api/schema/")

    def __call__(self, request):
        response = self.get_response(request)

        if request.path.startswith(self._relaxed_paths):
            # Swagger UI bundles inline styles/scripts and images from jsdelivr.
            response["Content-Security-Policy"] = (
                "default-src 'self'; "
                "script-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net; "
                "style-src 'self' 'unsafe-inline' https://cdn.jsdelivr.net https://fonts.googleapis.com; "
                "img-src 'self' data: https://cdn.jsdelivr.net; "
                "font-src 'self' https://fonts.gstatic.com; "
                "worker-src 'self' blob:;"
            )
        else:
            response["Content-Security-Policy"] = _CSP_VALUE

        response["Referrer-Policy"] = "strict-origin-when-cross-origin"
        response["Permissions-Policy"] = _PERMISSIONS_POLICY
        response["X-Content-Type-Options"] = "nosniff"
        response["Cross-Origin-Opener-Policy"] = "same-origin"
        response.setdefault("X-Frame-Options", "DENY")

        return response

"""
Request logging middleware.
Logs all API requests with timing information for monitoring and debugging.
"""

import logging
import time

from django.conf import settings

logger = logging.getLogger("core.middleware.request_logging")


class RequestLoggingMiddleware:
    """Middleware that logs request/response information."""

    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        # Skip logging for static files and health checks
        if self._should_skip(request.path):
            return self.get_response(request)

        start_time = time.time()
        response = self.get_response(request)
        duration_ms = (time.time() - start_time) * 1000

        # Log request details
        user = getattr(request, "user", None)
        username = user.username if user and user.is_authenticated else "anonymous"

        log_data = {
            "method": request.method,
            "path": request.path,
            "status_code": response.status_code,
            "duration_ms": round(duration_ms, 2),
            "user": username,
            "ip": self._get_client_ip(request),
        }

        if response.status_code >= 500:
            logger.error("Request failed: %(method)s %(path)s -> %(status_code)s (%(duration_ms)sms)", log_data, extra=log_data)
        elif response.status_code >= 400:
            logger.warning("Request error: %(method)s %(path)s -> %(status_code)s (%(duration_ms)sms)", log_data, extra=log_data)
        elif duration_ms > 1000:
            logger.warning("Slow request: %(method)s %(path)s -> %(status_code)s (%(duration_ms)sms)", log_data, extra=log_data)
        else:
            logger.info("%(method)s %(path)s -> %(status_code)s (%(duration_ms)sms)", log_data, extra=log_data)

        return response

    @staticmethod
    def _should_skip(path: str) -> bool:
        """Check if the request should be skipped from logging."""
        skip_prefixes = ("/static/", "/health/", "/favicon.ico", "/__debug__/")
        return any(path.startswith(prefix) for prefix in skip_prefixes)

    @staticmethod
    def _get_client_ip(request) -> str:
        """Get the client IP address from the request."""
        x_forwarded_for = request.META.get("HTTP_X_FORWARDED_FOR")
        if x_forwarded_for:
            return x_forwarded_for.split(",")[0].strip()
        return request.META.get("REMOTE_ADDR", "")

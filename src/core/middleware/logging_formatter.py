"""
JSON log formatter for structured logging in production.
"""

import json
import logging
import traceback
from datetime import datetime, timezone


class JSONFormatter(logging.Formatter):
    """Format log records as JSON for production logging."""

    def format(self, record):
        log_entry = {
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "level": record.levelname,
            "logger": record.name,
            "message": record.getMessage(),
            "module": record.module,
            "function": record.funcName,
            "line": record.lineno,
        }

        # Add extra fields
        for key in ["method", "path", "status_code", "duration_ms", "user", "ip",
                    "session_id", "user_id", "app_name", "distraction_type"]:
            if hasattr(record, key):
                log_entry[key] = getattr(record, key)

        # Add exception info
        if record.exc_info:
            log_entry["exception"] = traceback.format_exception(*record.exc_info)

        return json.dumps(log_entry)

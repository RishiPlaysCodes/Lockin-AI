"""
Custom exception handler for DRF.
Provides consistent error response format across the API.
"""

import logging

from django.core.exceptions import ValidationError as DjangoValidationError
from django.http import Http404
from rest_framework import status
from rest_framework.exceptions import APIException, ValidationError
from rest_framework.response import Response
from rest_framework.views import exception_handler

logger = logging.getLogger(__name__)


def custom_exception_handler(exc, context):
    """
    Custom exception handler that returns consistent error responses.

    Response format:
    {
        "error": {
            "code": "error_code",
            "message": "Human-readable message",
            "details": {} | [] | null
        }
    }
    """
    # Convert Django ValidationError to DRF ValidationError
    if isinstance(exc, DjangoValidationError):
        exc = ValidationError(detail=exc.message_dict if hasattr(exc, "message_dict") else exc.messages)

    # Call DRF's default exception handler first
    response = exception_handler(exc, context)

    if response is None:
        # Unhandled exception
        logger.exception(
            "Unhandled exception in view",
            extra={
                "view": context.get("view", "").__class__.__name__,
                "request_path": context.get("request", {}).path if hasattr(context.get("request", {}), "path") else "",
            },
            exc_info=exc,
        )
        return Response(
            {
                "error": {
                    "code": "internal_error",
                    "message": "An unexpected error occurred. Please try again later.",
                    "details": None,
                }
            },
            status=status.HTTP_500_INTERNAL_SERVER_ERROR,
        )

    # Format the error response consistently
    error_code = _get_error_code(exc)
    error_message = _get_error_message(exc, response)
    error_details = _get_error_details(response)

    response.data = {
        "error": {
            "code": error_code,
            "message": error_message,
            "details": error_details,
        }
    }

    return response


def _get_error_code(exc) -> str:
    """Get a machine-readable error code from the exception."""
    if isinstance(exc, ValidationError):
        return "validation_error"
    elif isinstance(exc, Http404):
        return "not_found"
    elif isinstance(exc, APIException):
        return exc.default_code
    return "error"


def _get_error_message(exc, response) -> str:
    """Get a human-readable error message."""
    if isinstance(exc, ValidationError):
        return "Validation failed. Please check the provided data."
    elif isinstance(exc, Http404):
        return "The requested resource was not found."
    elif hasattr(exc, "detail") and isinstance(exc.detail, str):
        return exc.detail
    elif response.status_code == 401:
        return "Authentication required."
    elif response.status_code == 403:
        return "You do not have permission to perform this action."
    elif response.status_code == 429:
        return "Too many requests. Please slow down."
    return "An error occurred."


def _get_error_details(response):
    """Extract detailed error information for validation errors."""
    if response.status_code == 400 and isinstance(response.data, dict):
        return response.data
    elif response.status_code == 400 and isinstance(response.data, list):
        return response.data
    return None

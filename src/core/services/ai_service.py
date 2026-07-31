"""
AI Service - Handles AI provider communication.

Supports two providers out of the box:
  - Google Gemini (FREE tier) via its OpenAI-compatible endpoint
  - OpenAI (paid)

Provider is auto-selected based on which API key is configured.
Gemini takes priority since it has a free tier.
"""

import logging
from dataclasses import dataclass

from django.conf import settings

logger = logging.getLogger(__name__)

SYSTEM_PROMPT = """You are Focus Guardian AI Teacher - a helpful, encouraging study companion. Your role is to:
1. Help students understand difficult concepts by breaking them down simply
2. Provide study tips, memory techniques, and focus strategies
3. Keep students motivated and accountable
4. Answer questions about any academic subject
5. Suggest break activities and productivity techniques

Be concise, supportive, and actionable. If a student seems frustrated, acknowledge their feelings first."""


@dataclass
class AIResponse:
    """Structured AI response."""

    reply: str
    model_used: str
    success: bool
    error: str | None = None


class AITeacherService:
    """
    Service for AI teacher interactions.

    Uses the OpenAI Python SDK for both providers:
      - Gemini exposes an OpenAI-compatible endpoint, so we just point the
        client at Google's base URL and use a Gemini model name.
      - OpenAI uses its default base URL.
    """

    def __init__(self):
        # Gemini takes priority (free tier). Fall back to OpenAI if set.
        self.gemini_api_key = getattr(settings, "GEMINI_API_KEY", "")
        self.openai_api_key = getattr(settings, "OPENAI_API_KEY", "")
        self.max_tokens = settings.OPENAI_MAX_TOKENS

        if self.gemini_api_key:
            self.provider = "gemini"
            self.api_key = self.gemini_api_key
            self.base_url = settings.GEMINI_BASE_URL
            self.model = settings.GEMINI_MODEL
        elif self.openai_api_key:
            self.provider = "openai"
            self.api_key = self.openai_api_key
            self.base_url = None  # default OpenAI endpoint
            self.model = settings.OPENAI_MODEL
        else:
            self.provider = "none"
            self.api_key = ""
            self.base_url = None
            self.model = "mock"

    def is_configured(self) -> bool:
        """Check if any AI provider is configured."""
        return self.provider != "none"

    def get_response(self, user_message: str, context: str = "") -> AIResponse:
        """
        Get an AI response to the user's message.

        Args:
            user_message: The user's question or message.
            context: Optional additional context (e.g., current study topic).

        Returns:
            AIResponse with the reply or error information.
        """
        if not self.is_configured():
            logger.warning("No AI provider configured. Using mock response.")
            return AIResponse(
                reply=(
                    f"I'm your Focus Guardian AI Teacher. You asked: '{user_message[:100]}'. "
                    "Keep focusing on your studies! "
                    "(Note: AI is not configured. Set GEMINI_API_KEY (free) or OPENAI_API_KEY "
                    "to enable real AI responses.)"
                ),
                model_used="mock",
                success=True,
            )

        try:
            import openai

            # Both providers use the OpenAI SDK; Gemini just needs a base_url.
            client_kwargs = {"api_key": self.api_key}
            if self.base_url:
                client_kwargs["base_url"] = self.base_url
            client = openai.OpenAI(**client_kwargs)

            messages = [
                {"role": "system", "content": SYSTEM_PROMPT},
            ]
            if context:
                messages.append({"role": "system", "content": f"Student context: {context}"})
            messages.append({"role": "user", "content": user_message})

            response = client.chat.completions.create(
                model=self.model,
                messages=messages,
                max_tokens=self.max_tokens,
                temperature=0.7,
            )

            reply = response.choices[0].message.content
            model_used = getattr(response, "model", self.model)

            logger.info(
                "AI response generated successfully",
                extra={
                    "provider": self.provider,
                    "model": model_used,
                    "message_length": len(user_message),
                },
            )

            return AIResponse(reply=reply, model_used=model_used, success=True)

        except openai.RateLimitError:
            logger.error("%s rate limit exceeded", self.provider)
            return AIResponse(
                reply="",
                model_used=self.model,
                success=False,
                error="AI service is temporarily busy. Please try again in a moment.",
            )
        except openai.AuthenticationError:
            logger.error("%s authentication failed - check API key", self.provider)
            return AIResponse(
                reply="",
                model_used=self.model,
                success=False,
                error="AI service configuration error. Please check the API key.",
            )
        except Exception as e:
            logger.exception("Unexpected error in AI service", exc_info=e)
            return AIResponse(
                reply="",
                model_used=self.model,
                success=False,
                error="An unexpected error occurred. Please try again later.",
            )

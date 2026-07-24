"""
AI Service - Handles OpenAI API communication.
Encapsulates all AI-related logic with proper error handling and configuration.
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
    """Service for AI teacher interactions using OpenAI API."""

    def __init__(self):
        self.api_key = settings.OPENAI_API_KEY
        self.model = settings.OPENAI_MODEL
        self.max_tokens = settings.OPENAI_MAX_TOKENS

    def is_configured(self) -> bool:
        """Check if the AI service is properly configured."""
        return bool(self.api_key)

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
            logger.warning("OpenAI API key not configured. Using mock response.")
            return AIResponse(
                reply=(
                    f"I'm your Focus Guardian AI Teacher. You asked: '{user_message[:100]}'. "
                    "Keep focusing on your studies! "
                    "(Note: AI service is not configured. Set OPENAI_API_KEY for full functionality.)"
                ),
                model_used="mock",
                success=True,
            )

        try:
            import openai

            client = openai.OpenAI(api_key=self.api_key)

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
            model_used = response.model

            logger.info(
                "AI response generated successfully",
                extra={"model": model_used, "message_length": len(user_message)},
            )

            return AIResponse(reply=reply, model_used=model_used, success=True)

        except openai.RateLimitError:
            logger.error("OpenAI rate limit exceeded")
            return AIResponse(
                reply="",
                model_used=self.model,
                success=False,
                error="AI service is temporarily busy. Please try again in a moment.",
            )
        except openai.AuthenticationError:
            logger.error("OpenAI authentication failed - check API key")
            return AIResponse(
                reply="",
                model_used=self.model,
                success=False,
                error="AI service configuration error. Please contact support.",
            )
        except Exception as e:
            logger.exception("Unexpected error in AI service", exc_info=e)
            return AIResponse(
                reply="",
                model_used=self.model,
                success=False,
                error="An unexpected error occurred. Please try again later.",
            )

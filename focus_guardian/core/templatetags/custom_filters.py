from django import template

register = template.Library()


@register.filter
def duration_format(value):
    """Format a timedelta as 'Xh Ym'."""
    if not value:
        return "0m"
    total_seconds = int(value.total_seconds())
    hours = total_seconds // 3600
    minutes = (total_seconds % 3600) // 60
    if hours > 0:
        return f"{hours}h {minutes}m"
    return f"{minutes}m"


@register.filter
def percentage(value, total):
    """Calculate percentage."""
    try:
        return round((float(value) / float(total)) * 100, 1)
    except (ValueError, ZeroDivisionError, TypeError):
        return 0


@register.filter
def subtract(value, arg):
    """Subtract arg from value."""
    try:
        return float(value) - float(arg)
    except (ValueError, TypeError):
        return 0


@register.filter
def multiply(value, arg):
    """Multiply value by arg."""
    try:
        return float(value) * float(arg)
    except (ValueError, TypeError):
        return 0


@register.filter
def divide(value, arg):
    """Divide value by arg."""
    try:
        return round(float(value) / float(arg), 1)
    except (ValueError, ZeroDivisionError, TypeError):
        return 0

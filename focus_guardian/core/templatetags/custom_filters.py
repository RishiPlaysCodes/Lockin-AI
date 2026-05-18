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

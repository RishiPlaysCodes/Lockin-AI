#!/usr/bin/env python3
"""
Focus Guardian AI - Universal Cross-Platform Launcher
=====================================================
Works on Windows, macOS, Linux, and Android (Termux).

This single script handles the complete setup and run process:
  - Detects your operating system
  - Creates a virtual environment
  - Installs dependencies
  - Runs database migrations
  - Optionally seeds demo data
  - Starts the development server

Usage:
    python run.py              # Full setup + run server
    python run.py setup        # Only setup (venv + deps + migrate)
    python run.py serve        # Only run the server
    python run.py test         # Run the test suite
    python run.py seed         # Seed demo data
    python run.py --help       # Show help

No prior knowledge needed - just run: python run.py
"""

import os
import platform
import subprocess
import sys
import venv
from pathlib import Path

# ------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------
PROJECT_ROOT = Path(__file__).resolve().parent
SRC_DIR = PROJECT_ROOT / "src"
VENV_DIR = PROJECT_ROOT / "venv"
ENV_FILE = PROJECT_ROOT / ".env"
ENV_EXAMPLE = PROJECT_ROOT / ".env.example"
REQUIREMENTS = PROJECT_ROOT / "requirements" / "development.txt"
MIN_PYTHON = (3, 11)
DEFAULT_HOST = "0.0.0.0"
DEFAULT_PORT = "8000"


# ------------------------------------------------------------------
# Terminal colors (auto-disabled on unsupported terminals)
# ------------------------------------------------------------------
class Color:
    _enabled = sys.stdout.isatty() and os.environ.get("NO_COLOR") is None

    GREEN = "\033[92m" if _enabled else ""
    YELLOW = "\033[93m" if _enabled else ""
    RED = "\033[91m" if _enabled else ""
    BLUE = "\033[94m" if _enabled else ""
    BOLD = "\033[1m" if _enabled else ""
    END = "\033[0m" if _enabled else ""


def info(msg):
    print(f"{Color.BLUE}[INFO]{Color.END} {msg}")


def success(msg):
    print(f"{Color.GREEN}[OK]{Color.END} {msg}")


def warn(msg):
    print(f"{Color.YELLOW}[WARN]{Color.END} {msg}")


def error(msg):
    print(f"{Color.RED}[ERROR]{Color.END} {msg}")


def header(msg):
    print(f"\n{Color.BOLD}{Color.BLUE}=== {msg} ==={Color.END}\n")


# ------------------------------------------------------------------
# Platform detection
# ------------------------------------------------------------------
def detect_platform():
    """Detect the operating system, including Android/Termux."""
    system = platform.system().lower()

    # Termux (Android) detection
    if "ANDROID_ROOT" in os.environ or "com.termux" in os.environ.get("PREFIX", ""):
        return "android"
    if system == "windows":
        return "windows"
    if system == "darwin":
        return "macos"
    if system == "linux":
        return "linux"
    return system or "unknown"


def is_windows():
    return detect_platform() == "windows"


def get_venv_python():
    """Get the path to the Python executable inside the venv."""
    if is_windows():
        return VENV_DIR / "Scripts" / "python.exe"
    return VENV_DIR / "bin" / "python"


def get_venv_pip():
    """Get the path to pip inside the venv."""
    if is_windows():
        return VENV_DIR / "Scripts" / "pip.exe"
    return VENV_DIR / "bin" / "pip"


# ------------------------------------------------------------------
# Setup steps
# ------------------------------------------------------------------
def check_python_version():
    """Ensure Python meets the minimum version requirement."""
    if sys.version_info < MIN_PYTHON:
        error(
            f"Python {MIN_PYTHON[0]}.{MIN_PYTHON[1]}+ required. "
            f"You have {sys.version_info.major}.{sys.version_info.minor}."
        )
        sys.exit(1)
    success(f"Python {sys.version_info.major}.{sys.version_info.minor} detected")


def create_venv():
    """Create a virtual environment if it doesn't exist."""
    if VENV_DIR.exists():
        success("Virtual environment already exists")
        return
    info("Creating virtual environment...")
    try:
        venv.create(VENV_DIR, with_pip=True)
        success("Virtual environment created")
    except Exception as exc:  # noqa: BLE001
        error(f"Failed to create venv: {exc}")
        warn("On Debian/Ubuntu/Termux you may need: pkg install python-venv")
        sys.exit(1)


def run_command(cmd, cwd=None, env=None, check=True):
    """Run a shell command, streaming output."""
    merged_env = os.environ.copy()
    if env:
        merged_env.update(env)
    try:
        subprocess.run(cmd, cwd=cwd, env=merged_env, check=check)
    except subprocess.CalledProcessError as exc:
        error(f"Command failed: {' '.join(str(c) for c in cmd)}")
        raise SystemExit(exc.returncode) from exc


def install_dependencies():
    """Install project dependencies into the venv."""
    header("Installing Dependencies")
    pip = str(get_venv_pip())

    # Upgrade pip first
    run_command([pip, "install", "--upgrade", "pip"], check=False)

    plat = detect_platform()
    if plat == "android":
        warn("Android/Termux detected - installing lightweight dependency set")
        warn("PostgreSQL driver (psycopg) is skipped; SQLite is used instead.")
        # Android: install packages individually, skipping psycopg (needs compilation)
        packages = [
            "Django", "djangorestframework", "djangorestframework-simplejwt",
            "django-cors-headers", "django-filter", "drf-spectacular",
            "django-health-check", "whitenoise", "python-dotenv", "openai",
            "gunicorn", "django-debug-toolbar", "pytest", "pytest-django",
        ]
        run_command([pip, "install", *packages])
    else:
        run_command([pip, "install", "-r", str(REQUIREMENTS)])

    success("Dependencies installed")


def ensure_env_file():
    """Create .env from .env.example if it doesn't exist."""
    if ENV_FILE.exists():
        success(".env file already exists")
        return
    if ENV_EXAMPLE.exists():
        info("Creating .env from .env.example...")
        content = ENV_EXAMPLE.read_text(encoding="utf-8")
        # Ensure development settings by default
        content = content.replace(
            "DJANGO_SETTINGS_MODULE=focus_guardian.settings.development",
            "DJANGO_SETTINGS_MODULE=focus_guardian.settings.development",
        )
        ENV_FILE.write_text(content, encoding="utf-8")
        success(".env file created (edit it to add your OpenAI key if desired)")
    else:
        warn(".env.example not found, skipping .env creation")


def manage_env():
    """Return environment variables forcing development settings."""
    return {
        "DJANGO_SETTINGS_MODULE": "focus_guardian.settings.development",
        "PYTHONPATH": str(SRC_DIR),
    }


def run_migrations():
    """Run Django database migrations."""
    header("Running Database Migrations")
    python = str(get_venv_python())
    run_command([python, "manage.py", "migrate"], cwd=str(SRC_DIR), env=manage_env())
    success("Migrations complete")


def seed_data():
    """Seed the database with demo data."""
    header("Seeding Demo Data")
    python = str(get_venv_python())
    run_command(
        [python, "manage.py", "seed_data"],
        cwd=str(SRC_DIR),
        env=manage_env(),
        check=False,
    )
    success("Demo data seeded (login: demo / DemoPass123!)")


def get_local_ip():
    """Best-effort detection of the machine's LAN IP address."""
    import socket

    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except Exception:  # noqa: BLE001
        return "127.0.0.1"


def serve(host=DEFAULT_HOST, port=DEFAULT_PORT):
    """Start the Django development server."""
    header("Starting Development Server")
    python = str(get_venv_python())
    local_ip = get_local_ip()

    print(f"{Color.BOLD}Server starting...{Color.END}")
    print(f"  Local:   {Color.GREEN}http://127.0.0.1:{port}/api/docs/{Color.END}")
    print(f"  Network: {Color.GREEN}http://{local_ip}:{port}/api/docs/{Color.END}")
    print(f"  {Color.YELLOW}(Use the Network URL to test from your phone on the same WiFi){Color.END}")
    print(f"\n  Admin panel: http://127.0.0.1:{port}/admin/")
    print(f"  Health check: http://127.0.0.1:{port}/health/")
    print(f"\n  {Color.YELLOW}Press CTRL+C to stop the server{Color.END}\n")

    run_command(
        [python, "manage.py", "runserver", f"{host}:{port}"],
        cwd=str(SRC_DIR),
        env=manage_env(),
        check=False,
    )


def run_tests():
    """Run the test suite."""
    header("Running Tests")
    python = str(get_venv_python())
    run_command([python, "-m", "pytest", "-v"], cwd=str(PROJECT_ROOT), check=False)


def full_setup():
    """Run the complete setup process."""
    header("Focus Guardian AI - Setup")
    info(f"Platform detected: {Color.BOLD}{detect_platform()}{Color.END}")
    check_python_version()
    create_venv()
    install_dependencies()
    ensure_env_file()
    run_migrations()
    success("Setup complete!")


def print_help():
    print(__doc__)


# ------------------------------------------------------------------
# Main entry point
# ------------------------------------------------------------------
def main():
    args = sys.argv[1:]
    command = args[0] if args else "all"

    if command in ("--help", "-h", "help"):
        print_help()
        return

    if command == "setup":
        full_setup()
    elif command == "serve":
        if not VENV_DIR.exists():
            warn("No venv found. Running full setup first...")
            full_setup()
        serve()
    elif command == "test":
        if not VENV_DIR.exists():
            full_setup()
        run_tests()
    elif command == "seed":
        if not VENV_DIR.exists():
            full_setup()
        seed_data()
    elif command == "all":
        full_setup()
        seed_data()
        serve()
    else:
        error(f"Unknown command: {command}")
        print_help()
        sys.exit(1)


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print(f"\n{Color.YELLOW}Stopped by user. Bye!{Color.END}")
        sys.exit(0)

#!/usr/bin/env bash
# ============================================================
# Focus Guardian AI - Launcher for macOS / Linux / Termux
# ============================================================
# Usage:
#   ./run.sh           Full setup + run server
#   ./run.sh setup     Only setup
#   ./run.sh serve     Only run server
#   ./run.sh test      Run tests
#   ./run.sh seed      Seed demo data
#
# Make it executable first (one time): chmod +x run.sh
# ============================================================

set -e

# Move to the script's directory so it works from anywhere
cd "$(dirname "$0")"

# Find a working Python 3 interpreter
if command -v python3 >/dev/null 2>&1; then
    PYTHON=python3
elif command -v python >/dev/null 2>&1; then
    PYTHON=python
else
    echo "[ERROR] Python 3 is not installed."
    echo "  - macOS:   brew install python"
    echo "  - Ubuntu:  sudo apt install python3 python3-venv"
    echo "  - Termux:  pkg install python"
    exit 1
fi

echo "Using: $($PYTHON --version)"
exec "$PYTHON" run.py "$@"

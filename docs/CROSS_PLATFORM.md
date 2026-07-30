# Focus Guardian AI - Run on ANY Platform

Ye project **har device pe chalta hai** - Windows, Mac, Linux, aur Android (phone) bhi!

The easiest way is the **universal launcher** (`run.py`). It automatically:
- Detects your OS
- Creates a virtual environment
- Installs dependencies
- Runs migrations
- Seeds demo data
- Starts the server (and shows a URL you can open on your phone)

---

## The One-Command Way (All Platforms)

After you have Python installed and the repo cloned:

```bash
python run.py
```

That's it. Everything else is automatic. Then open the URL it prints.

> On some systems use `python3 run.py` instead of `python run.py`.

---

## Windows

### Option A - Double-click (easiest)
1. Install Python from [python.org/downloads](https://www.python.org/downloads/)
   - **IMPORTANT:** During install, check the box **"Add Python to PATH"**
2. Download/clone the project
3. Double-click **`run.bat`**
4. Wait for setup, then open the URL shown (e.g. `http://127.0.0.1:8000/api/docs/`)

### Option B - PowerShell
```powershell
git clone https://github.com/RishiPlaysCodes/Lockin-AI.git
cd Lockin-AI
.\run.ps1
```
> If you get an execution policy error, run once:
> `Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned`

### Option C - CMD
```cmd
git clone https://github.com/RishiPlaysCodes/Lockin-AI.git
cd Lockin-AI
run.bat
```

---

## macOS

```bash
# Install Python (if not already installed)
brew install python

# Clone and run
git clone https://github.com/RishiPlaysCodes/Lockin-AI.git
cd Lockin-AI
chmod +x run.sh
./run.sh
```

Or simply: `python3 run.py`

---

## Linux (Ubuntu / Debian / Fedora / Arch)

```bash
# Install Python + venv (Ubuntu/Debian example)
sudo apt update && sudo apt install -y python3 python3-venv git

# Fedora:  sudo dnf install python3 git
# Arch:    sudo pacman -S python git

# Clone and run
git clone https://github.com/RishiPlaysCodes/Lockin-AI.git
cd Lockin-AI
chmod +x run.sh
./run.sh
```

---

## Android (Phone) via Termux

Yes, tu apne **phone pe hi** ye project chala sakta hai! Termux ek terminal app hai Android ke liye.

### Step 1: Install Termux
- Install **Termux** from [F-Droid](https://f-droid.org/en/packages/com.termux/) (recommended)
- **Note:** The Play Store version is outdated - use F-Droid.

### Step 2: Set up Termux
Open Termux and run:
```bash
# Update packages
pkg update -y && pkg upgrade -y

# Install Python and Git
pkg install -y python git

# (Optional) Grant storage access
termux-setup-storage
```

### Step 3: Clone and Run
```bash
git clone https://github.com/RishiPlaysCodes/Lockin-AI.git
cd Lockin-AI
python run.py
```

The script auto-detects Termux and installs a lightweight dependency set (skips PostgreSQL driver, uses SQLite instead - perfect for phone).

### Step 4: Open in Phone Browser
Once the server starts, open your phone's browser (Chrome/Firefox) and go to:
```
http://127.0.0.1:8000/api/docs/
```

You now have the full API running **on your phone**!

### Termux Tips
| Task | Command |
|------|---------|
| Stop server | Press `CTRL + C` (volume-down + C) |
| Restart later | `cd Lockin-AI && python run.py serve` |
| Keep running in background | Install `pkg install tmux`, run `tmux`, then start server |
| Free up space | `python run.py` reuses the venv, no re-download |

---

## Test from Your Phone (App running on PC)

Agar app tere **computer pe chal raha hai** aur tu **phone se test** karna chahta hai (same WiFi):

1. On your computer, run: `python run.py serve`
2. The launcher prints a **Network URL** like:
   ```
   Network: http://192.168.1.5:8000/api/docs/
   ```
3. On your phone browser, open that Network URL.

Both devices must be on the **same WiFi network**.

---

## Launcher Commands (All Platforms)

| Command | What it does |
|---------|-------------|
| `python run.py` | Full setup + seed + run server |
| `python run.py setup` | Only setup (venv + deps + migrate) |
| `python run.py serve` | Only start the server |
| `python run.py test` | Run the test suite |
| `python run.py seed` | Add demo data (demo / DemoPass123!) |
| `python run.py --help` | Show help |

On Windows you can also use `run.bat serve`, `run.bat test`, etc.
On Mac/Linux/Termux you can use `./run.sh serve`, `./run.sh test`, etc.

---

## Docker (Works on Windows, Mac, Linux)

If you have Docker installed, this works identically everywhere:

```bash
# Development
docker compose -f docker-compose.dev.yml up

# Production
docker compose up -d
```

> Docker is not available on Android/Termux - use the `python run.py` method there.

---

## Troubleshooting

| Problem | Platform | Fix |
|---------|----------|-----|
| `python: command not found` | Mac/Linux | Use `python3` instead, or `sudo apt install python3` |
| `python not recognized` | Windows | Reinstall Python, check "Add to PATH" |
| `venv creation failed` | Ubuntu/Termux | `sudo apt install python3-venv` or `pkg install python` |
| `Permission denied: ./run.sh` | Mac/Linux | `chmod +x run.sh` |
| Execution policy error | Windows PS | `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` |
| psycopg build error | Android | Ignore - Termux uses SQLite automatically |
| Port 8000 in use | All | `python run.py serve` then edit port, or kill the process |

---

## What Works Where

| Feature | Windows | macOS | Linux | Android (Termux) |
|---------|:-------:|:-----:|:-----:|:----------------:|
| Full API | Yes | Yes | Yes | Yes |
| Swagger docs | Yes | Yes | Yes | Yes |
| Admin panel | Yes | Yes | Yes | Yes |
| SQLite (dev) | Yes | Yes | Yes | Yes |
| PostgreSQL | Yes | Yes | Yes | Limited* |
| Docker | Yes | Yes | Yes | No |
| AI Teacher | Yes | Yes | Yes | Yes |

*On Android, SQLite is used by default (PostgreSQL driver needs compilation).

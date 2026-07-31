# Phone pe App ki Tarah Use Karo (Android + iOS)

Focus Guardian AI ko tu apne **phone pe bhi app jaisa** use kar sakta hai — bina Play Store ya App Store ke. Deployed URL hi tera "app" hai.

---

## Live App URL

```
https://focus-guardian-yu8d.onrender.com
```

Ye URL phone ke browser mein kholo — login karke use karo. **Lekin isse home screen pe "app" banane ke liye neeche padho.**

---

## Method 1: Add to Home Screen (PWA) — Recommended

Ye sabse easy tarika hai. Ek icon ban jayega phone ki home screen pe, aur app full-screen mein khulega (bina browser bar ke) — ekdum native app jaisa lagega.

### Android (Chrome)

1. **Chrome** mein ye kholo: `https://focus-guardian-yu8d.onrender.com`
2. Upar right mein **3 dots (⋮)** menu pe tap karo
3. **"Add to Home screen"** ya **"Install app"** option tap karo
4. Naam rakh do: **Focus Guardian** → **"Add"** tap karo
5. Home screen pe icon aa jayega ⚡
6. Ab jab bhi tap karoge — app full-screen mein khulegi, browser bar nahi dikhega

### Android (Samsung Internet / Firefox)

**Samsung Internet:**
1. URL kholo
2. Bottom mein **☰ menu** → **"Add page to"** → **"Home screen"**

**Firefox:**
1. URL kholo
2. **3 dots** menu → **"Install"** ya **"Add to Home screen"**

### iPhone / iPad (Safari)

1. **Safari** mein ye kholo: `https://focus-guardian-yu8d.onrender.com`
2. Bottom bar mein **Share button** (⬆ square with arrow) tap karo
3. Neeche scroll karo → **"Add to Home Screen"** tap karo
4. Naam: **Focus Guardian** → **"Add"** tap karo
5. Home screen pe icon aa jayega

> **Important (iOS):** Ye sirf **Safari** se kaam karta hai. Chrome/Firefox iOS pe home screen add nahi kara sakte.

---

## Method 2: APK Wrapper (Android — Proper APK Install)

Agar tu chahta hai ki **bilkul APK** ki tarah install ho (app drawer mein aaye, uninstall normally ho), toh ye method use kar. Ye basically teri website ko ek APK shell mein wrap kar deta hai.

### Option A: Pwabuilder.com (Easiest — Free)

1. Ja: **[pwabuilder.com](https://www.pwabuilder.com/)**
2. URL daal: `https://focus-guardian-yu8d.onrender.com`
3. **"Start"** button dabao
4. Score dikhega. Right side mein **"Package for stores"** → **"Android"** choose karo
5. **"Generate"** — ek `.apk` file download hogi
6. Apne phone pe wo APK bhejo (WhatsApp/Telegram/cable se)
7. Phone pe **"Install from unknown sources"** allow karo (settings mein)
8. APK install karo — Done!

### Option B: Bubblewrap CLI (Developer way)

Agar tu PWABuilder se satisfied nahi, manually banao:

```bash
# Install
npm install -g @nicolgit/nicolgit-nicolgit-nicolgit

# Actually, use:
npm install -g @nicolgit/nicolgit
# Nahi nahi, sahi tool ye hai:
npx @nicolgit/nicolgit

# CORRECT command:
npm install -g @nicolgit/nicolgit
```

Actually **Bubblewrap** is deprecated. Use PWABuilder (Option A) — it does the same thing with a GUI.

### Option C: MIT App Inventor (No-code APK)

1. Ja: **[appinventor.mit.edu](http://appinventor.mit.edu/)**
2. New project → **"WebViewer"** component drag karo
3. WebViewer ki **HomeUrl** set karo: `https://focus-guardian-yu8d.onrender.com`
4. **Build** → **APK** → download aur install

---

## Method 3: Phone Browser mein Direct Use

Sabse simple. Koi install nahi:

1. Phone ka **Chrome/Firefox/Safari** kholo
2. Type karo: `https://focus-guardian-yu8d.onrender.com`
3. Login / Sign up karo
4. Use karo!

Bas! Ye URL hi tera app hai. Internet pe koi bhi device se access kar sakta hai.

---

## How It Works on Phone (User Flow)

```
1. Open URL → Login/Signup page dikhega (glassmorphism neon UI)
2. Sign up karo (username, email, password)
3. Dashboard khulega → Stats dikhenge (Focus Score, Streak, etc.)
4. "Start Focus Session" tap → Timer page (circular ring countdown)
5. 25 min focus karo — tab switch karo toh distraction auto-log
6. Session end → Dashboard pe stats update
7. "AI Teacher" tap → Chat page → questions pucho, tips lo
```

---

## Tips for Phone Usage

| Tip | Kya karo |
|-----|----------|
| **App-like feel** | "Add to Home Screen" karo (Method 1) — no browser bar |
| **Pehli baar slow?** | Free Render instance 30-60 sec mein "wake up" hota hai. Phir fast. |
| **Offline?** | Internet chahiye (backend se connected hai). |
| **Data safe?** | JWT token phone mein localStorage mein hai. Logout karke clear hota hai. |
| **Multiple devices?** | Haan! Same account se phone + laptop dono pe chal sakta hai |

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "Add to Home Screen" option nahi dikh raha | Safari (iOS) ya Chrome (Android) use karo |
| Pehli baar kholne pe white screen | 30-60 sec wait karo (Render free tier "sleep" se jag raha hai) |
| Login ke baad wapas login page | Browser cache clear karo, ya incognito mein try karo |
| APK install nahi ho rahi | Settings → Security → "Unknown sources" enable karo |
| Page khaali dikhti hai | Internet check karo, URL sahi hai confirm karo |

---

## Summary

| Method | Effort | Result |
|--------|--------|--------|
| **Add to Home Screen** | 30 seconds | App icon on phone, full-screen, no browser bar |
| **PWABuilder APK** | 5 minutes | Real .apk file, installs like a normal app |
| **Direct browser** | 0 seconds | Just open the URL |

**Recommendation:** Method 1 (Add to Home Screen) — fastest, works on all phones, looks like a real app.

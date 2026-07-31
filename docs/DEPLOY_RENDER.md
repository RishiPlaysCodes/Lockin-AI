# Deploy FREE on Render.com (Easiest - No Credit Card)

Ye sabse easy tareeka hai apne app ko internet pe **free mein** live karne ka.
Credit card ki **zaroorat nahi**. Bas GitHub account chahiye.

Deploy hone ke baad tujhe ek public URL milega (jaise `https://focus-guardian.onrender.com`)
jise tu **phone pe, kahin se bhi** kholke use kar sakta hai.

---

## Ek Baar Samajh le (Important)

Render ka **free tier** kaisa hai:
- **Web service** 15 minute tak koi request na aaye toh "sleep" ho jaata hai.
  Jab tu dobara kholega toh 30-60 second lagega jagne mein (uske baad fast).
- **Free PostgreSQL** database 30 din tak free milta hai, phir naya banana padta hai.
- Sab kuch free, no card.

> Agar tujhe app **hamesha awake** chahiye (sleep na ho), toh niche "UptimeRobot"
> wala tip padh - wo bhi free hai.

---

## Step 1: Code GitHub pe daal (already done!)

Tera code already GitHub pe hai: `https://github.com/RishiPlaysCodes/Lockin-AI`

Bas ye PR merge kar de `main` branch mein:
- [Pull Request #4](https://github.com/RishiPlaysCodes/Lockin-AI/pull/4) kholo
- **"Merge pull request"** button dabao

---

## Step 2: Render Account Banao

1. Ja [render.com](https://render.com) pe
2. **"Get Started"** ya **"Sign Up"** dabao
3. **"Sign in with GitHub"** choose karo (sabse easy)
4. GitHub se authorize kar de

> Koi card nahi maangega. Bilkul free.

---

## Step 3: Blueprint se Deploy (One-Click)

Maine tere project mein `render.yaml` file daal di hai - ye Render ko bata deti hai
ki kya-kya banana hai (web service + database), automatically.

1. Render dashboard mein ja: [dashboard.render.com/blueprints](https://dashboard.render.com/blueprints)
2. **"New Blueprint Instance"** dabao
3. Apna **Lockin-AI** repo select karo (connect karna pade toh kar de)
4. Render khud `render.yaml` padhega aur sab dikha dega:
   - `focus-guardian` (web service)
   - `focus-guardian-db` (PostgreSQL database)
5. **"Apply"** / **"Create"** dabao

Bas! Render ab automatically:
- Dependencies install karega
- Database banayega aur connect karega
- Migrations chalayega
- App live kar dega

Pehli baar 3-5 minute lagega. Chai pi le tab tak.

---

## Step 4: Apna App Kholo

Deploy hone ke baad Render tujhe ek URL dega, jaise:
```
https://focus-guardian.onrender.com
```

Ye kholo:
- **API Docs:** `https://focus-guardian.onrender.com/api/docs/`
- **Admin:** `https://focus-guardian.onrender.com/admin/`
- **Health:** `https://focus-guardian.onrender.com/health/`

Phone pe bhi yahi URL kholke use kar sakta hai!

---

## Step 5: Admin Account Banao (optional)

Admin panel use karne ke liye superuser chahiye. Render dashboard mein:

1. `focus-guardian` service pe click karo
2. **"Environment"** tab mein ye 3 variables add karo:
   | Key | Value |
   |-----|-------|
   | `DJANGO_SUPERUSER_USERNAME` | `admin` |
   | `DJANGO_SUPERUSER_EMAIL` | `tera-email@gmail.com` |
   | `DJANGO_SUPERUSER_PASSWORD` | `KoiStrongPassword123!` |
3. **"Manual Deploy"** > **"Deploy latest commit"** dabao
4. Ab `https://tera-app.onrender.com/admin/` pe in credentials se login kar

---

## Step 6: OpenAI Key Add Karo (optional)

Bina key ke bhi AI Teacher chalta hai (mock reply deta hai).
Agar tere paas OpenAI key hai:

1. Service > **"Environment"** tab
2. `OPENAI_API_KEY` variable mein apni key daal (`sk-...`)
3. Save karo - auto redeploy ho jaayega

---

## App ko Hamesha Awake Rakhna (Free Trick)

Free service 15 min baad sleep ho jaata hai. Isko awake rakhne ke liye:

1. Ja [uptimerobot.com](https://uptimerobot.com) pe (free account)
2. **"Add New Monitor"**:
   - Type: **HTTP(s)**
   - URL: `https://tera-app.onrender.com/health/`
   - Interval: **5 minutes**
3. Save

Ab UptimeRobot har 5 min mein tere app ko "ping" karega, toh wo kabhi soyega nahi.
(Isse tera monthly free time zyada use hoga, but chalega.)

---

## Har Update Automatic Deploy Hoga

Jab bhi tu code change karke GitHub pe push karega (`main` branch pe),
Render **automatically** naya version deploy kar dega. Kuch karne ki zaroorat nahi!

---

## Agar Kuch Galat Ho (Troubleshooting)

| Problem | Solution |
|---------|----------|
| Build fail hua | Render dashboard > service > **"Logs"** dekho, error wahan milega |
| "Bad Request (400)" | `ALLOWED_HOSTS` issue - already handle kiya hai, redeploy karo |
| App slow khul raha | Free tier sleep se jaga hai, 30-60 sec normal hai |
| Database error | 30 din baad free DB expire - naya blueprint apply karo |
| Static files nahi dikhe | `build.sh` mein collectstatic hai, logs check karo |

**Logs kaise dekhe:** Service pe click > **"Logs"** tab. Live logs wahan aate hain.

---

## Cost: 100% FREE

- Web service: Free (sleeps after 15 min)
- PostgreSQL: Free for 30 days
- No credit card
- No hidden charges

Perfect for a student project you want to show off or use personally!

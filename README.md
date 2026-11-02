# Mazhi Sheti (माझी शेती) - Smart Farming Flutter App

**Mazhi Sheti** is an end-to-end smart agricultural application designed for farmers, land owners, agriculture students, and experts. It features a complete 3-step project lifecycle:

```
[ Step 1: 8-Screen Onboarding ] ──▶ [ Step 2: User Sign In & Sign Up ] ──▶ [ Step 3: Post-Login Screens ]
```

---

## The 3-Step App Architecture & Project Direction

### 1. Step #1: Interactive 8-Screen User Onboarding Flow
- **1 / 8 — Choose Your Language**: Multilingual support (`English`, `मराठी`, `हिंदी`) with *"Better Farms Brighter Tomorrows"*.
- **2 / 8 — Welcome, Vineet! 👋**: Personalized greeting with feature highlights (crop recommendations, farm activity tracking, timely alerts).
- **3 / 8 — What's Your Role?**: Role selection (`Farmer`, `Land Owner`, `Agriculture Student`, `Advisor / Expert`).
- **4 / 8 — Tell Us About Your Farm**: State, District, Farm Size (Acres), and Main Crop.
- **5 / 8 — Enable Permissions**: Interactive toggles for Location, Camera, and Notifications.
- **6 / 8 — Which Crops Do You Grow?**: Multi-select crop picker (Rice, Wheat, Soybean, Cotton, Sugarcane, Maize, Tur, Groundnut, etc.) + custom crop adder.
- **7 / 8 — Set Your Location**: Nagpur, Maharashtra default with local weather, market prices, and regional tips.
- **8 / 8 — Grow Better, Live Brighter**: Vision screen with direct **"Continue to Sign In / Sign Up (Step 2) →"** action button.
- **Top Quick Bar**: Toggle between interactive Phone View, All 8 Screens Grid Overview, and direct Step 2 jump.

---

### 2. Step #2: User Sign In & Sign Up (`SignupScreen`)
Supports both existing user authentication and new farmer registration:
- **Sign In Tab**:
  - Registered Mobile Number / Email + 4-Digit MPIN / Password.
  - "Sign In to Mazhi Sheti" action button.
  - One-tap "Quick Demo Sign In (Vineet - Nagpur)" for instant testing.
  - Quick toggle to switch to Sign Up for new users.
- **Sign Up Tab**:
  - **Personal & Contact Info**: Full Name, 10-digit Mobile with SMS OTP verification, Email, and MPIN.
  - **Farm & Land Ownership Profile**: Farm Name, State, District, Taluka, Village, Farm Size (Acres), Gut / 7/12 Land Survey Number, Ownership Type (*Own Land*, *Leased*, *Joint Family*).
  - **Soil & Irrigation Configuration**: Drip, Sprinkler, Borewell, Canal, or Rainfed; Black Cotton Soil, Red Soil, or Alluvial; Multi-select Crop Chips.
  - **Government Schemes**: PM-KISAN Beneficiary DBT alerts & PMFBY Crop Insurance enrollment.
  - **Firebase Integration**: Directly syncs registered user accounts to Firebase Authentication and Cloud Firestore!

---

### 3. Step #3: Post-Login Screens (`PostLoginAppScreen`)
Directly integrated from `mazhi_sheti_flutter_android.zip` matching the exact visual design boards:
- **Screen 1 — Home ("Grow Better, Live Brighter")**:
  - Sunrise green hills & rural farmhouse hero banner
  - Interactive Smart Farming Search bar
  - 6 Feature Cards with interactive detail modal sheets:
    * *Crop Advice* (AI-powered tips)
    * *Weather* (Live telemetry)
    * *Market Prices* (Real-time APMC rates)
    * *Scan & Diagnose* (AI leaf vision scanner)
    * *Learn* (Guides & video walkthroughs)
    * *Community* (Farmer producer group)
  - Promotional banner: *"This Season, A Healthier Harvest"*
- **Screen 2 — Insights ("Your Farm at a Glance")**:
  - 26°C Nagpur, Maharashtra weather card & Good Conditions badge
  - *My Fields (5 Total Fields)* with 3D isometric agricultural map
  - Afternoon 32°C forecast & 68% root-zone soil moisture telemetry
  - Quick Action pills: *Map My Field*, *Check Market*, *Scan Crop*
  - Tools for You: *Map Your Fields*, *Grow Smarter*, *Track Progress*
- **Screen 3 — AI Assistant & Live Market**:
  - Personalized AI greeting: *"Hi Vineet! How can I help your farm today?"*
  - Interactive quick agronomy prompts:
    * *How to control leaf spot in soybean?*
    * *Best time to sow wheat?*
    * *Current market price of cotton?*
  - Custom question input box with instant tailored advice
  - Live APMC Mandi rates table with daily trend indicators:
    * Soybean: ₹4,892/q (↑ 2.4%)
    * Wheat: ₹2,425/q (↓ 1.1%)
    * Cotton: ₹6,150/q (↑ 3.2%)
    * Maize: ₹1,980/q (↑ 0.8%)
  - Banner: *"Small Steps. A Greener Future."*
- **Interactive Multi-View Switcher**:
  - **Single Phone View**: Scaled and responsive interactive phone experience with bottom navigation bar (Home, Insights, '+' Quick Action, Market, Profile).
  - **3-Screen Exact View**: Exact 1024x682 multi-screen board view showing all 3 screens side-by-side with full hotspot interactivity!

---

### 4. Firebase Cloud Integration
- **Project ID**: `mazhisheti-428da`
- **Application ID / Package**: `com.mazhisheti.app`
- **Android BoM**: `com.google.firebase:firebase-bom:33.10.0`
- **Analytics & Auth**: `firebase-analytics`, `firebase_auth`, `cloud_firestore`
- **Config Files**:
  - `android/app/google-services.json`
  - `lib/firebase_options.dart`
  - `lib/services/firebase_service.dart`

---

## Project Structure

```
MazhiShetiFlutter/
├── android/
│   ├── app/
│   │   ├── build.gradle.kts     # BoM & Google Services plugin
│   │   ├── google-services.json # Live Firebase credentials
│   │   └── src/main/kotlin/com/mazhisheti/app/MainActivity.kt
│   ├── build.gradle.kts
│   └── settings.gradle.kts
├── assets/
│   └── images/                  # All Onboarding + Post-Login 3-Screen visual assets
│       ├── screen_1_bg.jpg ... screen_8_bg.jpg
│       ├── exact_board_1024x682.png
│       ├── screen_1_exact.png ... screen_3_exact.png
│       └── s1_hero_exact.png ... s3_greener_banner.png
├── lib/
│   ├── firebase_options.dart    # Live multi-platform Firebase options
│   ├── main.dart                # App orchestrator (Onboarding -> Sign In -> Post-Login App)
│   ├── models/
│   │   └── farmer_profile.dart  # Reactive state model
│   ├── screens/
│   │   ├── post_login_app_screen.dart # Step 3: Exact Post-Login Screens
│   │   ├── signup_screen.dart   # Step 2: Sign In & Sign Up Form
│   │   └── main_app_screen.dart # Full agricultural dashboard
│   └── services/
│       └── firebase_service.dart # Auth & Firestore sync service
├── test/
│   └── widget_test.dart         # Widget smoke test
├── pubspec.yaml                 # Dependencies and assets
└── README.md
```

---

## How to Run the App

1. Fetch dependencies:
   ```bash
   flutter pub get
   ```

2. Run static analyzer and tests:
   ```bash
   flutter analyze
   flutter test
   ```

3. Launch on your desired device:
   ```bash
   # Run in Chrome
   flutter run -d chrome

   # Run on Windows Desktop
   flutter run -d windows

   # Run on Android device / emulator
   flutter run -d android
   ```

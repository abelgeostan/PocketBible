# PocketBible — Malayalam Holy Bible (മലയാളം സത്യവേദപുസ്തകം 1910)
### Production Mobile Flutter Application for Google Play Store

PocketBible is the official mobile Flutter application equivalent of the responsive web application at [PocketBible.in](https://pocketbible.in). It brings the complete text of the **Malayalam Sathyavedapusthakam 1910 (revised in contemporary orthography, FBF 2015, CC BY-SA 4.0)** to mobile devices with 100% offline capability, ultra-fast performance, and mobile-native features.

---

## 🌟 Features

### 📖 Faithful Design & Scripture Reading
- **Exact Visual Design**: Matches the clean, typography-focused aesthetic of PocketBible.in with Light mode (clean white surfaces, warm `#725335` bronze accents) and Dark mode (deep slate `#0F1317`, `#D4A66D` golden amber).
- **All 66 Books & 1,189 Chapters**: Complete Old Testament (39 books) and New Testament (27 books), 31,098 verses.
- **Offline First**: All 31,098 verses are embedded directly in an optimized local SQLite database with indices, loading chapters in under 2 milliseconds with **zero internet needed**.
- **Responsive Paragraph Verse Display**: Each verse displayed in the clean format with superscript verse numbers and Noto Sans Malayalam typography.
- **Reading Tools Toolbar**:
  - Font Size adjustments: `A-`, `A`, `A+` (14px to 26px)
  - Reading Width modes: `Narrow`, `Normal`, and `Wide`
  - `Copy Chapter` button
  - `Full Screen` reading mode
- **Swipe Navigation**: Horizontal swipe gestures smoothly transition between chapters.

### 📱 Mobile-Specific Features
- **Sidebar Drawer Menu**:
  - Header with official branding, subtitle, and version badge
  - Quick links to Read Bible, Search, Bookmarks, Highlights, Notes, History, Settings, About, and Share App.
- **Interactive Verse Actions**:
  - Tap any verse to open the actions sheet
  - 🔖 **Bookmark / Unbookmark**
  - 🖍 **Highlight** with 4 distinct colors (Yellow, Green, Blue, Pink)
  - ⧉ **Copy Verse** with formatted reference
  - ↗ **Share Verse** natively to WhatsApp, SMS, Telegram, etc.
  - 📝 **Personal Notes**: Attach personal reflections to any verse.
- **Lightning-Fast Malayalam Search**:
  - Real-time search across all 31,098 verses
  - Filter by Old Testament, New Testament, or specific books
  - Highlighting of search terms directly in the Malayalam scripture text.
- **Today's Verse (ദിവസത്തെ വചനം)**:
  - Curated daily inspirational verse based on the day-of-year formula from PocketBible.in.
- **Random Verse Generator (ക്രമരഹിത വചനം)**:
  - Pick a random scripture passage for meditation.
- **Last-Read Memory (അവസാനം വായിച്ചത്)**:
  - Automatically remembers the last book and chapter with a 1-tap "Continue Reading →" button.
- **Comprehensive Settings**:
  - Light, Dark, or System Default theme
  - Live Font Size slider with interactive Malayalam preview
  - Keep Screen Awake (wakelock) while reading toggle
  - Show/Hide verse numbers toggle
  - Reading history management

---

## 🚀 Play Store Readiness & Standards

This app is built strictly in accordance with Google Play Store standards:
- **Package Name**: `in.pocketbible.app`
- **Target SDK**: `35` (Android 15 ready, meeting the latest Google Play requirement)
- **Minimum SDK**: `21` (Android 5.0+, covering 99%+ of all Android devices worldwide)
- **Architecture**: Production-ready Clean Architecture with Flutter Provider state management.
- **ProGuard / R8 Rules**: Configured in `android/app/proguard-rules.pro` with code shrinking and resource optimization enabled for release builds.
- **Launcher Icons**: Generated adaptive and round mipmap icons across all densities (`mdpi`, `hdpi`, `xhdpi`, `xxhdpi`, `xxxhdpi`).
- **Permissions**: Safe permissions declared in `AndroidManifest.xml` (`INTERNET` for external sharing, `WAKE_LOCK` for screen awake).

---

## 🛠️ Build & Release Instructions

### 1. Prerequisites
Ensure you have the Flutter SDK installed and on your PATH:
```bash
flutter doctor
```

### 2. Install Dependencies
In the project root directory:
```bash
flutter pub get
```

### 3. Run Locally (Emulator or Device)
```bash
flutter run
```

### 4. Build Production App Bundle (.aab) for Google Play Store
```bash
flutter build appbundle --release
```
The generated bundle will be at:
`build/app/outputs/bundle/release/app-release.aab`

---

## 📋 Google Play Store Listing Information

- **App Name**: `PocketBible — മലയാളം ബൈബിൾ`
- **Short Description**: `മലയാളം സത്യവേദപുസ്തകം 1910. ഓഫ്‌ലൈൻ ബൈബിൾ വായന, തിരച്ചിൽ, ബുക്ക്മാർക്കുകൾ.`
- **Full Description**:
  ```text
  PocketBible — ലളിതവും മനോഹരവുമായ മലയാളം സത്യവേദപുസ്തകം 1910 മൊബൈൽ ആപ്പ്.

  സവിശേഷതകൾ:
  • 66 പുസ്തകങ്ങൾ, 1,189 അധ്യായങ്ങൾ, 31,098 വാക്യങ്ങൾ
  • പൂർണ്ണമായും ഓഫ്‌ലൈൻ — ഇന്റർനെറ്റ് ആവശ്യമില്ല
  • പഴയ നിയമം / പുതിയ നിയമം എളുപ്പത്തിൽ തിരഞ്ഞെടുക്കൽ
  • സമ്പൂർണ്ണ മലയാളം വേദപുസ്തക തിരച്ചിൽ (Search)
  • വാക്യങ്ങൾ ബുക്ക്മാർക്ക് ചെയ്യാനും 4 നിറങ്ങളിൽ ഹൈലൈറ്റ് ചെയ്യാനുമുള്ള സൗകര്യം
  • വാക്യങ്ങൾക്ക് വ്യക്തിഗത കുറിപ്പുകൾ (Notes) രേഖപ്പെടുത്താം
  • ദിവസത്തെ വചനവും (Today's Verse) ക്രമരഹിത വചനവും (Random Verse)
  • ലൈറ്റ് / ഡാർക്ക് മോഡ് (Light & Dark Themes)
  • ഫോണ്ട് വലിപ്പവും വായനാ വീതിയും (Narrow / Normal / Wide) മാറ്റാം
  • അവസാനം വായിച്ച അധ്യായം ഓർത്തുസൂക്ഷിക്കുന്നു (Continue Reading)
  • വാക്യങ്ങൾ പകർപ്പടെടുക്കാനും (Copy) സുഹൃത്തുക്കൾക്ക് പങ്കിടാനും (Share) സാധിക്കും

  ഉറവിടം:
  മലയാളം സത്യവേദപുസ്തകം 1910 പതിപ്പ്, സമകാലിക ലിപിയിൽ പുനഃക്രമീകരിച്ചത് (The Free Bible Foundation, 2015, CC BY-SA 4.0).
  Powered by Sansnet (PocketBible.in).
  ```
- **Category**: Books & Reference
- **Content Rating**: Everyone

---

## 📄 License & Attribution
- **Scripture Text**: Malayalam Sathyavedapusthakam 1910, revised in contemporary orthography, © 2015 The Free Bible Foundation (FBF), licensed under [CC BY-SA 4.0](https://creativecommons.org/licenses/by-sa/4.0/).
- **Application**: PocketBible.in by Sansnet.

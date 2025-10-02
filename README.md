# Deep Fake detection

A Flutter application for deepfake detection. The app authenticates users with Firebase Authentication and communicates with a backend inference API (FastAPI) that serves a ResNeXt + BiLSTM model to classify videos or frames as REAL or FAKE.

This README is intentionally concise and pragmatic so new contributors can get productive fast.

## 1) Features
- Firebase Authentication (Email/Password; optional Google Sign‑In)
- Capture / Pick media (video or image) for analysis
- Upload to inference API and receive prediction + confidence
- History & details views with stored snapshots/metadata

## 2) App Tour (Screens)

Auth (Login / Register): Minimal flows backed by Firebase Auth.
Home / Capture: Pick from gallery or record a short clip / frame to analyze.
Result: Shows label (REAL/FAKE), confidence, and brief explanation.
History: Chronological list of prior analyses.
Statistic : statistic of real or fake video analyzed
Analysis Details: Displays stored frame(s) and associated metadata.
Screens are deliberately streamlined: one primary action per screen, clear status messages, direct paths to History and Details.

## 3) Project Structure (high-level)

android/ # Android app
ios/ # iOS app
web/ # Web support
assets/ # Static assets
lib/ # Flutter source (widgets, screens, services)
screen/ # UI pages (if separated from lib/widgets)
screenshot/ # App screenshots used in README / store listings
test/ # Flutter tests

Some folders may be FlutterFlow‑generated; keep generated files under version control unless noted by tool docs.

## 4) Firebase Setup (so anyone can use their own project)

The repository was originally linked to the author’s Firebase project. Follow these steps to plug in your own Firebase environment.

### 1 - Create a Firebase project at https://console.firebase.google.com.
### 2 - Enable Authentication → Sign‑in method:
- Enable Email/Password.
- Enable Google.

### 3 - Register your apps:
Android: add your package name (e.g., com.example.deepfake), and add SHA‑1 fingerprint (via ./android/gradlew signingReport or Play Console).
download google-services.json from Firebase console → place it at android/app/google-services.json. Ensure com.google.gms.google-services Gradle plugin is applied in android/build.gradle and android/app/build.gradle.


## 5) Before launch the front
### Launch the FAST API :
You can take a look at the ReadME of this repository: 
(https://github.com/amined2am/deep_fake_api)

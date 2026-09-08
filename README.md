<div align="center">
<img alt="FacePlugin" src="https://avatars.githubusercontent.com/u/160751046?s=200&v=4" width="200"/>
</div>

#### 🌐 Company Site - [Here](https://faceplugin.com)
#### 🤗 Hugging Face - [Here](https://huggingface.co/FacePlugin-Ltd)
#### 🛟 Help Center - [Here](https://doc.faceplugin.com)
#### 🐳 Docker Hub - [Here](https://hub.docker.com/u/faceplugin)

# FacePlugin ID Document Recognition SDK — Ionic Capacitor (Fully On-Premise)

> Drop Android AAR + iOS framework → Sync Capacitor → run on a **physical** phone.
> Jump: [Quick Start](#quick-start) · [Get the runtimes](#get-the-runtimes) · [Run the demo](#run-the-demo) · [Setup](#setup-on-your-own-app) · [JS API](#about-sdk)

## Quick Start

- [ ] Install [Node.js 18+](https://nodejs.org/) (includes **npm**)
- [ ] Install [JDK 17](https://adoptium.net/)
- [ ] Install [Android Studio](https://developer.android.com/studio) (Android) or [Xcode 15+](https://developer.apple.com/xcode/) (iOS, macOS only)
- [ ] `git clone https://github.com/Faceplugin-ltd/ID-Document-Recognition-Ionic-Capacitor.git`
- [ ] `cd ID-Document-Recognition-Ionic-Capacitor`
- [ ] `npm install`
- [ ] `npm run build`
- [ ] `cd example && npm install`
- [ ] Download runtimes → [Get the runtimes](#get-the-runtimes)
- [ ] Copy `documentreadersdk.aar` → `example/android/libdocsdk/`
- [ ] Copy `docsdk.framework` → `ios/Frameworks/docsdk.framework` (iOS)
- [ ] `npm run build`
- [ ] `npx cap sync`
- [ ] `npx cap open android` **or** `npx cap open ios`
- [ ] Run on a **physical** phone from Android Studio / Xcode
- [ ] Home status bar → **Ready** → Camera / Gallery / About

> Own app? → [Setup on your own app](#setup-on-your-own-app). Docs: [https://doc.faceplugin.com](https://doc.faceplugin.com)

## Introduction

FacePlugin **ID Document Recognition SDK for Ionic Capacitor** is a fully on-device identity verification plugin for Android and iOS. Scan ID cards, passports, and driver licenses with OCR, MRZ, barcode and QR extraction, live camera overlay, gallery front/back, authenticity / document liveness, and Result / Security / Images / Raw JSON. Package: `document-reader-capacitor`. No biometric data leaves the device — built for KYC and hybrid mobile onboarding.

| Folder          | Purpose                                                                      |
| --------------- | ---------------------------------------------------------------------------- |
| Repository root | `document-reader-capacitor` — Capacitor plugin you install in your Ionic app |
| `example/`      | Ionic React demo (Home, Camera, Gallery, Result, About)                      |

Native binaries are **not** on GitHub. Download them from Google Drive (links below).

> **Browser /** `ionic serve` **alone is not enough.** Native Document Reader APIs require a Capacitor Android or iOS build on a device.

### Main Functionalities

| Feature                              | Supported |
| ------------------------------------ | --------- |
| ID Card, Passport, and Driver License recognition  | ✓         |
| MRZ, Barcode, QR, and OCR data extraction             | ✓         |
| Document detection and type classification  | ✓         |
| Live camera locate overlay + Capture | ✓         |
| Gallery front / optional back        | ✓         |
| Result (fields, Security, images, JSON)        | ✓         |
| Authenticity / Security (document liveness)  | ✓         |

### Product List

| Platform | Repository |
|----------|------------|
| Android | [ID-Document-Recognition-Android](https://github.com/Faceplugin-ltd/ID-Document-Recognition-Android) |
| iOS | [ID-Document-Recognition-iOS](https://github.com/Faceplugin-ltd/ID-Document-Recognition-iOS) |
| Windows | [ID-Document-Recognition-Windows](https://github.com/Faceplugin-ltd/ID-Document-Recognition-Windows) |
| Linux / Docker | [ID-Document-Recognition-Docker](https://github.com/Faceplugin-ltd/ID-Document-Recognition-Docker) |
| React Native | [ID-Document-Recognition-React-Native](https://github.com/Faceplugin-ltd/ID-Document-Recognition-React-Native) |
| Flutter | [ID-Document-Recognition-Flutter](https://github.com/Faceplugin-ltd/ID-Document-Recognition-Flutter) |
| **Ionic Capacitor** | **[ID-Document-Recognition-Ionic-Capacitor](https://github.com/Faceplugin-ltd/ID-Document-Recognition-Ionic-Capacitor)** (**this repo**) |
| Ionic Cordova | [ID-Document-Recognition-Ionic-Cordova](https://github.com/Faceplugin-ltd/ID-Document-Recognition-Ionic-Cordova) |
| Linux / Docker (Liveness-Only) | [ID-Document-Liveness-Detection-Docker](https://github.com/Faceplugin-ltd/ID-Document-Liveness-Detection-Docker) |


---

## Before you start

| Step | What you need                                                                                                                                                                                                                                                    |
| ---- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1    | **Node.js 18+**, **npm**, Ionic / Capacitor                                                                                                                                                                                                                      |
| 2    | **Physical device** recommended (camera; emulator is limited)                                                                                                                                                                                                    |
| 3    | Android `documentreadersdk.aar` and iOS `docsdk.framework` — [Get the runtimes](#get-the-runtimes)                                                                                                                                                               |
| 4    | Demo licenses are in `example/src/license.ts` (Android `com.faceplugin.documentreader`, iOS `com.faceplugin.documentreader.app`, valid until **12 August 2027**). Request a new key only if you change `applicationId` / bundle id — [SDK License](#sdk-license) |

### System requirements

| Item   | Android                                  | iOS                       |
| ------ | ---------------------------------------- | ------------------------- |
| OS     | API 24 min; **API 29 (10)+ recommended** | 13.0 min; 16+ recommended |
| Device | Physical phone with rear camera          | iPhone with A12 or newer  |
| Stack  | Capacitor 6 + Ionic React (`example/`)   | Same                      |
| Build  | Android Studio / JDK 17                  | Xcode 15+, CocoaPods      |

---

## Get the runtimes

Binaries are gitignored. Copy them **before** your first native build.

### Android — `documentreadersdk.aar`

**Download:** [DocumentReader Android runtime (Google Drive)](https://drive.google.com/drive/folders/1nDSfvj0WtC1lZgzwFd7471ECVtk-nuYH)

| File                    | Example app path                                  | Your own app path                                                           |
| ----------------------- | ------------------------------------------------- | --------------------------------------------------------------------------- |
| `documentreadersdk.aar` | `example/android/libdocsdk/documentreadersdk.aar` | `node_modules/document-reader-capacitor/android/libs/documentreadersdk.aar` |

### iOS — `docsdk.framework`

**Download:** [DocumentReader iOS runtime (Google Drive)](https://drive.google.com/drive/folders/1do6Ws_BlXGkR_K9jI_ULd1zHjqLGSP4q) — unzip if needed.

```text
ios/Frameworks/docsdk.framework
```

Then `npx cap sync ios` / `pod install`. Framework is **device arm64** only.

---

## Run the demo

Follow these steps in order to run the demo.

### 1. Install tools on your computer

1. Install **Node.js 18 or newer** from [https://nodejs.org/](https://nodejs.org/) (choose the LTS version). This also installs **npm**.
2. Open a terminal (PowerShell, Terminal, or Command Prompt) and check:

```bash
node -v
npm -v
```

3. Install **JDK 17** from [https://adoptium.net/](https://adoptium.net/) (Temurin 17).
4. **Android:** install [Android Studio](https://developer.android.com/studio), open it once, and install the Android SDK + a device USB driver if needed.
5. **iOS (Mac only):** install **Xcode 15+** from the App Store, then open Xcode once and accept the license. Install CocoaPods if prompted (`sudo gem install cocoapods`).
6. Plug in a **physical phone** and enable **Developer / USB debugging** (Android) or trust the computer (iPhone). Emulators are limited for camera.

### 2. Download this project

```bash
git clone https://github.com/Faceplugin-ltd/ID-Document-Recognition-Ionic-Capacitor.git
cd ID-Document-Recognition-Ionic-Capacitor
```

If you do not use Git, download the ZIP from GitHub → **Code → Download ZIP**, unzip it, and `cd` into the folder.

### 3. Install npm packages and build the plugin

From the **repository root**:

```bash
npm install
npm run build
```

Then install the **example** app:

```bash
cd example
npm install
```

### 4. Place the native runtimes

Download the binaries from [Get the runtimes](#get-the-runtimes), then copy them exactly here:

| Platform | File | Put it here |
| -------- | ---- | ----------- |
| Android | `documentreadersdk.aar` | `example/android/libdocsdk/documentreadersdk.aar` |
| iOS | `docsdk.framework` | `ios/Frameworks/docsdk.framework` |

Create the folders if they do not exist. Do **not** rename the files.

### 5. Build the web app and sync Capacitor

Still inside `example/`:

```bash
npm run build
npx cap sync
```

This copies the web build into the native Android / iOS projects and links the Capacitor plugin.

### 6. Open and run on your phone

**Android**

```bash
npx cap open android
```

1. Android Studio opens the `example/android` project.
2. Wait until Gradle finishes syncing.
3. Choose your USB phone in the device list.
4. Press the green **Run** button.

**iOS (macOS only)**

```bash
npx cap open ios
```

1. Xcode opens the workspace.
2. Select your **Team** under Signing & Capabilities.
3. Choose your **physical iPhone** (not a simulator).
4. Press **Run**.

> `docsdk.framework` is **device-only (arm64)**. Simulator builds may compile, but the engine will not activate on a simulator.

Keep these demo app ids so the included license works:

| Platform | Identifier |
| -------- | ---------- |
| Android `applicationId` | `com.faceplugin.documentreader` |
| iOS bundle id | `com.faceplugin.documentreader.app` |

### 7. Use the demo

1. Wait for the home **status bar** → **Ready**.
2. **Camera** — live rear preview with document locate overlay → **Capture** → on-device OCR, MRZ, barcode, and authenticity checks.
3. **Gallery** — pick front (back optional) → recognize two-sided IDs.
4. **Result** — tabs **Result** / **Security** / **Images** / **Raw JSON** for fields, liveness, crops, and the full JSON response.

### Screenshots

| Home | Camera | Gallery |
| ---- | ------ | ------- |
| <p align="center"><img src="https://raw.githubusercontent.com/Faceplugin-ltd/faceplugin-assets/main/screenshots/document-reader/mobile/home.png" alt="FacePlugin Document Reader — Home with Camera, Gallery, About and Recognition + Liveness" width="240"/></p> | <p align="center"><img src="https://raw.githubusercontent.com/Faceplugin-ltd/faceplugin-assets/main/screenshots/document-reader/mobile/camera.png" alt="FacePlugin Document Reader — live camera overlay and Capture for ID scanning" width="240"/></p> | <p align="center"><img src="https://raw.githubusercontent.com/Faceplugin-ltd/faceplugin-assets/main/screenshots/document-reader/mobile/gallery.png" alt="FacePlugin Document Reader — Gallery front and optional back, then Recognize" width="240"/></p> |

| Result | Security | Images |
| ------ | -------- | ------ |
| <p align="center"><img src="https://raw.githubusercontent.com/Faceplugin-ltd/faceplugin-assets/main/screenshots/document-reader/mobile/result.png" alt="FacePlugin Document Reader — Result tab with OCR, MRZ, and barcode fields" width="240"/></p> | <p align="center"><img src="https://raw.githubusercontent.com/Faceplugin-ltd/faceplugin-assets/main/screenshots/document-reader/mobile/security.png" alt="FacePlugin Document Reader — Liveness tab with authenticity and document liveness" width="240"/></p> | <p align="center"><img src="https://raw.githubusercontent.com/Faceplugin-ltd/faceplugin-assets/main/screenshots/document-reader/mobile/images.png" alt="FacePlugin Document Reader — Images tab with portrait, signature, and document crops" width="240"/></p> |

| Raw JSON | About |
| -------- | ----- |
| <p align="center"><img src="https://raw.githubusercontent.com/Faceplugin-ltd/faceplugin-assets/main/screenshots/document-reader/mobile/raw.png" alt="FacePlugin Document Reader — Raw JSON recognize response for integration" width="240"/></p> | <p align="center"><img src="https://raw.githubusercontent.com/Faceplugin-ltd/faceplugin-assets/main/screenshots/document-reader/mobile/about.png" alt="FacePlugin Document Reader — About with on-device Recognition + Liveness license" width="240"/></p> |

---

## SDK License

Licenses are **offline** and bound to your `applicationId` / bundle identifier.

The sample app already includes a valid key for `com.faceplugin.documentreader` (Android) / `com.faceplugin.documentreader.app` (iOS) (until **12 August 2027**). You only need a new key if you use a different id.

### How to get a license

The code below shows how to use the license:

[https://github.com/Faceplugin-ltd/ID-Document-Recognition-Ionic-Capacitor/blob/d9f1feaff33d7d18d36aea500b239402b3fb0ced/example/src/license.ts#L7-L17](https://github.com/Faceplugin-ltd/ID-Document-Recognition-Ionic-Capacitor/blob/d9f1feaff33d7d18d36aea500b239402b3fb0ced/example/src/license.ts#L7-L17)

[https://github.com/Faceplugin-ltd/ID-Document-Recognition-Ionic-Capacitor/blob/d9f1feaff33d7d18d36aea500b239402b3fb0ced/example/src/SdkContext.tsx#L60-L70](https://github.com/Faceplugin-ltd/ID-Document-Recognition-Ionic-Capacitor/blob/d9f1feaff33d7d18d36aea500b239402b3fb0ced/example/src/SdkContext.tsx#L60-L70)

Please [contact us](#contact) to get a license for **your own app**.

### License capabilities (Recognition + Liveness)

After activation, `getLicenseStatus` reports what the key unlocks. Home shows the same summary on the status bar (for example **Ready · Recognition + Liveness**). About shows **License: …**.

| Capability | Meaning |
| ---------- | ------- |
| **Recognition** | OCR, MRZ, barcode/QR, and document type classification |
| **Liveness** (authenticity) | Document authenticity: physical document, security patterns, photo origin, barcode format |

Typical labels:

- **Recognition + Liveness** — full identity verification (Result + Liveness tabs)
- **Recognition** — OCR, MRZ, and barcode only; Security stays empty / not checked
- **Liveness** — authenticity / document liveness only; OCR/MRZ/barcode stays empty / not checked
- **Not licensed** — until you activate

---

## Setup on your own app

You need the `document-reader-capacitor` plugin, the native runtimes, and a few lines of TypeScript. You do **not** need the example pages unless you want the demo UI.

### 1. Install the plugin

```bash
npm install git+https://github.com/Faceplugin-ltd/ID-Document-Recognition-Ionic-Capacitor.git
npx cap sync
```

### 2. Copy runtimes

- Android AAR → `node_modules/document-reader-capacitor/android/libs/documentreadersdk.aar`
- iOS framework → `node_modules/document-reader-capacitor/ios/Frameworks/docsdk.framework`

Then `npx cap sync` again.

### 3. Activate + recognize

```ts
import {
  getMachineCode,
  setActivation,
  init,
  recognize,
  SDK_SUCCESS,
} from 'document-reader-capacitor';

const machine = await getMachineCode(); // FPMC1.…
const act = await setActivation(YOUR_FP1_LICENSE);
if (act !== SDK_SUCCESS) throw new Error('activation failed');
const code = await init();
if (code !== SDK_SUCCESS) throw new Error('init failed');

const json = await recognize(frontUri, backUri ?? null, true);
```

For live locate, use `startLivePreview(false)`, `LocateSession`, `takeLiveSnapshot`, and `locateDocument` (see `example/src/components/DocumentCapture.tsx`).

---

## About SDK

Public helpers:

| Method                                                      | Description                            |
| ----------------------------------------------------------- | -------------------------------------- |
| `getMachineCode()`                                          | `FPMC1.…` for license requests         |
| `setActivation(license)`                                    | Activate with `FP1.…`                  |
| `getLicenseStatus()`                                        | Recognition / Liveness flags + label   |
| `init()` / `deinit()`                                       | Load / unload engine                   |
| `locateDocument(image)`                                     | Document locate JSON (corners + score) |
| `recognize(front, back?, authenticity?)`                    | OCR / MRZ / barcode → canonical JSON   |
| `documentRecognition(front, back?)`                         | OCR / MRZ / barcode only               |
| `documentLiveness(front, back?)`                            | Authenticity / security only           |
| `recognizeResult(...)`                                      | Typed `DocResult`                      |
| `startLivePreview` / `stopLivePreview` / `takeLiveSnapshot` | Native camera under WebView            |
| `LocateSession`                                             | Poll locate for live overlay           |
| `lastLicenseError()`                                        | Last license error detail              |

Status codes: `0` success, `1` invalid, `2` expired, `3` not activated, `4` init failed, `5` no database, `6` database load error.

---

## Contact

<div align="left">
<a target="_blank" href="mailto:info@faceplugin.com"><img src="https://img.shields.io/badge/email-info@faceplugin.com-blue.svg?logo=gmail" alt="faceplugin.com"></a>&emsp;
<a target="_blank" href="https://wa.me/+14692784822"><img src="https://img.shields.io/badge/whatsapp-faceplugin-blue.svg?logo=whatsapp" alt="faceplugin.com"></a>
</div>

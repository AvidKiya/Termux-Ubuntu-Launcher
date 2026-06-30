# AvidKiya DevHub Android APK

This is a real Android WebView launcher for the local Termux DevHub backend.

Build APK:

```bash
cd android
./gradlew assembleDebug
```

Output:

```text
android/app/build/outputs/apk/debug/app-debug.apk
```

Install Termux project first, then open the APK. The APK loads:

```text
http://127.0.0.1:8765/?mode=apk
```

The button attempts to start Termux backend through Termux RunCommand service, and falls back to opening Termux if unavailable.

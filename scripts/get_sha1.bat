@echo off
REM Get SHA-1 fingerprint for Android Google Sign-In
REM This script helps fix "ApiException: 10" error

echo ========================================
echo Getting SHA-1 Fingerprint for Android
echo ========================================
echo.

cd android

echo Running Gradle signing report...
echo.

call gradlew signingReport

echo.
echo ========================================
echo Instructions:
echo ========================================
echo 1. Look for "SHA1:" in the output above
echo 2. Copy the SHA-1 value (looks like: XX:XX:XX:XX:XX...)
echo 3. Go to Firebase Console
echo 4. Project Settings ^> Your Android App
echo 5. Click "Add fingerprint"
echo 6. Paste the SHA-1 value
echo 7. Download new google-services.json
echo 8. Replace android/app/google-services.json
echo.
echo See docs/FIX_GOOGLE_SIGNIN_ANDROID.md for detailed instructions
echo.

pause


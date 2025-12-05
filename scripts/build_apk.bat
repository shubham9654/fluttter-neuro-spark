@echo off
echo ========================================
echo Building NeuroSpark APKs
echo ========================================
echo.

REM Check if Flutter is installed
where flutter >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Flutter is not installed or not in PATH
    echo Please install Flutter and add it to your PATH
    pause
    exit /b 1
)

echo Checking Flutter setup...
flutter doctor -v
echo.

REM Clean previous builds
echo Cleaning previous builds...
flutter clean
echo.

REM Get dependencies
echo Getting dependencies...
flutter pub get
echo.

REM Build Debug APK (for testing)
echo ========================================
echo Building DEBUG APK (for testing)...
echo ========================================
flutter build apk --debug
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to build debug APK
    pause
    exit /b 1
)
echo.
echo ✅ Debug APK built successfully!
echo Location: build\app\outputs\flutter-apk\app-debug.apk
echo.

REM Build Release APK (for production)
echo ========================================
echo Building RELEASE APK (for production)...
echo ========================================
flutter build apk --release --android-skip-build-dependency-validation
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to build release APK
    pause
    exit /b 1
)
echo.
echo ✅ Release APK built successfully!
echo Location: build\app\outputs\flutter-apk\app-release.apk
echo.

echo ========================================
echo Build Complete!
echo ========================================
echo.
echo APK Files:
echo   - Debug (Testing):   build\app\outputs\flutter-apk\app-debug.apk
echo   - Release (Production): build\app\outputs\flutter-apk\app-release.apk
echo.
pause


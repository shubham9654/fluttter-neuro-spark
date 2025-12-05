@echo off
echo ========================================
echo Installing Android SDK Command-Line Tools
echo ========================================
echo.

REM Set Android SDK path
set "ANDROID_SDK=%LOCALAPPDATA%\Android\sdk"
echo Android SDK Path: %ANDROID_SDK%

REM Check if SDK exists
if not exist "%ANDROID_SDK%" (
    echo ERROR: Android SDK not found at %ANDROID_SDK%
    echo Please install Android Studio first
    pause
    exit /b 1
)

REM Check for existing cmdline-tools
if exist "%ANDROID_SDK%\cmdline-tools\latest\bin\sdkmanager.bat" (
    echo Found existing cmdline-tools
    set "SDKMANAGER=%ANDROID_SDK%\cmdline-tools\latest\bin\sdkmanager.bat"
) else if exist "%ANDROID_SDK%\tools\bin\sdkmanager.bat" (
    echo Found tools\bin\sdkmanager
    set "SDKMANAGER=%ANDROID_SDK%\tools\bin\sdkmanager.bat"
) else (
    echo.
    echo ERROR: sdkmanager not found!
    echo.
    echo Please install Android SDK Command-Line Tools:
    echo 1. Open Android Studio
    echo 2. Go to Tools ^> SDK Manager
    echo 3. Click on "SDK Tools" tab
    echo 4. Check "Android SDK Command-line Tools (latest)"
    echo 5. Click "Apply" to install
    echo.
    echo OR download from:
    echo https://developer.android.com/studio#command-line-tools-only
    echo.
    pause
    exit /b 1
)

echo.
echo Installing/Updating Command-Line Tools...
"%SDKMANAGER%" --install "cmdline-tools;latest"

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: Failed to install command-line tools
    echo Please install manually via Android Studio SDK Manager
    pause
    exit /b 1
)

echo.
echo ========================================
echo Accepting Android Licenses...
echo ========================================
if exist "%ANDROID_SDK%\cmdline-tools\latest\bin\sdkmanager.bat" (
    "%ANDROID_SDK%\cmdline-tools\latest\bin\sdkmanager.bat" --licenses
) else (
    flutter doctor --android-licenses
)

echo.
echo ========================================
echo Installation Complete!
echo ========================================
echo.
echo Verifying installation...
flutter doctor -v
echo.
pause



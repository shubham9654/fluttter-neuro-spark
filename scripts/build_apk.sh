#!/bin/bash

echo "========================================"
echo "Building NeuroSpark APKs"
echo "========================================"
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "ERROR: Flutter is not installed or not in PATH"
    echo "Please install Flutter and add it to your PATH"
    exit 1
fi

echo "Checking Flutter setup..."
flutter doctor -v
echo ""

# Clean previous builds
echo "Cleaning previous builds..."
flutter clean
echo ""

# Get dependencies
echo "Getting dependencies..."
flutter pub get
echo ""

# Build Debug APK (for testing)
echo "========================================"
echo "Building DEBUG APK (for testing)..."
echo "========================================"
flutter build apk --debug
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to build debug APK"
    exit 1
fi
echo ""
echo "✅ Debug APK built successfully!"
echo "Location: build/app/outputs/flutter-apk/app-debug.apk"
echo ""

# Build Release APK (for production)
echo "========================================"
echo "Building RELEASE APK (for production)..."
echo "========================================"
flutter build apk --release --android-skip-build-dependency-validation
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to build release APK"
    exit 1
fi
echo ""
echo "✅ Release APK built successfully!"
echo "Location: build/app/outputs/flutter-apk/app-release.apk"
echo ""

echo "========================================"
echo "Build Complete!"
echo "========================================"
echo ""
echo "APK Files:"
echo "  - Debug (Testing):   build/app/outputs/flutter-apk/app-debug.apk"
echo "  - Release (Production): build/app/outputs/flutter-apk/app-release.apk"
echo ""


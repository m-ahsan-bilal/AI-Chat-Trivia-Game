#!/bin/bash

# APK Build Script for AI Chat Trivia
# This script builds both debug and release APKs

echo "🚀 Building AI Chat Trivia APK..."
echo "================================="

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed or not in PATH"
    echo "Please install Flutter: https://flutter.dev/docs/get-started/install"
    exit 1
fi

# Check if Android SDK is set up
if [ -z "$ANDROID_HOME" ]; then
    echo "⚠️  ANDROID_HOME is not set"
    echo "Please set up Android SDK and ANDROID_HOME environment variable"
fi

echo "📋 Flutter Doctor Check..."
flutter doctor

echo ""
echo "🧹 Cleaning previous build..."
flutter clean

echo ""
echo "📦 Getting dependencies..."
flutter pub get

echo ""
echo "🔧 Building Debug APK..."
flutter build apk --debug

if [ $? -eq 0 ]; then
    echo "✅ Debug APK built successfully!"
    echo "📍 Location: build/app/outputs/flutter-apk/app-debug.apk"
else
    echo "❌ Debug APK build failed!"
    exit 1
fi

echo ""
echo "🔧 Building Release APK..."
flutter build apk --release

if [ $? -eq 0 ]; then
    echo "✅ Release APK built successfully!"
    echo "📍 Location: build/app/outputs/flutter-apk/app-release.apk"
    
    # Get APK size
    APK_SIZE=$(du -h build/app/outputs/flutter-apk/app-release.apk | cut -f1)
    echo "📊 APK Size: $APK_SIZE"
else
    echo "❌ Release APK build failed!"
    exit 1
fi

echo ""
echo "🎯 Building Split APKs for different architectures..."
flutter build apk --split-per-abi --release

if [ $? -eq 0 ]; then
    echo "✅ Split APKs built successfully!"
    echo "📍 Location: build/app/outputs/flutter-apk/"
    ls -la build/app/outputs/flutter-apk/app-*-release.apk
else
    echo "⚠️  Split APK build failed, but main APK is ready"
fi

echo ""
echo "🎉 Build Complete!"
echo "================================="
echo "📱 Install on device: adb install build/app/outputs/flutter-apk/app-release.apk"
echo "🔍 Test debug version: adb install build/app/outputs/flutter-apk/app-debug.apk"
echo ""
echo "💡 APK Files Created:"
echo "   - app-debug.apk (for testing)"
echo "   - app-release.apk (for distribution)"
echo "   - app-*-release.apk (architecture-specific)"
echo ""
echo "🚀 Ready to deploy!"
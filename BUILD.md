# Build and Run Guide

This document contains all commands needed to build and run the devtool Flutter application.

## Prerequisites

- Flutter SDK installed (version 3.3.4 or higher)
- Dart SDK (included with Flutter)
- Platform-specific tools:
  - **macOS/iOS**: Xcode
  - **Linux**: CMake and required development libraries
  - **Windows**: Visual Studio with C++ development tools

## Getting Started

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Generate Localization Files

```bash
flutter gen-l10n
```

### 3. Platform-Specific Setup

#### iOS/macOS - Install CocoaPods Dependencies

```bash
# For macOS
cd macos
pod install
cd ..
```
### 4. Verify Flutter Setup

```bash
flutter doctor
```

## Running the App

### Run on macOS (Desktop)

```bash
flutter run -d macos
```

### Run on Linux

```bash
flutter run -d linux
```

### Run on Windows

```bash
flutter run -d windows
```

### Run in Debug Mode (Default)

```bash
flutter run
```

### Run in Release Mode

```bash
flutter run --release
```

### Run in Profile Mode

```bash
flutter run --profile
```

### Hot Reload and Hot Restart

When the app is running, you can use:
- **Hot Reload**: Press `r` in the terminal (or click the reload button in IDE)
- **Hot Restart**: Press `R` in the terminal (or click the restart button in IDE)
- **Quit**: Press `q` in the terminal

### Run with Specific Configuration

```bash
# Run with specific flavor (if configured)
flutter run --flavor <flavor-name>

# Run with specific target file
flutter run -t lib/main.dart

# Run with specific entry point
flutter run --dart-define=KEY=VALUE
```

## Building the App

### Build for macOS

```bash
# Debug build
flutter build macos --debug

# Release build
flutter build macos --release

# Profile build
flutter build macos --profile
```

### Build for Linux

```bash
# Debug build
flutter build linux --debug

# Release build
flutter build linux --release
```

### Build for Windows

```bash
# Debug build
flutter build windows --debug

# Release build
flutter build windows --release
```

## Development Commands

### Clean Build Files

```bash
flutter clean
```

### Get Dependencies After Clean

```bash
flutter clean && flutter pub get
```

### Analyze Code

```bash
flutter analyze
```

### Run Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart
```

### Check for Outdated Dependencies

```bash
flutter pub outdated
```

### Upgrade Dependencies

```bash
flutter pub upgrade
```

### Upgrade Dependencies (Major Versions)

```bash
flutter pub upgrade --major-versions
```

### Format Code

```bash
# Format all Dart files
flutter format .

# Format specific file
flutter format lib/main.dart

# Check formatting without changing files
flutter format --set-exit-if-changed .
```

### Generate Code (if using code generation)

```bash
# Generate code (e.g., for MobX, JSON serialization, etc.)
flutter pub run build_runner build

# Watch mode for code generation
flutter pub run build_runner watch

# Clean and rebuild generated code
flutter pub run build_runner build --delete-conflicting-outputs
```

## Platform-Specific Build Locations

After building, the output files can be found at:

- **macOS**: `build/macos/Build/Products/Release/devtool.app`
- **iOS**: `build/ios/iphoneos/Runner.app`
- **Android**: `build/app/outputs/flutter-apk/app-release.apk`
- **Linux**: `build/linux/x64/release/bundle/`
- **Windows**: `build/windows/x64/runner/Release/`
- **Web**: `build/web/`

## Troubleshooting

### Clear Flutter Cache

```bash
flutter clean
flutter pub get
```

### Rebuild with Verbose Output

```bash
flutter run --verbose
```

### Check Connected Devices

```bash
flutter devices
```

### Check Flutter Version

```bash
flutter --version
```

### Enable Desktop Support (if not already enabled)

```bash
# Enable macOS desktop
flutter config --enable-macos-desktop

# Enable Linux desktop
flutter config --enable-linux-desktop

# Enable Windows desktop
flutter config --enable-windows-desktop
```

### Update Flutter SDK

```bash
# Update Flutter to latest stable version
flutter upgrade

# Update Flutter to specific channel
flutter channel stable
flutter channel beta
flutter channel dev
flutter upgrade
```

## Quick Reference

| Command | Description |
|---------|-------------|
| `flutter pub get` | Install dependencies |
| `flutter run` | Run app in debug mode |
| `flutter run --release` | Run app in release mode |
| `flutter build <platform>` | Build for specific platform |
| `flutter clean` | Clean build files |
| `flutter doctor` | Check Flutter setup |
| `flutter devices` | List available devices |
| `flutter analyze` | Analyze code for issues |
| `flutter test` | Run tests |
| `flutter format .` | Format all Dart files |
| `flutter upgrade` | Update Flutter SDK |
| `flutter gen-l10n` | Generate localization files |
| `flutter pub upgrade` | Upgrade dependencies |
| `flutter pub outdated` | Check for outdated packages |
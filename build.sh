#!/bin/bash

APP_NAME="RestReminder"
SOURCES_DIR="RestReminder/Sources"
BUILD_DIR="build"
APP_BUNDLE_PATH="${BUILD_DIR}/${APP_NAME}.app"

# Clean previous build
rm -rf "${BUILD_DIR}"
mkdir -p "${APP_BUNDLE_PATH}/Contents/MacOS"
mkdir -p "${APP_BUNDLE_PATH}/Contents/Resources"

# Get SDK path
SDK_PATH=$(xcrun --show-sdk-path --sdk macosx)

# Check if SDK path exists
if [ ! -d "$SDK_PATH" ]; then
  echo "Error: macOS SDK not found. Please make sure Xcode Command Line Tools are installed." >&2
  exit 1
fi

# Compile Swift files using the SDK
swiftc -o "${APP_BUNDLE_PATH}/Contents/MacOS/${APP_NAME}" \
    -swift-version 5 \
    -sdk "${SDK_PATH}" \
    "${SOURCES_DIR}/main.swift" "${SOURCES_DIR}/ReminderView.swift" "${SOURCES_DIR}/PreferencesView.swift"

# Check if compilation was successful
if [ $? -ne 0 ]; then
    echo "Error: Swift compilation failed." >&2
    exit 1
fi

# Copy Info.plist
cp "RestReminder/Info.plist" "${APP_BUNDLE_PATH}/Contents/Info.plist"

echo "Build successful. App is at ${APP_BUNDLE_PATH}"
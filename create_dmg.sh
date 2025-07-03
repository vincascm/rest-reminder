#!/bin/bash

# --- Configuration ---
APP_NAME="RestReminder"
APP_BUNDLE="build/${APP_NAME}.app"
DMG_NAME="${APP_NAME}.dmg"
TEMP_DIR="./dmg_temp"
VOLUME_NAME="${APP_NAME} Installer"

# --- Cleanup previous builds ---
echo "Cleaning up old DMG and temporary directory..."
rm -f "${DMG_NAME}"
rm -rf "${TEMP_DIR}"

# --- Create temporary directory for DMG contents ---
echo "Creating temporary directory: ${TEMP_DIR}"
mkdir -p "${TEMP_DIR}"

# --- Copy application bundle to temporary directory ---
echo "Copying ${APP_BUNDLE} to ${TEMP_DIR}/"
cp -R "${APP_BUNDLE}" "${TEMP_DIR}/"

# --- Create a symlink to /Applications ---
echo "Creating /Applications symlink..."
ln -s /Applications "${TEMP_DIR}/Applications"

# --- Create a read-write disk image ---
echo "Creating read-write disk image..."
hdiutil create -ov -volname "${VOLUME_NAME}" -fs HFS+ -srcfolder "${TEMP_DIR}" -format UDRW "${DMG_NAME}.temp.dmg"

# --- Mount the disk image ---
echo "Mounting the disk image..."
MOUNT_POINT="/Volumes/${VOLUME_NAME}"
hdiutil attach "${DMG_NAME}.temp.dmg" -readwrite -noverify -noBrowse -mountpoint "${MOUNT_POINT}"

# --- Customize the mounted volume (optional) ---
# You can add .DS_Store for custom icon sizes, window positions, background images here.
# For example, to set a background image:
# cp "path/to/your/background.png" "${MOUNT_POINT}/.background.png"
# osascript <<EOD
#   tell application "Finder"
#     tell disk "${VOLUME_NAME}"
#       open
#       set current view of container window to icon view
#       set toolbar visible of container window to false
#       set the bounds of the container window to {400, 100, 800, 700} # x, y, width, height
#       set the arrangement of items of container window to not arranged
#       set the icon size of the container window to 128
#       set background picture of container window to file ".background.png"
#       update every icon view of container window
#       delay 2
#       close
#     end tell
#   end tell
# EOD

# --- Unmount the disk image ---
echo "Unmounting the disk image..."
hdiutil detach "${MOUNT_POINT}"

# --- Convert to a compressed, read-only disk image ---
echo "Converting to compressed, read-only DMG..."
hdiutil convert "${DMG_NAME}.temp.dmg" -format UDBZ -o "${DMG_NAME}"

# --- Cleanup temporary files ---
echo "Cleaning up temporary files..."
rm -f "${DMG_NAME}.temp.dmg"
rm -rf "${TEMP_DIR}"

echo "DMG created successfully: ${DMG_NAME}"

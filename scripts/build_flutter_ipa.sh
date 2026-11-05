#!/usr/bin/env bash
set -euo pipefail

echo "=========================================================="
echo " CineVerse Stream (Xuper TV Edition) - Flutter iOS Builder"
echo "=========================================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

echo "[1/5] Generando estructura limpia iOS para Flutter e inyectando iconos/Info.plist..."
mkdir -p /tmp/cv_ios_backup
cp ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png /tmp/cv_ios_backup/Icon-1024.png
cp -R ios/Runner/Assets.xcassets/LaunchImage.imageset /tmp/cv_ios_backup/LaunchImage.imageset

rm -rf ios
flutter create --platforms=ios --project-name cineverse_xuper_tv --org tv.cineverse.xuper .

ICON_DIR="ios/Runner/Assets.xcassets/AppIcon.appiconset"
cp /tmp/cv_ios_backup/Icon-1024.png "$ICON_DIR/Icon-App-1024x1024@1x.png"
for f in "$ICON_DIR"/Icon-App-*.png; do
  if [ "$f" != "$ICON_DIR/Icon-App-1024x1024@1x.png" ]; then
    WIDTH=$(sips -g pixelWidth "$f" | awk '/pixelWidth:/{print $2}')
    sips -z "$WIDTH" "$WIDTH" /tmp/cv_ios_backup/Icon-1024.png --out "$f" >/dev/null
  fi
done

rm -rf ios/Runner/Assets.xcassets/LaunchImage.imageset
cp -R /tmp/cv_ios_backup/LaunchImage.imageset ios/Runner/Assets.xcassets/LaunchImage.imageset

PLIST="ios/Runner/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName CineVerse" "$PLIST" || /usr/libexec/PlistBuddy -c "Add :CFBundleDisplayName string CineVerse" "$PLIST"
/usr/libexec/PlistBuddy -c "Set :CFBundleName CineVerse" "$PLIST" || /usr/libexec/PlistBuddy -c "Add :CFBundleName string CineVerse" "$PLIST"
/usr/libexec/PlistBuddy -c "Delete :NSAppTransportSecurity" "$PLIST" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :NSAppTransportSecurity dict" "$PLIST"
/usr/libexec/PlistBuddy -c "Add :NSAppTransportSecurity:NSAllowsArbitraryLoads bool true" "$PLIST"
/usr/libexec/PlistBuddy -c "Delete :UIBackgroundModes" "$PLIST" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :UIBackgroundModes array" "$PLIST"
/usr/libexec/PlistBuddy -c "Add :UIBackgroundModes:0 string audio" "$PLIST"

echo "[2/5] Obteniendo dependencias de Flutter..."
flutter pub get

echo "[3/5] Analizando código Dart..."
flutter analyze --no-fatal-infos --no-fatal-warnings

echo "[4/5] Compilando Runner.app en modo Release (--no-codesign)..."
flutter build ios --release --no-codesign

echo "[5/5] Firmando Ad-Hoc y empaquetando Payload (.ipa)..."
rm -rf build/ipa_payload
mkdir -p build/ipa_payload/Payload
cp -R build/ios/iphoneos/Runner.app build/ipa_payload/Payload/Runner.app
codesign --force --deep --sign - build/ipa_payload/Payload/Runner.app

cd build/ipa_payload
zip -r9 "$PROJECT_ROOT/CineVerse_XuperTV_Flutter_iOS.ipa" Payload

echo "¡Compilación completada! Archivo: $PROJECT_ROOT/CineVerse_XuperTV_Flutter_iOS.ipa"

#!/usr/bin/env bash
set -euo pipefail

echo "=========================================================="
echo " CineVerse Stream (Xuper TV Edition) - Flutter iOS Builder"
echo "=========================================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

echo "[1/5] Sincronizando estructura iOS de Flutter y respaldando configuraciones..."
mkdir -p /tmp/cv_ios_backup
cp ios/Runner/Info.plist /tmp/cv_ios_backup/Info.plist
cp ios/Runner/AppDelegate.swift /tmp/cv_ios_backup/AppDelegate.swift
cp ios/Podfile /tmp/cv_ios_backup/Podfile
cp -R ios/Runner/Assets.xcassets /tmp/cv_ios_backup/Assets.xcassets

flutter create --platforms=ios --project-name cineverse_xuper_tv --org tv.cineverse.xuper .

cp /tmp/cv_ios_backup/Info.plist ios/Runner/Info.plist
cp /tmp/cv_ios_backup/AppDelegate.swift ios/Runner/AppDelegate.swift
cp /tmp/cv_ios_backup/Podfile ios/Podfile
rm -rf ios/Runner/Assets.xcassets
cp -R /tmp/cv_ios_backup/Assets.xcassets ios/Runner/Assets.xcassets

echo "[2/5] Obteniendo dependencias de Flutter y CocoaPods..."
flutter pub get
cd ios
pod install
cd ..

echo "[3/5] Compilando Runner.app en modo Release (--no-codesign)..."
flutter build ios --release --no-codesign

echo "[4/5] Firmando Ad-Hoc y empaquetando Payload (.ipa)..."
rm -rf build/ipa_payload
mkdir -p build/ipa_payload/Payload
cp -R build/ios/iphoneos/Runner.app build/ipa_payload/Payload/Runner.app
codesign --force --deep --sign - build/ipa_payload/Payload/Runner.app

cd build/ipa_payload
zip -r9 "$PROJECT_ROOT/CineVerse_XuperTV_Flutter_iOS.ipa" Payload

echo "[5/5] ¡Compilación completada!"
echo "Archivo generado: $PROJECT_ROOT/CineVerse_XuperTV_Flutter_iOS.ipa"

# CineVerse Stream (Xuper TV Edition) — Proyecto Flutter para iOS

Aplicación nativa para **iOS 15.0 – iOS 26+** desarrollada en **Flutter / Dart** a partir de la arquitectura interna, rutas, endpoints y recursos gráficos del APK reconstruido de **Xuper TV v4.34.4** (`Xuper_TV`) bajo el sistema de diseño **CineVerse ("Cinematic Glass")**.

---

## 🏗️ Arquitectura Portada desde el APK (`Xuper_TV`)

1. **Cliente Nativo PortalCore (`lib/services/xuper_portal_core_service.dart`)**
   * Implementación completa de los más de 30 endpoints extraídos de `classes2.dex` (`/api/PreInstall/auth`, `/api/portalCore/terminalAuth`, `/api/portalCore/v8/active`, `/api/portalCore/v8/login`, `/api/portalCore/v3/snToken`, `/api/portalCore/getHome`, `/api/portalCore/v3/getShelveData`, `/api/portalCore/v4/getItemData`, `/api/portalCore/v10/startPlayVOD`, `/api/portalCore/v6/getLiveData`, `/api/portalCore/v4/startPlayLive`, `/api/portalCore/epg/v5/getNearestMatch`, `/api/portalCore/v3/searchByName`, etc.).
   * Generador de rutas EPG en tiempo real (`/epg/v2/live/app/utc{timezone}/{liveType}`).
   * Resolver **Google DNS-over-HTTPS** (`https://dns.google.com/resolve?name=...`) extraído de `classes2.dex`.
   * Mapeo directo de `Xuper_TV/assets/therouter/routeMap.json` y `domain_test.json`.

2. **Motor IPTV M3U8, Xtream Codes & Reproductor HLS (`lib/services/iptv_parser_service.dart`)**
   * Analizador de listas `#EXTM3U` / `#EXTINF` con detección automática de grupos (`group-title`), logos (`tvg-logo`) y streams maestros HLS (`#EXT-X-STREAM-INF`).
   * Conector para servidores **Xtream Codes API** (`player_api.php?action=get_live_streams`).
   * Reproductor de video nativo para iOS (`video_player` sobre `AVPlayer`) con controles **Cinematic Glass**, salto ±10s, selector de audio/subtítulos, gaveta de cambio rápido de canal en vivo y guardado automático de progreso VOD.

3. **Sistema de Diseño "Cinematic Glass" (`lib/theme/cinematic_glass_theme.dart`)**
   * **Superficies Obsidian**: `#0A0A0C` (Void), `#131315` (Surface Low), `#1C1C24` (Surface Container), `#242430` (Surface High) y `#2A2A36` (Surface Bright).
   * **Acentos CineVerse**: Crimson `#E50914`, Deep Crimson `#93000A` y Soft Coral `#FFB4AA`.
   * Tarjetas translúcidas con `BackdropFilter` (`ImageFilter.blur`) y barra de navegación flotante en cápsula.

---

## 📂 Estructura del Proyecto

```text
CineVerse_Flutter_iOS/
├── .github/workflows/
│   └── build-flutter-ios-ipa.yml      # GitHub Actions (macOS) para compilar el .ipa
├── assets/
│   ├── data/
│   │   ├── domain_config.json         # Copiado de Xuper_TV/assets/domain_test.json
│   │   └── route_map.json             # Copiado de Xuper_TV/assets/therouter/routeMap.json
│   └── images/
│       ├── app_icon.png               # Icono CineVerse del APK reconstruido
│       ├── home_bg.png                # Fondo Home del APK reconstruido
│       └── splash_bg.png              # Fondo Splash 4K del APK reconstruido
├── ios/                               # Proyecto Xcode Runner completo para iOS 15-26+
│   ├── Flutter/
│   ├── Runner/
│   │   ├── AppDelegate.swift          # AVAudioSession .playback + AirPlay habilitado
│   │   ├── Info.plist                 # ATS habilitado para IPTV HTTP/HLS + Audio Background
│   │   └── Assets.xcassets/           # AppIcon 1024x1024 y LaunchImage
│   ├── Runner.xcodeproj/
│   └── Podfile
├── lib/
│   ├── main.dart                      # Entrada, SplashWelcomeScreen, ProfileGate y Scaffold
│   ├── controllers/
│   │   └── app_state_controller.dart  # Estado reactivo + persistencia SharedPreferences
│   ├── models/
│   │   └── models.dart                # Modelos VOD, LiveChannel, EPG, Server, UserProfile
│   ├── screens/
│   │   ├── home_dashboard_screen.dart         # Port de activity_home.xml / activity_vod_home.xml
│   │   ├── live_tv_guide_screen.dart          # Guía TV en Vivo + EPG interactiva
│   │   ├── explore_search_screen.dart         # Port de VodCategoryActivity + Buscador
│   │   ├── vod_detail_screen.dart             # Port de VodDetailsActivity + Temporadas/Episodios
│   │   ├── cinematic_video_player_screen.dart # Reproductor HLS con controles Cinematic Glass
│   │   ├── iptv_server_manager_screen.dart    # Gestor PortalCore / M3U8 / Xtream + Diagnóstico
│   │   └── profile_manager_screen.dart        # Perfiles + Control Parental con PIN
│   ├── services/
│   │   ├── iptv_parser_service.dart
│   │   └── xuper_portal_core_service.dart
│   └── theme/
│       └── cinematic_glass_theme.dart
├── scripts/
│   └── build_flutter_ipa.sh           # Script para generar CineVerse_XuperTV_Flutter_iOS.ipa
└── pubspec.yaml
```

---

## 🚀 Cómo Compilar el `.ipa` para iOS

### Opción 1: En la nube con GitHub Actions (Desde Windows sin necesitar Mac)
1. Sube la carpeta `CineVerse_Flutter_iOS` a tu repositorio de GitHub.
2. Ve a la pestaña **Actions** → **Build CineVerse Flutter iOS (.ipa)** y pulsa **Run workflow**.
3. Al finalizar, descarga el artefacto **`CineVerse_XuperTV_Flutter_iOS_IPA`** que contiene el archivo `CineVerse_XuperTV_Flutter_iOS.ipa` listo para instalar con **AltStore**, **SideStore**, **Sideloadly** o **TrollStore**.

### Opción 2: En macOS con Flutter + Xcode
```bash
cd CineVerse_Flutter_iOS
chmod +x scripts/build_flutter_ipa.sh
./scripts/build_flutter_ipa.sh
```


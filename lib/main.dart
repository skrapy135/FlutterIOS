import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'controllers/app_state_controller.dart';
import 'models/models.dart';
import 'screens/cinematic_video_player_screen.dart';
import 'screens/explore_search_screen.dart';
import 'screens/home_dashboard_screen.dart';
import 'screens/iptv_server_manager_screen.dart';
import 'screens/live_tv_guide_screen.dart';
import 'screens/profile_manager_screen.dart';
import 'screens/vod_detail_screen.dart';
import 'theme/cinematic_glass_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: CVColors.background,
    ),
  );
  runApp(const CineVerseFlutterApp());
}

class CineVerseFlutterApp extends StatefulWidget {
  const CineVerseFlutterApp({super.key});

  @override
  State<CineVerseFlutterApp> createState() => _CineVerseFlutterAppState();
}

class _CineVerseFlutterAppState extends State<CineVerseFlutterApp> {
  final AppStateController _appState = AppStateController();

  @override
  void dispose() {
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CineVerse',
      debugShowCheckedModeBanner: false,
      theme: CVColors.darkTheme,
      home: ListenableBuilder(
        listenable: _appState,
        builder: (context, _) {
          if (_appState.showSplash) {
            return SplashWelcomeScreen(
              onCompleted: _appState.completeSplash,
            );
          }
          if (_appState.showProfileSelector) {
            return ProfileGateScreen(appState: _appState);
          }
          return MainContainerScaffold(appState: _appState);
        },
      ),
    );
  }
}

/// Port en Flutter para iOS de `activity_welcome.xml` del APK Xuper TV con diseño CineVerse
class SplashWelcomeScreen extends StatefulWidget {
  final VoidCallback onCompleted;

  const SplashWelcomeScreen({
    super.key,
    required this.onCompleted,
  });

  @override
  State<SplashWelcomeScreen> createState() => _SplashWelcomeScreenState();
}

class _SplashWelcomeScreenState extends State<SplashWelcomeScreen> {
  double _progress = 0.18;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 220), (timer) {
      if (!mounted) return;
      setState(() {
        _progress += 0.24;
      });
      if (_progress >= 1.0) {
        timer.cancel();
        widget.onCompleted();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CVColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Opacity(
            opacity: 0.45,
            child: Image.asset(
              'assets/images/splash_bg.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  CVColors.primaryCrimson.withValues(alpha: 0.28),
                  CVColors.background.withValues(alpha: 0.94),
                ],
                radius: 0.95,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Container(
                    width: 108,
                    height: 108,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: CVColors.primaryCrimson.withValues(alpha: 0.5),
                          blurRadius: 32,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      'assets/images/app_icon.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        decoration: const BoxDecoration(
                          gradient: CVColors.crimsonGradient,
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 54,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'CINEVERSE',
                    style: TextStyle(
                      color: CVColors.textPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'XUPER TV EDITION • CINEMATIC GLASS iOS',
                    style: TextStyle(
                      color: CVColors.softCoral,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const Spacer(),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _progress.clamp(0.0, 1.0),
                      minHeight: 5,
                      backgroundColor: Colors.white12,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        CVColors.primaryCrimson,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Inicializando PortalCore v8 & Motor HLS 4K...',
                    style: TextStyle(
                      color: CVColors.textSecondary,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Selector rápido de perfil estilo CineVerse
class ProfileGateScreen extends StatelessWidget {
  final AppStateController appState;

  const ProfileGateScreen({
    super.key,
    required this.appState,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CVColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '¿Quién está viendo CineVerse?',
                style: TextStyle(
                  color: CVColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Selecciona tu perfil para personalizar canales en vivo y catálogo VOD',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CVColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 28),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: appState.profiles.map((profile) {
                  final color = Color(profile.avatarColorHex);
                  return SizedBox(
                    width: 145,
                    child: GlassCard(
                      borderRadius: 18,
                      isHighlighted: profile.id == appState.activeProfile.id,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 20,
                      ),
                      onTap: () => appState.selectProfile(profile),
                      child: Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.22),
                              shape: BoxShape.circle,
                              border: Border.all(color: color, width: 2),
                            ),
                            child: Icon(
                              profile.iconData,
                              color: color,
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            profile.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: CVColors.textPrimary,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            profile.isKidsProfile
                                ? 'Modo Kids ATP'
                                : profile.maxMaturityLevel,
                            style: const TextStyle(
                              color: CVColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),
              SecondaryGlassButton(
                label: 'Volver al Inicio',
                icon: Icons.arrow_back_rounded,
                onPressed: () => appState.toggleProfileGate(false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Contenedor Principal con Barra Inferior Flotante "Cinematic Glass"
class MainContainerScaffold extends StatelessWidget {
  final AppStateController appState;

  const MainContainerScaffold({
    super.key,
    required this.appState,
  });

  void _openVODDetail(BuildContext context, VODItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VODDetailScreen(
          item: item,
          appState: appState,
          onStartPlayback: (ctx) => _startPlayback(context, ctx),
        ),
      ),
    );
  }

  void _startPlayback(BuildContext context, PlaybackContext playbackContext) {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => CinematicVideoPlayerScreen(
          initialContext: playbackContext,
          appState: appState,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CVColors.background,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: _buildCurrentTab(context),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).padding.bottom + 10,
              child: _buildFloatingGlassTabBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentTab(BuildContext context) {
    switch (appState.selectedTab) {
      case 0:
        return HomeDashboardScreen(
          appState: appState,
          onOpenVODDetail: (item) => _openVODDetail(context, item),
          onStartPlayback: (ctx) => _startPlayback(context, ctx),
        );
      case 1:
        return LiveTVGuideScreen(
          appState: appState,
          onStartPlayback: (ctx) => _startPlayback(context, ctx),
        );
      case 2:
        return ExploreSearchScreen(
          appState: appState,
          onOpenVODDetail: (item) => _openVODDetail(context, item),
          onStartPlayback: (ctx) => _startPlayback(context, ctx),
        );
      case 3:
        return IPTVServerManagerScreen(appState: appState);
      case 4:
        return ProfileManagerScreen(appState: appState);
      default:
        return HomeDashboardScreen(
          appState: appState,
          onOpenVODDetail: (item) => _openVODDetail(context, item),
          onStartPlayback: (ctx) => _startPlayback(context, ctx),
        );
    }
  }

  Widget _buildFloatingGlassTabBar() {
    const items = [
      (icon: Icons.home_filled, label: 'Inicio'),
      (icon: Icons.live_tv_rounded, label: 'TV en Vivo'),
      (icon: Icons.explore_rounded, label: 'Explorar'),
      (icon: Icons.dns_rounded, label: 'Servidores'),
      (icon: Icons.person_rounded, label: 'Mi Perfil'),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
          decoration: BoxDecoration(
            color: CVColors.surfaceLow.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.65),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = appState.selectedTab == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () => appState.setTab(index),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? CVColors.primaryCrimson.withValues(alpha: 0.22)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          item.icon,
                          size: 20,
                          color: isSelected
                              ? CVColors.primaryCrimson
                              : CVColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: isSelected
                              ? CVColors.textPrimary
                              : CVColors.textSecondary,
                          fontSize: 10.5,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}


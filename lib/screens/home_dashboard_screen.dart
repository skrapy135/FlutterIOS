import 'package:flutter/material.dart';
import '../controllers/app_state_controller.dart';
import '../models/models.dart';
import '../theme/cinematic_glass_theme.dart';

/// Port en Flutter para iOS de `activity_home.xml` y `activity_vod_home.xml` del APK Xuper TV
class HomeDashboardScreen extends StatelessWidget {
  final AppStateController appState;
  final ValueChanged<VODItem> onOpenVODDetail;
  final ValueChanged<PlaybackContext> onStartPlayback;

  const HomeDashboardScreen({
    super.key,
    required this.appState,
    required this.onOpenVODDetail,
    required this.onStartPlayback,
  });

  @override
  Widget build(BuildContext context) {
    final heroItem = appState.featuredHeroItem;
    final continueItems = appState.continueWatchingItems;
    final trendingItems = appState.trendingItems;
    final allVodItems = appState.filteredVODCatalog;

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 120),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildTopBrandHeader(),
        ),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildHeroFeaturedBanner(heroItem),
        ),
        if (continueItems.isNotEmpty) ...[
          const SizedBox(height: 26),
          _buildContinueWatchingSection(continueItems),
        ],
        const SizedBox(height: 26),
        _buildLiveChannelsPreviewSection(),
        const SizedBox(height: 26),
        _buildVODPosterRail(
          title: 'Tendencias en CineVerse',
          subtitle: 'Sincronizado con /api/portalCore/getHome',
          items: trendingItems,
        ),
        const SizedBox(height: 26),
        _buildVODPosterRail(
          title: 'Originales & Estrenos 4K HDR',
          subtitle: 'Catálogo VOD Premium (/api/portalCore/v3/getShelveData)',
          items: allVodItems,
        ),
      ],
    );
  }

  Widget _buildTopBrandHeader() {
    final server = appState.activeServer;
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: CVColors.crimsonGradient,
            borderRadius: BorderRadius.circular(11),
            boxShadow: [
              BoxShadow(
                color: CVColors.primaryCrimson.withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            'assets/images/app_icon.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.live_tv_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CINEVERSE',
                style: TextStyle(
                  color: CVColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.6,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    width: 6.5,
                    height: 6.5,
                    decoration: const BoxDecoration(
                      color: CVColors.successGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      '${server.name} • ${server.latencyMs}ms',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: CVColors.textSecondary,
                        fontSize: 11,
                        fontFamily: 'Courier',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        GlassCard(
          borderRadius: 12,
          padding: const EdgeInsets.all(10),
          onTap: () => appState.setTab(2),
          child: const Icon(
            Icons.search_rounded,
            color: CVColors.textPrimary,
            size: 19,
          ),
        ),
        const SizedBox(width: 8),
        GlassCard(
          borderRadius: 12,
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
          onTap: () => appState.toggleProfileGate(true),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                appState.activeProfile.iconData,
                color: CVColors.primaryCrimson,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                appState.activeProfile.name,
                style: const TextStyle(
                  color: CVColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroFeaturedBanner(VODItem item) {
    final accentColor = Color(item.posterAccentHex);
    return GlassCard(
      borderRadius: 20,
      isHighlighted: true,
      child: SizedBox(
        height: 365,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Fondo atmosférico del APK + Gradiente Carmesí
            Opacity(
              opacity: 0.35,
              child: Image.asset(
                'assets/images/home_bg.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accentColor.withValues(alpha: 0.65),
                    CVColors.surfaceHigh.withValues(alpha: 0.80),
                    CVColors.background,
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
            ),
            Positioned(
              right: -20,
              top: 15,
              child: Icon(
                item.posterIconData,
                size: 165,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
            Container(
              decoration: const BoxDecoration(gradient: CVColors.heroVignette),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      const CVBadge(
                        text: 'ORIGINAL XUPER • CINEVERSE',
                        backgroundColor: CVColors.primaryCrimson,
                        textColor: Colors.white,
                      ),
                      CVBadge.quality(item.qualityBadge),
                      CVBadge(
                        text: '★ ${item.ratingScore.toStringAsFixed(1)}',
                        backgroundColor: Colors.black54,
                        textColor: CVColors.warningAmber,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: CVColors.textPrimary,
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${item.year} • ${item.maturityRating} • ${item.durationOrSeasons} • ${item.genres.join(" / ")}',
                    style: const TextStyle(
                      color: CVColors.softCoral,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.synopsis,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: CVColors.textSecondary,
                      fontSize: 12.5,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CrimsonPrimaryButton(
                          label: 'Reproducir Ahora',
                          icon: Icons.play_arrow_rounded,
                          isExpanded: true,
                          onPressed: () {
                            onStartPlayback(
                              PlaybackContext(
                                title: item.title,
                                subtitle:
                                    '${item.year} • ${item.durationOrSeasons}',
                                streamURL: item.streamURL,
                                isLiveStream: false,
                                qualityBadge: item.qualityBadge,
                                vodItemId: item.id,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      SecondaryGlassButton(
                        label: 'Detalles',
                        icon: Icons.info_outline_rounded,
                        onPressed: () => onOpenVODDetail(item),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueWatchingSection(List<VODItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Continuar Viendo',
            style: TextStyle(
              color: CVColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 128,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              final pct = (item.watchProgress * 100).round();
              return SizedBox(
                width: 245,
                child: GlassCard(
                  borderRadius: 14,
                  padding: const EdgeInsets.all(12),
                  onTap: () {
                    onStartPlayback(
                      PlaybackContext(
                        title: item.title,
                        subtitle: 'Reanudando en $pct%',
                        streamURL: item.streamURL,
                        isLiveStream: false,
                        qualityBadge: item.qualityBadge,
                        vodItemId: item.id,
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Color(item.posterAccentHex)
                                  .withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.play_circle_fill_rounded,
                              color: CVColors.primaryCrimson,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: CVColors.textPrimary,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.durationOrSeasons,
                                  style: const TextStyle(
                                    color: CVColors.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$pct% completado',
                            style: const TextStyle(
                              color: CVColors.softCoral,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          CVBadge.quality(item.qualityBadge),
                        ],
                      ),
                      const SizedBox(height: 7),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: item.watchProgress,
                          minHeight: 5,
                          backgroundColor: Colors.white12,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            CVColors.primaryCrimson,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLiveChannelsPreviewSection() {
    final channels = appState.filteredLiveChannels;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TV en Vivo • Señal Directa',
                    style: TextStyle(
                      color: CVColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Guía EPG en tiempo real (/api/portalCore/v6/getLiveData)',
                    style: TextStyle(
                      color: CVColors.textSecondary,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => appState.setTab(1),
                child: const Text(
                  'Ver Guía →',
                  style: TextStyle(
                    color: CVColors.primaryCrimson,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 136,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: channels.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final channel = channels[index];
              return SizedBox(
                width: 235,
                child: GlassCard(
                  borderRadius: 14,
                  padding: const EdgeInsets.all(13),
                  onTap: () {
                    appState.setPreviewChannel(channel);
                    onStartPlayback(
                      PlaybackContext(
                        title: channel.name,
                        subtitle:
                            'CH ${channel.number} • ${channel.currentProgram.title}',
                        streamURL: channel.streamURL,
                        isLiveStream: true,
                        qualityBadge: channel.qualityBadge,
                        channelNumber: channel.number,
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: CVColors.primaryCrimson
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'CH ${channel.number}',
                              style: const TextStyle(
                                color: CVColors.primaryCrimson,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Courier',
                              ),
                            ),
                          ),
                          const Spacer(),
                          CVBadge.live(),
                        ],
                      ),
                      const SizedBox(height: 9),
                      Row(
                        children: [
                          Icon(
                            channel.iconData,
                            color: CVColors.textPrimary,
                            size: 18,
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              channel.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: CVColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        channel.currentProgram.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: CVColors.textSecondary,
                          fontSize: 11.5,
                        ),
                      ),
                      const Spacer(),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: channel.currentProgram.progress,
                          minHeight: 4,
                          backgroundColor: Colors.white12,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            CVColors.primaryCrimson,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVODPosterRail({
    required String title,
    required String subtitle,
    required List<VODItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: CVColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: CVColors.textSecondary,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 13),
            itemBuilder: (context, index) {
              final item = items[index];
              final accent = Color(item.posterAccentHex);
              return SizedBox(
                width: 148,
                child: GlassCard(
                  borderRadius: 15,
                  onTap: () => onOpenVODDetail(item),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              accent.withValues(alpha: 0.55),
                              CVColors.surfaceContainer,
                              CVColors.background,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      Positioned(
                        right: -12,
                        top: 22,
                        child: Icon(
                          item.posterIconData,
                          size: 86,
                          color: Colors.white.withValues(alpha: 0.10),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CVBadge.quality(item.qualityBadge),
                                Text(
                                  '★ ${item.ratingScore.toStringAsFixed(1)}',
                                  style: const TextStyle(
                                    color: CVColors.warningAmber,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              item.type.label.toUpperCase(),
                              style: const TextStyle(
                                color: CVColors.softCoral,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.7,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: CVColors.textPrimary,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.year} • ${item.durationOrSeasons}',
                              style: const TextStyle(
                                color: CVColors.textSecondary,
                                fontSize: 10.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}


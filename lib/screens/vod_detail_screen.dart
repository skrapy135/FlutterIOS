import 'package:flutter/material.dart';
import '../controllers/app_state_controller.dart';
import '../models/models.dart';
import '../theme/cinematic_glass_theme.dart';

/// Port en Flutter para iOS de `com.vod.ui.activity.VodDetailsActivity`
class VODDetailScreen extends StatefulWidget {
  final VODItem item;
  final AppStateController appState;
  final ValueChanged<PlaybackContext> onStartPlayback;

  const VODDetailScreen({
    super.key,
    required this.item,
    required this.appState,
    required this.onStartPlayback,
  });

  @override
  State<VODDetailScreen> createState() => _VODDetailScreenState();
}

class _VODDetailScreenState extends State<VODDetailScreen> {
  int _selectedSeasonIdx = 0;

  VODItem get _liveItem {
    return widget.appState.vodCatalog.firstWhere(
      (v) => v.id == widget.item.id,
      orElse: () => widget.item,
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = _liveItem;
    final accent = Color(item.posterAccentHex);

    return Scaffold(
      backgroundColor: CVColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 310,
            pinned: true,
            backgroundColor: CVColors.surfaceLow,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GlassCard(
                borderRadius: 20,
                onTap: () => Navigator.of(context).pop(),
                child: const Icon(
                  Icons.close_rounded,
                  color: CVColors.textPrimary,
                  size: 20,
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GlassCard(
                  borderRadius: 20,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  onTap: () {
                    widget.appState.toggleVODFavorite(item);
                    setState(() {});
                  },
                  child: Row(
                    children: [
                      Icon(
                        item.isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: item.isFavorite
                            ? CVColors.primaryCrimson
                            : CVColors.textPrimary,
                        size: 18,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        item.isFavorite ? 'En Mi Lista' : 'Mi Lista',
                        style: const TextStyle(
                          color: CVColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accent.withValues(alpha: 0.72),
                          CVColors.surfaceHigh,
                          CVColors.background,
                        ],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -20,
                    top: 35,
                    child: Icon(
                      item.posterIconData,
                      size: 180,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: CVColors.heroVignette,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            CVBadge(
                              text: item.type.label.toUpperCase(),
                              backgroundColor: CVColors.primaryCrimson,
                              textColor: Colors.white,
                            ),
                            CVBadge.quality(item.qualityBadge),
                            CVBadge(
                              text: 'IMDb ${item.ratingScore.toStringAsFixed(1)}',
                              backgroundColor: Colors.black54,
                              textColor: CVColors.warningAmber,
                            ),
                            CVBadge(
                              text: item.maturityRating,
                              backgroundColor: Colors.white12,
                              textColor: CVColors.textPrimary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item.title,
                          style: const TextStyle(
                            color: CVColors.textPrimary,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item.originalTitle} • ${item.year} • ${item.durationOrSeasons}',
                          style: const TextStyle(
                            color: CVColors.softCoral,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 48),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                CrimsonPrimaryButton(
                  label: item.watchProgress > 0
                      ? 'Reanudar (${(item.watchProgress * 100).round()}%)'
                      : 'Reproducir en ${item.qualityBadge}',
                  icon: Icons.play_arrow_rounded,
                  isExpanded: true,
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onStartPlayback(
                      PlaybackContext(
                        title: item.title,
                        subtitle: '${item.year} • ${item.durationOrSeasons}',
                        streamURL: item.streamURL,
                        isLiveStream: false,
                        qualityBadge: item.qualityBadge,
                        vodItemId: item.id,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 18),
                Text(
                  item.synopsis,
                  style: const TextStyle(
                    color: CVColors.textPrimary,
                    fontSize: 14,
                    height: 1.48,
                  ),
                ),
                const SizedBox(height: 16),
                GlassCard(
                  borderRadius: 14,
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMetaRow('Géneros', item.genres.join(' • ')),
                      const SizedBox(height: 6),
                      _buildMetaRow('Dirección', item.director),
                      const SizedBox(height: 6),
                      _buildMetaRow('Reparto', item.cast.join(', ')),
                      const SizedBox(height: 6),
                      _buildMetaRow('Audio', item.audioLanguages.join(' / ')),
                      const SizedBox(height: 6),
                      _buildMetaRow(
                        'Subtítulos',
                        item.subtitleLanguages.join(' / '),
                      ),
                    ],
                  ),
                ),
                if (item.seasons.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Temporadas & Episodios',
                        style: TextStyle(
                          color: CVColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (item.seasons.length > 1)
                        DropdownButton<int>(
                          value: _selectedSeasonIdx,
                          dropdownColor: CVColors.surfaceHigh,
                          underline: const SizedBox.shrink(),
                          style: const TextStyle(
                            color: CVColors.primaryCrimson,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                          items: List.generate(
                            item.seasons.length,
                            (idx) => DropdownMenuItem(
                              value: idx,
                              child: Text(
                                'Temporada ${item.seasons[idx].seasonNumber}',
                              ),
                            ),
                          ),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedSeasonIdx = val);
                            }
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...item.seasons[_selectedSeasonIdx].episodes.map(
                    (ep) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GlassCard(
                        borderRadius: 14,
                        padding: const EdgeInsets.all(13),
                        onTap: () {
                          Navigator.of(context).pop();
                          widget.onStartPlayback(
                            PlaybackContext(
                              title: '${item.title} - Ep. ${ep.episodeNumber}',
                              subtitle: ep.title,
                              streamURL: ep.streamURL,
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
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    gradient: CVColors.crimsonGradient,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ep.title,
                                        style: const TextStyle(
                                          color: CVColors.textPrimary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      Text(
                                        'Duración: ${ep.duration}',
                                        style: const TextStyle(
                                          color: CVColors.textSecondary,
                                          fontSize: 11.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              ep.synopsis,
                              style: const TextStyle(
                                color: CVColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            if (ep.watchProgress > 0) ...[
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: ep.watchProgress,
                                  minHeight: 4,
                                  backgroundColor: Colors.white12,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                    CVColors.primaryCrimson,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 85,
          child: Text(
            label,
            style: const TextStyle(
              color: CVColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: CVColors.textPrimary,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}


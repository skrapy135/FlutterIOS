import 'package:flutter/material.dart';
import '../controllers/app_state_controller.dart';
import '../models/models.dart';
import '../theme/cinematic_glass_theme.dart';

/// Port en Flutter para iOS de `VodCategoryActivity` y buscador `/api/portalCore/v3/searchByName`
class ExploreSearchScreen extends StatelessWidget {
  final AppStateController appState;
  final ValueChanged<VODItem> onOpenVODDetail;
  final ValueChanged<PlaybackContext> onStartPlayback;

  const ExploreSearchScreen({
    super.key,
    required this.appState,
    required this.onOpenVODDetail,
    required this.onStartPlayback,
  });

  @override
  Widget build(BuildContext context) {
    final genres = appState.availableGenres;
    final vodResults = appState.searchFilteredVOD;
    final channelResults = appState.searchFilteredChannels;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Explorar & Búsqueda Global',
                style: TextStyle(
                  color: CVColors.textPrimary,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              GlassCard(
                borderRadius: 14,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                child: TextField(
                  onChanged: appState.setSearchQuery,
                  style: const TextStyle(color: CVColors.textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    icon: const Icon(
                      Icons.search_rounded,
                      color: CVColors.primaryCrimson,
                    ),
                    hintText:
                        'Buscar películas, series, actores o canales en vivo...',
                    hintStyle: const TextStyle(
                      color: CVColors.textMuted,
                      fontSize: 13.5,
                    ),
                    border: InputBorder.none,
                    suffixIcon: appState.searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () => appState.setSearchQuery(''),
                            icon: const Icon(
                              Icons.clear_rounded,
                              color: CVColors.textSecondary,
                              size: 18,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 38,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: genres.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final genre = genres[index];
              final isSelected = appState.selectedSearchGenre == genre;
              return GestureDetector(
                onTap: () => appState.setSearchGenre(genre),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected ? CVColors.crimsonGradient : null,
                    color: isSelected ? null : CVColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? Colors.white24
                          : Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Text(
                    genre,
                    style: TextStyle(
                      color: isSelected ? Colors.white : CVColors.textSecondary,
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
            children: [
              if (channelResults.isNotEmpty) ...[
                const Text(
                  'Canales en Vivo Coincidentes',
                  style: TextStyle(
                    color: CVColors.textPrimary,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                ...channelResults.map(
                  (channel) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GlassCard(
                      borderRadius: 12,
                      padding: const EdgeInsets.all(11),
                      onTap: () {
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
                      child: Row(
                        children: [
                          CVBadge.live(text: 'CH ${channel.number}'),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${channel.name} • ${channel.currentProgram.title}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: CVColors.textPrimary,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.play_arrow_rounded,
                            color: CVColors.primaryCrimson,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Catálogo VOD (Películas & Series)',
                    style: TextStyle(
                      color: CVColors.textPrimary,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '${vodResults.length} títulos',
                    style: const TextStyle(
                      color: CVColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                itemCount: vodResults.length,
                itemBuilder: (context, index) {
                  final item = vodResults[index];
                  final accent = Color(item.posterAccentHex);
                  return GlassCard(
                    borderRadius: 16,
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
                          right: -10,
                          top: 25,
                          child: Icon(
                            item.posterIconData,
                            size: 95,
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(13),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CVBadge.quality(item.qualityBadge),
                                  Text(
                                    '★ ${item.ratingScore.toStringAsFixed(1)}',
                                    style: const TextStyle(
                                      color: CVColors.warningAmber,
                                      fontSize: 11.5,
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
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: CVColors.textPrimary,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w900,
                                  height: 1.15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item.year} • ${item.genres.take(2).join(" / ")}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}


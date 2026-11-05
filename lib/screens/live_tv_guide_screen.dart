import 'package:flutter/material.dart';
import '../controllers/app_state_controller.dart';
import '../models/models.dart';
import '../theme/cinematic_glass_theme.dart';

/// Guía Interactiva de TV en Vivo & EPG (Port de `bg_home_live_channel_item.xml` y `/epg/v2/live/app/utc`)
class LiveTVGuideScreen extends StatelessWidget {
  final AppStateController appState;
  final ValueChanged<PlaybackContext> onStartPlayback;

  const LiveTVGuideScreen({
    super.key,
    required this.appState,
    required this.onStartPlayback,
  });

  @override
  Widget build(BuildContext context) {
    final previewChannel = appState.selectedPreviewChannel ??
        (appState.filteredLiveChannels.isNotEmpty
            ? appState.filteredLiveChannels.first
            : null);
    final categories = appState.liveCategories;
    final channels = appState.filteredLiveChannels;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TV en Vivo & Guía EPG',
                    style: TextStyle(
                      color: CVColors.textPrimary,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Señales HLS adaptativas • /epg/v2/live/app/utc-6/all',
                    style: TextStyle(
                      color: CVColors.textSecondary,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
              CVBadge.live(text: '${channels.length} CANALES'),
            ],
          ),
        ),
        if (previewChannel != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildLiveMonitorCard(previewChannel),
          ),
        const SizedBox(height: 14),
        SizedBox(
          height: 38,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = appState.selectedLiveCategory == category;
              return GestureDetector(
                onTap: () => appState.setLiveCategory(category),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected ? CVColors.crimsonGradient : null,
                    color: isSelected ? null : CVColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.25)
                          : Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : CVColors.textSecondary,
                      fontSize: 12.5,
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
          child: channels.isEmpty
              ? const Center(
                  child: Text(
                    'No hay canales en esta categoría.',
                    style: TextStyle(color: CVColors.textSecondary),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
                  itemCount: channels.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final channel = channels[index];
                    final isSelected = previewChannel?.id == channel.id;
                    return _buildChannelRowCard(channel, isSelected);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildLiveMonitorCard(LiveChannel channel) {
    return GlassCard(
      borderRadius: 18,
      isHighlighted: true,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CVBadge.live(text: 'EN VIVO • CH ${channel.number}'),
              const SizedBox(width: 8),
              CVBadge.quality(channel.qualityBadge),
              const Spacer(),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () => appState.toggleChannelFavorite(channel),
                icon: Icon(
                  channel.isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: channel.isFavorite
                      ? CVColors.primaryCrimson
                      : CVColors.textSecondary,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: CVColors.crimsonGradient,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(channel.iconData, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      channel.name,
                      style: const TextStyle(
                        color: CVColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      channel.currentProgram.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: CVColors.softCoral,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${channel.currentProgram.startTime} - ${channel.currentProgram.endTime} • ${channel.currentProgram.subtitle}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: channel.currentProgram.progress,
              minHeight: 5,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(
                CVColors.primaryCrimson,
              ),
            ),
          ),
          if (channel.upcomingPrograms.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'A continuación (${channel.upcomingPrograms.first.startTime}): ${channel.upcomingPrograms.first.title}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: CVColors.textMuted,
                fontSize: 11,
              ),
            ),
          ],
          const SizedBox(height: 12),
          CrimsonPrimaryButton(
            label: 'Abrir Señal en Pantalla Completa',
            icon: Icons.play_circle_fill_rounded,
            isExpanded: true,
            onPressed: () {
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
          ),
        ],
      ),
    );
  }

  Widget _buildChannelRowCard(LiveChannel channel, bool isSelected) {
    return GlassCard(
      borderRadius: 14,
      isHighlighted: isSelected,
      padding: const EdgeInsets.all(12),
      onTap: () => appState.setPreviewChannel(channel),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected
                  ? CVColors.primaryCrimson.withValues(alpha: 0.22)
                  : CVColors.surfaceHigh,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Text(
              '${channel.number}',
              style: TextStyle(
                color: isSelected
                    ? CVColors.primaryCrimson
                    : CVColors.textSecondary,
                fontSize: 13.5,
                fontWeight: FontWeight.w900,
                fontFamily: 'Courier',
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        channel.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: CVColors.textPrimary,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    CVBadge.quality(channel.qualityBadge),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  channel.currentProgram.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: CVColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: channel.currentProgram.progress,
                    minHeight: 3.5,
                    backgroundColor: Colors.white10,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      CVColors.primaryCrimson,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: () {
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
            icon: const Icon(
              Icons.play_circle_fill_rounded,
              color: CVColors.primaryCrimson,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}


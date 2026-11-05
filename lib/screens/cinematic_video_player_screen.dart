import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../controllers/app_state_controller.dart';
import '../models/models.dart';
import '../theme/cinematic_glass_theme.dart';

/// Reproductor de Video HLS Nativo para iOS con controles Cinematic Glass
class CinematicVideoPlayerScreen extends StatefulWidget {
  final PlaybackContext initialContext;
  final AppStateController appState;

  const CinematicVideoPlayerScreen({
    super.key,
    required this.initialContext,
    required this.appState,
  });

  @override
  State<CinematicVideoPlayerScreen> createState() =>
      _CinematicVideoPlayerScreenState();
}

class _CinematicVideoPlayerScreenState
    extends State<CinematicVideoPlayerScreen> {
  VideoPlayerController? _controller;
  late String _currentTitle;
  late String _currentSubtitle;
  late String _currentQualityBadge;
  late bool _isLive;

  bool _showOverlay = true;
  bool _showChannelDrawer = false;
  bool _isBuffering = true;
  bool _hasError = false;

  String _selectedAudioTrack = 'Español Latino (Dolby 5.1)';
  String _selectedSubtitleTrack = 'Español';

  @override
  void initState() {
    super.initState();
    _currentTitle = widget.initialContext.title;
    _currentSubtitle = widget.initialContext.subtitle;
    _currentQualityBadge = widget.initialContext.qualityBadge;
    _isLive = widget.initialContext.isLiveStream;
    _initializeStream(widget.initialContext.streamURL);
  }

  Future<void> _initializeStream(String url) async {
    setState(() {
      _isBuffering = true;
      _hasError = false;
    });

    final oldController = _controller;
    if (oldController != null) {
      await oldController.dispose();
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      setState(() {
        _isBuffering = false;
        _hasError = true;
      });
      return;
    }

    final controller = VideoPlayerController.networkUrl(uri);
    _controller = controller;
    controller.addListener(_onVideoListener);

    try {
      await controller.initialize();
      await controller.play();
      if (mounted) {
        setState(() {
          _isBuffering = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isBuffering = false;
          _hasError = true;
        });
      }
    }
  }

  void _onVideoListener() {
    if (!mounted) return;
    final c = _controller;
    if (c == null) return;
    setState(() {
      _isBuffering = c.value.isBuffering;
    });
  }

  void _saveProgressAndClose() {
    final c = _controller;
    if (!_isLive &&
        c != null &&
        c.value.isInitialized &&
        c.value.duration.inSeconds > 0) {
      final ratio = c.value.position.inSeconds / c.value.duration.inSeconds;
      widget.appState.updateVODProgress(widget.initialContext.vodItemId, ratio);
    }
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _controller?.removeListener(_onVideoListener);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    final isInitialized = c != null && c.value.isInitialized;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Superficie de Video HLS
            GestureDetector(
              onTap: () => setState(() => _showOverlay = !_showOverlay),
              behavior: HitTestBehavior.opaque,
              child: Center(
                child: isInitialized
                    ? AspectRatio(
                        aspectRatio: c.value.aspectRatio > 0
                            ? c.value.aspectRatio
                            : 16 / 9,
                        child: VideoPlayer(c),
                      )
                    : _buildFallbackStage(),
              ),
            ),

            // Controles Superpuestos Cinematic Glass
            if (_showOverlay)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.78),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.85),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTopBar(),
                    _buildCenterTransportControls(c, isInitialized),
                    _buildBottomScrubberBar(c, isInitialized),
                  ],
                ),
              ),

            // Gaveta lateral de Cambio Rápido de Canal en Vivo
            if (_showChannelDrawer) _buildQuickChannelDrawer(),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackStage() {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isBuffering) ...[
            const CircularProgressIndicator(color: CVColors.primaryCrimson),
            const SizedBox(height: 16),
            Text(
              'Conectando stream HLS ($_currentQualityBadge)...',
              style: const TextStyle(
                color: CVColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ] else if (_hasError) ...[
            const Icon(
              Icons.wifi_tethering_error_rounded,
              color: CVColors.primaryCrimson,
              size: 46,
            ),
            const SizedBox(height: 10),
            const Text(
              'Reconectando al nodo PortalCore HLS...',
              style: TextStyle(
                color: CVColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            SecondaryGlassButton(
              label: 'Reintentar Señal',
              icon: Icons.refresh_rounded,
              onPressed: () =>
                  _initializeStream(widget.initialContext.streamURL),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        GlassCard(
          borderRadius: 20,
          padding: const EdgeInsets.all(9),
          onTap: _saveProgressAndClose,
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (_isLive) ...[
                    CVBadge.live(),
                    const SizedBox(width: 6),
                  ],
                  CVBadge.quality(_currentQualityBadge),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _currentTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                _currentSubtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: CVColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        GlassCard(
          borderRadius: 12,
          padding: const EdgeInsets.all(10),
          onTap: _openAudioSubtitleModal,
          child: const Icon(
            Icons.subtitles_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        if (_isLive) ...[
          const SizedBox(width: 8),
          GlassCard(
            borderRadius: 12,
            padding: const EdgeInsets.all(10),
            onTap: () =>
                setState(() => _showChannelDrawer = !_showChannelDrawer),
            child: const Icon(
              Icons.view_list_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCenterTransportControls(
    VideoPlayerController? c,
    bool isInitialized,
  ) {
    final isPlaying = isInitialized && c.value.isPlaying;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!_isLive) ...[
          GlassCard(
            borderRadius: 30,
            padding: const EdgeInsets.all(13),
            onTap: () {
              if (!isInitialized) return;
              final target =
                  c.value.position - const Duration(seconds: 10);
              c.seekTo(target < Duration.zero ? Duration.zero : target);
            },
            child: const Icon(
              Icons.replay_10_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 28),
        ],
        GestureDetector(
          onTap: () {
            if (!isInitialized) return;
            setState(() {
              c.value.isPlaying ? c.pause() : c.play();
            });
          },
          child: Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              gradient: CVColors.crimsonGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: CVColors.primaryCrimson.withValues(alpha: 0.5),
                  blurRadius: 18,
                ),
              ],
            ),
            child: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
        ),
        if (!_isLive) ...[
          const SizedBox(width: 28),
          GlassCard(
            borderRadius: 30,
            padding: const EdgeInsets.all(13),
            onTap: () {
              if (!isInitialized) return;
              final target =
                  c.value.position + const Duration(seconds: 10);
              c.seekTo(target);
            },
            child: const Icon(
              Icons.forward_10_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBottomScrubberBar(
    VideoPlayerController? c,
    bool isInitialized,
  ) {
    final position = isInitialized ? c.value.position : Duration.zero;
    final duration = isInitialized ? c.value.duration : Duration.zero;
    final maxSeconds =
        duration.inSeconds > 0 ? duration.inSeconds.toDouble() : 1.0;
    final currentSeconds =
        position.inSeconds.toDouble().clamp(0.0, maxSeconds);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!_isLive)
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: CVColors.primaryCrimson,
              inactiveTrackColor: Colors.white24,
              thumbColor: CVColors.primaryCrimson,
              trackHeight: 4,
            ),
            child: Slider(
              value: currentSeconds,
              min: 0.0,
              max: maxSeconds,
              onChanged: (val) {
                if (isInitialized) {
                  c.seekTo(Duration(seconds: val.round()));
                }
              },
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _isLive
                  ? 'TRANSMISIÓN EN VIVO • LATENCIA ULTRA BAJA'
                  : '${_formatDuration(position)} / ${_formatDuration(duration)}',
              style: const TextStyle(
                color: CVColors.textSecondary,
                fontSize: 11.5,
                fontFamily: 'Courier',
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Audio: $_selectedAudioTrack • Sub: $_selectedSubtitleTrack',
              style: const TextStyle(
                color: CVColors.softCoral,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickChannelDrawer() {
    final channels = widget.appState.filteredLiveChannels;
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        width: 285,
        color: CVColors.surfaceLow.withValues(alpha: 0.96),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Cambio Rápido de Canal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _showChannelDrawer = false),
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: channels.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final ch = channels[index];
                  final isCurrent = ch.name == _currentTitle;
                  return GlassCard(
                    borderRadius: 10,
                    isHighlighted: isCurrent,
                    padding: const EdgeInsets.all(10),
                    onTap: () {
                      setState(() {
                        _currentTitle = ch.name;
                        _currentSubtitle =
                            'CH ${ch.number} • ${ch.currentProgram.title}';
                        _currentQualityBadge = ch.qualityBadge;
                        _showChannelDrawer = false;
                      });
                      _initializeStream(ch.streamURL);
                    },
                    child: Row(
                      children: [
                        Text(
                          '${ch.number}',
                          style: const TextStyle(
                            color: CVColors.primaryCrimson,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Courier',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ch.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                ch.currentProgram.title,
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
            ),
          ],
        ),
      ),
    );
  }

  void _openAudioSubtitleModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: CVColors.surfaceHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pistas de Audio & Subtítulos',
                    style: TextStyle(
                      color: CVColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Audio',
                    style: TextStyle(
                      color: CVColors.softCoral,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  ...[
                    'Español Latino (Dolby 5.1)',
                    'Inglés Original (Atmos)',
                    'Portugués'
                  ].map(
                    (track) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        track,
                        style: const TextStyle(color: CVColors.textPrimary),
                      ),
                      trailing: _selectedAudioTrack == track
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: CVColors.primaryCrimson,
                            )
                          : null,
                      onTap: () {
                        setState(() => _selectedAudioTrack = track);
                        setModalState(() {});
                      },
                    ),
                  ),
                  const Divider(color: Colors.white12),
                  const Text(
                    'Subtítulos',
                    style: TextStyle(
                      color: CVColors.softCoral,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  ...['Desactivados', 'Español', 'Inglés', 'Portugués'].map(
                    (sub) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        sub,
                        style: const TextStyle(color: CVColors.textPrimary),
                      ),
                      trailing: _selectedSubtitleTrack == sub
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: CVColors.primaryCrimson,
                            )
                          : null,
                      onTap: () {
                        setState(() => _selectedSubtitleTrack = sub);
                        setModalState(() {});
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatDuration(Duration d) {
    final totalSeconds = d.inSeconds;
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    final mm = minutes.toString().padLeft(2, '0');
    final ss = seconds.toString().padLeft(2, '0');
    if (hours > 0) {
      return '$hours:$mm:$ss';
    }
    return '$mm:$ss';
  }
}


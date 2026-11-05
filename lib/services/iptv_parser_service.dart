import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

/// Parser de listas M3U/M3U8, cliente Xtream Codes API y catálogo base 4K HDR
class IPTVParserService {
  IPTVParserService._();
  static final IPTVParserService instance = IPTVParserService._();

  /// Parsea contenido `#EXTM3U` o enlaces HLS directos en canales `LiveChannel`
  List<LiveChannel> parseM3U(String content, {int startingChannelNumber = 101}) {
    final lines = const LineSplitter().convert(content);
    final channels = <LiveChannel>[];
    var currentName = 'Canal IPTV';
    var currentGroup = 'Entretenimiento';
    String? currentLogo;
    var number = startingChannelNumber;

    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty || line == '#EXTM3U') continue;

      if (line.startsWith('#EXTINF:')) {
        final commaIdx = line.lastIndexOf(',');
        if (commaIdx != -1 && commaIdx + 1 < line.length) {
          final parsedName = line.substring(commaIdx + 1).trim();
          if (parsedName.isNotEmpty) currentName = parsedName;
        }
        currentGroup =
            _extractAttribute(line, 'group-title') ?? 'Entretenimiento';
        currentLogo = _extractAttribute(line, 'tvg-logo');
      } else if (!line.startsWith('#') &&
          (line.startsWith('http://') || line.startsWith('https://'))) {
        final lower = line.toLowerCase();
        final quality = (lower.contains('4k') || lower.contains('uhd'))
            ? '4K HDR'
            : 'FHD 60fps';

        channels.add(
          LiveChannel(
            id: 'm3u-$number-${DateTime.now().microsecondsSinceEpoch}',
            number: number,
            name: currentName,
            category: currentGroup,
            iconName: _iconForCategory(currentGroup),
            logoURL: currentLogo,
            streamURL: line,
            qualityBadge: quality,
            currentProgram: EPGProgram(
              id: 'epg-$number-now',
              title: 'Transmisión en Vivo • $currentName',
              subtitle: currentGroup,
              startTime: 'AHORA',
              endTime: 'EN VIVO',
              progress: 0.52,
              isLiveNow: true,
            ),
            upcomingPrograms: [
              EPGProgram(
                id: 'epg-$number-next',
                title: 'Programación Continua • $currentName',
                subtitle: 'Próximo bloque',
                startTime: '+1h',
                endTime: '+2h',
                progress: 0.0,
                isLiveNow: false,
              ),
            ],
          ),
        );
        number++;
        currentName = 'Canal $number';
        currentGroup = 'Entretenimiento';
        currentLogo = null;
      }
    }
    return channels;
  }

  /// Descarga y parsea una lista M3U/M3U8 remota o detecta si es un stream HLS maestro directo
  Future<List<LiveChannel>> fetchRemoteM3U(
    String urlString, {
    String fallbackName = 'Canal HLS Directo',
  }) async {
    final trimmed = urlString.trim();
    final uri = Uri.tryParse(trimmed);
    if (uri == null) return const [];

    final response =
        await http.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return const [];
    }

    final text = utf8.decode(response.bodyBytes, allowMalformed: true);
    if (text.contains('#EXT-X-STREAM-INF') ||
        text.contains('#EXT-X-TARGETDURATION')) {
      return [
        LiveChannel(
          id: 'hls-direct-199',
          number: 199,
          name: fallbackName,
          category: 'Directo HLS',
          iconName: 'tv',
          streamURL: trimmed,
          qualityBadge: 'HLS Auto',
          currentProgram: EPGProgram(
            id: 'epg-199-now',
            title: 'Señal Directa • $fallbackName',
            subtitle: 'Streaming Adaptativo HLS',
            startTime: 'EN VIVO',
            endTime: '24/7',
            progress: 0.5,
            isLiveNow: true,
          ),
          upcomingPrograms: const [],
        ),
      ];
    }

    return parseM3U(text, startingChannelNumber: 201);
  }

  /// Conecta a un servidor Xtream Codes API (`player_api.php`) y obtiene canales en vivo
  Future<List<LiveChannel>> fetchXtreamCodesLiveStreams(
    IPTVServerConfig server, {
    int startingChannelNumber = 300,
  }) async {
    final base = server.hostURL.trim().replaceAll(RegExp(r'/+$'), '');
    final user = Uri.encodeComponent(server.username ?? '');
    final pass = Uri.encodeComponent(server.password ?? '');
    if (base.isEmpty || user.isEmpty) return const [];

    final uri = Uri.tryParse(
        '$base/player_api.php?username=$user&password=$pass&action=get_live_streams');
    if (uri == null) return const [];

    final response =
        await http.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return const [];
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) return const [];

    final channels = <LiveChannel>[];
    var number = startingChannelNumber;
    for (final item in decoded.take(80)) {
      if (item is! Map<String, dynamic>) continue;
      final name = item['name']?.toString() ?? 'Canal Xtream $number';
      final streamId = item['stream_id']?.toString();
      if (streamId == null || streamId.isEmpty) continue;
      final streamURL = '$base/live/$user/$pass/$streamId.m3u8';
      final logo = item['stream_icon']?.toString();

      channels.add(
        LiveChannel(
          id: 'xtream-$streamId',
          number: number,
          name: name,
          category: 'Xtream TV',
          iconName: 'tv',
          logoURL: logo,
          streamURL: streamURL,
          qualityBadge: 'FHD',
          currentProgram: EPGProgram(
            id: 'epg-xt-$streamId',
            title: 'En Vivo • $name',
            subtitle: 'Xtream Codes API',
            startTime: 'AHORA',
            endTime: 'EN VIVO',
            progress: 0.5,
            isLiveNow: true,
          ),
          upcomingPrograms: const [],
        ),
      );
      number++;
    }
    return channels;
  }

  String? _extractAttribute(String line, String key) {
    final regex = RegExp('$key="([^"]+)"', caseSensitive: false);
    final match = regex.firstMatch(line);
    return match?.group(1);
  }

  String _iconForCategory(String category) {
    final lower = category.toLowerCase();
    if (lower.contains('deport') || lower.contains('sport')) return 'sports';
    if (lower.contains('cine') || lower.contains('movie')) return 'movie';
    if (lower.contains('notic') || lower.contains('news')) return 'news';
    if (lower.contains('infant') || lower.contains('kid')) return 'kids';
    return 'tv';
  }

  /// Canales HLS funcionales predeterminados (Apple BipBop fMP4, Mux, Unified Streaming, Akamai)
  static List<LiveChannel> defaultLiveChannels() {
    return const [
      LiveChannel(
        id: 'ch-101',
        number: 101,
        name: 'CineVerse Premiere 4K',
        category: 'Cine',
        iconName: 'movie',
        streamURL:
            'https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8',
        qualityBadge: '4K HDR',
        currentProgram: EPGProgram(
          id: 'epg-101-1',
          title: 'Horizonte de Obsidiana (Estreno Exclusivo)',
          subtitle: 'Audio Dolby Atmos • Subtítulos ES/EN',
          startTime: '12:00',
          endTime: '14:30',
          progress: 0.62,
          isLiveNow: true,
        ),
        upcomingPrograms: [
          EPGProgram(
            id: 'epg-101-2',
            title: 'Detrás de Cámaras: Universo Xuper',
            subtitle: 'Documental Exclusivo',
            startTime: '14:30',
            endTime: '15:30',
            progress: 0,
            isLiveNow: false,
          ),
          EPGProgram(
            id: 'epg-101-3',
            title: 'Noche de Acción IMAX',
            subtitle: 'Acción / Sci-Fi',
            startTime: '15:30',
            endTime: '18:00',
            progress: 0,
            isLiveNow: false,
          ),
        ],
        isFavorite: true,
      ),
      LiveChannel(
        id: 'ch-102',
        number: 102,
        name: 'Xuper Sports Arena HD',
        category: 'Deportes',
        iconName: 'sports',
        streamURL: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
        qualityBadge: 'FHD 60fps',
        currentProgram: EPGProgram(
          id: 'epg-102-1',
          title: 'UEFA Champions League: Cuartos de Final',
          subtitle: 'En Vivo • Multi-Cámara portalCore EPG v5',
          startTime: '11:45',
          endTime: '14:00',
          progress: 0.78,
          isLiveNow: true,
        ),
        upcomingPrograms: [
          EPGProgram(
            id: 'epg-102-2',
            title: 'Resumen Jornada Europea',
            subtitle: 'Análisis Deportivo',
            startTime: '14:00',
            endTime: '15:00',
            progress: 0,
            isLiveNow: false,
          ),
          EPGProgram(
            id: 'epg-102-3',
            title: 'Fórmula 1: GP Prácticas Libres',
            subtitle: 'Automovilismo',
            startTime: '15:00',
            endTime: '17:00',
            progress: 0,
            isLiveNow: false,
          ),
        ],
        isFavorite: true,
      ),
      LiveChannel(
        id: 'ch-103',
        number: 103,
        name: 'CineVerse Sci-Fi & Action',
        category: 'Cine',
        iconName: 'scifi',
        streamURL:
            'https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8',
        qualityBadge: '4K HDR',
        currentProgram: EPGProgram(
          id: 'epg-103-1',
          title: 'Tears of Steel: Edición Remasterizada',
          subtitle: 'Ciencia Ficción • Cyberpunk',
          startTime: '12:15',
          endTime: '13:45',
          progress: 0.45,
          isLiveNow: true,
        ),
        upcomingPrograms: [
          EPGProgram(
            id: 'epg-103-2',
            title: 'Crónicas de Neón 2099',
            subtitle: 'Sci-Fi',
            startTime: '13:45',
            endTime: '16:00',
            progress: 0,
            isLiveNow: false,
          ),
        ],
        isFavorite: false,
      ),
      LiveChannel(
        id: 'ch-104',
        number: 104,
        name: 'Global News 24/7',
        category: 'Noticias',
        iconName: 'news',
        streamURL:
            'https://cph-p2p-msl.akamaized.net/hls/live/2000341/test/master.m3u8',
        qualityBadge: 'FHD 60fps',
        currentProgram: EPGProgram(
          id: 'epg-104-1',
          title: 'Panorama Internacional: Edición Mediodía',
          subtitle: 'Cobertura en tiempo real',
          startTime: '12:00',
          endTime: '13:00',
          progress: 0.55,
          isLiveNow: true,
        ),
        upcomingPrograms: [
          EPGProgram(
            id: 'epg-104-2',
            title: 'Mercados & Tecnología FinTech',
            subtitle: 'Economía Global',
            startTime: '13:00',
            endTime: '14:00',
            progress: 0,
            isLiveNow: false,
          ),
        ],
        isFavorite: false,
      ),
      LiveChannel(
        id: 'ch-105',
        number: 105,
        name: 'CineVerse Kids & Animation',
        category: 'Infantil',
        iconName: 'kids',
        streamURL: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
        qualityBadge: 'FHD',
        currentProgram: EPGProgram(
          id: 'epg-105-1',
          title: 'Las Aventuras de Big Buck Bunny',
          subtitle: 'Animación Familiar • Clasificación ATP',
          startTime: '12:00',
          endTime: '13:30',
          progress: 0.35,
          isLiveNow: true,
        ),
        upcomingPrograms: [
          EPGProgram(
            id: 'epg-105-2',
            title: 'Guardianes Estelares Kids',
            subtitle: 'Aventura Familiar',
            startTime: '13:30',
            endTime: '15:00',
            progress: 0,
            isLiveNow: false,
          ),
        ],
        isFavorite: false,
      ),
      LiveChannel(
        id: 'ch-106',
        number: 106,
        name: 'Estadio Fútbol Total 4K',
        category: 'Deportes',
        iconName: 'sports',
        streamURL:
            'https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8',
        qualityBadge: '4K 60fps',
        currentProgram: EPGProgram(
          id: 'epg-106-1',
          title: 'Copa Libertadores: Previa & Alineaciones',
          subtitle: 'Transmisión Oficial portalCore EPG v5',
          startTime: '12:00',
          endTime: '14:00',
          progress: 0.50,
          isLiveNow: true,
        ),
        upcomingPrograms: [
          EPGProgram(
            id: 'epg-106-2',
            title: 'Clásico Sudamericano en Vivo',
            subtitle: 'Partido en Directo',
            startTime: '14:00',
            endTime: '16:30',
            progress: 0,
            isLiveNow: false,
          ),
        ],
        isFavorite: true,
      ),
    ];
  }

  /// Catálogo VOD predeterminado sincronizado con la estructura de `VodDetailsActivity`
  static List<VODItem> defaultVODCatalog() {
    return const [
      VODItem(
        id: 'vod-1',
        title: 'Protocolo Carmesí: Eclipse',
        originalTitle: 'Crimson Protocol: Eclipse',
        type: VODContentType.series,
        year: 2026,
        ratingScore: 9.6,
        maturityRating: 'TV-MA',
        durationOrSeasons: '2 Temporadas',
        genres: ['Ciencia Ficción', 'Thriller', 'Cyberpunk'],
        synopsis:
            'En una metrópolis controlada por redes cuánticas, una ex-arquitecta de seguridad descubre una señal oculta capaz de reescribir la memoria colectiva.',
        director: 'Elena Vance',
        cast: ['Diego Luna', 'Ana de Armas', 'Wagner Moura', 'Tessa Thompson'],
        qualityBadge: '4K Dolby Vision',
        audioLanguages: [
          'Español Latino (5.1)',
          'Inglés Original (Atmos)',
          'Portugués'
        ],
        subtitleLanguages: ['Español', 'Inglés', 'Portugués'],
        posterAccentHex: 0xFFE50914,
        posterIconName: 'cpu',
        streamURL:
            'https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8',
        seasons: [
          SeasonItem(
            id: 's1',
            seasonNumber: 1,
            title: 'Temporada 1: La Señal Oculta',
            episodes: [
              EpisodeItem(
                id: 's1e1',
                episodeNumber: 1,
                title: '1. El Nodo Cero',
                duration: '54m',
                synopsis:
                    'Kira intercepta un paquete cifrado proveniente de un satélite fuera de órbita.',
                streamURL:
                    'https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8',
                watchProgress: 1.0,
              ),
              EpisodeItem(
                id: 's1e2',
                episodeNumber: 2,
                title: '2. Espejos de Obsidiana',
                duration: '51m',
                synopsis:
                    'El sindicato bloquea los sectores financieros mientras comienza la persecución.',
                streamURL:
                    'https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8',
                watchProgress: 0.65,
              ),
              EpisodeItem(
                id: 's1e3',
                episodeNumber: 3,
                title: '3. Frecuencia Fantasma',
                duration: '58m',
                synopsis:
                    'Una alianza inesperada revela el verdadero origen del proyecto Xuper.',
                streamURL: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
                watchProgress: 0.0,
              ),
              EpisodeItem(
                id: 's1e4',
                episodeNumber: 4,
                title: '4. Horizonte Rojo',
                duration: '62m',
                synopsis:
                    'Final de temporada en la torre central de procesamiento orbital.',
                streamURL:
                    'https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8',
                watchProgress: 0.0,
              ),
            ],
          ),
          SeasonItem(
            id: 's2',
            seasonNumber: 2,
            title: 'Temporada 2: Resurrección',
            episodes: [
              EpisodeItem(
                id: 's2e1',
                episodeNumber: 1,
                title: '1. Cenizas Digitales',
                duration: '56m',
                synopsis:
                    'Seis meses después del apagón global, una nueva transmisión despierta la red.',
                streamURL:
                    'https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8',
                watchProgress: 0.0,
              ),
              EpisodeItem(
                id: 's2e2',
                episodeNumber: 2,
                title: '2. Vector de Ataque',
                duration: '53m',
                synopsis:
                    'El consejo activa el protocolo de contención en tres continentes.',
                streamURL: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
                watchProgress: 0.0,
              ),
            ],
          ),
        ],
        watchProgress: 0.65,
        isFavorite: true,
        isTrending: true,
        isOriginal: true,
      ),
      VODItem(
        id: 'vod-2',
        title: 'Sinfonía del Abismo',
        originalTitle: 'Abyssal Symphony',
        type: VODContentType.movie,
        year: 2026,
        ratingScore: 9.2,
        maturityRating: 'PG-13',
        durationOrSeasons: '2h 24m',
        genres: ['Acción', 'Aventura', 'IMAX'],
        synopsis:
            'Una expedición submarina a 11,000 metros de profundidad descubre una estructura biomecánica activa que altera las mareas del planeta.',
        director: 'Denis Villeneuve',
        cast: ['Oscar Isaac', 'Rebecca Ferguson', 'Stellan Skarsgård'],
        qualityBadge: 'IMAX Enhanced',
        audioLanguages: ['Español Latino', 'Inglés Original'],
        subtitleLanguages: ['Español', 'Inglés'],
        posterAccentHex: 0xFF93000A,
        posterIconName: 'waves',
        streamURL:
            'https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8',
        seasons: [],
        watchProgress: 0.38,
        isFavorite: true,
        isTrending: true,
        isOriginal: true,
      ),
      VODItem(
        id: 'vod-3',
        title: 'Imperio de Velocidad: Apex',
        originalTitle: 'Velocity Empire: Apex',
        type: VODContentType.movie,
        year: 2025,
        ratingScore: 8.9,
        maturityRating: 'PG-13',
        durationOrSeasons: '2h 08m',
        genres: ['Deportes', 'Drama', 'Acción'],
        synopsis:
            'Un piloto veterano regresa al campeonato mundial de resistencia para competir contra una escudería impulsada por telemetría predictiva.',
        director: 'Joseph Kosinski',
        cast: ['Pedro Pascal', 'Daniel Brühl', 'Charles Leclerc'],
        qualityBadge: '4K 60fps',
        audioLanguages: ['Español Latino', 'Inglés Original'],
        subtitleLanguages: ['Español', 'Inglés'],
        posterAccentHex: 0xFFBF1E2E,
        posterIconName: 'speed',
        streamURL: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
        seasons: [],
        watchProgress: 0.0,
        isFavorite: false,
        isTrending: true,
        isOriginal: false,
      ),
      VODItem(
        id: 'vod-4',
        title: 'El Último Guardián Estelar',
        originalTitle: 'The Last Star Guardian',
        type: VODContentType.series,
        year: 2026,
        ratingScore: 9.1,
        maturityRating: 'ATP',
        durationOrSeasons: '1 Temporada',
        genres: ['Animación', 'Aventura', 'Familia'],
        synopsis:
            'Un joven navegante y su droide restaurado viajan por constelaciones olvidadas para encender los faros estelares antes del gran invierno cósmico.',
        director: 'Makoto Shinkai',
        cast: ['Voces Originales', 'Doblaje Latino Oficial'],
        qualityBadge: '4K HDR',
        audioLanguages: ['Español Latino', 'Japonés', 'Inglés'],
        subtitleLanguages: ['Español', 'Inglés'],
        posterAccentHex: 0xFFD9381E,
        posterIconName: 'stars',
        streamURL: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
        seasons: [
          SeasonItem(
            id: 's4-1',
            seasonNumber: 1,
            title: 'Temporada 1',
            episodes: [
              EpisodeItem(
                id: 's4e1',
                episodeNumber: 1,
                title: '1. La Brújula de Cristal',
                duration: '28m',
                synopsis:
                    'El hallazgo del mapa estelar en el taller subterráneo.',
                streamURL: 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8',
                watchProgress: 0.80,
              ),
              EpisodeItem(
                id: 's4e2',
                episodeNumber: 2,
                title: '2. Nebulosa Carmesí',
                duration: '27m',
                synopsis:
                    'El primer salto hiperespacial hacia el sector exterior.',
                streamURL:
                    'https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8',
                watchProgress: 0.0,
              ),
            ],
          ),
        ],
        watchProgress: 0.80,
        isFavorite: false,
        isTrending: false,
        isOriginal: true,
      ),
      VODItem(
        id: 'vod-5',
        title: 'Código Silencioso',
        originalTitle: 'Silent Cipher',
        type: VODContentType.movie,
        year: 2025,
        ratingScore: 8.7,
        maturityRating: 'TV-MA',
        durationOrSeasons: '1h 58m',
        genres: ['Suspenso', 'Crimen', 'Misterio'],
        synopsis:
            'En Ginebra, un auditor criptográfico descubre una bóveda fuera de registro que financia operaciones clandestinas a escala global.',
        director: 'Michael Mann',
        cast: ['Cillian Murphy', 'Léa Seydoux', 'Idris Elba'],
        qualityBadge: '4K Dolby Vision',
        audioLanguages: ['Español Latino', 'Inglés', 'Francés'],
        subtitleLanguages: ['Español', 'Inglés'],
        posterAccentHex: 0xFF7A0916,
        posterIconName: 'shield',
        streamURL:
            'https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8',
        seasons: [],
        watchProgress: 0.0,
        isFavorite: false,
        isTrending: true,
        isOriginal: false,
      ),
    ];
  }
}


import 'package:flutter/material.dart';

/// Protocol types supported by CineVerse Xuper TV
enum ServerProtocolType {
  xuperPortalCore('Xuper PortalCore'),
  m3uPlaylist('Lista M3U / M3U8'),
  xtreamCodes('Xtream Codes API');

  final String label;
  const ServerProtocolType(this.label);

  static ServerProtocolType fromLabel(String value) {
    return ServerProtocolType.values.firstWhere(
      (e) => e.label == value || e.name == value,
      orElse: () => ServerProtocolType.xuperPortalCore,
    );
  }
}

/// IPTV & Xuper PortalCore Server Configuration
class IPTVServerConfig {
  final String id;
  final String name;
  final ServerProtocolType type;
  final String hostURL;
  final String? backupHostURL;
  final String? username;
  final String? password;
  final String? snToken;
  final String? portalCode;
  final bool isActive;
  final int latencyMs;
  final int channelCount;
  final int vodCount;

  const IPTVServerConfig({
    required this.id,
    required this.name,
    required this.type,
    required this.hostURL,
    this.backupHostURL,
    this.username,
    this.password,
    this.snToken,
    this.portalCode,
    required this.isActive,
    required this.latencyMs,
    required this.channelCount,
    required this.vodCount,
  });

  IPTVServerConfig copyWith({
    String? name,
    ServerProtocolType? type,
    String? hostURL,
    String? backupHostURL,
    String? username,
    String? password,
    String? snToken,
    String? portalCode,
    bool? isActive,
    int? latencyMs,
    int? channelCount,
    int? vodCount,
  }) {
    return IPTVServerConfig(
      id: id,
      name: name ?? this.name,
      type: type ?? this.type,
      hostURL: hostURL ?? this.hostURL,
      backupHostURL: backupHostURL ?? this.backupHostURL,
      username: username ?? this.username,
      password: password ?? this.password,
      snToken: snToken ?? this.snToken,
      portalCode: portalCode ?? this.portalCode,
      isActive: isActive ?? this.isActive,
      latencyMs: latencyMs ?? this.latencyMs,
      channelCount: channelCount ?? this.channelCount,
      vodCount: vodCount ?? this.vodCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.name,
        'hostURL': hostURL,
        'backupHostURL': backupHostURL,
        'username': username,
        'password': password,
        'snToken': snToken,
        'portalCode': portalCode,
        'isActive': isActive,
        'latencyMs': latencyMs,
        'channelCount': channelCount,
        'vodCount': vodCount,
      };

  factory IPTVServerConfig.fromJson(Map<String, dynamic> json) {
    return IPTVServerConfig(
      id: json['id'] as String? ?? 'srv-1',
      name: json['name'] as String? ?? 'Servidor CineVerse',
      type: ServerProtocolType.fromLabel(json['type'] as String? ?? ''),
      hostURL: json['hostURL'] as String? ?? 'https://portal.xuper-cineverse.tv',
      backupHostURL: json['backupHostURL'] as String?,
      username: json['username'] as String?,
      password: json['password'] as String?,
      snToken: json['snToken'] as String?,
      portalCode: json['portalCode'] as String?,
      isActive: json['isActive'] as bool? ?? false,
      latencyMs: json['latencyMs'] as int? ?? 28,
      channelCount: json['channelCount'] as int? ?? 120,
      vodCount: json['vodCount'] as int? ?? 0,
    );
  }
}

/// Electronic Program Guide (EPG) slot
class EPGProgram {
  final String id;
  final String title;
  final String subtitle;
  final String startTime;
  final String endTime;
  final double progress;
  final bool isLiveNow;

  const EPGProgram({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.startTime,
    required this.endTime,
    required this.progress,
    required this.isLiveNow,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'startTime': startTime,
        'endTime': endTime,
        'progress': progress,
        'isLiveNow': isLiveNow,
      };

  factory EPGProgram.fromJson(Map<String, dynamic> json) {
    return EPGProgram(
      id: json['id'] as String? ?? 'epg-0',
      title: json['title'] as String? ?? 'Transmisión en Vivo',
      subtitle: json['subtitle'] as String? ?? 'Programación Continua',
      startTime: json['startTime'] as String? ?? 'AHORA',
      endTime: json['endTime'] as String? ?? 'EN VIVO',
      progress: (json['progress'] as num?)?.toDouble() ?? 0.5,
      isLiveNow: json['isLiveNow'] as bool? ?? true,
    );
  }
}

/// Live TV Channel with EPG & HLS Stream URL
class LiveChannel {
  final String id;
  final int number;
  final String name;
  final String category;
  final String iconName;
  final String? logoURL;
  final String streamURL;
  final String qualityBadge;
  final EPGProgram currentProgram;
  final List<EPGProgram> upcomingPrograms;
  final bool isFavorite;

  const LiveChannel({
    required this.id,
    required this.number,
    required this.name,
    required this.category,
    required this.iconName,
    this.logoURL,
    required this.streamURL,
    required this.qualityBadge,
    required this.currentProgram,
    required this.upcomingPrograms,
    this.isFavorite = false,
  });

  LiveChannel copyWith({bool? isFavorite}) {
    return LiveChannel(
      id: id,
      number: number,
      name: name,
      category: category,
      iconName: iconName,
      logoURL: logoURL,
      streamURL: streamURL,
      qualityBadge: qualityBadge,
      currentProgram: currentProgram,
      upcomingPrograms: upcomingPrograms,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  IconData get iconData {
    switch (iconName) {
      case 'sports':
        return Icons.sports_soccer_rounded;
      case 'movie':
        return Icons.movie_filter_rounded;
      case 'news':
        return Icons.newspaper_rounded;
      case 'kids':
        return Icons.smart_toy_rounded;
      case 'scifi':
        return Icons.auto_awesome_rounded;
      default:
        return Icons.live_tv_rounded;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'number': number,
        'name': name,
        'category': category,
        'iconName': iconName,
        'logoURL': logoURL,
        'streamURL': streamURL,
        'qualityBadge': qualityBadge,
        'currentProgram': currentProgram.toJson(),
        'upcomingPrograms': upcomingPrograms.map((e) => e.toJson()).toList(),
        'isFavorite': isFavorite,
      };

  factory LiveChannel.fromJson(Map<String, dynamic> json) {
    return LiveChannel(
      id: json['id'] as String? ?? 'ch-1',
      number: json['number'] as int? ?? 101,
      name: json['name'] as String? ?? 'Canal CineVerse',
      category: json['category'] as String? ?? 'Entretenimiento',
      iconName: json['iconName'] as String? ?? 'tv',
      logoURL: json['logoURL'] as String?,
      streamURL: json['streamURL'] as String? ?? '',
      qualityBadge: json['qualityBadge'] as String? ?? 'FHD 60fps',
      currentProgram: json['currentProgram'] != null
          ? EPGProgram.fromJson(json['currentProgram'] as Map<String, dynamic>)
          : const EPGProgram(
              id: 'epg-def',
              title: 'En Vivo',
              subtitle: 'CineVerse TV',
              startTime: 'AHORA',
              endTime: '24/7',
              progress: 0.5,
              isLiveNow: true,
            ),
      upcomingPrograms: (json['upcomingPrograms'] as List<dynamic>?)
              ?.map((e) => EPGProgram.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }
}

enum VODContentType {
  movie('Película'),
  series('Serie');

  final String label;
  const VODContentType(this.label);

  static VODContentType fromString(String value) {
    return VODContentType.values.firstWhere(
      (e) => e.name == value || e.label == value,
      orElse: () => VODContentType.movie,
    );
  }
}

class EpisodeItem {
  final String id;
  final int episodeNumber;
  final String title;
  final String duration;
  final String synopsis;
  final String streamURL;
  final double watchProgress;

  const EpisodeItem({
    required this.id,
    required this.episodeNumber,
    required this.title,
    required this.duration,
    required this.synopsis,
    required this.streamURL,
    required this.watchProgress,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'episodeNumber': episodeNumber,
        'title': title,
        'duration': duration,
        'synopsis': synopsis,
        'streamURL': streamURL,
        'watchProgress': watchProgress,
      };

  factory EpisodeItem.fromJson(Map<String, dynamic> json) {
    return EpisodeItem(
      id: json['id'] as String? ?? 'ep-1',
      episodeNumber: json['episodeNumber'] as int? ?? 1,
      title: json['title'] as String? ?? 'Episodio 1',
      duration: json['duration'] as String? ?? '50m',
      synopsis: json['synopsis'] as String? ?? '',
      streamURL: json['streamURL'] as String? ?? '',
      watchProgress: (json['watchProgress'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class SeasonItem {
  final String id;
  final int seasonNumber;
  final String title;
  final List<EpisodeItem> episodes;

  const SeasonItem({
    required this.id,
    required this.seasonNumber,
    required this.title,
    required this.episodes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'seasonNumber': seasonNumber,
        'title': title,
        'episodes': episodes.map((e) => e.toJson()).toList(),
      };

  factory SeasonItem.fromJson(Map<String, dynamic> json) {
    return SeasonItem(
      id: json['id'] as String? ?? 's-1',
      seasonNumber: json['seasonNumber'] as int? ?? 1,
      title: json['title'] as String? ?? 'Temporada 1',
      episodes: (json['episodes'] as List<dynamic>?)
              ?.map((e) => EpisodeItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}

class VODItem {
  final String id;
  final String title;
  final String originalTitle;
  final VODContentType type;
  final int year;
  final double ratingScore;
  final String maturityRating;
  final String durationOrSeasons;
  final List<String> genres;
  final String synopsis;
  final String director;
  final List<String> cast;
  final String qualityBadge;
  final List<String> audioLanguages;
  final List<String> subtitleLanguages;
  final int posterAccentHex;
  final String posterIconName;
  final String streamURL;
  final List<SeasonItem> seasons;
  final double watchProgress;
  final bool isFavorite;
  final bool isTrending;
  final bool isOriginal;

  const VODItem({
    required this.id,
    required this.title,
    required this.originalTitle,
    required this.type,
    required this.year,
    required this.ratingScore,
    required this.maturityRating,
    required this.durationOrSeasons,
    required this.genres,
    required this.synopsis,
    required this.director,
    required this.cast,
    required this.qualityBadge,
    required this.audioLanguages,
    required this.subtitleLanguages,
    required this.posterAccentHex,
    required this.posterIconName,
    required this.streamURL,
    required this.seasons,
    required this.watchProgress,
    this.isFavorite = false,
    this.isTrending = false,
    this.isOriginal = false,
  });

  VODItem copyWith({
    double? watchProgress,
    bool? isFavorite,
  }) {
    return VODItem(
      id: id,
      title: title,
      originalTitle: originalTitle,
      type: type,
      year: year,
      ratingScore: ratingScore,
      maturityRating: maturityRating,
      durationOrSeasons: durationOrSeasons,
      genres: genres,
      synopsis: synopsis,
      director: director,
      cast: cast,
      qualityBadge: qualityBadge,
      audioLanguages: audioLanguages,
      subtitleLanguages: subtitleLanguages,
      posterAccentHex: posterAccentHex,
      posterIconName: posterIconName,
      streamURL: streamURL,
      seasons: seasons,
      watchProgress: watchProgress ?? this.watchProgress,
      isFavorite: isFavorite ?? this.isFavorite,
      isTrending: isTrending,
      isOriginal: isOriginal,
    );
  }

  IconData get posterIconData {
    switch (posterIconName) {
      case 'cpu':
        return Icons.memory_rounded;
      case 'waves':
        return Icons.waves_rounded;
      case 'speed':
        return Icons.speed_rounded;
      case 'stars':
        return Icons.auto_awesome_rounded;
      case 'shield':
        return Icons.security_rounded;
      default:
        return Icons.movie_creation_rounded;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'originalTitle': originalTitle,
        'type': type.name,
        'year': year,
        'ratingScore': ratingScore,
        'maturityRating': maturityRating,
        'durationOrSeasons': durationOrSeasons,
        'genres': genres,
        'synopsis': synopsis,
        'director': director,
        'cast': cast,
        'qualityBadge': qualityBadge,
        'audioLanguages': audioLanguages,
        'subtitleLanguages': subtitleLanguages,
        'posterAccentHex': posterAccentHex,
        'posterIconName': posterIconName,
        'streamURL': streamURL,
        'seasons': seasons.map((e) => e.toJson()).toList(),
        'watchProgress': watchProgress,
        'isFavorite': isFavorite,
        'isTrending': isTrending,
        'isOriginal': isOriginal,
      };

  factory VODItem.fromJson(Map<String, dynamic> json) {
    return VODItem(
      id: json['id'] as String? ?? 'vod-1',
      title: json['title'] as String? ?? 'Título CineVerse',
      originalTitle: json['originalTitle'] as String? ?? '',
      type: VODContentType.fromString(json['type'] as String? ?? 'movie'),
      year: json['year'] as int? ?? 2026,
      ratingScore: (json['ratingScore'] as num?)?.toDouble() ?? 9.0,
      maturityRating: json['maturityRating'] as String? ?? 'PG-13',
      durationOrSeasons: json['durationOrSeasons'] as String? ?? '2h 00m',
      genres: (json['genres'] as List<dynamic>?)?.cast<String>() ?? const [],
      synopsis: json['synopsis'] as String? ?? '',
      director: json['director'] as String? ?? '',
      cast: (json['cast'] as List<dynamic>?)?.cast<String>() ?? const [],
      qualityBadge: json['qualityBadge'] as String? ?? '4K HDR',
      audioLanguages:
          (json['audioLanguages'] as List<dynamic>?)?.cast<String>() ?? const [],
      subtitleLanguages:
          (json['subtitleLanguages'] as List<dynamic>?)?.cast<String>() ??
              const [],
      posterAccentHex: json['posterAccentHex'] as int? ?? 0xFFE50914,
      posterIconName: json['posterIconName'] as String? ?? 'movie',
      streamURL: json['streamURL'] as String? ?? '',
      seasons: (json['seasons'] as List<dynamic>?)
              ?.map((e) => SeasonItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      watchProgress: (json['watchProgress'] as num?)?.toDouble() ?? 0.0,
      isFavorite: json['isFavorite'] as bool? ?? false,
      isTrending: json['isTrending'] as bool? ?? false,
      isOriginal: json['isOriginal'] as bool? ?? false,
    );
  }
}

/// User Profile & Parental Control Config
class UserProfile {
  final String id;
  final String name;
  final String avatarIconName;
  final int avatarColorHex;
  final bool isKidsProfile;
  final String? parentalPin;
  final String maxMaturityLevel;
  final String preferredAudioLanguage;
  final String preferredSubtitleLanguage;

  const UserProfile({
    required this.id,
    required this.name,
    required this.avatarIconName,
    required this.avatarColorHex,
    required this.isKidsProfile,
    this.parentalPin,
    required this.maxMaturityLevel,
    required this.preferredAudioLanguage,
    required this.preferredSubtitleLanguage,
  });

  IconData get iconData {
    switch (avatarIconName) {
      case 'tv':
        return Icons.tv_rounded;
      case 'kids':
        return Icons.sentiment_very_satisfied_rounded;
      case 'star':
        return Icons.stars_rounded;
      default:
        return Icons.verified_user_rounded;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'avatarIconName': avatarIconName,
        'avatarColorHex': avatarColorHex,
        'isKidsProfile': isKidsProfile,
        'parentalPin': parentalPin,
        'maxMaturityLevel': maxMaturityLevel,
        'preferredAudioLanguage': preferredAudioLanguage,
        'preferredSubtitleLanguage': preferredSubtitleLanguage,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? 'prof-1',
      name: json['name'] as String? ?? 'Ángel',
      avatarIconName: json['avatarIconName'] as String? ?? 'user',
      avatarColorHex: json['avatarColorHex'] as int? ?? 0xFFE50914,
      isKidsProfile: json['isKidsProfile'] as bool? ?? false,
      parentalPin: json['parentalPin'] as String?,
      maxMaturityLevel: json['maxMaturityLevel'] as String? ?? '18+',
      preferredAudioLanguage:
          json['preferredAudioLanguage'] as String? ?? 'Español Latino',
      preferredSubtitleLanguage:
          json['preferredSubtitleLanguage'] as String? ?? 'Español',
    );
  }
}

/// Active Video Playback Context
class PlaybackContext {
  final String title;
  final String subtitle;
  final String streamURL;
  final bool isLiveStream;
  final String qualityBadge;
  final int? channelNumber;
  final String? vodItemId;

  const PlaybackContext({
    required this.title,
    required this.subtitle,
    required this.streamURL,
    required this.isLiveStream,
    required this.qualityBadge,
    this.channelNumber,
    this.vodItemId,
  });
}

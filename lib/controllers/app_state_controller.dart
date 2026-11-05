import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/iptv_parser_service.dart';
import '../services/xuper_portal_core_service.dart';

/// Controlador de estado global reactivo con persistencia en SharedPreferences
class AppStateController extends ChangeNotifier {
  static const _profilesKey = 'cv_flutter_ios_profiles_v1';
  static const _serversKey = 'cv_flutter_ios_servers_v1';
  static const _channelsKey = 'cv_flutter_ios_channels_v1';
  static const _vodKey = 'cv_flutter_ios_vod_v1';

  bool showSplash = true;
  bool showProfileSelector = false;
  int selectedTab = 0;

  List<UserProfile> profiles = const [
    UserProfile(
      id: 'prof-1',
      name: 'Ángel',
      avatarIconName: 'user',
      avatarColorHex: 0xFFE50914,
      isKidsProfile: false,
      parentalPin: '1234',
      maxMaturityLevel: '18+',
      preferredAudioLanguage: 'Español Latino (Dolby 5.1)',
      preferredSubtitleLanguage: 'Español',
    ),
    UserProfile(
      id: 'prof-2',
      name: 'Sala Cine 4K',
      avatarIconName: 'tv',
      avatarColorHex: 0xFF93000A,
      isKidsProfile: false,
      parentalPin: null,
      maxMaturityLevel: '18+',
      preferredAudioLanguage: 'Inglés Original (Atmos)',
      preferredSubtitleLanguage: 'Español',
    ),
    UserProfile(
      id: 'prof-3',
      name: 'CineVerse Kids',
      avatarIconName: 'kids',
      avatarColorHex: 0xFFFF6B6B,
      isKidsProfile: true,
      parentalPin: null,
      maxMaturityLevel: 'ATP',
      preferredAudioLanguage: 'Español Latino',
      preferredSubtitleLanguage: 'Desactivados',
    ),
  ];

  late UserProfile activeProfile;

  List<IPTVServerConfig> servers = const [
    IPTVServerConfig(
      id: 'srv-1',
      name: 'Xuper PortalCore Principal',
      type: ServerProtocolType.xuperPortalCore,
      hostURL: 'https://portal.xuper-cineverse.tv',
      backupHostURL: 'https://backup.tvmagis.net',
      username: 'angel.fuentes',
      password: '••••••••',
      snToken: 'XP-CV-9842-ACTIVE',
      portalCode: 'portal100001',
      isActive: true,
      latencyMs: 28,
      channelCount: 1240,
      vodCount: 18500,
    ),
    IPTVServerConfig(
      id: 'srv-2',
      name: 'Lista M3U8 Deportes & Cine',
      type: ServerProtocolType.m3uPlaylist,
      hostURL: 'https://iptv-org.github.io/iptv/languages/spa.m3u',
      isActive: false,
      latencyMs: 42,
      channelCount: 380,
      vodCount: 0,
    ),
    IPTVServerConfig(
      id: 'srv-3',
      name: 'Xtream Codes Premium 4K',
      type: ServerProtocolType.xtreamCodes,
      hostURL: 'http://line.cineverse-iptv.pro:8080',
      username: 'cineverse_vip',
      password: '••••••••',
      isActive: false,
      latencyMs: 35,
      channelCount: 950,
      vodCount: 9200,
    ),
  ];

  List<LiveChannel> liveChannels = IPTVParserService.defaultLiveChannels();
  List<VODItem> vodCatalog = IPTVParserService.defaultVODCatalog();

  String selectedLiveCategory = 'Todos';
  LiveChannel? selectedPreviewChannel;

  String searchQuery = '';
  String selectedSearchGenre = 'Todos';

  bool isSyncingServer = false;
  String? statusBannerMessage;
  List<String> resolvedDnsIps = const ['104.21.48.192', '172.67.189.44'];

  AppStateController() {
    activeProfile = profiles.first;
    selectedPreviewChannel = liveChannels.first;
    _loadPersistedState();
  }

  Future<void> _loadPersistedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final rawProfiles = prefs.getString(_profilesKey);
      if (rawProfiles != null) {
        final list = (jsonDecode(rawProfiles) as List<dynamic>)
            .map((e) => UserProfile.fromJson(e as Map<String, dynamic>))
            .toList();
        if (list.isNotEmpty) {
          profiles = list;
          activeProfile = list.first;
        }
      }

      final rawServers = prefs.getString(_serversKey);
      if (rawServers != null) {
        final list = (jsonDecode(rawServers) as List<dynamic>)
            .map((e) => IPTVServerConfig.fromJson(e as Map<String, dynamic>))
            .toList();
        if (list.isNotEmpty) {
          servers = list;
        }
      }

      final rawChannels = prefs.getString(_channelsKey);
      if (rawChannels != null) {
        final list = (jsonDecode(rawChannels) as List<dynamic>)
            .map((e) => LiveChannel.fromJson(e as Map<String, dynamic>))
            .toList();
        if (list.isNotEmpty) {
          liveChannels = list;
          selectedPreviewChannel = liveChannels.first;
        }
      }

      final rawVod = prefs.getString(_vodKey);
      if (rawVod != null) {
        final list = (jsonDecode(rawVod) as List<dynamic>)
            .map((e) => VODItem.fromJson(e as Map<String, dynamic>))
            .toList();
        if (list.isNotEmpty) {
          vodCatalog = list;
        }
      }

      notifyListeners();
    } catch (_) {
      // Usa estado inicial por defecto si no hay datos previos
    }
  }

  Future<void> saveState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _profilesKey,
        jsonEncode(profiles.map((e) => e.toJson()).toList()),
      );
      await prefs.setString(
        _serversKey,
        jsonEncode(servers.map((e) => e.toJson()).toList()),
      );
      await prefs.setString(
        _channelsKey,
        jsonEncode(liveChannels.map((e) => e.toJson()).toList()),
      );
      await prefs.setString(
        _vodKey,
        jsonEncode(vodCatalog.map((e) => e.toJson()).toList()),
      );
    } catch (_) {}
  }

  void completeSplash() {
    showSplash = false;
    notifyListeners();
  }

  void setTab(int index) {
    selectedTab = index;
    notifyListeners();
  }

  void toggleProfileGate(bool visible) {
    showProfileSelector = visible;
    notifyListeners();
  }

  void selectProfile(UserProfile profile) {
    activeProfile = profile;
    showProfileSelector = false;
    notifyListeners();
  }

  IPTVServerConfig get activeServer {
    return servers.firstWhere(
      (s) => s.isActive,
      orElse: () => servers.first,
    );
  }

  List<String> get liveCategories {
    final cats = liveChannels.map((c) => c.category).toSet().toList()..sort();
    return ['Todos', 'Favoritos', ...cats];
  }

  List<LiveChannel> get filteredLiveChannels {
    final baseList = activeProfile.isKidsProfile
        ? liveChannels.where((c) => c.category == 'Infantil').toList()
        : liveChannels;

    if (selectedLiveCategory == 'Todos') return baseList;
    if (selectedLiveCategory == 'Favoritos') {
      return baseList.where((c) => c.isFavorite).toList();
    }
    return baseList.where((c) => c.category == selectedLiveCategory).toList();
  }

  List<VODItem> get filteredVODCatalog {
    if (activeProfile.isKidsProfile) {
      return vodCatalog.where((v) => v.maturityRating == 'ATP').toList();
    }
    return vodCatalog;
  }

  VODItem get featuredHeroItem {
    final catalog = filteredVODCatalog;
    return catalog.isNotEmpty
        ? catalog.first
        : IPTVParserService.defaultVODCatalog().first;
  }

  List<VODItem> get continueWatchingItems {
    return filteredVODCatalog
        .where((v) => v.watchProgress > 0 && v.watchProgress < 1.0)
        .toList();
  }

  List<VODItem> get trendingItems {
    return filteredVODCatalog.where((v) => v.isTrending).toList();
  }

  List<VODItem> get originalSeriesItems {
    return filteredVODCatalog.where((v) => v.isOriginal).toList();
  }

  List<String> get availableGenres {
    final genres = <String>{};
    for (final item in filteredVODCatalog) {
      genres.addAll(item.genres);
    }
    final sorted = genres.toList()..sort();
    return ['Todos', ...sorted];
  }

  List<VODItem> get searchFilteredVOD {
    return filteredVODCatalog.where((item) {
      final matchesGenre = selectedSearchGenre == 'Todos' ||
          item.genres.contains(selectedSearchGenre);
      final q = searchQuery.trim().toLowerCase();
      final matchesQuery = q.isEmpty ||
          item.title.toLowerCase().contains(q) ||
          item.originalTitle.toLowerCase().contains(q) ||
          item.director.toLowerCase().contains(q) ||
          item.cast.any((actor) => actor.toLowerCase().contains(q));
      return matchesGenre && matchesQuery;
    }).toList();
  }

  List<LiveChannel> get searchFilteredChannels {
    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return filteredLiveChannels.where((ch) {
      return ch.name.toLowerCase().contains(q) ||
          ch.currentProgram.title.toLowerCase().contains(q) ||
          ch.category.toLowerCase().contains(q);
    }).toList();
  }

  void setLiveCategory(String category) {
    selectedLiveCategory = category;
    notifyListeners();
  }

  void setPreviewChannel(LiveChannel channel) {
    selectedPreviewChannel = channel;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void setSearchGenre(String genre) {
    selectedSearchGenre = genre;
    notifyListeners();
  }

  void toggleChannelFavorite(LiveChannel channel) {
    final idx = liveChannels.indexWhere((c) => c.id == channel.id);
    if (idx == -1) return;
    final updated = liveChannels[idx].copyWith(
      isFavorite: !liveChannels[idx].isFavorite,
    );
    final copy = List<LiveChannel>.from(liveChannels);
    copy[idx] = updated;
    liveChannels = copy;
    if (selectedPreviewChannel?.id == channel.id) {
      selectedPreviewChannel = updated;
    }
    notifyListeners();
    saveState();
  }

  void toggleVODFavorite(VODItem item) {
    final idx = vodCatalog.indexWhere((v) => v.id == item.id);
    if (idx == -1) return;
    final updated = vodCatalog[idx].copyWith(
      isFavorite: !vodCatalog[idx].isFavorite,
    );
    final copy = List<VODItem>.from(vodCatalog);
    copy[idx] = updated;
    vodCatalog = copy;
    notifyListeners();
    saveState();
  }

  void updateVODProgress(String? vodItemId, double progress) {
    if (vodItemId == null || !progress.isFinite) return;
    final idx = vodCatalog.indexWhere((v) => v.id == vodItemId);
    if (idx == -1) return;
    final clamped = progress.clamp(0.05, 0.98);
    final copy = List<VODItem>.from(vodCatalog);
    copy[idx] = copy[idx].copyWith(watchProgress: clamped);
    vodCatalog = copy;
    notifyListeners();
    saveState();
  }

  Future<void> activateServer(IPTVServerConfig server) async {
    servers = servers
        .map((s) => s.copyWith(isActive: s.id == server.id))
        .toList();
    notifyListeners();
    saveState();
    await syncServer(server);
  }

  void deleteServer(IPTVServerConfig server) {
    if (servers.length <= 1) return;
    final copy = servers.where((s) => s.id != server.id).toList();
    if (!copy.any((s) => s.isActive) && copy.isNotEmpty) {
      copy[0] = copy[0].copyWith(isActive: true);
    }
    servers = copy;
    notifyListeners();
    saveState();
  }

  Future<void> syncServer(IPTVServerConfig server) async {
    isSyncingServer = true;
    statusBannerMessage = 'Sincronizando ${server.name}...';
    notifyListeners();

    final latency = await XuperPortalCoreService.instance
        .measureServerLatency(server.hostURL);
    final dnsIps = await XuperPortalCoreService.instance
        .resolveHostViaGoogleDNS(server.hostURL);
    if (dnsIps.isNotEmpty) {
      resolvedDnsIps = dnsIps;
    }

    var updatedCount = server.channelCount;

    switch (server.type) {
      case ServerProtocolType.m3uPlaylist:
        try {
          final remote = await IPTVParserService.instance.fetchRemoteM3U(
            server.hostURL,
            fallbackName: server.name,
          );
          if (remote.isNotEmpty) {
            liveChannels = [
              ...IPTVParserService.defaultLiveChannels(),
              ...remote.take(60),
            ];
            updatedCount = remote.length;
          }
        } catch (_) {}
      case ServerProtocolType.xtreamCodes:
        try {
          final xtream = await IPTVParserService.instance
              .fetchXtreamCodesLiveStreams(server);
          if (xtream.isNotEmpty) {
            liveChannels = [
              ...IPTVParserService.defaultLiveChannels(),
              ...xtream,
            ];
            updatedCount = xtream.length;
          }
        } catch (_) {}
      case ServerProtocolType.xuperPortalCore:
        await XuperPortalCoreService.instance.requestPortalEndpoint(
          server: server,
          endpoint: XuperEndpoint.getHome,
          payload: const {'pageSize': '30'},
        );
    }

    servers = servers.map((s) {
      if (s.id == server.id) {
        return s.copyWith(latencyMs: latency, channelCount: updatedCount);
      }
      return s;
    }).toList();

    isSyncingServer = false;
    statusBannerMessage = 'Conectado a ${server.name} ($latency ms)';
    notifyListeners();
    saveState();
  }

  void addCustomServer({
    required String name,
    required ServerProtocolType type,
    required String hostURL,
    String? username,
    String? password,
    String? m3uRawText,
  }) {
    var addedChannelsCount = 120;
    if (m3uRawText != null && m3uRawText.trim().isNotEmpty) {
      final parsed = IPTVParserService.instance.parseM3U(
        m3uRawText,
        startingChannelNumber: 200 + liveChannels.length,
      );
      if (parsed.isNotEmpty) {
        liveChannels = [...liveChannels, ...parsed];
        addedChannelsCount = parsed.length;
      }
    }

    final randomToken = 1000 + Random().nextInt(8999);
    final newServer = IPTVServerConfig(
      id: 'srv-${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim().isEmpty ? 'Servidor CineVerse' : name.trim(),
      type: type,
      hostURL: hostURL.trim().isEmpty
          ? 'https://portal.xuper-cineverse.tv'
          : hostURL.trim(),
      username: username,
      password: password,
      snToken: type == ServerProtocolType.xuperPortalCore
          ? 'XP-IOS-$randomToken'
          : null,
      portalCode: type == ServerProtocolType.xuperPortalCore
          ? 'portal100001'
          : null,
      isActive: true,
      latencyMs: 22 + Random().nextInt(24),
      channelCount: addedChannelsCount,
      vodCount: type == ServerProtocolType.m3uPlaylist ? 0 : 4500,
    );

    servers = [
      newServer,
      ...servers.map((s) => s.copyWith(isActive: false)),
    ];
    notifyListeners();
    saveState();
    syncServer(newServer);
  }

  void addProfile({
    required String name,
    required String avatarIconName,
    required int colorHex,
    required bool isKids,
    String? pin,
  }) {
    final newProfile = UserProfile(
      id: 'prof-${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim().isEmpty ? 'Nuevo Perfil' : name.trim(),
      avatarIconName: avatarIconName,
      avatarColorHex: colorHex,
      isKidsProfile: isKids,
      parentalPin: (pin != null && pin.trim().isNotEmpty) ? pin.trim() : null,
      maxMaturityLevel: isKids ? 'ATP' : '18+',
      preferredAudioLanguage: 'Español Latino (Dolby 5.1)',
      preferredSubtitleLanguage: 'Español',
    );
    profiles = [...profiles, newProfile];
    activeProfile = newProfile;
    notifyListeners();
    saveState();
  }
}


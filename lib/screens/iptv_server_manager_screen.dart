import 'package:flutter/material.dart';
import '../controllers/app_state_controller.dart';
import '../models/models.dart';
import '../services/xuper_portal_core_service.dart';
import '../theme/cinematic_glass_theme.dart';

/// Gestor de Servidores PortalCore, Listas IPTV M3U8 y Xtream Codes API
class IPTVServerManagerScreen extends StatelessWidget {
  final AppStateController appState;

  const IPTVServerManagerScreen({
    super.key,
    required this.appState,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Servidores & Listas IPTV',
                    style: TextStyle(
                      color: CVColors.textPrimary,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Xuper PortalCore v8 • Listas M3U8 • Xtream Codes',
                    style: TextStyle(
                      color: CVColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            CrimsonPrimaryButton(
              label: 'Añadir',
              icon: Icons.add_rounded,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              onPressed: () => _openAddServerSheet(context),
            ),
          ],
        ),
        if (appState.statusBannerMessage != null) ...[
          const SizedBox(height: 12),
          GlassCard(
            borderRadius: 12,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                if (appState.isSyncingServer)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: CVColors.primaryCrimson,
                    ),
                  )
                else
                  const Icon(
                    Icons.check_circle_rounded,
                    color: CVColors.successGreen,
                    size: 18,
                  ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    appState.statusBannerMessage!,
                    style: const TextStyle(
                      color: CVColors.textPrimary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        ...appState.servers.map(
          (server) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildServerCard(server),
          ),
        ),
        const SizedBox(height: 14),
        _buildApkArchitectureDiagnosticCard(),
      ],
    );
  }

  Widget _buildServerCard(IPTVServerConfig server) {
    return GlassCard(
      borderRadius: 16,
      isHighlighted: server.isActive,
      padding: const EdgeInsets.all(15),
      onTap: () => appState.activateServer(server),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: server.isActive ? CVColors.crimsonGradient : null,
                  color: server.isActive ? null : CVColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.dns_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      server.name,
                      style: const TextStyle(
                        color: CVColors.textPrimary,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      server.hostURL,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: CVColors.textSecondary,
                        fontSize: 11.5,
                        fontFamily: 'Courier',
                      ),
                    ),
                  ],
                ),
              ),
              if (server.isActive)
                const CVBadge(
                  text: 'ACTIVO',
                  backgroundColor: Color(0x3330D158),
                  textColor: CVColors.successGreen,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              CVBadge.quality(server.type.label),
              CVBadge(
                text: '${server.latencyMs} ms',
                backgroundColor: Colors.white10,
                textColor: CVColors.textPrimary,
              ),
              CVBadge(
                text: '${server.channelCount} Canales',
                backgroundColor: Colors.white10,
                textColor: CVColors.textSecondary,
              ),
              if (server.vodCount > 0)
                CVBadge(
                  text: '${server.vodCount} VOD',
                  backgroundColor: Colors.white10,
                  textColor: CVColors.textSecondary,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SecondaryGlassButton(
                label: 'Sincronizar',
                icon: Icons.sync_rounded,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                onPressed: () => appState.syncServer(server),
              ),
              const Spacer(),
              if (appState.servers.length > 1)
                IconButton(
                  onPressed: () => appState.deleteServer(server),
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: CVColors.textMuted,
                    size: 20,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildApkArchitectureDiagnosticCard() {
    return GlassCard(
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.verified_rounded,
                color: CVColors.primaryCrimson,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Núcleo Nativo Xuper TV APK (v4.34.4)',
                style: TextStyle(
                  color: CVColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'DNS-over-HTTPS Google Resolver activo: ${appState.resolvedDnsIps.join(", ")}',
            style: const TextStyle(
              color: CVColors.softCoral,
              fontSize: 11.5,
              fontFamily: 'Courier',
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Rutas TheRouter & Endpoints PortalCore integrados desde el APK:',
            style: TextStyle(
              color: CVColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          ...XuperPortalCoreService.theRouterTable.map(
            (route) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(
                '• ${route["path"]} → ${route["flutterScreen"]}',
                style: const TextStyle(
                  color: CVColors.textMuted,
                  fontSize: 11,
                  fontFamily: 'Courier',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openAddServerSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    final userCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final m3uCtrl = TextEditingController();
    var selectedType = ServerProtocolType.m3uPlaylist;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: CVColors.surfaceHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Añadir Servidor o Lista M3U8',
                      style: TextStyle(
                        color: CVColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<ServerProtocolType>(
                      value: selectedType,
                      dropdownColor: CVColors.surfaceContainer,
                      style: const TextStyle(color: CVColors.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Protocolo',
                        labelStyle: TextStyle(color: CVColors.textSecondary),
                      ),
                      items: ServerProtocolType.values
                          .map(
                            (t) => DropdownMenuItem(
                              value: t,
                              child: Text(t.label),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => selectedType = val);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: nameCtrl,
                      style: const TextStyle(color: CVColors.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Nombre del Servidor / Lista',
                        labelStyle: TextStyle(color: CVColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: urlCtrl,
                      style: const TextStyle(color: CVColors.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'URL del Servidor o enlace .m3u8',
                        labelStyle: TextStyle(color: CVColors.textSecondary),
                      ),
                    ),
                    if (selectedType != ServerProtocolType.m3uPlaylist) ...[
                      const SizedBox(height: 10),
                      TextField(
                        controller: userCtrl,
                        style: const TextStyle(color: CVColors.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Usuario / Portal SN',
                          labelStyle: TextStyle(color: CVColors.textSecondary),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: passCtrl,
                        obscureText: true,
                        style: const TextStyle(color: CVColors.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Contraseña',
                          labelStyle: TextStyle(color: CVColors.textSecondary),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 10),
                      TextField(
                        controller: m3uCtrl,
                        maxLines: 3,
                        style: const TextStyle(
                          color: CVColors.textPrimary,
                          fontSize: 12,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'O pega bloques #EXTM3U directamente',
                          labelStyle: TextStyle(color: CVColors.textSecondary),
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    CrimsonPrimaryButton(
                      label: 'Guardar y Conectar',
                      icon: Icons.check_rounded,
                      isExpanded: true,
                      onPressed: () {
                        appState.addCustomServer(
                          name: nameCtrl.text,
                          type: selectedType,
                          hostURL: urlCtrl.text,
                          username: userCtrl.text,
                          password: passCtrl.text,
                          m3uRawText: m3uCtrl.text,
                        );
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}


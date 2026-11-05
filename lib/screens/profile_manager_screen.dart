import 'package:flutter/material.dart';
import '../controllers/app_state_controller.dart';
import '../models/models.dart';
import '../theme/cinematic_glass_theme.dart';

/// Port en Flutter para iOS de `com.mine.ui.activity.UserCenterActivity`
class ProfileManagerScreen extends StatelessWidget {
  final AppStateController appState;

  const ProfileManagerScreen({
    super.key,
    required this.appState,
  });

  @override
  Widget build(BuildContext context) {
    final active = appState.activeProfile;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Perfiles & Control Parental',
                  style: TextStyle(
                    color: CVColors.textPrimary,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Gestión de cuenta CineVerse • PIN Parental',
                  style: TextStyle(
                    color: CVColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            CrimsonPrimaryButton(
              label: 'Nuevo Perfil',
              icon: Icons.person_add_alt_1_rounded,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              onPressed: () => _openCreateProfileModal(context),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GlassCard(
          borderRadius: 18,
          isHighlighted: true,
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(active.avatarColorHex).withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Color(active.avatarColorHex),
                    width: 2,
                  ),
                ),
                child: Icon(
                  active.iconData,
                  color: Color(active.avatarColorHex),
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          active.name,
                          style: const TextStyle(
                            color: CVColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 8),
                        CVBadge(
                          text: active.isKidsProfile
                              ? 'MODO KIDS (ATP)'
                              : 'CLASIFICACIÓN ${active.maxMaturityLevel}',
                          backgroundColor: CVColors.primaryCrimson,
                          textColor: Colors.white,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Audio: ${active.preferredAudioLanguage} • Subtítulos: ${active.preferredSubtitleLanguage}',
                      style: const TextStyle(
                        color: CVColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'Cambiar de Perfil',
          style: TextStyle(
            color: CVColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        ...appState.profiles.map(
          (profile) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GlassCard(
              borderRadius: 14,
              isHighlighted: profile.id == active.id,
              padding: const EdgeInsets.all(13),
              onTap: () => _handleProfileSwitch(context, profile),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        Color(profile.avatarColorHex).withValues(alpha: 0.25),
                    child: Icon(
                      profile.iconData,
                      color: Color(profile.avatarColorHex),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.name,
                          style: const TextStyle(
                            color: CVColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          profile.isKidsProfile
                              ? 'Catálogo Infantil Filtrado (ATP)'
                              : 'Catálogo Completo 4K HDR (${profile.maxMaturityLevel})',
                          style: const TextStyle(
                            color: CVColors.textSecondary,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (profile.parentalPin != null)
                    const Icon(
                      Icons.lock_outline_rounded,
                      color: CVColors.softCoral,
                      size: 18,
                    ),
                  const SizedBox(width: 8),
                  if (profile.id == active.id)
                    const Icon(
                      Icons.check_circle_rounded,
                      color: CVColors.primaryCrimson,
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleProfileSwitch(BuildContext context, UserProfile profile) {
    if (profile.parentalPin == null || profile.id == appState.activeProfile.id) {
      appState.selectProfile(profile);
      return;
    }

    final pinCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: CVColors.surfaceHigh,
          title: Text(
            'PIN Parental • ${profile.name}',
            style: const TextStyle(
              color: CVColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: TextField(
            controller: pinCtrl,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 4,
            style: const TextStyle(color: CVColors.textPrimary),
            decoration: const InputDecoration(
              hintText: 'Ingresa el PIN (ej. 1234)',
              hintStyle: TextStyle(color: CVColors.textMuted),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: CVColors.primaryCrimson,
              ),
              onPressed: () {
                if (pinCtrl.text.trim() == profile.parentalPin) {
                  appState.selectProfile(profile);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('PIN incorrecto. Intenta con 1234.'),
                    ),
                  );
                }
              },
              child: const Text(
                'Desbloquear',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _openCreateProfileModal(BuildContext context) {
    final nameCtrl = TextEditingController();
    final pinCtrl = TextEditingController();
    var isKids = false;

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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Crear Nuevo Perfil CineVerse',
                    style: TextStyle(
                      color: CVColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameCtrl,
                    style: const TextStyle(color: CVColors.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Nombre del Perfil',
                      labelStyle: TextStyle(color: CVColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeThumbColor: CVColors.primaryCrimson,
                    title: const Text(
                      'Perfil Infantil (CineVerse Kids ATP)',
                      style: TextStyle(
                        color: CVColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                    value: isKids,
                    onChanged: (v) => setModalState(() => isKids = v),
                  ),
                  if (!isKids)
                    TextField(
                      controller: pinCtrl,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      obscureText: true,
                      style: const TextStyle(color: CVColors.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'PIN Parental de 4 dígitos (Opcional)',
                        labelStyle: TextStyle(color: CVColors.textSecondary),
                      ),
                    ),
                  const SizedBox(height: 14),
                  CrimsonPrimaryButton(
                    label: 'Guardar Perfil',
                    icon: Icons.check_rounded,
                    isExpanded: true,
                    onPressed: () {
                      appState.addProfile(
                        name: nameCtrl.text,
                        avatarIconName: isKids ? 'kids' : 'star',
                        colorHex: isKids ? 0xFFFF6B6B : 0xFFE50914,
                        isKids: isKids,
                        pin: pinCtrl.text,
                      );
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}


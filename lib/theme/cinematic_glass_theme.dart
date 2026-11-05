import 'dart:ui';
import 'package:flutter/material.dart';

/// CineVerse "Cinematic Glass" Design System
/// Basado en Stream/cinematic_glass/DESIGN.md y Xuper_TV/res/values/colors.xml
class CVColors {
  CVColors._();

  /// Base Void / Background: #0A0A0C
  static const Color background = Color(0xFF0A0A0C);

  /// Elevated Surface 1 (Navigation / Sidebars): #131315
  static const Color surfaceLow = Color(0xFF131315);

  /// Elevated Surface 2 (Cards / Panels): #1C1C24
  static const Color surfaceContainer = Color(0xFF1C1C24);

  /// Elevated Surface 3 (Hover / Active / Modals): #242430
  static const Color surfaceHigh = Color(0xFF242430);

  /// Highest Surface (Focused / Highlighted): #2A2A36
  static const Color surfaceBright = Color(0xFF2A2A36);

  /// Primary Accent (CineVerse Crimson): #E50914
  static const Color primaryCrimson = Color(0xFFE50914);

  /// Deep Crimson (Gradient End): #93000A
  static const Color deepCrimson = Color(0xFF93000A);

  /// Soft Coral Highlight: #FFB4AA
  static const Color softCoral = Color(0xFFFFB4AA);

  /// Primary Text: #F5F5F7
  static const Color textPrimary = Color(0xFFF5F5F7);

  /// Secondary Text: #9E9EA9
  static const Color textSecondary = Color(0xFF9E9EA9);

  /// Muted / Technical Text: #8E8E9F
  static const Color textMuted = Color(0xFF8E8E9F);

  /// Status Colors
  static const Color successGreen = Color(0xFF30D158);
  static const Color warningAmber = Color(0xFFFFD60A);

  /// Gradients
  static const LinearGradient crimsonGradient = LinearGradient(
    colors: [primaryCrimson, deepCrimson],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroVignette = LinearGradient(
    colors: [
      Colors.transparent,
      Color(0x990A0A0C),
      background,
    ],
    stops: [0.0, 0.58, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primaryCrimson,
      colorScheme: const ColorScheme.dark(
        primary: primaryCrimson,
        secondary: softCoral,
        surface: surfaceContainer,
        onPrimary: textPrimary,
        onSecondary: background,
        onSurface: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceHigh,
        contentTextStyle: const TextStyle(color: textPrimary, fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Reusable Translucent Glass Card matching Xuper_TV shape_btn_normal.xml & DESIGN.md
class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool isHighlighted;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 14.0,
    this.padding,
    this.isHighlighted = false,
    this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor ??
                CVColors.surfaceContainer.withValues(alpha: 0.86),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: isHighlighted
                  ? CVColors.primaryCrimson.withValues(alpha: 0.90)
                  : Colors.white.withValues(alpha: 0.10),
              width: isHighlighted ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isHighlighted
                    ? CVColors.primaryCrimson.withValues(alpha: 0.25)
                    : Colors.black.withValues(alpha: 0.45),
                blurRadius: isHighlighted ? 16 : 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: cardContent,
      );
    }
    return cardContent;
  }
}

/// Primary CTA Button with Crimson Gradient (#E50914 -> #93000A)
class CrimsonPrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool isExpanded;
  final EdgeInsetsGeometry padding;

  const CrimsonPrimaryButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.isExpanded = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
  });

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, color: CVColors.textPrimary, size: 18),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: CVColors.textPrimary,
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          gradient: CVColors.crimsonGradient,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.22),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: CVColors.primaryCrimson.withValues(alpha: 0.38),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: content,
      ),
    );
  }
}

/// Secondary Glass Button matching Xuper_TV shape_btn_normal.xml
class SecondaryGlassButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final EdgeInsetsGeometry padding;

  const SecondaryGlassButton({
    super.key,
    required this.label,
    this.icon,
    required this.onPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: CVColors.surfaceHigh.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.14),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: CVColors.textPrimary, size: 17),
              const SizedBox(width: 7),
            ],
            Text(
              label,
              style: const TextStyle(
                color: CVColors.textPrimary,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Quality / Metadata Pill Badge (e.g., "4K HDR", "EN VIVO", "Dolby Atmos")
class CVBadge extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;

  const CVBadge({
    super.key,
    required this.text,
    this.backgroundColor = const Color(0x33E50914),
    this.textColor = CVColors.textPrimary,
    this.borderColor,
  });

  factory CVBadge.live({String text = 'EN VIVO'}) {
    return CVBadge(
      text: text,
      backgroundColor: CVColors.primaryCrimson,
      textColor: Colors.white,
    );
  }

  factory CVBadge.quality(String text) {
    return CVBadge(
      text: text,
      backgroundColor: CVColors.surfaceBright.withValues(alpha: 0.85),
      textColor: CVColors.softCoral,
      borderColor: Colors.white.withValues(alpha: 0.16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: borderColor != null ? Border.all(color: borderColor!) : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}


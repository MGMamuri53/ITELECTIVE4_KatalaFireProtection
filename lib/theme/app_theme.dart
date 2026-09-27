import 'package:flutter/material.dart';

/// Centralized design tokens for the Katala design system.
/// Keeps the red brand family while refining it into a consistent scale.
class AppColors {
  AppColors._();

  // Brand — red family
  static const Color brand = Color(0xFFB71C1C);
  static const Color brandBright = Color(0xFFE53935);
  static const Color brandDark = Color(0xFF8C1212);
  static const Color brandTint = Color(0xFFFBECEC);
  static const Color brandTintBorder = Color(0xFFF4C7C6);

  // Typography
  static const Color ink = Color(0xFF181A1F);
  static const Color inkSoft = Color(0xFF393D44);
  static const Color inkMuted = Color(0xFF6A6F78);
  static const Color inkFaint = Color(0xFF9AA0AA);

  // Surfaces
  static const Color canvas = Color(0xFFF4F5F7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFEFF0F2);
  static const Color divider = Color(0xFFE4E6EA);
  static const Color nav = Color(0xFF15181E);

  // Status
  static const Color success = Color(0xFF2E7D32);
  static const Color successTint = Color(0xFFEBF5EB);
  static const Color warning = Color(0xFFB26A00);
  static const Color warningTint = Color(0xFFFFF4E5);
  static const Color danger = Color(0xFFC62828);
  static const Color dangerTint = Color(0xFFFBECEC);
}

/// Shared UI recipes so every screen renders the same "Katala" look.
class KataUi {
  KataUi._();

  static const double radiusCard = 16;

  /// Standard elevated card surface used across the app.
  static BoxDecoration cardBox() => BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(radiusCard),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A12151C),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      );

  /// Subtle inset well used for search bars, code blocks, notes.
  static BoxDecoration insetBox() => BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(radiusCard),
        border: Border.all(color: AppColors.divider),
      );

  /// Rounded square icon tile used inside cards and stat tiles.
  static Widget iconTile(IconData icon, {Color background = AppColors.brandTint, Color foreground = AppColors.brand, double size = 20}) =>
      Container(
        width: size + 24,
        height: size + 24,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: foreground, size: size),
      );

  /// Consistent section heading: title + optional muted subtitle.
  static Widget sectionHeader(String title, {String? subtitle, Widget? trailing}) {
    final titleWidget = Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: AppColors.ink,
      ),
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (subtitle == null)
          titleWidget
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleWidget,
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 13, color: AppColors.inkMuted),
              ),
            ],
          ),
        const Spacer(),
        ?trailing,
      ],
    );
  }
}

class KataTheme {
  KataTheme._();

  static const double radiusControl = 12;
  static const double radiusCard = 16;
  static const double radiusDialog = 20;

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.brand,
      primary: AppColors.brand,
      onPrimary: Colors.white,
      primaryContainer: AppColors.brandTint,
      onPrimaryContainer: AppColors.brandDark,
      secondary: AppColors.brandBright,
      onSecondary: Colors.white,
      error: AppColors.danger,
      onError: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.ink,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.canvas,
      splashFactory: InkSparkle.splashFactory,
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        headlineSmall: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: AppColors.ink,
        ),
        titleLarge: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: AppColors.ink,
        ),
        titleMedium: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          color: AppColors.ink,
        ),
        titleSmall: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.inkSoft,
        ),
        bodyLarge: const TextStyle(fontSize: 16, height: 1.5, color: AppColors.inkSoft),
        bodyMedium: const TextStyle(fontSize: 14, height: 1.45, color: AppColors.inkSoft),
        bodySmall: const TextStyle(fontSize: 12, height: 1.4, color: AppColors.inkMuted),
        labelLarge: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        labelMedium: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Color(0x14000000),
        iconTheme: IconThemeData(color: AppColors.ink),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: AppColors.ink,
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusCard)),
          side: BorderSide(color: AppColors.divider),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.brand,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(radiusControl)),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.brand,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          side: const BorderSide(color: AppColors.brand),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(radiusControl)),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.brand,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(radiusControl)),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: AppColors.inkFaint, fontSize: 14),
        labelStyle: const TextStyle(color: AppColors.inkMuted, fontSize: 14),
        floatingLabelStyle: const TextStyle(color: AppColors.brand),
        helperStyle: const TextStyle(color: AppColors.inkMuted, fontSize: 12),
        counterStyle: const TextStyle(color: AppColors.inkFaint, fontSize: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusControl),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusControl),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusControl),
          borderSide: const BorderSide(color: AppColors.brand, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusControl),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusControl),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.6),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(radiusDialog)),
        ),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: AppColors.ink,
        ),
        contentTextStyle: TextStyle(fontSize: 14, height: 1.45, color: AppColors.inkSoft),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.nav,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusControl),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.surfaceMuted,
        selectedColor: AppColors.brandTint,
        side: const BorderSide(color: AppColors.divider),
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.inkSoft),
        secondaryLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.brand,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.brand,
        unselectedLabelColor: AppColors.inkMuted,
        dividerColor: AppColors.divider,
        indicatorColor: AppColors.brand,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        elevation: 0,
        height: 68,
        indicatorColor: AppColors.brandTint,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? AppColors.brand : AppColors.inkMuted);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? AppColors.brand : AppColors.inkMuted,
          );
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.brand,
        linearTrackColor: AppColors.surfaceMuted,
        circularTrackColor: AppColors.surfaceMuted,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.brand
              : Colors.transparent,
        ),
        checkColor: const WidgetStatePropertyAll(Colors.white),
        side: const BorderSide(color: AppColors.inkMuted, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStatePropertyAll(AppColors.brand),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.brand
              : AppColors.surfaceMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.brandTint
              : AppColors.divider,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: const Color(0x24000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusControl),
          side: const BorderSide(color: AppColors.divider),
        ),
        textStyle: const TextStyle(fontSize: 14, color: AppColors.inkSoft),
      ),
      tooltipTheme: const TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.nav,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        textStyle: TextStyle(color: Colors.white, fontSize: 12),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusDialog)),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: AppColors.inkMuted,
        textColor: AppColors.inkSoft,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusControl),
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.brand,
        selectionColor: AppColors.brandTint,
        selectionHandleColor: AppColors.brand,
      ),
    );
  }
}
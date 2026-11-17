import 'package:flutter/material.dart';

/// Paleta semântica do Design System do AgendaFácil em conformidade com WCAG 2.1 AA.
abstract final class AppColors {
  /// Cor primária da marca para ações principais e estados ativos.
  static const Color primary = Color(0xFF1A73E8);

  /// Variante escura da cor primária para estados pressionados e alto contraste.
  static const Color primaryDark = Color(0xFF1557B0);

  /// Fundo suave para chips selecionados, selos e destaques sutis.
  static const Color primaryContainer = Color(0xFFD2E3FC);

  /// Fundo geral da aplicação para reduzir fadiga visual.
  static const Color background = Color(0xFFF8F9FA);

  /// Superfície neutra de cartões, folhas modais e campos de entrada.
  static const Color surface = Color(0xFFFFFFFF);

  /// Cor de bordas delimitadoras e divisores de listas.
  static const Color outline = Color(0xFFE0E0E0);

  /// Texto principal com alto contraste sobre superfícies claras.
  static const Color onSurface = Color(0xFF202124);

  /// Texto secundário para metadados, subtítulos e durações.
  static const Color onSurfaceVariant = Color(0xFF5F6368);

  /// Cor semântica para confirmações e feedback positivo.
  static const Color success = Color(0xFF34A853);

  /// Cor semântica para alertas, avaliações e atendimentos em andamento.
  static const Color warning = Color(0xFFFBBC04);

  /// Cor semântica para erros, bloqueios de horário e cancelamentos.
  static const Color error = Color(0xFFEA4335);

  /// Alias semântico para [outline].
  static const Color border = outline;

  /// Alias semântico para [onSurface].
  static const Color textPrimary = onSurface;

  /// Alias semântico para [onSurfaceVariant].
  static const Color textSecondary = onSurfaceVariant;

  /// Superfície sutil para agrupamentos e barras de busca.
  static const Color surfaceVariant = Color(0xFFF1F3F4);

  /// Alias semântico para [success].
  static const Color secondary = success;

  /// Fundo suave para estados de confirmação.
  static const Color secondaryContainer = Color(0xFFE6F4EA);

  /// Fundo suave para alertas e status em andamento.
  static const Color warningContainer = Color(0xFFFEF7E0);

  /// Cor de texto e ícone com contraste acessível sobre [warningContainer].
  static const Color warningForeground = Color(0xFFB06000);

  /// Fundo suave para alertas de erro e cancelamento.
  static const Color errorContainer = Color(0xFFFCE8E6);

  /// Fundo neutro para estados finalizados ou horários indisponíveis.
  static const Color neutralContainer = Color(0xFFE8EAED);
}

/// Durações padronizadas de microinterações e transições de rota.
abstract final class AppDurations {
  /// Resposta tátil e visual imediata abaixo de 100 ms.
  static const Duration instantFeedback = Duration(milliseconds: 90);

  /// Transição fluida entre telas mantendo continuidade espacial.
  static const Duration routeTransition = Duration(milliseconds: 220);
}

/// Constantes geométricas baseadas no Grid Base 8 e na Lei de Fitts.
abstract final class AppDimensions {
  /// Dimensão mínima obrigatória de alvos interativos (48x48 dp).
  static const double minTouchTarget = 48.0;

  /// Altura mínima ergonômica para botões primários na zona do polegar.
  static const double primaryButtonHeight = 56.0;

  /// Margem horizontal padrão das telas.
  static const double screenPadding = 16.0;

  /// Espaçamento extra pequeno na escala Base 8.
  static const double spacingXs = 8.0;

  /// Espaçamento pequeno na escala Base 8.
  static const double spacingSm = 16.0;

  /// Espaçamento médio na escala Base 8.
  static const double spacingMd = 24.0;

  /// Espaçamento grande na escala Base 8.
  static const double spacingLg = 32.0;

  /// Raio de borda padrão para cartões e painéis.
  static const double cardRadius = 16.0;

  /// Raio de borda padrão para botões, chips e campos de texto.
  static const double controlRadius = 12.0;
}

/// Configuração centralizada do tema Material 3 do AgendaFácil.
abstract final class AppTheme {
  /// Tema claro principal com tipografia padronizada e alvos acessíveis.
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.secondary,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.outline,
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.error,
      brightness: Brightness.light,
    );

    final baseButtonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.controlRadius),
    );

    final primaryButtonStyle = ButtonStyle(
      minimumSize: WidgetStateProperty.all(
        const Size(
          AppDimensions.minTouchTarget,
          AppDimensions.primaryButtonHeight,
        ),
      ),
      tapTargetSize: MaterialTapTargetSize.padded,
      elevation: WidgetStateProperty.all(0),
      shape: WidgetStateProperty.all(baseButtonShape),
      textStyle: WidgetStateProperty.all(
        const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return AppColors.neutralContainer;
        }
        if (states.contains(WidgetState.pressed) ||
            states.contains(WidgetState.hovered)) {
          return AppColors.primaryDark;
        }
        return AppColors.primary;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return AppColors.onSurfaceVariant;
        }
        return Colors.white;
      }),
      overlayColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.pressed)) {
          return AppColors.primaryDark.withAlpha(48);
        }
        return null;
      }),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 24 / 18,
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          height: 32 / 24,
          color: AppColors.onSurface,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 24 / 18,
          color: AppColors.onSurface,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 22 / 16,
          color: AppColors.onSurface,
        ),
        bodyLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 20 / 14,
          color: AppColors.onSurface,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 20 / 14,
          color: AppColors.onSurfaceVariant,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 16 / 12,
          color: AppColors.onSurfaceVariant,
        ),
        labelLarge: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          side: const BorderSide(color: AppColors.outline),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.outline,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingSm,
          vertical: AppDimensions.spacingSm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.controlRadius),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.controlRadius),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.controlRadius),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.controlRadius),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(style: primaryButtonStyle),
      elevatedButtonTheme: ElevatedButtonThemeData(style: primaryButtonStyle),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(
            AppDimensions.minTouchTarget,
            AppDimensions.minTouchTarget,
          ),
          tapTargetSize: MaterialTapTargetSize.padded,
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: baseButtonShape,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(
            AppDimensions.minTouchTarget,
            AppDimensions.minTouchTarget,
          ),
          tapTargetSize: MaterialTapTargetSize.padded,
          foregroundColor: AppColors.primary,
          shape: baseButtonShape,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(
            AppDimensions.minTouchTarget,
            AppDimensions.minTouchTarget,
          ),
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.onSurface,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.controlRadius),
        ),
      ),
    );
  }
}

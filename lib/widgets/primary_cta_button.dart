import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme.dart';

/// Botão de ação primária acessível com altura mínima ergonômica de 56 dp.
///
/// Suporta variantes preenchida e contornada, ícone opcional e feedback visual
/// imediato ao toque respeitando a Lei de Fitts.
class PrimaryCtaButton extends StatelessWidget {
  /// Cria um botão de chamada para ação [PrimaryCtaButton].
  const PrimaryCtaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isOutlined = false,
    this.backgroundColor,
    this.foregroundColor,
  });

  /// Texto exibido em caixa mista no interior do botão.
  final String label;

  /// Callback executado ao tocar no botão, ou `null` para estado desabilitado.
  final VoidCallback? onPressed;

  /// Ícone opcional exibido à esquerda de [label].
  final IconData? icon;

  /// Indica se o botão deve usar estilo contornado em vez de preenchido.
  final bool isOutlined;

  /// Cor de fundo personalizada quando [isOutlined] for `false`.
  final Color? backgroundColor;

  /// Cor personalizada para texto, ícone e borda no modo contornado.
  final Color? foregroundColor;

  void _handlePressed() {
    HapticFeedback.lightImpact();
    onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final childContent = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20),
          const SizedBox(width: AppDimensions.spacingXs),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final resolvedWidth =
            constraints.hasBoundedWidth && constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : AppDimensions.minTouchTarget;
        final minimumSize = Size(
          resolvedWidth,
          AppDimensions.primaryButtonHeight,
        );
        final shape = RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.controlRadius),
        );
        final callback = onPressed == null ? null : _handlePressed;

        if (isOutlined) {
          final activeForeground = foregroundColor ?? AppColors.primary;
          return OutlinedButton(
            onPressed: callback,
            style: ButtonStyle(
              minimumSize: WidgetStateProperty.all(minimumSize),
              tapTargetSize: MaterialTapTargetSize.padded,
              shape: WidgetStateProperty.all(shape),
              backgroundColor: backgroundColor != null
                  ? WidgetStateProperty.all(backgroundColor)
                  : null,
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.disabled)) {
                  return AppColors.onSurfaceVariant;
                }
                return activeForeground;
              }),
              side: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.disabled)) {
                  return const BorderSide(color: AppColors.outline, width: 1.5);
                }
                return BorderSide(color: activeForeground, width: 1.5);
              }),
              textStyle: WidgetStateProperty.all(
                const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            child: childContent,
          );
        }

        final baseBackground = backgroundColor ?? AppColors.primary;
        final pressedBackground = baseBackground == AppColors.primary
            ? AppColors.primaryDark
            : (Color.lerp(baseBackground, Colors.black, 0.14) ??
                AppColors.primaryDark);
        final activeForeground = foregroundColor ?? Colors.white;

        return FilledButton(
          onPressed: callback,
          style: ButtonStyle(
            minimumSize: WidgetStateProperty.all(minimumSize),
            tapTargetSize: MaterialTapTargetSize.padded,
            shape: WidgetStateProperty.all(shape),
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return AppColors.neutralContainer;
              }
              if (states.contains(WidgetState.pressed) ||
                  states.contains(WidgetState.hovered)) {
                return pressedBackground;
              }
              return baseBackground;
            }),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return AppColors.onSurfaceVariant;
              }
              return activeForeground;
            }),
            textStyle: WidgetStateProperty.all(
              const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          child: childContent,
        );
      },
    );
  }
}

/// Barra inferior fixa ergonômica ancorada na zona do polegar.
///
/// Mantém o conteúdo protegido contra recortes de sistema com margem fixa de 16 dp.
class ThumbZoneBottomBar extends StatelessWidget {
  /// Cria uma barra inferior [ThumbZoneBottomBar] envolvendo [child].
  const ThumbZoneBottomBar({
    super.key,
    required this.child,
  });

  /// Widget ancorado no rodapé da tela, tipicamente um [PrimaryCtaButton].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.outline),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.screenPadding),
            child: child,
          ),
        ),
      ),
    );
  }
}

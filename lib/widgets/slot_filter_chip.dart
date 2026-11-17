import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme.dart';
import '../state/app_state.dart';

/// Chip de filtro padronizado em conformidade com a Lei de Fitts (>= 48x48 dp).
///
/// Exibe feedback visual imediato em menos de 100 ms ao alternar o estado
/// selecionado, mantendo contraste acessível WCAG 2.1 AA.
class AgendaFilterChip extends StatelessWidget {
  /// Cria um chip de filtro [AgendaFilterChip].
  const AgendaFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  /// Rótulo textual exibido no interior do chip.
  final String label;

  /// Indica se o filtro está ativo no momento.
  final bool selected;

  /// Callback acionado ao tocar no chip.
  final VoidCallback onTap;

  /// Ícone opcional exibido à esquerda de [label].
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final foregroundColor =
        selected ? AppColors.primaryDark : AppColors.onSurface;
    final backgroundColor =
        selected ? AppColors.primaryContainer : AppColors.surface;
    final borderColor = selected ? AppColors.primary : AppColors.outline;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.controlRadius),
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: AnimatedContainer(
            duration: AppDurations.instantFeedback,
            constraints: const BoxConstraints(
              minWidth: AppDimensions.minTouchTarget,
              minHeight: AppDimensions.minTouchTarget,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingSm,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(AppDimensions.controlRadius),
              border: Border.all(
                color: borderColor,
                width: selected ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: foregroundColor),
                  const SizedBox(width: AppDimensions.spacingXs),
                ],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: foregroundColor,
                      fontSize: 14,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Chip interativo de horário para a grade de agendamento com prevenção de erros.
///
/// Renderiza horários passados ou ocupados como fisicamente desabilitados com
/// texto tachado, e destaca horários em trava temporária com contador visual.
class TimeSlotChip extends StatelessWidget {
  /// Cria um chip de horário [TimeSlotChip] para o [slot] informado.
  const TimeSlotChip({
    super.key,
    required this.slot,
    required this.selected,
    required this.onTap,
  });

  /// Dados e status atual do horário na grade.
  final TimeSlotModel slot;

  /// Indica se o horário está selecionado pelo cliente atual.
  final bool selected;

  /// Callback executado ao selecionar um horário disponível.
  final VoidCallback onTap;

  String _formatRemainingTime() {
    final expiresAt = slot.reservaExpiraEm;
    if (expiresAt == null) {
      return '5:00';
    }
    final remainingMs = expiresAt.difference(DateTime.now()).inMilliseconds;
    final totalSeconds = (remainingMs / 1000).ceil().clamp(0, 300);
    final minutes = totalSeconds ~/ 60;
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = slot.isIndisponivel;
    final isSelected =
        !isDisabled && (selected || slot.isReservadoTemporariamente);

    final Color backgroundColor;
    final Color borderColor;
    final double borderWidth;
    final Color hourColor;
    final Color subtitleColor;
    final String subtitleText;
    final String semanticDescription;

    if (isDisabled) {
      backgroundColor = AppColors.neutralContainer;
      borderColor = AppColors.outline;
      borderWidth = 1.0;
      hourColor = AppColors.onSurfaceVariant;
      subtitleColor = AppColors.onSurfaceVariant;
      subtitleText =
          slot.status == SlotStatus.passado ? 'Passado' : 'Ocupado';
      semanticDescription =
          'Horário ${slot.hora}, $subtitleText e indisponível';
    } else if (isSelected) {
      final remaining = _formatRemainingTime();
      backgroundColor = AppColors.primaryContainer;
      borderColor = AppColors.primary;
      borderWidth = 2.0;
      hourColor = AppColors.primaryDark;
      subtitleColor = AppColors.primaryDark;
      subtitleText = 'Reservado • $remaining';
      semanticDescription =
          'Horário ${slot.hora}, reservado para você por $remaining';
    } else {
      backgroundColor = AppColors.surface;
      borderColor = AppColors.outline;
      borderWidth = 1.0;
      hourColor = AppColors.onSurface;
      subtitleColor = AppColors.onSurfaceVariant;
      subtitleText = 'Livre';
      semanticDescription = 'Horário ${slot.hora}, livre para agendamento';
    }

    return Semantics(
      button: true,
      enabled: !isDisabled,
      selected: isSelected,
      label: semanticDescription,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.controlRadius),
          onTap: isDisabled
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  onTap();
                },
          child: AnimatedContainer(
            duration: AppDurations.instantFeedback,
            constraints: const BoxConstraints(
              minWidth: AppDimensions.minTouchTarget,
              minHeight: AppDimensions.minTouchTarget,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(AppDimensions.controlRadius),
              border: Border.all(
                color: borderColor,
                width: borderWidth,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  slot.hora,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: hourColor,
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    decoration:
                        isDisabled ? TextDecoration.lineThrough : null,
                    decorationColor: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitleText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

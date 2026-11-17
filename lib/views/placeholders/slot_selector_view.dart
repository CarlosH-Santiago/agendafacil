import 'package:flutter/material.dart' hide DayPeriod;
import 'package:flutter/services.dart';

import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../state/app_state.dart';
import '../../widgets/slot_filter_chip.dart';
import 'placeholder_screen_scaffold.dart';

/// Tela 7 — Seletor de Data e Grade de Horários por Turnos.
///
/// Organiza os horários em Manhã, Tarde e Noite com alvos >= 48x48 dp,
/// bloqueia fisicamente horários ocupados ou passados (Heurística 5) e
/// simula trava temporária de 5 minutos ao selecionar um horário livre.
class SlotSelectorView extends StatelessWidget {
  /// Cria a tela [SlotSelectorView].
  const SlotSelectorView({super.key});

  static const List<String> _weekdayLabels = [
    'Seg',
    'Ter',
    'Qua',
    'Qui',
    'Sex',
    'Sáb',
    'Dom',
  ];

  String _dayLabel(DateTime date, DateTime today) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final diff = normalizedDate.difference(today).inDays;
    if (diff == 0) return 'Hoje';
    if (diff == 1) return 'Amanhã';
    return _weekdayLabels[date.weekday - 1];
  }

  IconData _periodIcon(DayPeriod period) {
    switch (period) {
      case DayPeriod.manha:
        return Icons.wb_sunny_outlined;
      case DayPeriod.tarde:
        return Icons.wb_twilight_rounded;
      case DayPeriod.noite:
        return Icons.nights_stay_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final textTheme = Theme.of(context).textTheme;
    final service = appState.selectedService ?? appState.services.first;
    final selectedSlot = appState.selectedSlotModel;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = List<DateTime>.generate(
      7,
      (index) => today.add(Duration(days: index)),
    );

    return PlaceholderScreenScaffold(
      screenNumber: 7,
      title: 'Seleção de Horário',
      description:
          'Carrossel semanal de datas e grade por turnos (Manhã, Tarde e Noite) com trava temporária de 5 minutos e prevenção de erros.',
      primaryActionLabel: 'Avançar para Checkout',
      primaryRoute: AppRoutes.checkout,
      primaryEnabled: appState.selectedSlot != null,
      secondaryActionLabel: 'Voltar para detalhes',
      secondaryRoute: AppRoutes.professionalDetail,
      bodyContent: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingSm),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.nome,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Profissional Responsável: ${service.prestadorNome}',
                          style: textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Duração: ${service.duracaoFormatada} • ${service.precoFormatado}',
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Text(
            'Escolha o dia',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: days.map((day) {
                final isSelected = day.year == appState.selectedDate.year &&
                    day.month == appState.selectedDate.month &&
                    day.day == appState.selectedDate.day;
                final dayFormatted =
                    '${day.day.toString().padLeft(2, '0')}/${day.month.toString().padLeft(2, '0')}';

                return Padding(
                  padding: const EdgeInsets.only(right: AppDimensions.spacingXs),
                  child: _DayChip(
                    title: _dayLabel(day, today),
                    subtitle: dayFormatted,
                    selected: isSelected,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      appState.selecionarData(day);
                    },
                  ),
                );
              }).toList(growable: false),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          if (selectedSlot != null && selectedSlot.isReservadoTemporariamente)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingSm,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                border: Border.all(color: AppColors.primary),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lock_clock_rounded,
                    color: AppColors.primaryDark,
                  ),
                  const SizedBox(width: AppDimensions.spacingXs),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reservado para você por 5:00',
                          style: textTheme.bodyLarge?.copyWith(
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Horário ${selectedSlot.hora} segurado temporariamente enquanto você finaliza.',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      appState.liberarReservaTemporaria();
                    },
                    child: const Text('Liberar'),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warningContainer,
                borderRadius: BorderRadius.circular(AppDimensions.controlRadius),
                border: Border.all(color: AppColors.outline),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.touch_app_outlined,
                    color: AppColors.warningForeground,
                  ),
                  const SizedBox(width: AppDimensions.spacingXs),
                  Expanded(
                    child: Text(
                      'Selecione um horário livre abaixo para liberar o botão "Avançar para Checkout".',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.warningForeground,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppDimensions.spacingSm),
          ...DayPeriod.values.map((period) {
            final periodSlots = appState.slotsPorPeriodo(period);
            if (periodSlots.isEmpty) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.spacingSm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _periodIcon(period),
                            size: 20,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: AppDimensions.spacingXs),
                          Text(
                            period.label,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: AppDimensions.spacingXs,
                        runSpacing: AppDimensions.spacingXs,
                        children: periodSlots.map((slot) {
                          return TimeSlotChip(
                            slot: slot,
                            selected: appState.selectedSlot == slot.hora,
                            onTap: () => appState.selecionarHorario(slot.hora),
                          );
                        }).toList(growable: false),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        selected ? AppColors.primaryContainer : AppColors.surface;
    final borderColor = selected ? AppColors.primary : AppColors.outline;
    final foreground = selected ? AppColors.primaryDark : AppColors.onSurface;

    return Semantics(
      button: true,
      selected: selected,
      label: '$title, $subtitle',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimensions.controlRadius),
          onTap: onTap,
          child: AnimatedContainer(
            duration: AppDurations.instantFeedback,
            constraints: const BoxConstraints(
              minWidth: 72,
              minHeight: 56,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(AppDimensions.controlRadius),
              border: Border.all(
                color: borderColor,
                width: selected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color:
                        selected ? AppColors.primaryDark : AppColors.onSurfaceVariant,
                    fontSize: 12,
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

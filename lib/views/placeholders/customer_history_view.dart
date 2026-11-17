import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../models/appointment_model.dart';
import '../../state/app_state.dart';
import '../../widgets/service_item_card.dart';
import '../../widgets/slot_filter_chip.dart';
import 'placeholder_screen_scaffold.dart';

enum _HistoryFilter {
  todos('Todos'),
  ativos('Ativos'),
  finalizados('Finalizados'),
  cancelados('Cancelados');

  const _HistoryFilter(this.label);

  final String label;
}

/// Tela 12 — Histórico Unificado de Reservas do Cliente.
///
/// Consolida agendamentos ativos e anteriores com acelerador "Reagendar em 1 toque"
/// (Heurística 7), cancelamento transparente (Heurística 3) e acesso à avaliação.
class CustomerHistoryView extends StatefulWidget {
  /// Cria a tela [CustomerHistoryView].
  const CustomerHistoryView({super.key});

  @override
  State<CustomerHistoryView> createState() => _CustomerHistoryViewState();
}

class _CustomerHistoryViewState extends State<CustomerHistoryView> {
  _HistoryFilter _filter = _HistoryFilter.todos;

  List<AppointmentModel> _applyFilter(List<AppointmentModel> list) {
    switch (_filter) {
      case _HistoryFilter.todos:
        return list;
      case _HistoryFilter.ativos:
        return list.where((a) => a.isAtivo).toList(growable: false);
      case _HistoryFilter.finalizados:
        return list
            .where((a) => a.status == AppointmentStatus.finalizado)
            .toList(growable: false);
      case _HistoryFilter.cancelados:
        return list
            .where((a) => a.status == AppointmentStatus.cancelado)
            .toList(growable: false);
    }
  }

  void _oneTapRebook(
    BuildContext context,
    AppState appState,
    AppointmentModel apt,
  ) {
    HapticFeedback.selectionClick();
    final reserved = appState.reagendarEmUmToque(apt);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text(
            reserved
                ? 'Serviço "${apt.servicoNome}" e próximo horário livre pré-selecionados!'
                : 'Serviço "${apt.servicoNome}" selecionado. Escolha um horário.',
          ),
        ),
      );
    Navigator.of(context).pushNamed(
      reserved ? AppRoutes.checkout : AppRoutes.slotSelector,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final textTheme = Theme.of(context).textTheme;
    final items = _applyFilter(appState.appointments);

    return PlaceholderScreenScaffold(
      screenNumber: 12,
      title: 'Histórico de Reservas',
      description:
          'Registro cronológico das reservas com atalho "Reagendar em 1 toque", cancelamento sem penalidades ocultas e avaliação do atendimento.',
      primaryActionLabel: 'Agendar novo serviço',
      primaryRoute: AppRoutes.catalogServices,
      secondaryActionLabel: 'Avaliar atendimento',
      secondaryRoute: AppRoutes.ratingReview,
      bodyContent: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(AppDimensions.controlRadius),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                  color: AppColors.success,
                ),
                const SizedBox(width: AppDimensions.spacingXs),
                Expanded(
                  child: Text(
                    'Cancelamento gratuito garantido até ${appState.janelaCancelamentoHoras}h antes do horário marcado.',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _HistoryFilter.values.map((option) {
                return Padding(
                  padding: const EdgeInsets.only(right: AppDimensions.spacingXs),
                  child: AgendaFilterChip(
                    label: option.label,
                    selected: _filter == option,
                    onTap: () {
                      setState(() {
                        _filter = option;
                      });
                    },
                  ),
                );
              }).toList(growable: false),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          if (items.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spacingSm),
                child: Text(
                  'Nenhuma reserva encontrada para o filtro selecionado.',
                  style: textTheme.bodyMedium,
                ),
              ),
            )
          else
            ...items.map((apt) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.spacingSm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: AppointmentStatusBadge(status: apt.status),
                            ),
                            Text(
                              '${apt.dataFormatada} • ${apt.hora}',
                              style: textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          apt.servicoNome,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(apt.prestador, style: textTheme.bodyMedium),
                        const SizedBox(height: 4),
                        Text(
                          apt.valorFormatado,
                          style: textTheme.bodyLarge?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (apt.avaliacaoEstrelas != null) ...[
                          const SizedBox(height: AppDimensions.spacingXs),
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 16,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Sua avaliação: ${apt.avaliacaoEstrelas}/5'
                                  '${(apt.comentarioAvaliacao ?? '').isNotEmpty ? ' • "${apt.comentarioAvaliacao}"' : ''}',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: AppColors.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: AppDimensions.spacingXs,
                          runSpacing: AppDimensions.spacingXs,
                          children: [
                            FilledButton.tonalIcon(
                              onPressed: () =>
                                  _oneTapRebook(context, appState, apt),
                              style: FilledButton.styleFrom(
                                minimumSize: const Size(
                                  AppDimensions.minTouchTarget,
                                  AppDimensions.minTouchTarget,
                                ),
                                backgroundColor: AppColors.primaryContainer,
                                foregroundColor: AppColors.primaryDark,
                              ),
                              icon: const Icon(Icons.replay_rounded, size: 18),
                              label: const Text('Reagendar em 1 toque'),
                            ),
                            if (apt.isAtivo)
                              OutlinedButton.icon(
                                onPressed: () {
                                  HapticFeedback.selectionClick();
                                  appState.alterarStatusAgendamento(
                                    apt.id,
                                    AppointmentStatus.cancelado,
                                  );
                                  ScaffoldMessenger.of(context)
                                    ..hideCurrentSnackBar()
                                    ..showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Agendamento cancelado gratuitamente.',
                                        ),
                                      ),
                                    );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                  side: const BorderSide(
                                    color: AppColors.error,
                                  ),
                                ),
                                icon: const Icon(Icons.cancel_outlined, size: 18),
                                label: const Text('Cancelar'),
                              ),
                            if (apt.status == AppointmentStatus.finalizado)
                              OutlinedButton.icon(
                                onPressed: () {
                                  HapticFeedback.selectionClick();
                                  Navigator.of(context).pushNamed(
                                    AppRoutes.ratingReview,
                                    arguments: apt.id,
                                  );
                                },
                                icon: const Icon(
                                  Icons.star_outline_rounded,
                                  size: 18,
                                ),
                                label: Text(
                                  apt.avaliacaoEstrelas == null
                                      ? 'Avaliar'
                                      : 'Editar nota',
                                ),
                              ),
                          ],
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../models/appointment_model.dart';
import '../../state/app_state.dart';
import '../../widgets/service_item_card.dart';
import 'placeholder_screen_scaffold.dart';

/// Tela 10 — Painel da Agenda do Prestador em Linha do Tempo Vertical.
///
/// Implementada com `CustomScrollView` e `Slivers` no modo retrato para eliminar
/// o esmagamento horizontal de múltiplas colunas de profissionais.
class ProviderTimelineView extends StatelessWidget {
  /// Cria a tela [ProviderTimelineView].
  const ProviderTimelineView({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final textTheme = Theme.of(context).textTheme;
    final appointments = appState.appointments;

    final activeCount =
        appointments.where((apt) => apt.isAtivo).length;
    final completedCount = appointments
        .where((apt) => apt.status == AppointmentStatus.finalizado)
        .length;
    final totalRevenue = appointments
        .where((apt) => apt.status != AppointmentStatus.cancelado)
        .fold<double>(0, (sum, item) => sum + item.valor);

    return PlaceholderScreenScaffold(
      screenNumber: 10,
      title: 'Agenda do Prestador',
      description:
          'Linha do tempo vertical em retrato (CustomScrollView com Slivers) exibindo a sequência de atendimentos e semáforo de status.',
      primaryActionLabel: 'Controlar status do atendimento',
      primaryRoute: AppRoutes.appointmentStatus,
      secondaryActionLabel: 'Regras e políticas da agenda',
      secondaryRoute: AppRoutes.providerSettingsRules,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPadding,
          ),
          sliver: SliverToBoxAdapter(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spacingSm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resumo operacional do dia',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingXs),
                    Wrap(
                      spacing: AppDimensions.spacingXs,
                      runSpacing: AppDimensions.spacingXs,
                      children: [
                        _KpiChip(
                          label: 'Ativos',
                          value: '$activeCount',
                          color: AppColors.primary,
                        ),
                        _KpiChip(
                          label: 'Concluídos',
                          value: '$completedCount',
                          color: AppColors.success,
                        ),
                        _KpiChip(
                          label: 'Previsto',
                          value:
                              'R\$ ${totalRevenue.toStringAsFixed(2).replaceAll('.', ',')}',
                          color: AppColors.onSurface,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SliverPadding(
          padding: EdgeInsets.only(top: AppDimensions.spacingSm),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPadding,
          ),
          sliver: SliverList.separated(
            itemCount: appointments.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppDimensions.spacingXs),
            itemBuilder: (context, index) {
              final apt = appointments[index];
              return _TimelineEntryCard(
                appointment: apt,
                isLast: index == appointments.length - 1,
                onTap: () {
                  HapticFeedback.selectionClick();
                  Navigator.of(context).pushNamed(
                    AppRoutes.appointmentStatus,
                    arguments: apt.id,
                  );
                },
                onStatusSelected: (newStatus) {
                  HapticFeedback.selectionClick();
                  appState.alterarStatusAgendamento(apt.id, newStatus);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _KpiChip extends StatelessWidget {
  const _KpiChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppDimensions.controlRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineEntryCard extends StatelessWidget {
  const _TimelineEntryCard({
    required this.appointment,
    required this.isLast,
    required this.onTap,
    required this.onStatusSelected,
  });

  final AppointmentModel appointment;
  final bool isLast;
  final VoidCallback onTap;
  final ValueChanged<AppointmentStatus> onStatusSelected;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 56,
            child: Column(
              children: [
                Text(
                  appointment.hora,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: appointment.status.foregroundColor,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: AppColors.outline,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.spacingXs),
          Expanded(
            child: Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.spacingSm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: AppointmentStatusBadge(
                              status: appointment.status,
                            ),
                          ),
                          PopupMenuButton<AppointmentStatus>(
                            tooltip: 'Alterar status',
                            onSelected: onStatusSelected,
                            itemBuilder: (_) => AppointmentStatus.values
                                .map(
                                  (status) => PopupMenuItem<AppointmentStatus>(
                                    value: status,
                                    child: Text(status.label),
                                  ),
                                )
                                .toList(growable: false),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        appointment.servicoNome,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Cliente: ${appointment.cliente} • ${appointment.dataFormatada}',
                        style: textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        appointment.valorFormatado,
                        style: textTheme.bodyLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

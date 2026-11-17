import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../models/appointment_model.dart';
import '../../state/app_state.dart';
import '../../widgets/service_item_card.dart';
import '../../widgets/slot_filter_chip.dart';
import 'placeholder_screen_scaffold.dart';

/// Tela 11 — Controle Rápido de Status do Atendimento (Semáforo).
///
/// Permite ao prestador alternar o estado do atendimento entre Confirmado
/// (verde), Em andamento (amarelo), Finalizado (cinza) e Cancelado (vermelho),
/// refletindo imediatamente na linha do tempo e na Home do cliente.
class AppointmentStatusView extends StatefulWidget {
  /// Cria a tela [AppointmentStatusView].
  const AppointmentStatusView({super.key});

  @override
  State<AppointmentStatusView> createState() => _AppointmentStatusViewState();
}

class _AppointmentStatusViewState extends State<AppointmentStatusView> {
  String? _selectedAppointmentId;

  AppointmentModel? _resolveTarget(AppState appState, Object? routeArgs) {
    final appointments = appState.appointments;
    if (appointments.isEmpty) return null;

    final preferredId =
        _selectedAppointmentId ?? (routeArgs is String ? routeArgs : null);
    if (preferredId != null) {
      for (final apt in appointments) {
        if (apt.id == preferredId) return apt;
      }
    }
    return appState.proximoAgendamento ?? appointments.first;
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    final target = _resolveTarget(appState, routeArgs);
    final textTheme = Theme.of(context).textTheme;

    return PlaceholderScreenScaffold(
      screenNumber: 11,
      title: 'Controle de Status',
      description:
          'Semáforo operacional para o profissional iniciar, concluir ou cancelar o atendimento em um toque.',
      primaryActionLabel: 'Voltar à agenda do prestador',
      primaryRoute: AppRoutes.providerTimeline,
      secondaryActionLabel: 'Configurar regras da agenda',
      secondaryRoute: AppRoutes.providerSettingsRules,
      bodyContent: target == null
          ? const Card(
              child: Padding(
                padding: EdgeInsets.all(AppDimensions.spacingSm),
                child: Text('Nenhum atendimento disponível para gerenciamento.'),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (appState.appointments.length > 1) ...[
                  Text(
                    'Selecionar atendimento',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXs),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: appState.appointments.map((apt) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            right: AppDimensions.spacingXs,
                          ),
                          child: AgendaFilterChip(
                            label: '${apt.hora} • ${apt.cliente}',
                            selected: apt.id == target.id,
                            onTap: () {
                              setState(() {
                                _selectedAppointmentId = apt.id;
                              });
                            },
                          ),
                        );
                      }).toList(growable: false),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingSm),
                ],
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.spacingSm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: AppointmentStatusBadge(
                                status: target.status,
                              ),
                            ),
                            Text(
                              '${target.dataFormatada} • ${target.hora}',
                              style: textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          target.servicoNome,
                          style: textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Cliente: ${target.cliente}',
                          style: textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Valor: ${target.valorFormatado}',
                          style: textTheme.bodyLarge?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.spacingSm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Semáforo de atendimento',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Toque em um estado abaixo para atualizar imediatamente.',
                          style: textTheme.bodyMedium,
                        ),
                        const SizedBox(height: AppDimensions.spacingSm),
                        ...AppointmentStatus.values.map((status) {
                          final isCurrent = target.status == status;
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppDimensions.spacingXs,
                            ),
                            child: _StatusTrafficLightTile(
                              status: status,
                              selected: isCurrent,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                appState.alterarStatusAgendamento(
                                  target.id,
                                  status,
                                );
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    SnackBar(
                                      duration: const Duration(seconds: 2),
                                      content: Text(
                                        'Status alterado para ${status.label}.',
                                      ),
                                    ),
                                  );
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _StatusTrafficLightTile extends StatelessWidget {
  const _StatusTrafficLightTile({
    required this.status,
    required this.selected,
    required this.onTap,
  });

  final AppointmentStatus status;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.controlRadius),
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppDurations.instantFeedback,
          constraints: const BoxConstraints(
            minHeight: AppDimensions.minTouchTarget,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingSm,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: selected ? status.backgroundColor : AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.controlRadius),
            border: Border.all(
              color: selected ? status.foregroundColor : AppColors.outline,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                status.icon,
                color: status.foregroundColor,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  status.label,
                  style: TextStyle(
                    color: selected
                        ? status.foregroundColor
                        : AppColors.onSurface,
                    fontSize: 15,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              if (selected)
                Icon(
                  Icons.check_circle_rounded,
                  color: status.foregroundColor,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

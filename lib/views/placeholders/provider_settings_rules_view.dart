import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../state/app_state.dart';
import '../../widgets/slot_filter_chip.dart';
import 'placeholder_screen_scaffold.dart';

/// Tela 14 — Configuração de Regras e Políticas do Prestador.
///
/// Permite ajustar a janela de cancelamento gratuito, a tolerância máxima de
/// atraso e os dias de funcionamento da agenda, refletindo imediatamente no
/// Checkout e no Histórico do cliente.
class ProviderSettingsRulesView extends StatefulWidget {
  /// Cria a tela [ProviderSettingsRulesView].
  const ProviderSettingsRulesView({super.key});

  @override
  State<ProviderSettingsRulesView> createState() =>
      _ProviderSettingsRulesViewState();
}

class _ProviderSettingsRulesViewState extends State<ProviderSettingsRulesView> {
  static const List<int> _cancellationOptions = [1, 2, 4, 12, 24];
  static const List<int> _toleranceOptions = [5, 10, 15, 20, 30];
  static const List<String> _weekDays = [
    'Seg',
    'Ter',
    'Qua',
    'Qui',
    'Sex',
    'Sáb',
    'Dom',
  ];

  final Set<String> _activeDays = {'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'};

  void _toggleDay(String day) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_activeDays.contains(day) && _activeDays.length > 1) {
        _activeDays.remove(day);
      } else {
        _activeDays.add(day);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final textTheme = Theme.of(context).textTheme;

    return PlaceholderScreenScaffold(
      screenNumber: 14,
      title: 'Regras e Políticas',
      description:
          'Painel para definir janela de cancelamento gratuito, tolerância máxima de atraso e dias de funcionamento da agenda.',
      primaryActionLabel: 'Salvar e voltar à agenda',
      primaryRoute: AppRoutes.providerTimeline,
      primaryIcon: Icons.check_rounded,
      secondaryActionLabel: 'Alternar para Modo Cliente',
      secondaryRoute: AppRoutes.homeCustomer,
      onPrimaryAction: () {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                'Regras salvas: cancelamento até ${appState.janelaCancelamentoHoras}h antes e tolerância de ${appState.toleranciaAtrasoMinutos} min.',
              ),
            ),
          );
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).pushReplacementNamed(
            AppRoutes.providerTimeline,
          );
        }
      },
      onSecondaryAction: () {
        appState.alternarPerfil(UserProfile.cliente);
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.homeCustomer,
          (route) => false,
        );
      },
      bodyContent: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Janela de cancelamento gratuito',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Cancelamento grátis até ${appState.janelaCancelamentoHoras} hora(s) antes do horário agendado.',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppDimensions.spacingSm),
                  Wrap(
                    spacing: AppDimensions.spacingXs,
                    runSpacing: AppDimensions.spacingXs,
                    children: _cancellationOptions.map((hours) {
                      return AgendaFilterChip(
                        label: '${hours}h antes',
                        selected: appState.janelaCancelamentoHoras == hours,
                        onTap: () => appState.atualizarRegrasPrestador(
                          janelaHoras: hours,
                        ),
                      );
                    }).toList(growable: false),
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
                    'Tolerância máxima de atraso',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tempo limite de espera: ${appState.toleranciaAtrasoMinutos} minutos.',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppDimensions.spacingSm),
                  Wrap(
                    spacing: AppDimensions.spacingXs,
                    runSpacing: AppDimensions.spacingXs,
                    children: _toleranceOptions.map((minutes) {
                      return AgendaFilterChip(
                        label: '$minutes min',
                        selected: appState.toleranciaAtrasoMinutos == minutes,
                        onTap: () => appState.atualizarRegrasPrestador(
                          toleranciaMinutos: minutes,
                        ),
                      );
                    }).toList(growable: false),
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
                    'Dias de funcionamento da agenda',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Atendimento ativo em ${_activeDays.length} dia(s) da semana.',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppDimensions.spacingSm),
                  Wrap(
                    spacing: AppDimensions.spacingXs,
                    runSpacing: AppDimensions.spacingXs,
                    children: _weekDays.map((day) {
                      return AgendaFilterChip(
                        label: day,
                        selected: _activeDays.contains(day),
                        onTap: () => _toggleDay(day),
                      );
                    }).toList(growable: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

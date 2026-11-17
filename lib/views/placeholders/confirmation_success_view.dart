import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../state/app_state.dart';
import '../../widgets/primary_cta_button.dart';
import '../../widgets/service_item_card.dart';
import 'placeholder_screen_scaffold.dart';

/// Tela 9 — Confirmação da Reserva e Sincronização com Agenda do Celular.
///
/// Exibe feedback imediato com ícone animado de sucesso, resumo do comprovante
/// e botão dedicado "Salvar na Agenda do Celular".
class ConfirmationSuccessView extends StatefulWidget {
  /// Cria a tela [ConfirmationSuccessView].
  const ConfirmationSuccessView({super.key});

  @override
  State<ConfirmationSuccessView> createState() =>
      _ConfirmationSuccessViewState();
}

class _ConfirmationSuccessViewState extends State<ConfirmationSuccessView> {
  bool _savedToDeviceCalendar = false;

  void _saveToCalendar() {
    HapticFeedback.mediumImpact();
    setState(() {
      _savedToDeviceCalendar = true;
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Reserva salva na agenda do celular com lembrete!'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final next = appState.proximoAgendamento ??
        (appState.appointments.isNotEmpty ? appState.appointments.first : null);
    final textTheme = Theme.of(context).textTheme;

    return PlaceholderScreenScaffold(
      screenNumber: 9,
      title: 'Agendamento Confirmado',
      description:
          'Feedback visual imediato da reserva efetivada com opção dedicada para salvar o compromisso na agenda do dispositivo móvel.',
      primaryActionLabel: 'Ver histórico de reservas',
      primaryRoute: AppRoutes.customerHistory,
      secondaryActionLabel: 'Voltar para o início',
      secondaryRoute: AppRoutes.homeCustomer,
      onSecondaryAction: () {
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
              padding: const EdgeInsets.all(AppDimensions.spacingMd),
              child: Column(
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.6, end: 1.0),
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutBack,
                    builder: (context, scale, child) {
                      return Transform.scale(scale: scale, child: child);
                    },
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: AppColors.secondaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                        size: 44,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingSm),
                  Text(
                    'Tudo certo com seu horário!',
                    textAlign: TextAlign.center,
                    style: textTheme.titleLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    next == null
                        ? 'Sua reserva foi registrada com sucesso.'
                        : 'Seu atendimento está confirmado para ${next.dataFormatada} às ${next.hora}.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium,
                  ),
                  if (next != null) ...[
                    const SizedBox(height: AppDimensions.spacingSm),
                    AppointmentStatusBadge(status: next.status),
                  ],
                ],
              ),
            ),
          ),
          if (next != null) ...[
            const SizedBox(height: AppDimensions.spacingSm),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spacingSm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Comprovante da reserva',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingXs),
                    Text(
                      next.servicoNome,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Profissional Responsável: ${next.prestador}',
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Data e horário: ${next.dataFormatada} • ${next.hora}',
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Valor combinado: ${next.valorFormatado}',
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: AppDimensions.spacingSm),
          PrimaryCtaButton(
            label: _savedToDeviceCalendar
                ? 'Salvo na Agenda do Celular'
                : 'Salvar na Agenda do Celular',
            icon: _savedToDeviceCalendar
                ? Icons.event_available_rounded
                : Icons.calendar_month_rounded,
            backgroundColor: _savedToDeviceCalendar
                ? AppColors.success
                : AppColors.primaryDark,
            onPressed: _saveToCalendar,
          ),
        ],
      ),
    );
  }
}

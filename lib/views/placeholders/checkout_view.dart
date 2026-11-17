import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../state/app_state.dart';
import '../../widgets/slot_filter_chip.dart';
import 'placeholder_screen_scaffold.dart';

enum _PaymentMethod {
  pix('PIX na confirmação', Icons.qr_code_rounded),
  cartaoLocal('Cartão no local', Icons.credit_card_rounded),
  dinheiro('Dinheiro', Icons.payments_outlined);

  const _PaymentMethod(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// Tela 8 — Checkout e Resumo da Reserva.
///
/// Mantém cartão sintético fixo no topo (Heurística 6: Reconhecimento em vez
/// de memorização), seleção de pagamento e políticas transparentes sem taxas ocultas.
class CheckoutView extends StatefulWidget {
  /// Cria a tela [CheckoutView].
  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  _PaymentMethod _selectedPayment = _PaymentMethod.pix;

  static const List<String> _fullWeekdays = [
    'Segunda-feira',
    'Terça-feira',
    'Quarta-feira',
    'Quinta-feira',
    'Sexta-feira',
    'Sábado',
    'Domingo',
  ];

  String _formatDateWithWeekday(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final weekday = _fullWeekdays[date.weekday - 1];
    return '$weekday, $day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final service = appState.selectedService ?? appState.services.first;
    final textTheme = Theme.of(context).textTheme;
    final selectedSlot = appState.selectedSlot;

    return PlaceholderScreenScaffold(
      screenNumber: 8,
      title: 'Checkout e Resumo',
      description:
          'Consolida o cartão sintético da reserva no topo, forma de pagamento preferencial e regras transparentes de cancelamento.',
      primaryActionLabel: 'Confirmar agendamento',
      primaryRoute: AppRoutes.confirmationSuccess,
      primaryIcon: Icons.check_circle_outline_rounded,
      primaryEnabled: selectedSlot != null,
      secondaryActionLabel: 'Alterar horário',
      secondaryRoute: AppRoutes.slotSelector,
      onPrimaryAction: () {
        final created = appState.confirmarAgendamento();
        if (created == null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(
                content: Text('Selecione um horário livre antes de confirmar.'),
              ),
            );
          return;
        }
        Navigator.of(context).pushReplacementNamed(
          AppRoutes.confirmationSuccess,
        );
      },
      bodyContent: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cartão sintético fixo no topo (Heurística 6: Reconhecimento em Vez de Memorização).
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingSm),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
              border: Border.all(color: AppColors.primary, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.primaryContainer,
                      foregroundColor: AppColors.primaryDark,
                      child: Icon(Icons.person_rounded, size: 26),
                    ),
                    const SizedBox(width: AppDimensions.spacingSm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.nome,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            service.prestadorNome,
                            style: textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                const Divider(),
                const SizedBox(height: AppDimensions.spacingXs),
                _SummaryInfoRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Dia escolhido',
                  value: _formatDateWithWeekday(appState.selectedDate),
                ),
                const SizedBox(height: AppDimensions.spacingXs),
                _SummaryInfoRow(
                  icon: Icons.schedule_rounded,
                  label: 'Horário e duração',
                  value:
                      '${selectedSlot ?? 'Não selecionado'} • ${service.duracaoFormatada}',
                ),
                const SizedBox(height: AppDimensions.spacingXs),
                const Divider(),
                const SizedBox(height: AppDimensions.spacingXs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Valor total',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      service.precoFormatado,
                      style: textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
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
                    'Forma de pagamento preferencial',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXs),
                  Wrap(
                    spacing: AppDimensions.spacingXs,
                    runSpacing: AppDimensions.spacingXs,
                    children: _PaymentMethod.values.map((method) {
                      return AgendaFilterChip(
                        label: method.label,
                        icon: method.icon,
                        selected: _selectedPayment == method,
                        onTap: () {
                          setState(() {
                            _selectedPayment = method;
                          });
                        },
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
                    'Política de cancelamento transparente',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXs),
                  _PolicyBullet(
                    icon: Icons.event_available_rounded,
                    color: AppColors.success,
                    text:
                        'Cancelamento gratuito até ${appState.janelaCancelamentoHoras}h antes do horário marcado.',
                  ),
                  const SizedBox(height: AppDimensions.spacingXs),
                  _PolicyBullet(
                    icon: Icons.timer_outlined,
                    color: AppColors.warningForeground,
                    text:
                        'Tolerância de atraso configurada pelo profissional: ${appState.toleranciaAtrasoMinutos} minutos.',
                  ),
                  const SizedBox(height: AppDimensions.spacingXs),
                  const _PolicyBullet(
                    icon: Icons.verified_outlined,
                    color: AppColors.primary,
                    text: 'Sem taxas ocultas ou cobranças extras na reserva.',
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

class _SummaryInfoRow extends StatelessWidget {
  const _SummaryInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: AppDimensions.spacingXs),
        Expanded(
          child: Text(label, style: textTheme.bodyMedium),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _PolicyBullet extends StatelessWidget {
  const _PolicyBullet({
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: AppDimensions.spacingXs),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

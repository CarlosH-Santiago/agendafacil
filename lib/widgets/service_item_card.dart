import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/appointment_model.dart';
import '../models/service_model.dart';

/// Selo semântico colorido que representa o status atual de um atendimento.
///
/// Materializa o semáforo da Heurística 1 com ícone e rótulo legível em
/// conformidade com as cores de alto contraste definidas em [AppointmentStatus].
class AppointmentStatusBadge extends StatelessWidget {
  /// Cria um selo de status [AppointmentStatusBadge] para [status].
  const AppointmentStatusBadge({
    super.key,
    required this.status,
  });

  /// Estado atual do agendamento exibido no selo.
  final AppointmentStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: BorderRadius.circular(AppDimensions.controlRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status.icon,
            size: 16,
            color: status.foregroundColor,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              status.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: status.foregroundColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Cartão padronizado para exibição de serviços no catálogo e no checkout.
///
/// Preserva consistência estrutural entre rotas exibindo categoria, avaliação,
/// duração, prestador, valor em reais e ação opcional de agendamento.
class ServiceItemCard extends StatelessWidget {
  /// Cria um cartão de serviço [ServiceItemCard].
  const ServiceItemCard({
    super.key,
    required this.service,
    this.onTap,
    this.onBookPressed,
    this.actionLabel = 'Agendar',
    this.compact = false,
  });

  /// Serviço cujos dados serão apresentados no cartão.
  final ServiceModel service;

  /// Callback executado ao tocar no corpo do cartão.
  final VoidCallback? onTap;

  /// Callback executado ao pressionar o botão de ação, quando exibido.
  final VoidCallback? onBookPressed;

  /// Rótulo do botão de ação exibido quando [onBookPressed] é fornecido.
  final String actionLabel;

  /// Indica se o cartão deve omitir descrição detalhada para uso em resumos.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.spacingXs,
                      ),
                    ),
                    child: Text(
                      service.categoria.label,
                      style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingXs),
                  const Icon(
                    Icons.star_rounded,
                    size: 16,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    service.avaliacao.toStringAsFixed(1),
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.schedule_rounded,
                    size: 16,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    service.duracaoFormatada,
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                service.nome,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                service.prestadorNome,
                style: textTheme.bodyMedium,
              ),
              if (!compact && service.descricao.isNotEmpty) ...[
                const SizedBox(height: AppDimensions.spacingXs),
                Text(
                  service.descricao,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: AppDimensions.spacingSm),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      service.precoFormatado,
                      style: textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  if (onBookPressed != null) ...[
                    const SizedBox(width: AppDimensions.spacingXs),
                    FilledButton(
                      onPressed: onBookPressed,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(
                          112,
                          AppDimensions.minTouchTarget,
                        ),
                      ),
                      child: Text(actionLabel),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../state/app_state.dart';
import '../../widgets/service_item_card.dart';
import 'placeholder_screen_scaffold.dart';

/// Tela 6 — Detalhes do Profissional e do Estúdio.
///
/// Exibe o especialista responsável, portfólio ilustrativo, endereço físico,
/// detalhes do procedimento selecionado e avaliações prévias validadas.
class ProfessionalDetailView extends StatelessWidget {
  /// Cria a tela [ProfessionalDetailView].
  const ProfessionalDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final service = appState.selectedService ?? appState.services.first;
    final textTheme = Theme.of(context).textTheme;

    final userReviews = appState.appointments
        .where((apt) => apt.avaliacaoEstrelas != null)
        .toList(growable: false);

    return PlaceholderScreenScaffold(
      screenNumber: 6,
      title: 'Detalhes do Profissional',
      description:
          'Apresenta o perfil do especialista, portfólio de atendimentos, endereço do estúdio e avaliações prévias validadas.',
      primaryActionLabel: 'Escolher data e horário',
      primaryRoute: AppRoutes.slotSelector,
      secondaryActionLabel: 'Voltar ao catálogo',
      secondaryRoute: AppRoutes.catalogServices,
      bodyContent: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.primaryContainer,
                        foregroundColor: AppColors.primaryDark,
                        child: Icon(Icons.person_rounded, size: 28),
                      ),
                      const SizedBox(width: AppDimensions.spacingSm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service.prestadorNome,
                              style: textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 18,
                                  color: AppColors.warning,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${service.avaliacao.toStringAsFixed(1)} • Avaliações verificadas',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: AppColors.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingSm),
                  const Divider(),
                  const SizedBox(height: AppDimensions.spacingXs),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppDimensions.spacingXs),
                      Expanded(
                        child: Text(
                          service.enderecoEstudio,
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingXs),
                  Row(
                    children: [
                      const Icon(
                        Icons.verified_user_outlined,
                        size: 18,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: AppDimensions.spacingXs),
                      Expanded(
                        child: Text(
                          'Cancelamento grátis até ${appState.janelaCancelamentoHoras}h antes do atendimento',
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Text(
            'Procedimento selecionado',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          ServiceItemCard(service: service),
          const SizedBox(height: AppDimensions.spacingSm),
          Text(
            'Portfólio do estúdio',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          const SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _PortfolioTile(
                  icon: Icons.content_cut_rounded,
                  title: 'Acabamento Navalhado',
                  subtitle: 'Precisão e simetria',
                ),
                SizedBox(width: AppDimensions.spacingXs),
                _PortfolioTile(
                  icon: Icons.face_retouching_natural_rounded,
                  title: 'Barboterapia',
                  subtitle: 'Toalha quente e óleos',
                ),
                SizedBox(width: AppDimensions.spacingXs),
                _PortfolioTile(
                  icon: Icons.spa_rounded,
                  title: 'Cuidados Faciais',
                  subtitle: 'Protocolo relaxante',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Text(
            'Avaliações recentes',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          if (userReviews.isNotEmpty)
            ...userReviews.map(
              (apt) => Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.spacingXs),
                child: _ReviewCard(
                  author: apt.cliente,
                  stars: apt.avaliacaoEstrelas ?? 5,
                  comment: (apt.comentarioAvaliacao ?? '').isEmpty
                      ? 'Atendimento avaliado pelo cliente.'
                      : apt.comentarioAvaliacao!,
                ),
              ),
            ),
          const _ReviewCard(
            author: 'Mariana Souza',
            stars: 5,
            comment: 'Pontualidade impecável e ambiente muito higienizado.',
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          const _ReviewCard(
            author: 'Carlos Eduardo',
            stars: 5,
            comment: 'Agendamento rápido, zero espera na recepção.',
          ),
        ],
      ),
    );
  }
}

class _PortfolioTile extends StatelessWidget {
  const _PortfolioTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: 164,
      padding: const EdgeInsets.all(AppDimensions.spacingSm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(AppDimensions.controlRadius),
            ),
            child: Icon(icon, color: AppColors.primaryDark),
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.author,
    required this.stars,
    required this.comment,
  });

  final String author;
  final int stars;
  final String comment;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingSm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    author,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < stars
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      size: 16,
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(comment, style: textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

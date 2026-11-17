import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../models/service_model.dart';
import '../../state/app_state.dart';
import '../../widgets/service_item_card.dart';
import '../../widgets/slot_filter_chip.dart';
import 'placeholder_screen_scaffold.dart';

enum _CatalogSort {
  relevancia('Recomendados'),
  menorPreco('Menor preço'),
  menorDuracao('Mais rápidos'),
  melhorAvaliacao('Melhor avaliação');

  const _CatalogSort(this.label);

  final String label;
}

/// Tela 5 — Catálogo de Serviços com filtros por categoria, preço, duração e avaliação.
class CatalogServicesView extends StatefulWidget {
  /// Cria a tela [CatalogServicesView].
  const CatalogServicesView({super.key});

  @override
  State<CatalogServicesView> createState() => _CatalogServicesViewState();
}

class _CatalogServicesViewState extends State<CatalogServicesView> {
  _CatalogSort _activeSort = _CatalogSort.relevancia;

  List<ServiceModel> _sortedServices(List<ServiceModel> source) {
    final copy = List<ServiceModel>.from(source);
    switch (_activeSort) {
      case _CatalogSort.relevancia:
        return copy;
      case _CatalogSort.menorPreco:
        copy.sort((a, b) => a.preco.compareTo(b.preco));
        return copy;
      case _CatalogSort.menorDuracao:
        copy.sort((a, b) => a.duracaoMinutos.compareTo(b.duracaoMinutos));
        return copy;
      case _CatalogSort.melhorAvaliacao:
        copy.sort((a, b) => b.avaliacao.compareTo(a.avaliacao));
        return copy;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final textTheme = Theme.of(context).textTheme;
    final items = _sortedServices(appState.filteredServices);

    return PlaceholderScreenScaffold(
      screenNumber: 5,
      title: 'Catálogo de Serviços',
      description:
          'Listagem dinâmica dos procedimentos disponíveis, com filtros de categoria, preço, duração e reputação do estabelecimento.',
      primaryActionLabel: 'Ver detalhes do profissional',
      primaryRoute: AppRoutes.professionalDetail,
      secondaryActionLabel: 'Ir para seleção de horário',
      secondaryRoute: AppRoutes.slotSelector,
      bodyContent: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categoria',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                AgendaFilterChip(
                  label: 'Todos',
                  icon: Icons.apps_rounded,
                  selected: appState.selectedCategory == null,
                  onTap: () => appState.selecionarCategoria(null),
                ),
                const SizedBox(width: AppDimensions.spacingXs),
                AgendaFilterChip(
                  label: ServiceCategory.cabelo.label,
                  icon: Icons.content_cut_rounded,
                  selected: appState.selectedCategory == ServiceCategory.cabelo,
                  onTap: () =>
                      appState.selecionarCategoria(ServiceCategory.cabelo),
                ),
                const SizedBox(width: AppDimensions.spacingXs),
                AgendaFilterChip(
                  label: ServiceCategory.barba.label,
                  icon: Icons.face_retouching_natural_rounded,
                  selected: appState.selectedCategory == ServiceCategory.barba,
                  onTap: () =>
                      appState.selecionarCategoria(ServiceCategory.barba),
                ),
                const SizedBox(width: AppDimensions.spacingXs),
                AgendaFilterChip(
                  label: ServiceCategory.estetica.label,
                  icon: Icons.spa_rounded,
                  selected:
                      appState.selectedCategory == ServiceCategory.estetica,
                  onTap: () =>
                      appState.selecionarCategoria(ServiceCategory.estetica),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Text(
            'Ordenar por',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _CatalogSort.values.map((sortOption) {
                return Padding(
                  padding: const EdgeInsets.only(right: AppDimensions.spacingXs),
                  child: AgendaFilterChip(
                    label: sortOption.label,
                    selected: _activeSort == sortOption,
                    onTap: () {
                      setState(() {
                        _activeSort = sortOption;
                      });
                    },
                  ),
                );
              }).toList(growable: false),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Text(
            '${items.length} procedimentos encontrados',
            style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          if (items.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spacingSm),
                child: Column(
                  children: [
                    Text(
                      'Nenhum procedimento corresponde aos filtros atuais.',
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppDimensions.spacingXs),
                    OutlinedButton(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        appState.selecionarCategoria(null);
                        appState.atualizarBusca('');
                      },
                      child: const Text('Limpar filtros'),
                    ),
                  ],
                ),
              ),
            )
          else
            ...items.map(
              (service) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ServiceItemCard(
                  service: service,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    appState.selecionarServico(service);
                    Navigator.of(context).pushNamed(
                      AppRoutes.professionalDetail,
                    );
                  },
                  onBookPressed: () {
                    HapticFeedback.selectionClick();
                    appState.selecionarServico(service);
                    Navigator.of(context).pushNamed(AppRoutes.slotSelector);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/routes.dart';
import '../core/theme.dart';
import '../models/appointment_model.dart';
import '../models/service_model.dart';
import '../state/app_state.dart';
import '../widgets/service_item_card.dart';
import '../widgets/slot_filter_chip.dart';

/// Tela 3 — Home / Dashboard Principal do Cliente (SSOT).
///
/// Concentra barra de busca em tempo real, carrossel de categorias com
/// [AgendaFilterChip], cartão de destaque do próximo agendamento com
/// [AppointmentStatusBadge] e atalho "Reagendar em 1 toque" (Heurística 7),
/// catálogo com [ServiceItemCard] e [NavigationBar] conectando Telas 3, 5, 12 e 4.
class HomeCustomerView extends StatefulWidget {
  /// Cria o dashboard do cliente [HomeCustomerView].
  const HomeCustomerView({super.key});

  @override
  State<HomeCustomerView> createState() => _HomeCustomerViewState();
}

class _HomeCustomerViewState extends State<HomeCustomerView> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleProfileAndNavigate(AppState appState) {
    HapticFeedback.selectionClick();
    appState.alternarPerfil(UserProfile.prestador);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 2),
          content: Text('Modo Prestador ativado.'),
        ),
      );
    Navigator.of(context).pushNamed(AppRoutes.providerTimeline);
  }

  void _handleOneTapRebook(AppState appState, AppointmentModel? reference) {
    HapticFeedback.selectionClick();
    final reserved = appState.reagendarEmUmToque(reference);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text(
            reserved
                ? 'Serviço e próximo horário livre pré-selecionados!'
                : 'Serviço selecionado. Escolha um horário livre.',
          ),
        ),
      );
    Navigator.of(context).pushNamed(
      reserved ? AppRoutes.checkout : AppRoutes.slotSelector,
    );
  }

  void _openTestScreensSheet() {
    HapticFeedback.selectionClick();
    final previewItems = AppRouter.catalog
        .where(
          (item) =>
              item.routeName != AppRoutes.splash &&
              item.routeName != AppRoutes.profileSwitch,
        )
        .toList(growable: false);

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.68,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, scrollController) {
            return ListView.separated(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.screenPadding,
                4,
                AppDimensions.screenPadding,
                AppDimensions.spacingMd,
              ),
              itemCount: previewItems.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppDimensions.spacingXs),
              itemBuilder: (context, index) {
                final descriptor = previewItems[index];
                return ListTile(
                  minVerticalPadding: 12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.controlRadius,
                    ),
                    side: const BorderSide(color: AppColors.outline),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: AppColors.primaryDark,
                    child: Text('${descriptor.screenNumber}'),
                  ),
                  title: Text(
                    'Tela ${descriptor.screenNumber} • ${descriptor.title}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    Navigator.of(context).pushNamed(descriptor.routeName);
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final textTheme = Theme.of(context).textTheme;
    final nextAppointment = appState.proximoAgendamento;
    final lastAppointment = nextAppointment ??
        (appState.appointments.isNotEmpty ? appState.appointments.first : null);
    final filteredServices = appState.filteredServices;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: AppDimensions.screenPadding,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Olá, ${appState.userName}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleLarge,
            ),
            Text(
              appState.isGuest
                  ? 'Modo Visitante • Cliente'
                  : 'Perfil ${appState.activeProfile.label}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _toggleProfileAndNavigate(appState),
            style: TextButton.styleFrom(
              minimumSize: const Size(
                AppDimensions.minTouchTarget,
                AppDimensions.minTouchTarget,
              ),
            ),
            icon: const Icon(Icons.swap_horiz_rounded, size: 20),
            label: const Text('Prestador'),
          ),
          if (appState.isTestPreviewMode)
            IconButton(
              tooltip: 'Visualização de teste',
              constraints: const BoxConstraints(
                minWidth: AppDimensions.minTouchTarget,
                minHeight: AppDimensions.minTouchTarget,
              ),
              onPressed: _openTestScreensSheet,
              icon: const Icon(Icons.grid_view_rounded),
            ),
          const SizedBox(width: AppDimensions.spacingXs),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.screenPadding,
            AppDimensions.spacingXs,
            AppDimensions.screenPadding,
            AppDimensions.spacingMd,
          ),
          children: [
            // Campo de busca com resposta instantânea (< 100 ms).
            TextField(
              controller: _searchController,
              onChanged: appState.atualizarBusca,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Buscar corte, barba, estética...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: appState.searchQuery.isNotEmpty
                    ? IconButton(
                        tooltip: 'Limpar busca',
                        constraints: const BoxConstraints(
                          minWidth: AppDimensions.minTouchTarget,
                          minHeight: AppDimensions.minTouchTarget,
                        ),
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          _searchController.clear();
                          appState.atualizarBusca('');
                        },
                        icon: const Icon(Icons.close_rounded),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMd),

            // Cartão em destaque: Próximo agendamento.
            Text(
              'Próximo agendamento',
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: AppDimensions.spacingXs),
            _NextAppointmentCard(
              appointment: nextAppointment,
              canRebookLast: lastAppointment != null,
              onOneTapRebook: () =>
                  _handleOneTapRebook(appState, lastAppointment),
              onManage: () {
                HapticFeedback.selectionClick();
                Navigator.of(context).pushNamed(AppRoutes.customerHistory);
              },
              onBookNew: () {
                HapticFeedback.selectionClick();
                Navigator.of(context).pushNamed(AppRoutes.catalogServices);
              },
            ),
            const SizedBox(height: AppDimensions.spacingMd),

            // Carrossel horizontal de categorias com AgendaFilterChip.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Categorias', style: textTheme.titleLarge),
                TextButton(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    Navigator.of(context).pushNamed(AppRoutes.catalogServices);
                  },
                  child: const Text('Ver tudo'),
                ),
              ],
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
                    selected:
                        appState.selectedCategory == ServiceCategory.cabelo,
                    onTap: () =>
                        appState.selecionarCategoria(ServiceCategory.cabelo),
                  ),
                  const SizedBox(width: AppDimensions.spacingXs),
                  AgendaFilterChip(
                    label: ServiceCategory.barba.label,
                    icon: Icons.face_retouching_natural_rounded,
                    selected:
                        appState.selectedCategory == ServiceCategory.barba,
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
            const SizedBox(height: AppDimensions.spacingMd),

            // Lista de serviços com componente reutilizável ServiceItemCard.
            Text(
              'Serviços disponíveis (${filteredServices.length})',
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            if (filteredServices.isEmpty)
              _EmptySearchCard(
                onReset: () {
                  HapticFeedback.selectionClick();
                  _searchController.clear();
                  appState.atualizarBusca('');
                  appState.selecionarCategoria(null);
                },
              )
            else
              ...filteredServices.map(
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
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          HapticFeedback.selectionClick();
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.of(context).pushNamed(AppRoutes.catalogServices);
            case 2:
              Navigator.of(context).pushNamed(AppRoutes.customerHistory);
            case 3:
              Navigator.of(context).pushNamed(AppRoutes.profileSwitch);
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.store_mall_directory_outlined),
            selectedIcon: Icon(Icons.store_mall_directory_rounded),
            label: 'Catálogo',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_rounded),
            selectedIcon: Icon(Icons.calendar_today_rounded),
            label: 'Histórico',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class _NextAppointmentCard extends StatelessWidget {
  const _NextAppointmentCard({
    required this.appointment,
    required this.canRebookLast,
    required this.onOneTapRebook,
    required this.onManage,
    required this.onBookNew,
  });

  final AppointmentModel? appointment;
  final bool canRebookLast;
  final VoidCallback onOneTapRebook;
  final VoidCallback onManage;
  final VoidCallback onBookNew;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (appointment == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingSm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Nenhum agendamento ativo',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Escolha um serviço abaixo ou repita seu último procedimento em 1 toque.',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: AppDimensions.spacingSm),
              Wrap(
                spacing: AppDimensions.spacingXs,
                runSpacing: AppDimensions.spacingXs,
                children: [
                  FilledButton.icon(
                    onPressed: onBookNew,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(
                        AppDimensions.minTouchTarget,
                        AppDimensions.minTouchTarget,
                      ),
                    ),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Agendar agora'),
                  ),
                  if (canRebookLast)
                    OutlinedButton.icon(
                      onPressed: onOneTapRebook,
                      icon: const Icon(Icons.replay_rounded),
                      label: const Text('Reagendar em 1 toque'),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    final item = appointment!;
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingSm),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppointmentStatusBadge(status: item.status),
              const SizedBox(width: AppDimensions.spacingXs),
              Expanded(
                child: Text(
                  '${item.dataFormatada} • ${item.hora}',
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            item.servicoNome,
            style: textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            item.prestador,
            style: TextStyle(
              color: Colors.white.withAlpha(230),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          LayoutBuilder(
            builder: (context, constraints) {
              final rebookButton = FilledButton.icon(
                onPressed: onOneTapRebook,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primaryDark,
                  minimumSize: const Size(
                    AppDimensions.minTouchTarget,
                    AppDimensions.minTouchTarget,
                  ),
                ),
                icon: const Icon(Icons.replay_rounded, size: 18),
                label: const Text(
                  'Reagendar em 1 toque',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );

              final manageButton = OutlinedButton(
                onPressed: onManage,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 1.5),
                  minimumSize: const Size(
                    AppDimensions.minTouchTarget,
                    AppDimensions.minTouchTarget,
                  ),
                ),
                child: const Text(
                  'Gerenciar',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );

              if (constraints.maxWidth < 310) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    rebookButton,
                    const SizedBox(height: AppDimensions.spacingXs),
                    manageButton,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(flex: 3, child: rebookButton),
                  const SizedBox(width: AppDimensions.spacingXs),
                  Expanded(flex: 2, child: manageButton),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EmptySearchCard extends StatelessWidget {
  const _EmptySearchCard({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        child: Column(
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: 36,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: AppDimensions.spacingXs),
            Text(
              'Nenhum serviço encontrado',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tente outro termo ou limpe os filtros aplicados.',
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            OutlinedButton(
              onPressed: onReset,
              child: const Text('Limpar filtros'),
            ),
          ],
        ),
      ),
    );
  }
}

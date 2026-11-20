import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/routes.dart';
import '../core/theme.dart';
import '../models/appointment_model.dart';
import '../models/service_model.dart';
import '../state/app_state.dart';
import '../widgets/service_item_card.dart';

class HomeCustomerView extends StatefulWidget {
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

  Future<void> _confirmCancelAppointment(
    AppState appState,
    AppointmentModel appointment,
  ) async {
    HapticFeedback.selectionClick();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cancelar agendamento?'),
          content: Text(
            'Deseja cancelar "${appointment.servicoNome}" marcado para '
            '${appointment.dataFormatada} às ${appointment.hora}? '
            'O horário voltará a ficar livre.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Manter'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                minimumSize: const Size(
                  AppDimensions.minTouchTarget,
                  AppDimensions.minTouchTarget,
                ),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Confirmar cancelamento'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;
    appState.alterarStatusAgendamento(
      appointment.id,
      AppointmentStatus.cancelado,
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 2),
          content: Text('Agendamento cancelado e horário liberado.'),
        ),
      );
  }

  void _openNotificationsSheet(AppState appState) {
    HapticFeedback.selectionClick();
    final active = appState.agendamentosAtivos;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.screenPadding,
              4,
              AppDimensions.screenPadding,
              AppDimensions.spacingMd,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Notificações e Lembretes',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppDimensions.spacingXs),
                if (active.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.spacingSm,
                    ),
                    child: Text(
                      'Nenhum lembrete pendente no momento.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                else
                  ...active.map(
                    (apt) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppDimensions.spacingXs,
                      ),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.controlRadius,
                          ),
                          side: const BorderSide(color: AppColors.outline),
                        ),
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.primaryContainer,
                          foregroundColor: AppColors.primaryDark,
                          child: Icon(Icons.notifications_active_outlined),
                        ),
                        title: Text(
                          apt.servicoNome,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${apt.dataFormatada} às ${apt.hora} • ${apt.prestador}',
                        ),
                        onTap: () {
                          Navigator.of(sheetContext).pop();
                          Navigator.of(context)
                              .pushNamed(AppRoutes.customerHistory);
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final textTheme = Theme.of(context).textTheme;
    final nextAppointment = appState.proximoAgendamento;
    final allAppointments = appState.appointments;
    final lastAppointment = nextAppointment ??
        (allAppointments.isNotEmpty ? allAppointments.first : null);
    final filteredServices = appState.filteredServices;
    final recentAppointments = allAppointments
        .where((apt) => apt.id != nextAppointment?.id)
        .toList(growable: false);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.screenPadding,
            AppDimensions.spacingSm,
            AppDimensions.screenPadding,
            AppDimensions.spacingMd,
          ),
          children: [
            // Cabeçalho: Saudação + Notificações + Perfil (Tela 4).
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Olá, ${appState.userName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        appState.isGuest
                            ? 'Modo Visitante • Agende sem cadastro'
                            : 'Bem-vindo de volta ao AgendaFácil',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingXs),
                _HeaderCircleButton(
                  tooltip: 'Notificações',
                  icon: Icons.notifications_none_rounded,
                  hasBadge: appState.agendamentosAtivos.isNotEmpty,
                  onPressed: () => _openNotificationsSheet(appState),
                ),
                const SizedBox(width: AppDimensions.spacingXs),
                _HeaderCircleButton(
                  tooltip: 'Perfil e alternância de modo',
                  icon: Icons.person_outline_rounded,
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    Navigator.of(context).pushNamed(AppRoutes.profileSwitch);
                  },
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingSm),

            // Barra de busca em tempo real (< 100 ms).
            TextField(
              controller: _searchController,
              onChanged: appState.atualizarBusca,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Buscar serviços, profissionais...',
                fillColor: AppColors.surfaceVariant,
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.onSurfaceVariant,
                ),
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

            // Carrossel horizontal de categorias circulares (>= 48x48 dp).
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CategoryCircleItem(
                    label: 'Todos',
                    icon: Icons.apps_rounded,
                    selected: appState.selectedCategory == null,
                    onTap: () => appState.selecionarCategoria(null),
                  ),
                  const SizedBox(width: AppDimensions.spacingSm),
                  _CategoryCircleItem(
                    label: ServiceCategory.cabelo.label,
                    icon: Icons.content_cut_rounded,
                    selected:
                        appState.selectedCategory == ServiceCategory.cabelo,
                    onTap: () =>
                        appState.selecionarCategoria(ServiceCategory.cabelo),
                  ),
                  const SizedBox(width: AppDimensions.spacingSm),
                  _CategoryCircleItem(
                    label: ServiceCategory.barba.label,
                    icon: Icons.face_retouching_natural_rounded,
                    selected:
                        appState.selectedCategory == ServiceCategory.barba,
                    onTap: () =>
                        appState.selecionarCategoria(ServiceCategory.barba),
                  ),
                  const SizedBox(width: AppDimensions.spacingSm),
                  _CategoryCircleItem(
                    label: ServiceCategory.estetica.label,
                    icon: Icons.spa_outlined,
                    selected:
                        appState.selectedCategory == ServiceCategory.estetica,
                    onTap: () =>
                        appState.selecionarCategoria(ServiceCategory.estetica),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMd),

            // Próximo agendamento (Card de destaque conforme Wireframe + Heurística 7).
            Text(
              'Próximo agendamento',
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: AppDimensions.spacingXs),
            _NextAppointmentHighlightCard(
              appointment: nextAppointment,
              canRebookLast: lastAppointment != null,
              onOneTapRebook: () =>
                  _handleOneTapRebook(appState, lastAppointment),
              onManage: () {
                HapticFeedback.selectionClick();
                Navigator.of(context).pushNamed(AppRoutes.customerHistory);
              },
              onCancel: nextAppointment == null
                  ? null
                  : () => _confirmCancelAppointment(appState, nextAppointment),
              onBookNew: () {
                HapticFeedback.selectionClick();
                Navigator.of(context).pushNamed(AppRoutes.catalogServices);
              },
            ),
            const SizedBox(height: AppDimensions.spacingMd),

            // Populares perto de você (Carrossel horizontal do Wireframe).
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Populares perto de você',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleLarge,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    Navigator.of(context).pushNamed(AppRoutes.catalogServices);
                  },
                  child: const Text('Ver todos'),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingXs),
            SizedBox(
              height: 184,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: appState.services.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppDimensions.spacingXs),
                itemBuilder: (context, index) {
                  final service = appState.services[index];
                  final distanceKm = (1.2 + index * 0.6).toStringAsFixed(1);
                  return _PopularPlaceCard(
                    service: service,
                    distanceLabel: '$distanceKm km',
                    onTap: () {
                      HapticFeedback.selectionClick();
                      appState.selecionarServico(service);
                      Navigator.of(context)
                          .pushNamed(AppRoutes.professionalDetail);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMd),

            // Serviços disponíveis (lista filtrada reativamente).
            Text(
              'Serviços disponíveis (${filteredServices.length})',
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: AppDimensions.spacingXs),
            if (filteredServices.isEmpty)
              _EmptyFilterCard(
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
                      Navigator.of(context)
                          .pushNamed(AppRoutes.professionalDetail);
                    },
                    onBookPressed: () {
                      HapticFeedback.selectionClick();
                      appState.selecionarServico(service);
                      Navigator.of(context).pushNamed(AppRoutes.slotSelector);
                    },
                  ),
                ),
              ),

            // Seus últimos agendamentos (conforme Wireframe).
            if (recentAppointments.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.spacingXs),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Seus últimos agendamentos',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleLarge,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      Navigator.of(context)
                          .pushNamed(AppRoutes.customerHistory);
                    },
                    child: const Text('Histórico'),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingXs),
              ...recentAppointments.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppDimensions.spacingXs,
                  ),
                  child: _RecentAppointmentTile(
                    appointment: item,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      Navigator.of(context)
                          .pushNamed(AppRoutes.customerHistory);
                    },
                    onRebook: () => _handleOneTapRebook(appState, item),
                  ),
                ),
              ),
            ],
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
              Navigator.of(context).pushNamed(AppRoutes.slotSelector);
            case 3:
              Navigator.of(context).pushNamed(AppRoutes.customerHistory);
            case 4:
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
            icon: Icon(Icons.search_rounded),
            selectedIcon: Icon(Icons.manage_search_rounded),
            label: 'Buscar',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today_rounded),
            label: 'Agenda',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_rounded),
            selectedIcon: Icon(Icons.history_toggle_off_rounded),
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

class _HeaderCircleButton extends StatelessWidget {
  const _HeaderCircleButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.hasBadge = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final bool hasBadge;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: AppColors.surfaceVariant,
          shape: const CircleBorder(
            side: BorderSide(color: AppColors.outline),
          ),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: SizedBox(
              width: AppDimensions.minTouchTarget,
              height: AppDimensions.minTouchTarget,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(icon, color: AppColors.onSurface, size: 22),
                  if (hasBadge)
                    Positioned(
                      top: 11,
                      right: 11,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryCircleItem extends StatelessWidget {
  const _CategoryCircleItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final circleColor =
        selected ? AppColors.primaryContainer : AppColors.surfaceVariant;
    final borderColor = selected ? AppColors.primary : AppColors.outline;
    final iconColor = selected ? AppColors.primaryDark : AppColors.onSurface;

    return Semantics(
      button: true,
      selected: selected,
      label: 'Categoria $label',
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.controlRadius),
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: 68,
            minHeight: AppDimensions.minTouchTarget,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: AppDurations.instantFeedback,
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: circleColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: borderColor,
                      width: selected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected
                        ? AppColors.primaryDark
                        : AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NextAppointmentHighlightCard extends StatelessWidget {
  const _NextAppointmentHighlightCard({
    required this.appointment,
    required this.canRebookLast,
    required this.onOneTapRebook,
    required this.onManage,
    required this.onCancel,
    required this.onBookNew,
  });

  final AppointmentModel? appointment;
  final bool canRebookLast;
  final VoidCallback onOneTapRebook;
  final VoidCallback onManage;
  final VoidCallback? onCancel;
  final VoidCallback onBookNew;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (appointment == null) {
      return Card(
        color: AppColors.surface,
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
              const SizedBox(height: 4),
              Text(
                'Escolha um serviço abaixo ou repita seu último atendimento em 1 toque.',
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
    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingSm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.servicoNome,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Profissional: ${item.prestador}',
                        style: textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingXs),
                AppointmentStatusBadge(status: item.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: AppDimensions.spacingXs),
                Expanded(
                  child: Text(
                    '${item.dataFormatada} • ${item.hora}',
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: AppDimensions.spacingXs),
                Expanded(
                  child: Text(
                    item.prestador,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            LayoutBuilder(
              builder: (context, constraints) {
                final rebookBtn = OutlinedButton.icon(
                  onPressed: onOneTapRebook,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
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

                final manageBtn = OutlinedButton(
                  onPressed: onManage,
                  onLongPress: onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.onSurface,
                    side: const BorderSide(color: AppColors.outline, width: 1),
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
                      rebookBtn,
                      const SizedBox(height: AppDimensions.spacingXs),
                      manageBtn,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(flex: 3, child: rebookBtn),
                    const SizedBox(width: AppDimensions.spacingXs),
                    Expanded(flex: 2, child: manageBtn),
                  ],
                );
              },
            ),
            if (onCancel != null) ...[
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onCancel,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                  ),
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: const Text('Cancelar agendamento'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PopularPlaceCard extends StatelessWidget {
  const _PopularPlaceCard({
    required this.service,
    required this.distanceLabel,
    required this.onTap,
  });

  final ServiceModel service;
  final String distanceLabel;
  final VoidCallback onTap;

  IconData _iconForCategory(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.cabelo:
        return Icons.content_cut_rounded;
      case ServiceCategory.barba:
        return Icons.face_retouching_natural_rounded;
      case ServiceCategory.estetica:
        return Icons.spa_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: 176,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 76,
                width: double.infinity,
                color: AppColors.surfaceVariant,
                alignment: Alignment.center,
                child: Icon(
                  _iconForCategory(service.categoria),
                  size: 30,
                  color: AppColors.primary,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.prestadorNome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 15,
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
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '• ${service.categoria.label}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      distanceLabel,
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentAppointmentTile extends StatelessWidget {
  const _RecentAppointmentTile({
    required this.appointment,
    required this.onTap,
    required this.onRebook,
  });

  final AppointmentModel appointment;
  final VoidCallback onTap;
  final VoidCallback onRebook;

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.servicoNome,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          appointment.prestador,
                          style: textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${appointment.dataFormatada} às ${appointment.hora}',
                          style: textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingXs),
                  AppointmentStatusBadge(status: appointment.status),
                ],
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onRebook,
                  icon: const Icon(Icons.replay_rounded, size: 18),
                  label: const Text('Reagendar em 1 toque'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyFilterCard extends StatelessWidget {
  const _EmptyFilterCard({required this.onReset});

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
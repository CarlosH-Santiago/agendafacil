import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../state/app_state.dart';
import '../../widgets/primary_cta_button.dart';
import '../../widgets/slot_filter_chip.dart';

class ProfileSwitchView extends StatelessWidget {
  const ProfileSwitchView({super.key});

  void _handleBack(BuildContext context) {
    HapticFeedback.selectionClick();
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      navigator.pushReplacementNamed(AppRoutes.homeCustomer);
    }
  }

  void _switchProfile(
    BuildContext context,
    AppState appState,
    UserProfile target,
  ) {
    HapticFeedback.selectionClick();
    appState.alternarPerfil(target);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          content: Text(
            target == UserProfile.prestador
                ? 'Modo Prestador ativado.'
                : 'Visão do Cliente ativada.',
          ),
        ),
      );
  }

  Future<void> _openProgressiveUpgradeSheet(
    BuildContext context,
    AppState appState,
  ) async {
    HapticFeedback.selectionClick();
    final emailController = TextEditingController(text: appState.userEmail);
    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppDimensions.screenPadding,
            4,
            AppDimensions.screenPadding,
            bottomInset + AppDimensions.spacingMd,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Identificar conta',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'Salve seu nome e histórico sem perder o agendamento atual.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Seu e-mail',
                    hintText: 'nome@exemplo.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty ||
                        !text.contains('@') ||
                        !text.contains('.')) {
                      return 'Informe um e-mail válido.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                PrimaryCtaButton(
                  label: 'Salvar identificação',
                  icon: Icons.check_circle_outline_rounded,
                  onPressed: () {
                    if (!(formKey.currentState?.validate() ?? false)) return;
                    appState.autenticarComEmail(emailController.text);
                    Navigator.of(sheetContext).pop();
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          duration: const Duration(seconds: 2),
                          content: Text(
                            'Conta identificada como ${appState.userName}.',
                          ),
                        ),
                      );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final textTheme = Theme.of(context).textTheme;
    final isProvider = appState.activeProfile == UserProfile.prestador;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Voltar',
          constraints: const BoxConstraints(
            minWidth: AppDimensions.minTouchTarget,
            minHeight: AppDimensions.minTouchTarget,
          ),
          onPressed: () => _handleBack(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(
          isProvider ? 'Dashboard do Prestador' : 'Perfil e Modo de Uso',
        ),
        actions: [
          IconButton(
            tooltip: 'Ir para Início',
            constraints: const BoxConstraints(
              minWidth: AppDimensions.minTouchTarget,
              minHeight: AppDimensions.minTouchTarget,
            ),
            onPressed: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.homeCustomer,
                (route) => false,
              );
            },
            icon: const Icon(Icons.home_outlined),
          ),
          const SizedBox(width: AppDimensions.spacingXs),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Cartão de Identidade do Usuário + Status do Perfil.
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.spacingSm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: AppColors.primaryContainer,
                            foregroundColor: AppColors.primaryDark,
                            child: Icon(
                              isProvider
                                  ? Icons.storefront_rounded
                                  : Icons.person_rounded,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: AppDimensions.spacingSm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  appState.userName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.titleLarge,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  appState.isGuest
                                      ? 'Visitante • Sem cadastro obrigatório'
                                      : (appState.userEmail.isEmpty
                                          ? 'Conta identificada'
                                          : appState.userEmail),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppDimensions.spacingXs),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isProvider
                                  ? AppColors.secondaryContainer
                                  : AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              appState.activeProfile.label,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isProvider
                                    ? AppColors.secondary
                                    : AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (appState.isGuest) ...[
                        const SizedBox(height: AppDimensions.spacingSm),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.warningContainer,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.controlRadius,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline_rounded,
                                    color: AppColors.warningForeground,
                                    size: 20,
                                  ),
                                  const SizedBox(
                                    width: AppDimensions.spacingXs,
                                  ),
                                  Expanded(
                                    child: Text(
                                      'Você está no modo visitante. Identifique seu e-mail quando quiser salvar seu histórico.',
                                      style: textTheme.bodySmall?.copyWith(
                                        color: AppColors.warningForeground,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppDimensions.spacingXs),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () =>
                                      _openProgressiveUpgradeSheet(
                                    context,
                                    appState,
                                  ),
                                  icon: const Icon(
                                    Icons.person_add_alt_1_rounded,
                                    size: 18,
                                  ),
                                  label: const Text('Completar cadastro'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.spacingSm),

              // Alternador Bilateral Instantâneo (Cliente ⇄ Prestador).
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.spacingSm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alternar modo do aplicativo',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Alterne instantaneamente entre agendar serviços como Cliente ou gerenciar atendimentos como Prestador.',
                        style: textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppDimensions.spacingXs),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          isProvider
                              ? 'Painel do Prestador ativo'
                              : 'Visão do Cliente ativa',
                          style: textTheme.titleMedium,
                        ),
                        subtitle: Text(
                          isProvider
                              ? 'Linha do tempo vertical, bloqueios e regras'
                              : 'Busca de serviços, horários livres e histórico',
                          style: textTheme.bodySmall,
                        ),
                        value: isProvider,
                        onChanged: (enabled) => _switchProfile(
                          context,
                          appState,
                          enabled ? UserProfile.prestador : UserProfile.cliente,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingXs),
                      Row(
                        children: [
                          Expanded(
                            child: AgendaFilterChip(
                              label: 'Visão do Cliente',
                              icon: Icons.person_outline_rounded,
                              selected: !isProvider,
                              onTap: () => _switchProfile(
                                context,
                                appState,
                                UserProfile.cliente,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppDimensions.spacingXs),
                          Expanded(
                            child: AgendaFilterChip(
                              label: 'Painel do Prestador',
                              icon: Icons.storefront_outlined,
                              selected: isProvider,
                              onTap: () => _switchProfile(
                                context,
                                appState,
                                UserProfile.prestador,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.spacingMd),

              // Acessos rápidos contextualizados (Wireframe Dashboard do Prestador / Cliente).
              if (isProvider) ...[
                Text(
                  'Acessos rápidos',
                  style: textTheme.titleLarge,
                ),
                const SizedBox(height: AppDimensions.spacingXs),
                _DashboardGridSection(
                  items: [
                    _DashboardTileData(
                      label: 'Agenda',
                      subtitle: '${appState.agendamentosAtivos.length} ativos',
                      icon: Icons.calendar_today_outlined,
                      onTap: () => Navigator.of(context)
                          .pushNamed(AppRoutes.providerTimeline),
                    ),
                    _DashboardTileData(
                      label: 'Atendimentos',
                      subtitle: 'Controle de status',
                      icon: Icons.assignment_outlined,
                      onTap: () => Navigator.of(context)
                          .pushNamed(AppRoutes.appointmentStatus),
                    ),
                    _DashboardTileData(
                      label: 'Serviços',
                      subtitle: '${appState.services.length} ofertados',
                      icon: Icons.content_cut_rounded,
                      onTap: () => Navigator.of(context)
                          .pushNamed(AppRoutes.catalogServices),
                    ),
                    _DashboardTileData(
                      label: 'Clientes',
                      subtitle: '${appState.appointments.length} registros',
                      icon: Icons.people_outline_rounded,
                      onTap: () => Navigator.of(context)
                          .pushNamed(AppRoutes.customerHistory),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingMd),
                Text(
                  'Mais áreas',
                  style: textTheme.titleLarge,
                ),
                const SizedBox(height: AppDimensions.spacingXs),
                _DashboardGridSection(
                  items: [
                    _DashboardTileData(
                      label: 'Histórico',
                      subtitle: 'Todos atendimentos',
                      icon: Icons.history_rounded,
                      onTap: () => Navigator.of(context)
                          .pushNamed(AppRoutes.customerHistory),
                    ),
                    _DashboardTileData(
                      label: 'Avaliações',
                      subtitle: 'Feedbacks recebidos',
                      icon: Icons.star_outline_rounded,
                      onTap: () => Navigator.of(context)
                          .pushNamed(AppRoutes.ratingReview),
                    ),
                    _DashboardTileData(
                      label: 'Disponibilidade',
                      subtitle: '${appState.availableSlots.length} horários',
                      icon: Icons.event_busy_outlined,
                      onTap: () => Navigator.of(context)
                          .pushNamed(AppRoutes.slotSelector),
                    ),
                    _DashboardTileData(
                      label: 'Regras e políticas',
                      subtitle:
                          'Cancelamento ${appState.janelaCancelamentoHoras}h',
                      icon: Icons.verified_user_outlined,
                      onTap: () => Navigator.of(context)
                          .pushNamed(AppRoutes.providerSettingsRules),
                    ),
                  ],
                ),
              ] else ...[
                Text(
                  'Atalhos da sua conta',
                  style: textTheme.titleLarge,
                ),
                const SizedBox(height: AppDimensions.spacingXs),
                _DashboardGridSection(
                  items: [
                    _DashboardTileData(
                      label: 'Meus agendamentos',
                      subtitle: '${appState.agendamentosAtivos.length} ativos',
                      icon: Icons.calendar_today_outlined,
                      onTap: () => Navigator.of(context)
                          .pushNamed(AppRoutes.customerHistory),
                    ),
                    _DashboardTileData(
                      label: 'Explorar serviços',
                      subtitle: '${appState.services.length} opções',
                      icon: Icons.storefront_outlined,
                      onTap: () => Navigator.of(context)
                          .pushNamed(AppRoutes.catalogServices),
                    ),
                    _DashboardTileData(
                      label: 'Avaliar atendimento',
                      subtitle: 'Compartilhar nota',
                      icon: Icons.star_outline_rounded,
                      onTap: () => Navigator.of(context)
                          .pushNamed(AppRoutes.ratingReview),
                    ),
                    _DashboardTileData(
                      label: 'Trocar conta',
                      subtitle: 'Login ou visitante',
                      icon: Icons.login_rounded,
                      onTap: () =>
                          Navigator.of(context).pushNamed(AppRoutes.login),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: ThumbZoneBottomBar(
        child: PrimaryCtaButton(
          label: isProvider
              ? 'Abrir Agenda do Prestador'
              : 'Alternar para Painel do Prestador',
          icon: isProvider
              ? Icons.calendar_view_day_rounded
              : Icons.swap_horiz_rounded,
          onPressed: () {
            if (!isProvider) {
              appState.alternarPerfil(UserProfile.prestador);
            }
            Navigator.of(context).pushNamed(AppRoutes.providerTimeline);
          },
        ),
      ),
    );
  }
}

class _DashboardTileData {
  const _DashboardTileData({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
}

class _DashboardGridSection extends StatelessWidget {
  const _DashboardGridSection({required this.items});

  final List<_DashboardTileData> items;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 300;
        final crossAxisCount = isNarrow ? 1 : 2;
        final itemWidth = isNarrow
            ? constraints.maxWidth
            : (constraints.maxWidth - AppDimensions.spacingXs) / 2;

        return Wrap(
          spacing: AppDimensions.spacingXs,
          runSpacing: AppDimensions.spacingXs,
          children: items.map((item) {
            return SizedBox(
              width: itemWidth,
              child: Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    item.onTap();
                  },
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: crossAxisCount == 1 ? 72 : 112,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.spacingSm),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              item.icon,
                              color: AppColors.onSurface,
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            item.label,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(growable: false),
        );
      },
    );
  }
}
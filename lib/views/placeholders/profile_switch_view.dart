import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../state/app_state.dart';
import '../../widgets/slot_filter_chip.dart';
import 'placeholder_screen_scaffold.dart';

/// Tela 4 — Perfil e Alternância de Modo (Cliente ↔ Prestador).
///
/// Permite gerenciar dados básicos da conta, converter visita em cadastro
/// completo e comutar instantaneamente entre a Visão do Cliente e o Painel do Prestador.
class ProfileSwitchView extends StatelessWidget {
  /// Cria a tela [ProfileSwitchView].
  const ProfileSwitchView({super.key});

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
                ? 'Painel do Prestador ativado.'
                : 'Visão do Cliente ativada.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final textTheme = Theme.of(context).textTheme;
    final isProvider = appState.activeProfile == UserProfile.prestador;

    return PlaceholderScreenScaffold(
      screenNumber: 4,
      title: 'Perfil e Alternância de Modo',
      description:
          'Comutação bilateral instantânea entre Visão do Cliente e Painel do Prestador, além da gestão progressiva da conta.',
      primaryActionLabel: isProvider
          ? 'Abrir Painel do Prestador'
          : 'Alternar para Painel do Prestador',
      primaryRoute: AppRoutes.providerTimeline,
      onPrimaryAction: () {
        if (!isProvider) {
          appState.alternarPerfil(UserProfile.prestador);
        }
        Navigator.of(context).pushNamed(AppRoutes.providerTimeline);
      },
      secondaryActionLabel:
          isProvider ? 'Voltar para Visão do Cliente' : 'Trocar conta / Login',
      secondaryRoute:
          isProvider ? AppRoutes.homeCustomer : AppRoutes.login,
      onSecondaryAction: () {
        if (isProvider) {
          appState.alternarPerfil(UserProfile.cliente);
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.homeCustomer,
            (route) => false,
          );
        } else {
          Navigator.of(context).pushNamed(AppRoutes.login);
        }
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
                              style: textTheme.titleLarge,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              appState.isGuest
                                  ? 'Acesso rápido como visitante'
                                  : (appState.userEmail.isEmpty
                                      ? 'Conta conectada'
                                      : appState.userEmail),
                              style: textTheme.bodyMedium,
                            ),
                          ],
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
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.warningForeground,
                            size: 20,
                          ),
                          const SizedBox(width: AppDimensions.spacingXs),
                          Expanded(
                            child: Text(
                              'Você está navegando sem cadastro. Entre com e-mail quando quiser salvar preferências.',
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.warningForeground,
                              ),
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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Modo de visualização do aplicativo',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Altere em um toque para testar o fluxo do cliente ou a agenda do profissional.',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppDimensions.spacingSm),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      isProvider ? 'Painel do Prestador' : 'Visão do Cliente',
                      style: textTheme.titleMedium,
                    ),
                    subtitle: Text(
                      isProvider
                          ? 'Exibindo linha do tempo vertical e regras'
                          : 'Exibindo busca de serviços e agendamentos',
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
        ],
      ),
    );
  }
}

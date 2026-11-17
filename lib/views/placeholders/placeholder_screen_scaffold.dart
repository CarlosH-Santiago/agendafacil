import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../widgets/primary_cta_button.dart';

/// Estrutura reutilizável para as telas modulares (Telas 4 a 14).
///
/// Padroniza `AppBar` com retorno explícito e atalho para a Home, cartão de
/// rastreabilidade (Tela, Dev responsável e Branch Git), margem lateral de
/// 16 dp, prevenção de overflow e barra inferior na Zona do Polegar.
class PlaceholderScreenScaffold extends StatelessWidget {
  /// Cria um esqueleto funcional padronizado para as telas 4 a 14.
  const PlaceholderScreenScaffold({
    super.key,
    required this.screenNumber,
    required this.title,
    required this.description,
    required this.primaryActionLabel,
    required this.primaryRoute,
    this.assignedDev,
    this.gitBranch,
    this.primaryIcon = Icons.arrow_forward_rounded,
    this.primaryEnabled = true,
    this.secondaryActionLabel,
    this.secondaryRoute,
    this.bodyContent,
    this.slivers,
    this.onPrimaryAction,
    this.onSecondaryAction,
    this.onBackPressed,
  }) : assert(
          bodyContent == null || slivers == null,
          'Forneça apenas bodyContent ou slivers, nunca ambos simultaneamente.',
        );

  /// Número identificador da tela no fluxo oficial (4 a 14).
  final int screenNumber;

  /// Título exibido na `AppBar` e no contexto da tela.
  final String title;

  /// Orientação objetiva sobre o papel funcional da tela no módulo.
  final String description;

  /// Desenvolvedor responsável conforme a Matriz 4.4 do Manual.
  final String? assignedDev;

  /// Branch Git designada para o desenvolvimento desta tela.
  final String? gitBranch;

  /// Rótulo do botão principal de avanço ancorado na Zona do Polegar.
  final String primaryActionLabel;

  /// Rota de destino padrão do botão principal.
  final String primaryRoute;

  /// Ícone exibido no botão principal do rodapé.
  final IconData primaryIcon;

  /// Define se o botão principal está habilitado (Heurística 5).
  final bool primaryEnabled;

  /// Rótulo opcional do botão secundário dentro do corpo rolável.
  final String? secondaryActionLabel;

  /// Rota opcional associada ao botão secundário.
  final String? secondaryRoute;

  /// Conteúdo interativo principal em telas baseadas em `SingleChildScrollView`.
  final Widget? bodyContent;

  /// Lista opcional de slivers para telas em `CustomScrollView` (ex.: Tela 10).
  final List<Widget>? slivers;

  /// Callback executado ao pressionar o CTA principal em vez da navegação padrão.
  final VoidCallback? onPrimaryAction;

  /// Callback opcional executado ao pressionar o botão secundário.
  final VoidCallback? onSecondaryAction;

  /// Callback opcional para personalizar a ação do botão explícito de voltar.
  final VoidCallback? onBackPressed;

  void _handleBack(BuildContext context) {
    HapticFeedback.selectionClick();
    if (onBackPressed != null) {
      onBackPressed!();
      return;
    }
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      navigator.pushReplacementNamed(AppRoutes.homeCustomer);
    }
  }

  void _handlePrimary(BuildContext context) {
    if (!primaryEnabled) return;
    HapticFeedback.selectionClick();
    if (onPrimaryAction != null) {
      onPrimaryAction!();
      return;
    }
    Navigator.of(context).pushNamed(primaryRoute);
  }

  void _handleSecondary(BuildContext context) {
    HapticFeedback.selectionClick();
    if (onSecondaryAction != null) {
      onSecondaryAction!();
      return;
    }
    if (secondaryRoute != null) {
      Navigator.of(context).pushNamed(secondaryRoute!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final descriptor = AppRouter.descriptorFor(screenNumber);
    final resolvedDev = assignedDev ?? descriptor?.assignedDev ?? 'Equipe';
    final resolvedBranch = gitBranch ?? descriptor?.gitBranch ?? 'dev';

    final metadataBanner = _PlaceholderMetadataBanner(
      screenNumber: screenNumber,
      title: title,
      assignedDev: resolvedDev,
      gitBranch: resolvedBranch,
      description: description,
    );

    final secondaryButton =
        secondaryActionLabel != null &&
                (secondaryRoute != null || onSecondaryAction != null)
            ? PrimaryCtaButton(
                label: secondaryActionLabel!,
                isOutlined: true,
                onPressed: () => _handleSecondary(context),
              )
            : null;

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
          'Tela $screenNumber • $title',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: 'Voltar para Home',
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
        child: slivers != null
            ? CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimensions.screenPadding,
                      AppDimensions.spacingXs,
                      AppDimensions.screenPadding,
                      AppDimensions.spacingSm,
                    ),
                    sliver: SliverToBoxAdapter(child: metadataBanner),
                  ),
                  ...slivers!,
                  if (secondaryButton != null)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppDimensions.screenPadding,
                        AppDimensions.spacingSm,
                        AppDimensions.screenPadding,
                        AppDimensions.spacingMd,
                      ),
                      sliver: SliverToBoxAdapter(child: secondaryButton),
                    )
                  else
                    const SliverPadding(
                      padding: EdgeInsets.only(bottom: AppDimensions.spacingMd),
                    ),
                ],
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    metadataBanner,
                    if (bodyContent != null) ...[
                      const SizedBox(height: AppDimensions.spacingSm),
                      bodyContent!,
                    ],
                    if (secondaryButton != null) ...[
                      const SizedBox(height: AppDimensions.spacingMd),
                      secondaryButton,
                    ],
                  ],
                ),
              ),
      ),
      bottomNavigationBar: ThumbZoneBottomBar(
        child: PrimaryCtaButton(
          label: primaryActionLabel,
          icon: primaryIcon,
          onPressed: primaryEnabled ? () => _handlePrimary(context) : null,
        ),
      ),
    );
  }
}

class _PlaceholderMetadataBanner extends StatelessWidget {
  const _PlaceholderMetadataBanner({
    required this.screenNumber,
    required this.title,
    required this.assignedDev,
    required this.gitBranch,
    required this.description,
  });

  final int screenNumber;
  final String title;
  final String assignedDev;
  final String gitBranch;
  final String description;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingSm),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(
          color: AppColors.primary.withAlpha(64),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppDimensions.spacingXs,
            runSpacing: AppDimensions.spacingXs,
            children: [
              _MetadataPill(
                icon: Icons.layers_outlined,
                label: 'Tela $screenNumber',
                isPrimary: true,
              ),
              _MetadataPill(
                icon: Icons.person_outline_rounded,
                label: assignedDev,
              ),
              _MetadataPill(
                icon: Icons.account_tree_outlined,
                label: gitBranch,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetadataPill extends StatelessWidget {
  const _MetadataPill({
    required this.icon,
    required this.label,
    this.isPrimary = false,
  });

  final IconData icon;
  final String label;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final background = isPrimary ? AppColors.primary : AppColors.surface;
    final foreground = isPrimary ? Colors.white : AppColors.primaryDark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: isPrimary ? null : Border.all(color: AppColors.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: foreground,
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

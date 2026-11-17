import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../state/app_state.dart';
import '../../widgets/primary_cta_button.dart';

/// Estrutura reutilizável para as telas modulares do fluxo de atendimento.
///
/// Padroniza `AppBar` com retorno explícito, margem lateral de 16 dp, prevenção
/// de overflow e barra inferior ancorada na Zona do Polegar. Exibe rótulo
/// numérico apenas quando o modo de visualização de teste está ativado.
class PlaceholderScreenScaffold extends StatelessWidget {
  /// Cria um esqueleto funcional padronizado para as telas do fluxo.
  const PlaceholderScreenScaffold({
    super.key,
    required this.screenNumber,
    required this.title,
    required this.description,
    required this.primaryActionLabel,
    required this.primaryRoute,
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

  /// Número identificador da tela utilizado exclusivamente em visualização de teste.
  final int screenNumber;

  /// Título exibido na `AppBar` da tela.
  final String title;

  /// Descrição funcional exibida somente no modo de visualização de teste.
  final String description;

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

  /// Lista opcional de slivers para telas em `CustomScrollView`.
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
    final isTestPreview = AppStateScope.of(context).isTestPreviewMode;

    final testPreviewBanner = isTestPreview
        ? _TestPreviewBanner(
            screenNumber: screenNumber,
            title: title,
            description: description,
          )
        : null;

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
          isTestPreview ? 'Tela $screenNumber • $title' : title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        child: slivers != null
            ? CustomScrollView(
                slivers: [
                  if (testPreviewBanner != null)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppDimensions.screenPadding,
                        AppDimensions.spacingXs,
                        AppDimensions.screenPadding,
                        AppDimensions.spacingSm,
                      ),
                      sliver: SliverToBoxAdapter(child: testPreviewBanner),
                    )
                  else
                    const SliverPadding(
                      padding: EdgeInsets.only(top: AppDimensions.spacingXs),
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
                    if (testPreviewBanner != null) ...[
                      testPreviewBanner,
                      const SizedBox(height: AppDimensions.spacingSm),
                    ],
                    if (bodyContent != null) bodyContent!,
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

class _TestPreviewBanner extends StatelessWidget {
  const _TestPreviewBanner({
    required this.screenNumber,
    required this.title,
    required this.description,
  });

  final int screenNumber;
  final String title;
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'Tela $screenNumber',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
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

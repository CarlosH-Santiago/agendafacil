import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/routes.dart';
import '../core/theme.dart';
import '../widgets/primary_cta_button.dart';

/// Tela 1 — Boas-vindas com identidade visual da marca e acesso ao Login.
///
/// Utiliza tipografia Display de 24 sp em negrito, margem lateral de 16 dp,
/// rolagem adaptativa contra overflow e ação principal ancorada na Zona do Polegar.
class SplashView extends StatefulWidget {
  /// Cria a tela inicial [SplashView].
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleStart() {
    HapticFeedback.selectionClick();
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.screenPadding,
                vertical: AppDimensions.spacingMd,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: (constraints.maxHeight -
                          (AppDimensions.spacingMd * 2))
                      .clamp(0.0, double.infinity),
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(36),
                              borderRadius: BorderRadius.circular(
                                AppDimensions.cardRadius,
                              ),
                              border: Border.all(
                                color: Colors.white.withAlpha(72),
                              ),
                            ),
                            child: const Icon(
                              Icons.calendar_month_rounded,
                              size: 38,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingMd),
                        Text(
                          'AgendaFácil',
                          style: textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            height: 32 / 24,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingXs),
                        Text(
                          'Agende serviços em menos de 45 segundos e gerencie atendimentos sem atrito.',
                          style: textTheme.titleMedium?.copyWith(
                            color: Colors.white.withAlpha(240),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingMd),
                        const _SplashHighlightPill(
                          icon: Icons.touch_app_rounded,
                          label: 'Horários livres com reserva imediata',
                        ),
                        const SizedBox(height: AppDimensions.spacingSm),
                        const _SplashHighlightPill(
                          icon: Icons.swap_horiz_rounded,
                          label: 'Experiência bilateral para cliente e prestador',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: ThumbZoneBottomBar(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PrimaryCtaButton(
              label: 'Começar',
              icon: Icons.arrow_forward_rounded,
              onPressed: _handleStart,
            ),
            const SizedBox(height: AppDimensions.spacingXs),
            Text(
              'Tema 11 • Agendamento de Serviços e Gestão de Atendimentos',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _SplashHighlightPill extends StatelessWidget {
  const _SplashHighlightPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingSm,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(28),
        borderRadius: BorderRadius.circular(AppDimensions.controlRadius),
        border: Border.all(color: Colors.white.withAlpha(48)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

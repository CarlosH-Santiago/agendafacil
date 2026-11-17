import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../models/appointment_model.dart';
import '../../state/app_state.dart';
import 'placeholder_screen_scaffold.dart';

/// Tela 13 — Avaliação do Serviço por Estrelas e Depoimento Opcional.
///
/// Oferece escala interativa de 1 a 5 estrelas com alvos >= 48x48 dp e campo
/// opcional para comentário rápido, gravando a avaliação no [AppState].
class RatingReviewView extends StatefulWidget {
  /// Cria a tela [RatingReviewView].
  const RatingReviewView({super.key});

  @override
  State<RatingReviewView> createState() => _RatingReviewViewState();
}

class _RatingReviewViewState extends State<RatingReviewView> {
  final TextEditingController _commentController = TextEditingController();
  int _selectedStars = 5;
  bool _initializedFromTarget = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  AppointmentModel? _resolveTarget(AppState appState, Object? routeArgs) {
    final appointments = appState.appointments;
    if (appointments.isEmpty) return null;

    if (routeArgs is String) {
      for (final apt in appointments) {
        if (apt.id == routeArgs) return apt;
      }
    }
    for (final apt in appointments) {
      if (apt.status == AppointmentStatus.finalizado) return apt;
    }
    return appointments.first;
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    final target = _resolveTarget(appState, routeArgs);
    final textTheme = Theme.of(context).textTheme;

    if (target != null && !_initializedFromTarget) {
      _initializedFromTarget = true;
      if (target.avaliacaoEstrelas != null) {
        _selectedStars = target.avaliacaoEstrelas!;
      }
      if ((target.comentarioAvaliacao ?? '').isNotEmpty) {
        _commentController.text = target.comentarioAvaliacao!;
      }
    }

    return PlaceholderScreenScaffold(
      screenNumber: 13,
      title: 'Avaliação do Serviço',
      description:
          'Coleta simplificada de feedback em escala de 1 a 5 estrelas com campo opcional para depoimento rápido.',
      primaryActionLabel: 'Enviar avaliação',
      primaryRoute: AppRoutes.customerHistory,
      primaryIcon: Icons.send_rounded,
      primaryEnabled: target != null,
      secondaryActionLabel: 'Voltar ao histórico',
      secondaryRoute: AppRoutes.customerHistory,
      onPrimaryAction: target == null
          ? null
          : () {
              appState.registrarAvaliacao(
                target.id,
                _selectedStars,
                _commentController.text,
              );
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(
                      'Avaliação de $_selectedStars estrela(s) registrada com sucesso!',
                    ),
                  ),
                );
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                Navigator.of(context).pushReplacementNamed(
                  AppRoutes.customerHistory,
                );
              }
            },
      bodyContent: target == null
          ? const Card(
              child: Padding(
                padding: EdgeInsets.all(AppDimensions.spacingSm),
                child: Text('Nenhum atendimento disponível para avaliação.'),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.spacingSm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          target.servicoNome,
                          style: textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Profissional Responsável: ${target.prestador}',
                          style: textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Realizado em ${target.dataFormatada} às ${target.hora}',
                          style: textTheme.bodySmall,
                        ),
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
                          'Como foi sua experiência?',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingXs),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 4,
                          children: List.generate(5, (index) {
                            final starValue = index + 1;
                            final isFilled = starValue <= _selectedStars;
                            return IconButton(
                              tooltip: '$starValue estrelas',
                              constraints: const BoxConstraints(
                                minWidth: AppDimensions.minTouchTarget,
                                minHeight: AppDimensions.minTouchTarget,
                              ),
                              iconSize: 36,
                              onPressed: () {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _selectedStars = starValue;
                                });
                              },
                              icon: Icon(
                                isFilled
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                color: isFilled
                                    ? AppColors.warning
                                    : AppColors.onSurfaceVariant,
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 4),
                        Center(
                          child: Text(
                            'Nota selecionada: $_selectedStars de 5 estrelas',
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimensions.spacingSm),
                        TextFormField(
                          controller: _commentController,
                          maxLines: 3,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            labelText: 'Comentário opcional',
                            hintText:
                                'Conte rapidamente o que você achou do atendimento...',
                            alignLabelWithHint: true,
                          ),
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

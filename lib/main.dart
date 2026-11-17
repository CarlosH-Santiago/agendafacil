import 'package:flutter/material.dart';

import 'core/routes.dart';
import 'core/theme.dart';
import 'state/app_state.dart';

void main() {
  runApp(const AgendaFacilApp());
}

/// Widget raiz do aplicativo AgendaFácil (Tema 11).
///
/// Fornece o [AppState] no topo da árvore de widgets via [AppStateScope] e
/// configura o [MaterialApp] com Material 3 e rotas nomeadas para as 14 telas.
class AgendaFacilApp extends StatefulWidget {
  /// Cria a instância raiz [AgendaFacilApp].
  const AgendaFacilApp({
    super.key,
    this.appState,
    this.initialRoute,
  });

  /// Instância opcional de [AppState] para injeção em testes automatizados.
  final AppState? appState;

  /// Rota inicial opcional para inspeção ou testes direcionados.
  final String? initialRoute;

  @override
  State<AgendaFacilApp> createState() => _AgendaFacilAppState();
}

class _AgendaFacilAppState extends State<AgendaFacilApp> {
  AppState? _ownedAppState;

  AppState get _resolvedAppState =>
      widget.appState ?? (_ownedAppState ??= AppState());

  @override
  void dispose() {
    _ownedAppState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      notifier: _resolvedAppState,
      child: MaterialApp(
        title: 'AgendaFácil',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: widget.initialRoute ?? AppRoutes.splash,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}

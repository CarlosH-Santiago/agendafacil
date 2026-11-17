import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agendafacil/core/routes.dart';
import 'package:agendafacil/core/theme.dart';
import 'package:agendafacil/main.dart';
import 'package:agendafacil/models/appointment_model.dart';
import 'package:agendafacil/state/app_state.dart';
import 'package:agendafacil/widgets/primary_cta_button.dart';
import 'package:agendafacil/widgets/slot_filter_chip.dart';

void main() {
  testWidgets('Fluxo inicial: Splash -> Login -> Visitante -> Home',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const AgendaFacilApp());
    await tester.pumpAndSettle();

    expect(find.text('AgendaFácil'), findsOneWidget);
    expect(find.text('Começar'), findsOneWidget);

    final startButtonSize = tester.getSize(find.byType(PrimaryCtaButton));
    expect(
      startButtonSize.height,
      greaterThanOrEqualTo(AppDimensions.primaryButtonHeight),
    );

    await tester.tap(find.text('Começar'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Voltar para boas-vindas'), findsOneWidget);
    expect(find.text('Entrar como Visitante'), findsOneWidget);
    expect(find.text('Sou Cliente'), findsOneWidget);
    expect(find.text('Sou Prestador'), findsOneWidget);

    final guestButtonSize = tester.getSize(
      find.widgetWithText(PrimaryCtaButton, 'Entrar como Visitante'),
    );
    expect(
      guestButtonSize.height,
      greaterThanOrEqualTo(AppDimensions.primaryButtonHeight),
    );

    await tester.tap(find.text('Entrar como Visitante'));
    await tester.pumpAndSettle();

    expect(find.text('Olá, Visitante'), findsOneWidget);
    expect(find.text('Próximo agendamento'), findsOneWidget);
    expect(find.text('Reagendar em 1 toque'), findsOneWidget);
    expect(find.text('Gerenciar'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    final firstChipSize = tester.getSize(find.byType(AgendaFilterChip).first);
    expect(firstChipSize.width, greaterThanOrEqualTo(AppDimensions.minTouchTarget));
    expect(
      firstChipSize.height,
      greaterThanOrEqualTo(AppDimensions.minTouchTarget),
    );
  });

  testWidgets('Botão voltar no Login retorna para a Splash (Heurística 3)',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const AgendaFacilApp(initialRoute: AppRoutes.login),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Voltar para boas-vindas'));
    await tester.pumpAndSettle();

    expect(find.text('AgendaFácil'), findsOneWidget);
    expect(find.text('Começar'), findsOneWidget);
  });

  test(
      'AppState: alternarPerfil, selecionarHorario (trava e bloqueios), '
      'liberarReservaTemporaria, confirmarAgendamento, alterarStatusAgendamento '
      'e reagendarEmUmToque', () {
    final state = AppState();
    final initialCount = state.appointments.length;

    // 1. alternarPerfil
    expect(state.activeProfile, UserProfile.cliente);
    state.alternarPerfil();
    expect(state.activeProfile, UserProfile.prestador);
    state.alternarPerfil(UserProfile.cliente);
    expect(state.activeProfile, UserProfile.cliente);

    // 2. selecionarHorario (Two-Phase Locking e bloqueio de ocupado/passado)
    state.selecionarHorario('16:00');
    expect(state.selectedSlot, '16:00');
    expect(
      state.selectedSlotModel?.status,
      SlotStatus.emReservaTemporaria,
    );
    expect(
      state.timeSlots.firstWhere((s) => s.hora == '15:00').status,
      SlotStatus.disponivel,
    );

    // Tentar selecionar horário ocupado ('14:00') ou passado ('09:00') não altera seleção.
    state.selecionarHorario('14:00');
    expect(state.selectedSlot, '16:00');
    expect(
      state.timeSlots.firstWhere((s) => s.hora == '14:00').status,
      SlotStatus.ocupado,
    );

    state.selecionarHorario('09:00');
    expect(state.selectedSlot, '16:00');
    expect(
      state.timeSlots.firstWhere((s) => s.hora == '09:00').status,
      SlotStatus.passado,
    );

    // 3. liberarReservaTemporaria
    state.liberarReservaTemporaria();
    expect(state.selectedSlot, isNull);
    expect(state.selectedSlotModel, isNull);
    expect(
      state.timeSlots.firstWhere((s) => s.hora == '16:00').status,
      SlotStatus.disponivel,
    );
    expect(state.confirmarAgendamento(), isNull);

    // 4. confirmarAgendamento
    state.selecionarHorario('16:00');
    final created = state.confirmarAgendamento();
    expect(created, isNotNull);
    expect(created!.hora, '16:00');
    expect(created.status, AppointmentStatus.confirmado);
    expect(state.appointments.length, initialCount + 1);
    expect(state.selectedSlot, isNull);
    expect(
      state.timeSlots.firstWhere((s) => s.hora == '16:00').status,
      SlotStatus.ocupado,
    );

    // 5. alterarStatusAgendamento (inclui liberação de vaga ao cancelar)
    state.alterarStatusAgendamento(created.id, AppointmentStatus.emAndamento);
    expect(
      state.appointments.firstWhere((a) => a.id == created.id).status,
      AppointmentStatus.emAndamento,
    );

    state.alterarStatusAgendamento(created.id, AppointmentStatus.cancelado);
    expect(
      state.appointments.firstWhere((a) => a.id == created.id).status,
      AppointmentStatus.cancelado,
    );
    expect(
      state.timeSlots.firstWhere((s) => s.hora == '16:00').status,
      SlotStatus.disponivel,
    );

    // 6. reagendarEmUmToque
    final pastAppointment = state.appointments.firstWhere(
      (a) => a.servicoNome == 'Limpeza de Pele Profunda',
    );
    final rebookOk = state.reagendarEmUmToque(pastAppointment);
    expect(rebookOk, isTrue);
    expect(state.selectedService?.nome, 'Limpeza de Pele Profunda');
    expect(state.selectedSlot, isNotNull);
    expect(
      state.selectedSlotModel?.status,
      SlotStatus.emReservaTemporaria,
    );

    // 7. Regras do prestador e avaliação
    state.atualizarRegrasPrestador(janelaHoras: 4, toleranciaMinutos: 10);
    expect(state.janelaCancelamentoHoras, 4);
    expect(state.toleranciaAtrasoMinutos, 10);

    state.registrarAvaliacao(pastAppointment.id, 5, 'Excelente atendimento');
    final reviewed = state.appointments.firstWhere(
      (a) => a.id == pastAppointment.id,
    );
    expect(reviewed.avaliacaoEstrelas, 5);
    expect(reviewed.comentarioAvaliacao, 'Excelente atendimento');
  });

  testWidgets(
      'Tela 7 (SlotSelectorView) previne avanço sem horário selecionado e '
      'respeita alvos >= 48x48 dp', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final state = AppState()..liberarReservaTemporaria();

    await tester.pumpWidget(
      AgendaFacilApp(
        appState: state,
        initialRoute: AppRoutes.slotSelector,
      ),
    );
    await tester.pumpAndSettle();

    final slotChipSize = tester.getSize(find.byType(TimeSlotChip).first);
    expect(slotChipSize.width, greaterThanOrEqualTo(AppDimensions.minTouchTarget));
    expect(
      slotChipSize.height,
      greaterThanOrEqualTo(AppDimensions.minTouchTarget),
    );

    final proceedFinder = find.widgetWithText(
      FilledButton,
      'Avançar para Checkout',
    );
    expect(proceedFinder, findsOneWidget);
    expect(tester.widget<FilledButton>(proceedFinder).onPressed, isNull);

    // Tocar em slot ocupado ('14:00') não deve habilitar avanço.
    await tester.ensureVisible(find.text('14:00'));
    await tester.tap(find.text('14:00'));
    await tester.pumpAndSettle();
    expect(state.selectedSlot, isNull);
    expect(tester.widget<FilledButton>(proceedFinder).onPressed, isNull);

    // Tocar em slot livre ('16:00') ativa trava de 5 min e habilita avanço.
    await tester.ensureVisible(find.text('16:00'));
    await tester.tap(find.text('16:00'));
    await tester.pumpAndSettle();

    expect(state.selectedSlot, '16:00');
    expect(find.text('Reservado para você por 5:00'), findsOneWidget);
    expect(tester.widget<FilledButton>(proceedFinder).onPressed, isNotNull);
  });

  testWidgets('Fluxo completo: Home -> Reagendar -> Checkout -> Confirmação',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final state = AppState();
    await tester.pumpWidget(
      AgendaFacilApp(
        appState: state,
        initialRoute: AppRoutes.homeCustomer,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reagendar em 1 toque'));
    await tester.pumpAndSettle();

    expect(find.text('Tela 8 • Checkout e Resumo'), findsOneWidget);
    expect(find.text('Confirmar agendamento'), findsOneWidget);

    await tester.tap(find.text('Confirmar agendamento'));
    await tester.pumpAndSettle();

    expect(find.text('Tela 9 • Agendamento Confirmado'), findsOneWidget);
    expect(find.text('Salvar na Agenda do Celular'), findsOneWidget);

    await tester.ensureVisible(find.text('Salvar na Agenda do Celular'));
    await tester.tap(find.text('Salvar na Agenda do Celular'));
    await tester.pumpAndSettle();

    expect(find.text('Salvo na Agenda do Celular'), findsOneWidget);
  });

  testWidgets('Todas as 14 rotas e aliases funcionam sem overflow em tela compacta',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    expect(AppRouter.catalog.length, 14);
    expect(AppRouter.routes.containsKey(AppRoutes.catalog), isTrue);
    expect(AppRouter.routes.containsKey(AppRoutes.serviceDetail), isTrue);
    expect(AppRouter.routes.containsKey(AppRoutes.bookingSuccess), isTrue);
    expect(AppRouter.routes.containsKey(AppRoutes.customerAppointments), isTrue);
    expect(AppRouter.routes.containsKey(AppRoutes.customerProfile), isTrue);
    expect(
      AppRouter.routes.containsKey(AppRoutes.providerAppointmentDetail),
      isTrue,
    );
    expect(AppRouter.routes.containsKey(AppRoutes.providerServices), isTrue);
    expect(AppRouter.routes.containsKey(AppRoutes.providerMetrics), isTrue);

    for (final descriptor in AppRouter.catalog) {
      final state = AppState();
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.2)),
          child: AgendaFacilApp(
            appState: state,
            initialRoute: descriptor.routeName,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.takeException(),
        isNull,
        reason: 'Falha ou overflow ao renderizar ${descriptor.routeName}',
      );
    }
  });
}

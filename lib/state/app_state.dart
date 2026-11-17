import 'dart:collection';

import 'package:flutter/material.dart';

import '../models/appointment_model.dart';
import '../models/service_model.dart';

/// Perfis suportados na arquitetura bilateral do aplicativo.
enum UserProfile {
  cliente('Cliente'),
  prestador('Prestador');

  const UserProfile(this.label);

  /// Nome amigável do perfil ativo.
  final String label;
}

/// Estados possíveis de disponibilidade para um horário na grade.
enum SlotStatus {
  disponivel,
  emReservaTemporaria,
  ocupado,
  passado,
}

/// Turnos do dia exibidos na organização da grade de horários.
enum DayPeriod {
  manha('Manhã'),
  tarde('Tarde'),
  noite('Noite');

  const DayPeriod(this.label);

  /// Rótulo amigável do turno exibido ao cliente.
  final String label;
}

/// Modelo imutável que representa um horário na grade de agendamentos.
class TimeSlotModel {
  /// Cria uma instância de [TimeSlotModel].
  const TimeSlotModel({
    required this.hora,
    required this.periodo,
    required this.status,
    this.reservaExpiraEm,
  });

  /// Horário formatado no padrão `HH:mm`.
  final String hora;

  /// Turno do dia ao qual o horário pertence.
  final DayPeriod periodo;

  /// Estado atual de disponibilidade ou bloqueio do horário.
  final SlotStatus status;

  /// Instante limite da trava temporária de cinco minutos, quando aplicável.
  final DateTime? reservaExpiraEm;

  /// Indica se o horário pode receber interação de seleção pelo usuário.
  bool get isDisponivelParaClique =>
      status == SlotStatus.disponivel ||
      status == SlotStatus.emReservaTemporaria;

  /// Indica se o horário está bloqueado por ocupação ou por já ter passado.
  bool get isIndisponivel =>
      status == SlotStatus.ocupado || status == SlotStatus.passado;

  /// Indica se o horário está reservado temporariamente para o usuário atual.
  bool get isReservadoTemporariamente =>
      status == SlotStatus.emReservaTemporaria;

  /// Retorna uma cópia do horário com os campos informados atualizados.
  ///
  /// Quando [clearReservaExpiraEm] é verdadeiro, limpa [reservaExpiraEm]
  /// definindo seu valor como `null`.
  TimeSlotModel copyWith({
    String? hora,
    DayPeriod? periodo,
    SlotStatus? status,
    DateTime? reservaExpiraEm,
    bool clearReservaExpiraEm = false,
  }) {
    return TimeSlotModel(
      hora: hora ?? this.hora,
      periodo: periodo ?? this.periodo,
      status: status ?? this.status,
      reservaExpiraEm: clearReservaExpiraEm
          ? null
          : (reservaExpiraEm ?? this.reservaExpiraEm),
    );
  }
}

/// Gerenciador de estado reativo em memória com dados simulados para o Demo Day.
///
/// Mantém serviços, grade de horários com trava temporária, agendamentos,
/// políticas do prestador e perfil bilateral (Cliente e Prestador).
class AppState extends ChangeNotifier {
  /// Inicializa o estado com catálogo, horários distribuídos nos três turnos e agendamentos.
  AppState() {
    final hoje = DateTime.now();
    _selectedDate = DateTime(hoje.year, hoje.month, hoje.day);
    _slots.addAll([
      const TimeSlotModel(
        hora: '09:00',
        periodo: DayPeriod.manha,
        status: SlotStatus.passado,
      ),
      const TimeSlotModel(
        hora: '10:30',
        periodo: DayPeriod.manha,
        status: SlotStatus.disponivel,
      ),
      const TimeSlotModel(
        hora: '14:00',
        periodo: DayPeriod.tarde,
        status: SlotStatus.ocupado,
      ),
      TimeSlotModel(
        hora: '15:00',
        periodo: DayPeriod.tarde,
        status: SlotStatus.emReservaTemporaria,
        reservaExpiraEm: hoje.add(const Duration(minutes: 5)),
      ),
      const TimeSlotModel(
        hora: '16:00',
        periodo: DayPeriod.tarde,
        status: SlotStatus.disponivel,
      ),
      const TimeSlotModel(
        hora: '17:30',
        periodo: DayPeriod.tarde,
        status: SlotStatus.disponivel,
      ),
      const TimeSlotModel(
        hora: '19:00',
        periodo: DayPeriod.noite,
        status: SlotStatus.disponivel,
      ),
    ]);
    _appointments.addAll([
      AppointmentModel(
        id: 'apt-001',
        cliente: _userName,
        prestador: 'Lucas Barbeiro • Studio Prime',
        data: _selectedDate,
        hora: '14:00',
        status: AppointmentStatus.confirmado,
        servicoNome: 'Corte Degradê + Barba',
        valor: 75.0,
      ),
      AppointmentModel(
        id: 'apt-002',
        cliente: 'Mariana Souza',
        prestador: 'Camila Estética • Studio Prime',
        data: _selectedDate.subtract(const Duration(days: 1)),
        hora: '10:30',
        status: AppointmentStatus.finalizado,
        servicoNome: 'Limpeza de Pele Profunda',
        valor: 110.0,
      ),
    ]);
    _selectedService = _services.first;
  }

  final List<ServiceModel> _services = const [
    ServiceModel(
      id: 'srv-01',
      nome: 'Corte Degradê Navalhado',
      preco: 45.0,
      duracaoMinutos: 40,
      categoria: ServiceCategory.cabelo,
      descricao: 'Corte moderno com acabamento na navalha e lavagem rápida.',
      prestadorNome: 'Lucas Barbeiro • Studio Prime',
    ),
    ServiceModel(
      id: 'srv-02',
      nome: 'Barba Terapia com Toalha Quente',
      preco: 38.0,
      duracaoMinutos: 30,
      categoria: ServiceCategory.barba,
      descricao: 'Modelagem de barba, vapor de toalha quente e óleo hidratante.',
      prestadorNome: 'Lucas Barbeiro • Studio Prime',
    ),
    ServiceModel(
      id: 'srv-03',
      nome: 'Combo Corte + Barba',
      preco: 75.0,
      duracaoMinutos: 60,
      categoria: ServiceCategory.cabelo,
      descricao: 'Pacote completo com corte personalizado e alinhamento de barba.',
      prestadorNome: 'Rafael Mendes • Studio Prime',
    ),
    ServiceModel(
      id: 'srv-04',
      nome: 'Limpeza de Pele Profunda',
      preco: 110.0,
      duracaoMinutos: 50,
      categoria: ServiceCategory.estetica,
      descricao: 'Higienização facial, extração suave e máscara calmante.',
      prestadorNome: 'Camila Estética • Studio Prime',
    ),
    ServiceModel(
      id: 'srv-05',
      nome: 'Design de Sobrancelha',
      preco: 30.0,
      duracaoMinutos: 20,
      categoria: ServiceCategory.estetica,
      descricao: 'Alinhamento natural respeitando a simetria facial.',
      prestadorNome: 'Camila Estética • Studio Prime',
    ),
  ];

  final List<TimeSlotModel> _slots = [];
  final List<AppointmentModel> _appointments = [];

  UserProfile _activeProfile = UserProfile.cliente;
  bool _isGuest = true;
  String _userName = 'Visitante';
  String _userEmail = '';
  String _searchQuery = '';
  ServiceCategory? _selectedCategory;
  ServiceModel? _selectedService;
  String? _selectedSlot = '15:00';
  late DateTime _selectedDate;
  int _janelaCancelamentoHoras = 2;
  int _toleranciaAtrasoMinutos = 15;

  /// Perfil ativo no momento ([UserProfile.cliente] ou [UserProfile.prestador]).
  UserProfile get activeProfile => _activeProfile;

  /// Indica se o usuário entrou utilizando o fluxo progressivo de visitante.
  bool get isGuest => _isGuest;

  /// Nome exibido nas saudações e novos agendamentos do cliente.
  String get userName => _userName;

  /// E-mail informado no login tradicional, quando houver.
  String get userEmail => _userEmail;

  /// Termo digitado na barra de busca da Home do cliente.
  String get searchQuery => _searchQuery;

  /// Categoria selecionada no carrossel (`null` representa "Todos").
  ServiceCategory? get selectedCategory => _selectedCategory;

  /// Serviço atualmente selecionado para agendamento.
  ServiceModel? get selectedService => _selectedService;

  /// Horário selecionado no fluxo de agendamento (ex.: `15:00`).
  String? get selectedSlot => _selectedSlot;

  /// Data selecionada para o novo agendamento.
  DateTime get selectedDate => _selectedDate;

  /// Janela mínima em horas para cancelamento gratuito pelo cliente.
  int get janelaCancelamentoHoras => _janelaCancelamentoHoras;

  /// Tolerância máxima de atraso em minutos configurada pelo prestador.
  int get toleranciaAtrasoMinutos => _toleranciaAtrasoMinutos;

  /// Catálogo completo e imutável de serviços disponíveis.
  UnmodifiableListView<ServiceModel> get services =>
      UnmodifiableListView(_services);

  /// Lista completa e imutável da grade de horários com seus respectivos estados.
  UnmodifiableListView<TimeSlotModel> get timeSlots =>
      UnmodifiableListView(_slots);

  /// Lista de horários configurados excluindo horários passados para compatibilidade.
  List<String> get availableSlots => UnmodifiableListView(
        _slots
            .where((slot) => slot.status != SlotStatus.passado)
            .map((slot) => slot.hora),
      );

  /// Modelo completo do horário atualmente selecionado, ou `null` se nenhum estiver ativo.
  TimeSlotModel? get selectedSlotModel {
    final slotHora = _selectedSlot;
    if (slotHora == null) return null;
    for (final slot in _slots) {
      if (slot.hora == slotHora) {
        return slot;
      }
    }
    return null;
  }

  /// Lista completa de agendamentos registrados em memória.
  UnmodifiableListView<AppointmentModel> get appointments =>
      UnmodifiableListView(_appointments);

  /// Serviços filtrados em tempo real pela categoria e pelo termo de busca.
  List<ServiceModel> get filteredServices {
    final query = _searchQuery.trim().toLowerCase();
    return _services.where((service) {
      final matchesCategory =
          _selectedCategory == null || service.categoria == _selectedCategory;
      final matchesQuery = query.isEmpty ||
          service.nome.toLowerCase().contains(query) ||
          service.categoria.label.toLowerCase().contains(query) ||
          service.prestadorNome.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList(growable: false);
  }

  /// Agendamentos ainda ativos (confirmados ou em andamento).
  List<AppointmentModel> get agendamentosAtivos =>
      _appointments.where((a) => a.isAtivo).toList(growable: false);

  /// Próximo agendamento ativo para o cartão de destaque na Home do cliente.
  AppointmentModel? get proximoAgendamento {
    for (final appointment in _appointments) {
      if (appointment.isAtivo) {
        return appointment;
      }
    }
    return null;
  }

  /// Retorna os horários filtrados pelo turno informado em [periodo].
  List<TimeSlotModel> slotsPorPeriodo(DayPeriod periodo) {
    return _slots
        .where((slot) => slot.periodo == periodo)
        .toList(growable: false);
  }

  /// Alterna instantaneamente o perfil ativo entre Cliente e Prestador.
  void alternarPerfil([UserProfile? perfilEspecifico]) {
    final nextProfile = perfilEspecifico ??
        (_activeProfile == UserProfile.cliente
            ? UserProfile.prestador
            : UserProfile.cliente);
    if (_activeProfile == nextProfile) return;
    _activeProfile = nextProfile;
    notifyListeners();
  }

  /// Autentica no modo visitante com fricção zero.
  void entrarComoVisitante() {
    _isGuest = true;
    _userName = 'Visitante';
    _userEmail = '';
    _activeProfile = UserProfile.cliente;
    notifyListeners();
  }

  /// Autentica com o [email] informado no formulário e opcionalmente define [perfil].
  void autenticarComEmail(String email, {UserProfile? perfil}) {
    final cleanEmail = email.trim();
    final extractedName = cleanEmail.contains('@')
        ? cleanEmail.split('@').first
        : (cleanEmail.isEmpty ? 'Cliente' : cleanEmail);
    final formattedName = extractedName.isEmpty
        ? 'Cliente'
        : '${extractedName[0].toUpperCase()}${extractedName.substring(1)}';

    _isGuest = false;
    _userEmail = cleanEmail;
    _userName = formattedName;
    if (perfil != null) {
      _activeProfile = perfil;
    }
    notifyListeners();
  }

  /// Atualiza o filtro textual de busca dos serviços com o valor de [query].
  void atualizarBusca(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    notifyListeners();
  }

  /// Seleciona ou limpa a [categoria] ativa do carrossel.
  void selecionarCategoria(ServiceCategory? categoria) {
    if (_selectedCategory == categoria) return;
    _selectedCategory = categoria;
    notifyListeners();
  }

  /// Define o [servico] escolhido para iniciar o fluxo de agendamento.
  void selecionarServico(ServiceModel servico) {
    _selectedService = servico;
    notifyListeners();
  }

  /// Seleciona o [horario] informado aplicando trava temporária de cinco minutos.
  ///
  /// Ignora a operação se o horário não existir ou estiver indisponível.
  void selecionarHorario(String horario) {
    final targetIndex = _slots.indexWhere((slot) => slot.hora == horario);
    if (targetIndex == -1 || _slots[targetIndex].isIndisponivel) {
      return;
    }

    for (var i = 0; i < _slots.length; i++) {
      if (_slots[i].status == SlotStatus.emReservaTemporaria) {
        _slots[i] = _slots[i].copyWith(
          status: SlotStatus.disponivel,
          clearReservaExpiraEm: true,
        );
      }
    }

    _slots[targetIndex] = _slots[targetIndex].copyWith(
      status: SlotStatus.emReservaTemporaria,
      reservaExpiraEm: DateTime.now().add(const Duration(minutes: 5)),
    );
    _selectedSlot = horario;
    notifyListeners();
  }

  /// Libera qualquer trava temporária ativa e limpa a seleção de horário.
  void liberarReservaTemporaria() {
    for (var i = 0; i < _slots.length; i++) {
      if (_slots[i].status == SlotStatus.emReservaTemporaria) {
        _slots[i] = _slots[i].copyWith(
          status: SlotStatus.disponivel,
          clearReservaExpiraEm: true,
        );
      }
    }
    _selectedSlot = null;
    notifyListeners();
  }

  /// Atualiza a data escolhida para o atendimento com base em [data].
  void selecionarData(DateTime data) {
    _selectedDate = DateTime(data.year, data.month, data.day);
    notifyListeners();
  }

  /// Cria e confirma um novo agendamento ocupando o horário selecionado.
  ///
  /// Utiliza [servico] e [clienteNome] quando informados, ou os valores ativos
  /// no estado. Retorna `null` se não houver horário válido selecionado.
  AppointmentModel? confirmarAgendamento({
    ServiceModel? servico,
    String? clienteNome,
  }) {
    final targetService = servico ?? _selectedService ?? _services.first;
    final slotHora = _selectedSlot;
    if (slotHora == null || slotHora.isEmpty) {
      return null;
    }

    final slotIndex = _slots.indexWhere((slot) => slot.hora == slotHora);
    if (slotIndex != -1 && _slots[slotIndex].isIndisponivel) {
      return null;
    }

    if (slotIndex != -1) {
      _slots[slotIndex] = _slots[slotIndex].copyWith(
        status: SlotStatus.ocupado,
        clearReservaExpiraEm: true,
      );
    }

    final newAppointment = AppointmentModel(
      id: 'apt-${DateTime.now().millisecondsSinceEpoch}',
      cliente: clienteNome ?? _userName,
      prestador: targetService.prestadorNome,
      data: _selectedDate,
      hora: slotHora,
      status: AppointmentStatus.confirmado,
      servicoNome: targetService.nome,
      valor: targetService.preco,
    );

    _appointments.insert(0, newAppointment);
    _selectedSlot = null;
    notifyListeners();
    return newAppointment;
  }

  /// Altera o status do agendamento [appointmentId] para [novoStatus].
  ///
  /// Quando [novoStatus] for [AppointmentStatus.cancelado] e a data coincidir
  /// com [selectedDate], libera o horário ocupado correspondente na grade.
  void alterarStatusAgendamento(
    String appointmentId,
    AppointmentStatus novoStatus,
  ) {
    final index = _appointments.indexWhere((item) => item.id == appointmentId);
    if (index == -1) return;

    final target = _appointments[index];
    _appointments[index] = target.copyWith(status: novoStatus);

    if (novoStatus == AppointmentStatus.cancelado) {
      final sameDate = target.data.year == _selectedDate.year &&
          target.data.month == _selectedDate.month &&
          target.data.day == _selectedDate.day;
      if (sameDate) {
        final slotIndex = _slots.indexWhere((slot) => slot.hora == target.hora);
        if (slotIndex != -1 && _slots[slotIndex].status == SlotStatus.ocupado) {
          _slots[slotIndex] = _slots[slotIndex].copyWith(
            status: SlotStatus.disponivel,
            clearReservaExpiraEm: true,
          );
        }
      }
    }

    notifyListeners();
  }

  /// Prepara o reagendamento rápido em um toque a partir de [referencia].
  ///
  /// Seleciona o serviço equivalente ao agendamento de referência (ou ao
  /// primeiro agendamento disponível), reserva o primeiro horário livre e
  /// retorna `true`. Retorna `false` caso nenhum horário livre esteja disponível.
  bool reagendarEmUmToque([AppointmentModel? referencia]) {
    final targetAppointment = referencia ??
        proximoAgendamento ??
        (_appointments.isNotEmpty ? _appointments.first : null);

    var matchedService = _services.first;
    if (targetAppointment != null) {
      final targetName = targetAppointment.servicoNome.trim().toLowerCase();
      final exactIndex = _services.indexWhere(
        (service) => service.nome.toLowerCase() == targetName,
      );
      if (exactIndex != -1) {
        matchedService = _services[exactIndex];
      } else {
        final partialIndex = _services.indexWhere(
          (service) =>
              service.nome.toLowerCase().contains(targetName) ||
              targetName.contains(service.nome.toLowerCase()) ||
              (service.preco == targetAppointment.valor &&
                  service.prestadorNome == targetAppointment.prestador),
        );
        if (partialIndex != -1) {
          matchedService = _services[partialIndex];
        } else {
          final priceIndex = _services.indexWhere(
            (service) => service.preco == targetAppointment.valor,
          );
          if (priceIndex != -1) {
            matchedService = _services[priceIndex];
          }
        }
      }
    }

    _selectedService = matchedService;

    TimeSlotModel? targetSlot;
    for (final slot in _slots) {
      if (slot.status == SlotStatus.disponivel) {
        targetSlot = slot;
        break;
      }
    }
    if (targetSlot == null && _selectedSlot != null) {
      for (final slot in _slots) {
        if (slot.hora == _selectedSlot && slot.isDisponivelParaClique) {
          targetSlot = slot;
          break;
        }
      }
    }

    if (targetSlot == null) {
      notifyListeners();
      return false;
    }

    selecionarHorario(targetSlot.hora);
    return true;
  }

  /// Atualiza as políticas operacionais do prestador com [janelaHoras] e [toleranciaMinutos].
  void atualizarRegrasPrestador({
    int? janelaHoras,
    int? toleranciaMinutos,
  }) {
    var changed = false;
    if (janelaHoras != null &&
        janelaHoras >= 0 &&
        janelaHoras != _janelaCancelamentoHoras) {
      _janelaCancelamentoHoras = janelaHoras;
      changed = true;
    }
    if (toleranciaMinutos != null &&
        toleranciaMinutos >= 0 &&
        toleranciaMinutos != _toleranciaAtrasoMinutos) {
      _toleranciaAtrasoMinutos = toleranciaMinutos;
      changed = true;
    }
    if (changed) {
      notifyListeners();
    }
  }

  /// Registra a avaliação em [estrelas] e o [comentario] para [appointmentId].
  void registrarAvaliacao(
    String appointmentId,
    int estrelas,
    String comentario,
  ) {
    final index = _appointments.indexWhere((item) => item.id == appointmentId);
    if (index == -1) return;

    final clampedStars = estrelas.clamp(1, 5);
    _appointments[index] = _appointments[index].copyWith(
      avaliacaoEstrelas: clampedStars,
      comentarioAvaliacao: comentario.trim(),
    );
    notifyListeners();
  }
}

/// Provedor reativo nativo no topo da árvore de widgets para o [AppState].
///
/// Funciona com a semântica de atualização seletiva via `InheritedNotifier`
/// sem dependências externas.
class AppStateScope extends InheritedNotifier<AppState> {
  /// Cria um escopo que expõe [notifier] para toda a subárvore [child].
  const AppStateScope({
    super.key,
    required AppState notifier,
    required super.child,
  }) : super(notifier: notifier);

  /// Obtém o [AppState] em [context] e inscreve o widget para reconstrução reativa.
  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope não encontrado na árvore de widgets.');
    return scope!.notifier!;
  }

  /// Obtém o [AppState] em [context] sem inscrever o widget para reconstruções.
  static AppState read(BuildContext context) {
    final element =
        context.getElementForInheritedWidgetOfExactType<AppStateScope>();
    final scope = element?.widget as AppStateScope?;
    assert(scope != null, 'AppStateScope não encontrado na árvore de widgets.');
    return scope!.notifier!;
  }
}

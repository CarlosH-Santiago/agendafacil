import 'package:flutter/material.dart';

/// Estados possíveis no ciclo de vida de um agendamento com semáforo visual.
enum AppointmentStatus {
  confirmado(
    'Confirmado',
    Color(0xFF34A853),
    Color(0xFFE6F4EA),
    Icons.event_available_rounded,
  ),
  emAndamento(
    'Em andamento',
    Color(0xFFB06000),
    Color(0xFFFEF7E0),
    Icons.timelapse_rounded,
  ),
  cancelado(
    'Cancelado',
    Color(0xFFEA4335),
    Color(0xFFFCE8E6),
    Icons.cancel_outlined,
  ),
  finalizado(
    'Finalizado',
    Color(0xFF5F6368),
    Color(0xFFE8EAED),
    Icons.task_alt_rounded,
  );

  const AppointmentStatus(
    this.label,
    this.foregroundColor,
    this.backgroundColor,
    this.icon,
  );

  /// Rótulo legível do status na interface.
  final String label;

  /// Cor principal de texto e ícone para contraste acessível.
  final Color foregroundColor;

  /// Cor de fundo do selo de status.
  final Color backgroundColor;

  /// Ícone semântico associado ao status.
  final IconData icon;
}

/// Modelo imutável que representa um agendamento entre cliente e prestador.
class AppointmentModel {
  /// Cria uma instância de [AppointmentModel].
  const AppointmentModel({
    required this.id,
    required this.cliente,
    required this.prestador,
    required this.data,
    required this.hora,
    required this.status,
    this.servicoNome = 'Serviço Agendado',
    this.valor = 0,
    this.avaliacaoEstrelas,
    this.comentarioAvaliacao,
  });

  /// Identificador único do agendamento.
  final String id;

  /// Nome do cliente que solicitou o atendimento.
  final String cliente;

  /// Nome do prestador responsável pelo atendimento.
  final String prestador;

  /// Data do atendimento.
  final DateTime data;

  /// Horário selecionado no formato `HH:mm` (ex.: `14:00`).
  final String hora;

  /// Estado atual do agendamento no fluxo bilateral.
  final AppointmentStatus status;

  /// Nome do serviço vinculado para exibição rápida nos cards.
  final String servicoNome;

  /// Valor acordado do serviço em reais (BRL).
  final double valor;

  /// Nota opcional de 1 a 5 estrelas atribuída pelo cliente após o atendimento.
  final int? avaliacaoEstrelas;

  /// Comentário opcional registrado pelo cliente na avaliação do serviço.
  final String? comentarioAvaliacao;

  /// Indica se o agendamento ainda está ativo para exibição nos próximos atendimentos.
  bool get isAtivo =>
      status == AppointmentStatus.confirmado ||
      status == AppointmentStatus.emAndamento;

  /// Data formatada no padrão `dd/MM/yyyy`.
  String get dataFormatada {
    final day = data.day.toString().padLeft(2, '0');
    final month = data.month.toString().padLeft(2, '0');
    return '$day/$month/${data.year}';
  }

  /// Valor formatado no padrão brasileiro (ex.: `R$ 50,00`).
  String get valorFormatado =>
      'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';

  /// Retorna uma cópia do agendamento com os campos informados alterados.
  AppointmentModel copyWith({
    String? id,
    String? cliente,
    String? prestador,
    DateTime? data,
    String? hora,
    AppointmentStatus? status,
    String? servicoNome,
    double? valor,
    int? avaliacaoEstrelas,
    String? comentarioAvaliacao,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      cliente: cliente ?? this.cliente,
      prestador: prestador ?? this.prestador,
      data: data ?? this.data,
      hora: hora ?? this.hora,
      status: status ?? this.status,
      servicoNome: servicoNome ?? this.servicoNome,
      valor: valor ?? this.valor,
      avaliacaoEstrelas: avaliacaoEstrelas ?? this.avaliacaoEstrelas,
      comentarioAvaliacao: comentarioAvaliacao ?? this.comentarioAvaliacao,
    );
  }
}

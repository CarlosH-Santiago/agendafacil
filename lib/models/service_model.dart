/// Categorias suportadas pelo catálogo de serviços.
enum ServiceCategory {
  cabelo('Cabelo'),
  barba('Barba'),
  estetica('Estética');

  const ServiceCategory(this.label);

  /// Rótulo amigável exibido nos chips e cards da interface.
  final String label;
}

/// Modelo imutável que representa um serviço ofertado na plataforma.
class ServiceModel {
  /// Cria uma instância de [ServiceModel].
  const ServiceModel({
    required this.id,
    required this.nome,
    required this.preco,
    required this.duracaoMinutos,
    required this.categoria,
    this.descricao = '',
    this.prestadorNome = 'Studio Prime',
    this.avaliacao = 4.9,
    this.enderecoEstudio = 'Av. Paulista, 1000 • Sala 12',
  });

  /// Identificador único do serviço.
  final String id;

  /// Nome curto e claro para reduzir a carga cognitiva na leitura.
  final String nome;

  /// Valor cobrado pelo serviço em reais (BRL).
  final double preco;

  /// Duração estimada do atendimento em minutos.
  final int duracaoMinutos;

  /// Categoria principal utilizada para filtragem no carrossel.
  final ServiceCategory categoria;

  /// Descrição opcional com detalhes do atendimento.
  final String descricao;

  /// Nome do prestador ou estabelecimento responsável.
  final String prestadorNome;

  /// Nota média de avaliação do serviço em escala de 0 a 5.
  final double avaliacao;

  /// Endereço físico do estúdio ou estabelecimento prestador.
  final String enderecoEstudio;

  /// Preço formatado no padrão brasileiro (ex.: `R$ 45,00`).
  String get precoFormatado =>
      'R\$ ${preco.toStringAsFixed(2).replaceAll('.', ',')}';

  /// Duração formatada de maneira compacta (ex.: `45 min`).
  String get duracaoFormatada => '$duracaoMinutos min';

  /// Retorna uma cópia do serviço com os campos informados atualizados.
  ServiceModel copyWith({
    String? id,
    String? nome,
    double? preco,
    int? duracaoMinutos,
    ServiceCategory? categoria,
    String? descricao,
    String? prestadorNome,
    double? avaliacao,
    String? enderecoEstudio,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      preco: preco ?? this.preco,
      duracaoMinutos: duracaoMinutos ?? this.duracaoMinutos,
      categoria: categoria ?? this.categoria,
      descricao: descricao ?? this.descricao,
      prestadorNome: prestadorNome ?? this.prestadorNome,
      avaliacao: avaliacao ?? this.avaliacao,
      enderecoEstudio: enderecoEstudio ?? this.enderecoEstudio,
    );
  }
}

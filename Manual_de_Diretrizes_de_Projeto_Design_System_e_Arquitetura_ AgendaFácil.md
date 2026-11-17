### Manual de Diretrizes de Projeto, Design System e Arquitetura: AgendaFácil (Tema 11\)

A transição da prototipagem conceitual para a engenharia de software funcional no Bloco 3 exige alinhamento absoluto entre os catorze membros da equipe. Quando múltiplos desenvolvedores escrevem código em paralelo, a ausência de parâmetros visuais, arquiteturais e ergonômicos rigorosamente padronizados resulta em fragmentação de interface, quebra de contratos de navegação e inconsistências de usabilidade que comprometem a avaliação acadêmica perante o corpo docente.  
Este documento consolida a carta de princípios do projeto  **AgendaFácil (Tema 11 — Agendamento de Serviços e Gestão de Atendimentos)**  da disciplina de UX Design e Prototipação de Interfaces. Seu propósito é servir como fonte única de verdade operacional, detalhando o propósito do produto, a matriz de dores mitigadas, as especificações matemáticas do Design System, as políticas de conformidade com as heurísticas de Nielsen e a governança da implementação em Flutter/Dart.

#### 1\. Definição do Produto: O que é, O que Resolve e Por que Existe

Para assegurar consistência em cada tela programada, cada seção documentada e cada argumento exposto no pitch comercial, todo o time precisa dominar a razão fundamental de existência do AgendaFácil.

##### 1.1. O que é o Aplicativo

O AgendaFácil é uma solução móvel bilateral desenvolvida nativamente em Flutter, projetada especificamente para o segmento de prestadores de serviços autônomos e pequenos estabelecimentos de cuidados pessoais e bem-estar (como barbearias, estúdios de estética, clínicas e consultórios independentes) e seus respectivos clientes finais.  
Diferente de sistemas legados que atuam apenas como cadernos eletrônicos ou ERPs burocráticos de desktop transpostos de forma desajeitada para a web, o AgendaFácil funciona como uma interface móvel adaptativa em circuito fechado. De um lado, oferece ao cliente final um funil de agendamento ultrarrápido e sem atritos, capaz de concluir uma reserva em menos de 45 segundos. Do outro lado, entrega ao prestador uma central de comando operacional em linha do tempo vertical no modo retrato, eliminando o esmagamento de layout e simplificando o controle de status do atendimento.

##### 1.2. O que Ele Resolve: As Dores Mapeadas no Bloco 1

O aplicativo foi desenhado como um analgésico digital para falhas de mercado e atritos comportamentais concretos identificados durante a pesquisa de UX e benchmarking competitivo:

* **A Troca Sistemática de Contexto (Context Switching):**  O atendimento manual via WhatsApp força o prestador a interromper procedimentos técnicos a todo instante para conferir cadernos, digitar mensagens e negociar horários. Essa fragmentação constante destrói o estado de concentração ( *flow* ), eleva a carga cognitiva residual e gera fadiga operacional crônica.  
* **A Evasão Silenciosa de Receita:**  Conforme atestado por relatórios setoriais de mercado, estabelecimentos sem funil digital de agendamento automático perdem até 40% de sua carteira potencial de clientes. O consumidor contemporâneo opera fora do horário comercial e desiste da contratação ao enfrentar demoras de atendimento ou respostas lentas no WhatsApp.  
* **A Ausência de Fonte Única de Verdade (SSOT):**  O gerenciamento fraturado entre anotações em papel, conversas em aplicativos de mensagens e memórias individuais resulta em condições de corrida ( *Race Conditions* ) no mundo físico, provocando o temido agendamento duplo ( *double-booking* ) e elevadas taxas de ausência não notificada ( *no-show* ).  
* **As Falhas Críticas de Usabilidade dos Concorrentes de Mercado:**  
* *Falha do Trinks (Cliente):*  Barreira de login precoce e obrigatória. O usuário é impedido de consultar a disponibilidade de datas e preços antes de preencher um longo cadastro inicial, gerando abandono imediato.  
* *Falha do Trinks (Prestador):*  Esmagamento severo de visualização em modo retrato. O aplicativo tenta exibir múltiplas colunas de profissionais lado a lado na tela do smartphone, tornando as fontes ilegíveis e exigindo rolagem horizontal exaustiva.  
* *Falha do Booksy:*  O chamado "fluxo invertido", que obriga o usuário a tentar selecionar horários às cegas em grids confusos antes de ter clareza sobre quais profissionais estão verdadeiramente livres.  
* *Falha da Doctoralia:*  Burocracia excessiva, perda recorrente de sincronização bidirecional com calendários externos e formulários densos que inflam o tempo de conclusão da tarefa ( *Time-to-Task* ).

##### 1.3. Por que Ele Existe: A Tese de Engenharia e Usabilidade

O projeto existe para validar a máxima central da disciplina de que código sem usabilidade constitui um produto falho. O AgendaFácil não busca construir infraestruturas de banco de dados pesadas ou serviços em nuvem onerosos; sua razão de existir é provar que a aplicação meticulosa de princípios de Interação Humano-Computador — como sinalizadores visuais explícitos, resposta do sistema abaixo de 100 milissegundos e superfícies táteis ergonômicas de 48x48 dp — viabiliza uma plataforma mobile estável, de alta conversão e humanizada para a economia de serviços.

#### 2\. Design System: Paleta de Cores, Tipografia e Ergonomia Matemática

Para garantir que as telas criadas por desenvolvedores distintos se encaixem perfeitamente sem rupturas visuais ou discrepâncias de espaçamento, todo o código do front-end deve obedecer estritamente às constantes geométricas e cromáticas declaradas no Design System central.

##### 2.1. Paleta Cromática e Níveis de Contraste

A paleta visual do AgendaFácil foi balanceada no padrão Material 3, garantindo conformidade com as diretrizes internacionais de acessibilidade (WCAG 2.1 nível AA), com contraste mínimo de 4.5:1 para texto padrão e 3:1 para componentes de interface:

| Papel Semântico no Flutter | Constante de Código | Código Hexadecimal | Finalidade e Contexto de Aplicação |
| :--- | :--- | :--- | :--- |
| Cor Primária (Brand) | `AppColors.primary` | `#1A73E8` | Ações principais (CTAs), botões primários de confirmação e status ativo. |
| Primária Escura (Press) | `AppColors.primaryDark` | `#1557B0` | Estados pressionados (pressed/hover) de botões principais. |
| Container Primário | `AppColors.primaryContainer` | `#D2E3FC` | Fundo de chips selecionados, badges e destaques sutis. |
| Superfície / Fundo | `AppColors.background` | `#F8F9FA` | Fundo geral da aplicação móvel (off-white anti-fadiga visual). |
| Superfície Neutra (Cards) | `AppColors.surface` | `#FFFFFF` | Cartões de conteúdo, folhas de modal e campos de input. |
| Bordas e Divisores | `AppColors.outline` | `#E0E0E0` | Linhas delimitadoras de cards e separadores de listas (1 dp). |
| Texto Primário (Títulos) | `AppColors.onSurface` | `#202124` | Títulos, rótulos principais e textos com alta ênfase visual. |
| Texto Secundário (Apoio) | `AppColors.onSurfaceVariant` | `#5F6368` | Metadados, subtítulos, durações e horários secundários. |
| Sucesso / Confirmado | `AppColors.success` | `#34A853` | Indicador de agendamento confirmado, feedback positivo e checks. |
| Alerta / Em Andamento | `AppColors.warning` | `#FBBC04` | Atendimento em execução e lembretes de tolerância de atraso. |
| Erro / Cancelado / Ocupado | `AppColors.error` | `#EA4335` | Horários bloqueados, ações de cancelamento e validações inválidas. |

##### 2.2. Tipografia e Escala de Leitura

O sistema adota a fonte sem serifa padrão do ecossistema mobile (Roboto no Android e SF Pro no iOS), com pesos e tamanhos estritamente padronizados:

* **Display / Header Principal:**  24 sp, Bold (peso 700), entrelinha de 32 sp. Uso restrito a boas-vindas na Splash e títulos de Dashboard.  
* **Título de Seção (Title Large):**  18 sp, Semi-Bold (peso 600), entrelinha de 24 sp. Cabeçalhos de cards e títulos de etapas.  
* **Subtítulo / Rótulo de Campo (Title Medium):**  16 sp, Medium (peso 500), entrelinha de 22 sp. Nomes de serviços e itens do catálogo.  
* **Corpo de Texto (Body Medium):**  14 sp, Regular (peso 400), entrelinha de 20 sp. Descrições de procedimentos e regras informativas.  
* **Legenda e Metadados (Body Small):**  12 sp, Regular (peso 400), entrelinha de 16 sp. Duração em minutos, valores em reais e timestamps.  
* **Rótulo de Ação (Button Label):**  14 sp a 16 sp, Semi-Bold (peso 600), caixa mista (nunca tudo em caixa alta para preservar leiturabilidade).

##### 2.3. Ergonomia Matemática e Grid de Espaçamento

* **Sistema Base 8 (Múltiplos de 8 dp):**  Todos os paddings, margens e alturas de componentes devem obedecer à escala 8dp, 16dp, 24dp, 32dp, 40dp, 48dp, 56dp. Margens laterais fixas da tela devem ser de rigorosos  **16 dp** .  
* **Lei de Fitts e Alvos de Toque:**  Nenhuma superfície interativa (botão de slot de horário, ícone de menu ou chip de filtro) pode possuir dimensão física inferior a  **48x48 dp**  (MaterialTapTargetSize.padded). Botões primários de rodapé devem possuir altura mínima de  **56 dp** .  
* **Ergonomia da Zona do Polegar (Thumb Zone):**  As chamadas de ação primária (CTAs de confirmação e avanço de fluxo) devem ser ancoradas na base inferior da tela (BottomAppBar ou barra fixa acima do rodapé). Ações destrutivas ou de configurações avançadas ficam alocadas no topo ou em menus gaveta ( *drawer* ), prevenindo toques involuntários com uma só mão.

#### 3\. Matriz de Conformidade com as Heurísticas de Usabilidade de Nielsen

Cada tela do código Flutter deve incorporar salvaguardas que materializem as heurísticas clássicas de Jakob Nielsen, convertendo preceitos teóricos em regras operacionais de desenvolvimento.

##### 3.1. Heurística \#1: Visibilidade do Status do Sistema

O usuário jamais deve ser deixado em dúvida sobre o estado do processamento ou sobre o contexto da sua reserva.

* **Regra de Código:**  Toda alteração de estado no seletor de horários deve exibir feedback visual em menos de 100 ms (alteração imediata da cor de borda e fundo do chip para AppColors.primaryContainer).  
* **Semáforo de Atendimento:**  O painel do prestador e a tela de histórico devem exibir chips semânticos padronizados: verde para  *Confirmado* , amarelo para  *Em Andamento* , vermelho para  *Cancelado*  e cinza neutro para  *Finalizado* .

##### 3.2. Heurística \#2: Correspondência entre o Sistema e o Mundo Real

A interface deve utilizar metáforas e linguagem naturais do cotidiano de barbearias, clínicas e salões.

* **Regra de Código:**  Fica proibido o uso de termos técnicos de banco de dados na tela (como "Slot ID", "Time-window" ou "Database Null"). A interface deve usar "Horário Livre", "Duração: 45 min", "Valor do Corte" e "Profissional Responsável". A seleção de calendário deve organizar os turnos familiares: Manhã, Tarde e Noite.

##### 3.3. Heurística \#3: Controle e Liberdade do Usuário

O usuário deve ter facilidade para desfazer seleções e cancelar percursos sem medo de penalidades ocultas.

* **Regra de Código:**  Toda tela do funil deve incluir botão explícito de "Voltar" no cabeçalho superior esquerdo, preservando os dados já preenchidos caso o usuário deseje retornar uma etapa. O histórico deve disponibilizar botão de cancelamento claro, respeitando a janela de gratuidade configurada pelo prestador.

##### 3.4. Heurística \#4: Consistência e Padrões

Componentes com o mesmo propósito visual devem se comportar da mesma forma ao longo de toda a aplicação.

* **Regra de Código:**  Os cards de serviços no catálogo utilizam a mesma anatomia visual dos cards de resumo no checkout. Ícones de calendário, relógio e moeda mantêm alinhamento e cores idênticos em todas as rotas.

##### 3.5. Heurística \#5: Prevenção de Erros (A Heurística Central do Projeto)

Mais eficaz do que emitir mensagens de erro é projetar a interface de modo a impossibilitar a ocorrência do erro.

* **Regra de Código:**  Horários passados ou que já estejam preenchidos no mock data devem ser renderizados fisicamente desabilitados (onPressed: null), com fundo cinza desbotado e texto tachado. O botão "Avançar para Checkout" só deve transitar para o estado ativo quando houver exatamente um slot de data e horário validamente selecionado na memória do AppState.

##### 3.6. Heurística \#6: Reconhecimento em Vez de Memorização

O usuário não deve ser obrigado a lembrar de informações vistas em telas anteriores.

* **Regra de Código:**  Na tela de Checkout (Tela 8), o cabeçalho superior deve manter um card sintético fixo contendo a foto do prestador, o nome do serviço, o dia da semana, o horário selecionado e o valor total em reais, eliminando a necessidade de o cliente voltar para conferir o que escolheu.

##### 3.7. Heurística \#7: Flexibilidade e Eficiência de Uso

A interface deve oferecer aceleradores para usuários recorrentes sem prejudicar os novatos.

* **Regra de Código:**  Implementação do botão "Reagendar em 1 toque" na Home e no Histórico, permitindo repetir o último serviço contratado sem necessidade de refazer a busca no catálogo.

##### 3.8. Heurística \#8: Estética e Design Minimalista

Diálogos e telas não devem conter informações irrelevantes ou redundantes.

* **Regra de Código:**  Rejeição absoluta de banners publicitários, pop-ups promocionais ou formulários com campos não essenciais (como endereço residencial completo ou CPF durante a escolha do corte).

#### 4\. Arquitetura da Solução: Módulos, 14 Telas e Divisão por Desenvolvedor

A aplicação móvel encontra-se estruturada em três macrofrentes operacionais que totalizam as catorze telas funcionais mapeadas na documentação do projeto. A execução do código é atribuída diretamente aos cinco integrantes do subgrupo de desenvolvimento:  
                            ARQUITETURA DAS 14 TELAS  
                                       │  
     ┌─────────────────────────────────┼─────────────────────────────────┐  
     ▼                                 ▼                                 ▼  
Subgrupo 1: Core & Onboarding    Subgrupo 2: Transacional          Subgrupo 3: Histórico  
   (Telas 1 a 4 — Dev 1 e 2\)       (Telas 5 a 9 — Dev 3 e 4\)        (Telas 10 a 14 — Dev 5\)

##### 4.1. Módulo Core & Onboarding (Telas 1 a 4\)

* **Tela 1 — Splash Screen (**  **splash\_view.dart**  **):**  Apresentação institucional da marca, carregamento leve de assets e transição assistida para o onboarding.  
* **Tela 2 — Login Progressivo (**  **login\_view.dart**  **):**  Tela de boas-vindas com campos de autenticação, mas com destaque visual para o botão primário "Entrar como Visitante". Essa funcionalidade materializa o princípio de login progressivo ( *opt-out login* ), permitindo que o cliente explore o catálogo e visualize horários sem barreiras cadastrais imediatas.  
* **Tela 3 — Home / Dashboard do Cliente (**  **home\_customer\_view.dart**  **):**  Central do consumidor atuando como Fonte Única de Verdade ( *Single Source of Truth \- SSOT* ), equipada com barra de busca rápida, carrossel de categorias de serviço (Cabelo, Barba, Estética) e um card de destaque fixo exibindo o próximo agendamento ativo.  
* **Tela 4 — Perfil e Alternância de Modo (**  **profile\_switch\_view.dart**  **):**  Interface de gestão de conta com um switch interativo ( *toggle* ) que permite comutar instantaneamente a perspectiva da aplicação entre "Visão do Cliente" e "Painel do Prestador".

##### 4.2. Módulo Transacional (Telas 5 a 9\)

* **Tela 5 — Catálogo de Serviços (**  **catalog\_services\_view.dart**  **):**  Listagem dinâmica dos procedimentos disponíveis, com filtros de preço, duração e reputação do estabelecimento.  
* **Tela 6 — Detalhes do Profissional / Estúdio (**  **professional\_detail\_view.dart**  **):**  Exibição do perfil do especialista, fotos de portfólio de cortes/atendimentos, endereço e avaliações prévias validadas.  
* **Tela 7 — Seletor de Data e Grid de Horários (**  **slot\_selector\_view.dart**  **):**  O núcleo transacional da aplicação. Apresenta um carrossel horizontal de dias da semana e um grid vertical de chips de horário com alvos dimensionados em conformidade rigorosa com a Lei de Fitts (mínimo de 48x48 dp), impedindo cliques acidentais ( *fat finger* ).  
* **Tela 8 — Checkout e Resumo da Reserva (**  **checkout\_view.dart**  **):**  Tela única de fechamento transacional consolidando o resumo do agendamento, método de pagamento preferencial e discriminação transparente das políticas de cancelamento sem taxas escondidas.  
* **Tela 9 — Confirmação e Salvar na Agenda (**  **confirmation\_success\_view.dart**  **):**  Feedback visual imediato com ícone animado de confirmação e botão dedicado "Salvar na Agenda do Celular", corrigindo a falha imperdoável do Trinks ao permitir a sincronização com o calendário nativo do dispositivo móvel.

##### 4.3. Módulo de Histórico, Relatórios & Handoff (Telas 10 a 14\)

* **Tela 10 — Painel da Agenda do Prestador (**  **provider\_timeline\_view.dart**  **):**  Linha do tempo vertical no modo retrato (CustomScrollView com Slivers) que resolve o esmagamento visual do Trinks Prestador, permitindo visualizar a sequência de clientes do dia sem exigir rolagem horizontal.  
* **Tela 11 — Controle de Status do Atendimento (**  **appointment\_status\_view.dart**  **):**  Interface de controle rápido para o profissional alterar o estado do atendimento atual ( *Confirmado, Em Andamento, Concluído ou Cancelado* ).  
* **Tela 12 — Histórico Unificado de Reservas (**  **customer\_history\_view.dart**  **):**  Registro cronológico consolidado de todas as visitas anteriores do cliente em diferentes estabelecimentos, integrando o botão de ação rápida "Reagendar em 1 toque".  
* **Tela 13 — Tela de Avaliação do Serviço (**  **rating\_review\_view.dart**  **):**  Componente simplificado de coleta de feedback com escala por estrelas interativas e campo opcional de texto para depoimento rápido.  
* **Tela 14 — Configuração de Regras e Políticas (**  **provider\_settings\_rules\_view.dart**  **):**  Painel onde o profissional define sua janela de cancelamento gratuito (exemplo: "Cancelamento grátis até 2 horas antes"), tolerância máxima de atraso e dias de funcionamento da agenda.

##### 4.4. Matriz de Atribuição entre os 5 Desenvolvedores

Para assegurar fluxo de trabalho contínuo no Git sem colisões de código, as tarefas ficam divididas conforme o quadro operacional abaixo:

| Desenvolvedor | Escopo de Arquivos e Telas | Branch Git Designada | Critério de Sucesso no Código |
| :--- | :--- | :--- | :--- |
| Dev 1 (Tech Lead) | `main.dart`, `core/`, `state/`, Tela 1 (Splash) e Tela 2 (Login) | `main` / `dev` | Arquitetura limpa, navegação funcional e modo visitante sem erros. |
| Dev 2 | Tela 3 (Home) e Tela 4 (Perfil e Alternância) | `feature/home-perfil` | Filtros por categoria funcionais e chave Cliente/Prestador reativa. |
| Dev 3 | Tela 5 (Catálogo), Tela 6 (Detalhes) e Tela 7 (Grid) | `feature/catalogo-grid` | Chips de horário respeitando 48x48 dp e seleção reativa imediata. |
| Dev 4 | Tela 8 (Checkout) e Tela 9 (Confirmação) | `feature/checkout` | Resumo de valores correto e botão de salvar no calendário visível. |
| Dev 5 | Tela 10 (Timeline), Tela 11 (Status) e Telas 12, 13 e 14 | `feature/prestador-historico` | Linha do tempo vertical fluida e atualização de status refletindo na Home. |

##### 4.5. Estrutura Oficial de Pastas e Contrato do AppState

Para que todos os desenvolvedores atuem em paralelo sem conflitos de importação, duplicação de componentes ou divergências de navegação, a organização oficial de arquivos em `lib/` e o contrato público do gerenciador de estado seguem estritamente a especificação abaixo.

**Árvore Oficial de Arquivos (`lib/`):**

```text
lib/
├── main.dart                                      # Ponto de entrada (AgendaFacilApp + AppStateScope)
├── core/
│   ├── theme.dart                                 # AppColors, AppDimensions, AppDurations e AppTheme (Material 3)
│   └── routes.dart                                # AppRoutes e AppRouter (rotas nomeadas das 14 telas)
├── models/
│   ├── service_model.dart                         # ServiceCategory e ServiceModel
│   └── appointment_model.dart                     # AppointmentStatus e AppointmentModel
├── state/
│   └── app_state.dart                             # AppState (ChangeNotifier) e AppStateScope (InheritedNotifier)
├── widgets/
│   ├── primary_cta_button.dart                    # Botão primário reutilizável (>= 56 dp de altura e >= 48x48 dp)
│   ├── slot_filter_chip.dart                      # Chip de horário/filtro com alvo >= 48x48 dp e feedback < 100 ms
│   └── service_item_card.dart                     # Card padronizado de serviço para catálogo e resumo
└── views/
    ├── splash_view.dart                           # Tela 1 — Splash Screen
    ├── login_view.dart                            # Tela 2 — Login Progressivo (com modo visitante)
    ├── home_customer_view.dart                    # Tela 3 — Home / Dashboard do Cliente
    └── placeholders/                              # Telas 4 a 14 distribuídas para desenvolvimento paralelo
        ├── profile_switch_view.dart               # Tela 4 — Perfil e Alternância de Modo
        ├── catalog_services_view.dart             # Tela 5 — Catálogo de Serviços
        ├── professional_detail_view.dart          # Tela 6 — Detalhes do Profissional / Estúdio
        ├── slot_selector_view.dart                # Tela 7 — Seletor de Data e Grid de Horários
        ├── checkout_view.dart                     # Tela 8 — Checkout e Resumo da Reserva
        ├── confirmation_success_view.dart         # Tela 9 — Confirmação e Salvar na Agenda
        ├── provider_timeline_view.dart            # Tela 10 — Painel da Agenda do Prestador
        ├── appointment_status_view.dart           # Tela 11 — Controle de Status do Atendimento
        ├── customer_history_view.dart             # Tela 12 — Histórico Unificado de Reservas
        ├── rating_review_view.dart                # Tela 13 — Tela de Avaliação do Serviço
        └── provider_settings_rules_view.dart      # Tela 14 — Configuração de Regras e Políticas
```

**Contrato Público do `AppState` e `AppStateScope` (`lib/state/app_state.dart`):**

O acesso reativo ao estado nas telas e widgets ocorre via `AppStateScope.of(context)` (para reconstrução automática na mudança de estado) e `AppStateScope.read(context)` (para disparo de ações em callbacks sem reconstrução desnecessária). Todas as mutações do fluxo bilateral devem utilizar os métodos abaixo:

```dart
abstract interface class AppStateContract {
  /// Alterna entre UserProfile.cliente e UserProfile.prestador (ou define o perfil informado).
  void alternarPerfil([UserProfile? perfilEspecifico]);

  /// Autentica no fluxo de login progressivo (opt-out login) como visitante.
  void entrarComoVisitante();

  /// Autentica usuário com e-mail informado e perfil opcional.
  void autenticarComEmail(String email, {UserProfile? perfil});

  /// Seleciona o horário na Tela 7 e ativa a trava temporária (emReservaTemporaria por 5 min).
  void selecionarHorario(String horario);

  /// Libera a trava temporária do horário selecionado/informado, revertendo-o para disponivel.
  void liberarReservaTemporaria([String? horario]);

  /// Consolida a reserva em memória como AppointmentStatus.confirmado e libera a trava pendente.
  AppointmentModel? confirmarAgendamento({
    ServiceModel? servico,
    String? clienteNome,
  });

  /// Atualiza o ciclo de vida de um atendimento (Confirmado, Em andamento, Cancelado, Finalizado).
  void alterarStatusAgendamento(
    String appointmentId,
    AppointmentStatus novoStatus,
  );

  /// Aplica a Heurística #7 (Flexibilidade), repetindo serviço/contexto de um atendimento anterior em 1 toque.
  AppointmentModel? reagendarEmUmToque(
    AppointmentModel agendamentoAnterior, {
    String? novoHorario,
    DateTime? novaData,
  });
}
```

| Método de `AppState` | Retorno | Responsabilidade no Fluxo de UX | Telas Consumidoras Principais |
| :--- | :--- | :--- | :--- |
| `alternarPerfil([UserProfile? perfilEspecifico])` | `void` | Comuta instantaneamente a visão entre Cliente e Prestador sem perda de contexto em memória. | Telas 3, 4 e 10 |
| `entrarComoVisitante()` | `void` | Habilita navegação imediata sem barreira de cadastro inicial (mitigação da dor do Trinks). | Tela 2 |
| `autenticarComEmail(String email, {UserProfile? perfil})` | `void` | Registra sessão identificada mantendo consistência de saudação e agendamentos do usuário. | Tela 2 e Tela 4 |
| `selecionarHorario(String horario)` | `void` | Marca o slot escolhido e inicia a trava temporária simulada (*Two-Phase Locking*, 5 min). | Tela 7 |
| `liberarReservaTemporaria([String? horario])` | `void` | Desbloqueia o slot em reserva caso o usuário volte da Tela 8 ou o contador expire. | Tela 7 e Tela 8 |
| `confirmarAgendamento({ServiceModel? servico, String? clienteNome})` | `AppointmentModel?` | Grava o novo agendamento no topo da lista em memória e atualiza o card de destaque da Home. | Tela 8 e Tela 9 |
| `alterarStatusAgendamento(String appointmentId, AppointmentStatus novoStatus)` | `void` | Atualiza o semáforo de status (*Confirmado*, *Em andamento*, *Cancelado*, *Finalizado*). | Telas 10, 11 e 12 |
| `reagendarEmUmToque(AppointmentModel agendamentoAnterior, {String? novoHorario, DateTime? novaData})` | `AppointmentModel?` | Acelera o retorno recorrente do cliente repetindo serviço e profissional a partir do histórico. | Tela 3 e Tela 12 |

#### 5\. Diretrizes de Engenharia em Flutter: Mock Reativo e Concorrência

Para atender às exigências de rigor técnico do barema da disciplina sem sobrecarregar a equipe com servidores em nuvem instáveis durante a apresentação do Demo Day, a aplicação deve operar sobre uma arquitetura reativa autossuficiente.

##### 5.1. Gerenciamento de Estado Reativo com Mock Data

* **Isolamento do Estado no**  **AppState**  **:**  Toda mutação de dados (como selecionar um horário vago, fechar um agendamento ou alternar o perfil de usuário) deve ser orquestrada exclusivamente através da classe AppState estendendo ChangeNotifier.  
* **Acesso pelo**  **AppStateScope**  **:**  O acesso aos métodos e propriedades deve ocorrer via AppStateScope.of(context), garantindo que apenas os widgets dependentes sejam reconstruídos, preservando taxas estáveis de 60 frames por segundo.  
* **Dados Pré-Carregados na Memória:**  A aplicação já deve inicializar com dados simulados consistentes (mínimo de cinco procedimentos com valores e durações reais, slots distribuídos nos turnos da manhã e tarde, um agendamento confirmado em aberto e um atendimento concluído no histórico).

##### 5.2. Simulação da Trava Temporária de Slot (Two-Phase Locking)

O tratamento da condição de corrida ( *Race Condition* ) mapeada no Bloco 1 — onde dois usuários tentam agendar o mesmo horário no mesmo instante — deve ser simulado no estado da aplicação:

* Ao clicar em um chip de horário disponível na Tela 7, o método selecionarHorario() do AppState deve alterar imediatamente o status daquele slot para emReservaTemporaria por um contador lógico de cinco minutos.  
* Visualmente, o chip deve receber uma borda destacada e um micro-rótulo de "Reservado para você por 5:00". Caso outro cliente hipotético tentasse acessar a grade, aquele horário seria exibido como indisponível.  
* Se o usuário abandonar o checkout ou exceder o tempo limite, o estado é revertido automaticamente para disponivel, liberando a vaga.

##### 5.3. Padrões de Código e Regras Anti-Quebra

1. **Proibição de Dependências Externas Não Homologadas:**  Fica proibido adicionar pacotes complexos no pubspec.yaml que dependam de compilações nativas de C++ ou chaves de API pagas. Toda a interface deve ser erguida estritamente com os recursos nativos do Flutter SDK (Material 3).  
2. **Responsividade e Prevenção de Overflow:**  Todo formulário ou lista deve estar envelopado em SingleChildScrollView ou ListView.builder para prevenir o erro clássico de tarja amarela e preta de overflow ( *Bottom Overflowed by X Pixels* ) quando o teclado virtual for acionado na tela do smartphone.  
3. **Componentes Reutilizáveis:**  Botões primários, seletores de chip e cards de serviço devem ser criados como widgets reutilizáveis dentro da pasta lib/widgets/, evitando duplicidade de código entre as telas dos diferentes desenvolvedores.

#### 6\. Governança de Equipe e Checklist de Homologação para o Bloco 3

Para assegurar nota máxima nos dois componentes avaliativos do Bloco 3 (os 8,0 pontos do Pitch e os 8,0 pontos da Documentação de Handoff), cada subgrupo deve operar sob o seguinte cronograma de validação:

##### 6.1. Subgrupo de Desenvolvimento (5 Alunos)

*  Todos os 5 programadores clonaram o repositório e executaram flutter run com sucesso.  
*  As branches de cada desenvolvedor foram criadas a partir da branch dev.  
*  As 14 telas estão navegáveis através do AppRouter sem quebras de pilha de rotas.  
*  Todos os alvos de clique no seletor de horários possuem tamanho mínimo comprovado de 48x48 dp.  
*  O feedback de toque opera em menos de 100 ms sem travamentos visíveis de interface.

##### 6.2. Subgrupo de Documentação Técnica (5 Alunos)

*  A documentação do  *Design Handoff Package*  contém a transcrição exata da árvore de pastas e classes de modelo do código.  
*  O Guia de Reprodução Passo a Passo foi testado por um membro não desenvolvedor do zero, comprovando que qualquer pessoa consegue rodar a aplicação.  
*  A seção de testes contém o registro de pelo menos dois cenários práticos de teste de tarefas com medição de  *Time-to-Task*  e evidências de prints.  
*  O texto foi submetido a verificadores anti-IA, apresentando redação autoral, técnica e reflexiva livre de padrões sintáticos automatizados.  
*  Todas as referências bibliográficas (Norman, Nielsen, relatórios de mercado) estão normatizadas no padrão ABNT.

##### 6.3. Subgrupo de Apresentação e Pitch (4 Alunos)

*  O deck de slides possui entre 6 e 8 slides executivos limpos, sem blocos densos de texto.  
*  O espelhamento de tela do celular ou emulador está configurado e testado com antecedência.  
*  O ensaio geral do pitch cronometrou a apresentação entre 5 e 7 minutos exatos.  
*  O roteiro equilibra 2 minutos de contextualização e fundamentação de UX com 3 a 4 minutos de demonstração ao vivo das telas operando.


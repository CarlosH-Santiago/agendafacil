# AgendaFácil — Tema 11

**Agendamento de Serviços e Gestão de Atendimentos** · Projeto Acadêmico de UX Design, Prototipação de Interfaces e Engenharia Flutter/Dart.

O **AgendaFácil** é um aplicativo móvel bilateral desenvolvido nativamente em **Flutter (Material 3)** para prestadores de serviços autônomos e pequenos estabelecimentos de cuidados pessoais e bem-estar (barbearias, estúdios de estética, clínicas e consultórios independentes) e seus clientes finais.

---

## Visão Geral do Produto

* **Para o Cliente Final:** funil de agendamento rápido (< 45 segundos) com **login progressivo** (*Entrar como Visitante*), permitindo consultar catálogo, preços e horários disponíveis sem barreira cadastral prévia, além de **reagendamento em 1 toque** e sincronização com a agenda do celular.
* **Para o Prestador de Serviços:** painel operacional em **linha do tempo vertical no modo retrato**, eliminando esmagamento de colunas e rolagem horizontal, com controle rápido de status (*Confirmado*, *Em andamento*, *Cancelado*, *Finalizado*) e configuração de regras de atendimento.
* **Arquitetura Autossuficiente (Demo Day Ready):** estado reativo em memória via `AppState` (`ChangeNotifier`) e `AppStateScope` (`InheritedNotifier`), sem dependências externas pagas ou compilações nativas de terceiros, incluindo simulação de trava temporária de horário (*Two-Phase Locking* de 5 minutos) contra *double-booking*.

> 📖 **Documentação Completa (Fonte Única de Verdade):** consulte o [Manual de Diretrizes de Projeto, Design System e Arquitetura — AgendaFácil](./Manual_de_Diretrizes_de_Projeto_Design_System_e_Arquitetura_%20AgendaFácil.md) para fundamentação de UX, heurísticas de Nielsen, especificações completas e checklist de homologação.

---

## Resumo do Design System

Construído sobre **Material 3** com conformidade **WCAG 2.1 Nível AA** (contraste mínimo de 4.5:1 para texto padrão e 3:1 para elementos de interface):

### Paleta Cromática Principal

| Papel Semântico | Token (`AppColors`) | Hexadecimal | Uso Principal |
| :--- | :--- | :--- | :--- |
| Cor Primária (Brand) | `AppColors.primary` | `#1A73E8` | CTAs principais, confirmações e estado ativo |
| Primária Escura (Press) | `AppColors.primaryDark` | `#1557B0` | Estados pressionados (*pressed/hover*) |
| Container Primário | `AppColors.primaryContainer` | `#D2E3FC` | Fundo de chips selecionados e badges |
| Superfície / Fundo | `AppColors.background` | `#F8F9FA` | Fundo geral off-white anti-fadiga visual |
| Superfície Neutra (Cards) | `AppColors.surface` | `#FFFFFF` | Cards de serviço, modais e inputs |
| Bordas e Divisores | `AppColors.outline` | `#E0E0E0` | Contornos de 1 dp e separadores |
| Texto Primário | `AppColors.onSurface` | `#202124` | Títulos e rótulos de alta ênfase |
| Texto Secundário | `AppColors.onSurfaceVariant` | `#5F6368` | Metadados, durações e horários |
| Sucesso / Confirmado | `AppColors.success` | `#34A853` | Agendamentos confirmados e checks |
| Alerta / Em Andamento | `AppColors.warning` | `#FBBC04` | Atendimento em execução e tolerância de atraso |
| Erro / Cancelado / Ocupado | `AppColors.error` | `#EA4335` | Horários indisponíveis, cancelamentos e erros |

### Tipografia e Ergonomia Matemática

* **Família Tipográfica:** fonte nativa sem serifa do sistema (**Roboto** no Android e **SF Pro** no iOS).
* **Escala Padronizada:**
  * *Display / Header:* `24 sp` Bold (entrelinha `32 sp`)
  * *Title Large:* `18 sp` Semi-Bold (entrelinha `24 sp`)
  * *Title Medium:* `16 sp` Medium (entrelinha `22 sp`)
  * *Body Medium:* `14 sp` Regular (entrelinha `20 sp`)
  * *Body Small:* `12 sp` Regular (entrelinha `16 sp`)
  * *Button Label:* `14–16 sp` Semi-Bold em caixa mista (sem *ALL CAPS*)
* **Grid Base 8 dp:** espaçamentos múltiplos de `8 dp` (`8, 16, 24, 32, 40, 48, 56`) e margens laterais fixas de `16 dp`.
* **Lei de Fitts e Zona do Polegar (*Thumb Zone*):** todos os alvos interativos possuem área mínima de **`48x48 dp`** (`MaterialTapTargetSize.padded`), botões primários de rodapé têm altura mínima de **`56 dp`** e a resposta visual ao toque ocorre em **`< 100 ms`**.

---

## Arquitetura de Pastas

```text
lib/
├── main.dart                                      # Ponto de entrada (AgendaFacilApp + AppStateScope)
├── core/
│   ├── theme.dart                                 # Design System (AppColors, AppDimensions, AppDurations, AppTheme)
│   └── routes.dart                                # Rotas nomeadas e catálogo das 14 telas (AppRoutes, AppRouter)
├── models/
│   ├── service_model.dart                         # ServiceCategory e ServiceModel
│   └── appointment_model.dart                     # AppointmentStatus e AppointmentModel
├── state/
│   └── app_state.dart                             # AppState (ChangeNotifier) e AppStateScope (InheritedNotifier)
├── widgets/
│   ├── primary_cta_button.dart                    # CTA primário reutilizável (>= 56 dp)
│   ├── slot_filter_chip.dart                      # Chip de horário/filtro (>= 48x48 dp)
│   └── service_item_card.dart                     # Card padronizado de serviço
└── views/
    ├── splash_view.dart                           # Tela 1 — Splash Screen
    ├── login_view.dart                            # Tela 2 — Login Progressivo (Entrar como Visitante)
    ├── home_customer_view.dart                    # Tela 3 — Home / Dashboard do Cliente
    └── placeholders/                              # Telas 4 a 14 para evolução paralela por feature branch
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

> Consulte a **Seção 4.5** do [Manual de Diretrizes](./Manual_de_Diretrizes_de_Projeto_Design_System_e_Arquitetura_%20AgendaFácil.md) para o contrato detalhado de métodos do `AppState`.

---

## Mapeamento das 14 Telas, Equipe e Branches Git

### Distribuição das 14 Telas

| # | Tela | Módulo | Arquivo | Desenvolvedor | Branch |
| :---: | :--- | :--- | :--- | :--- | :--- |
| 1 | Splash Screen | Core & Onboarding | `lib/views/splash_view.dart` | Dev 1 (Tech Lead) | `main` / `dev` |
| 2 | Login Progressivo | Core & Onboarding | `lib/views/login_view.dart` | Dev 1 (Tech Lead) | `main` / `dev` |
| 3 | Home / Dashboard do Cliente | Core & Onboarding | `lib/views/home_customer_view.dart` | Dev 2 | `feature/home-perfil` |
| 4 | Perfil e Alternância de Modo | Core & Onboarding | `lib/views/placeholders/profile_switch_view.dart` | Dev 2 | `feature/home-perfil` |
| 5 | Catálogo de Serviços | Transacional | `lib/views/placeholders/catalog_services_view.dart` | Dev 3 | `feature/catalogo-grid` |
| 6 | Detalhes do Profissional / Estúdio | Transacional | `lib/views/placeholders/professional_detail_view.dart` | Dev 3 | `feature/catalogo-grid` |
| 7 | Seletor de Data e Grid de Horários | Transacional | `lib/views/placeholders/slot_selector_view.dart` | Dev 3 | `feature/catalogo-grid` |
| 8 | Checkout e Resumo da Reserva | Transacional | `lib/views/placeholders/checkout_view.dart` | Dev 4 | `feature/checkout` |
| 9 | Confirmação e Salvar na Agenda | Transacional | `lib/views/placeholders/confirmation_success_view.dart` | Dev 4 | `feature/checkout` |
| 10 | Painel da Agenda do Prestador | Histórico, Relatórios & Handoff | `lib/views/placeholders/provider_timeline_view.dart` | Dev 5 | `feature/prestador-historico` |
| 11 | Controle de Status do Atendimento | Histórico, Relatórios & Handoff | `lib/views/placeholders/appointment_status_view.dart` | Dev 5 | `feature/prestador-historico` |
| 12 | Histórico Unificado de Reservas | Histórico, Relatórios & Handoff | `lib/views/placeholders/customer_history_view.dart` | Dev 5 | `feature/prestador-historico` |
| 13 | Tela de Avaliação do Serviço | Histórico, Relatórios & Handoff | `lib/views/placeholders/rating_review_view.dart` | Dev 5 | `feature/prestador-historico` |
| 14 | Configuração de Regras e Políticas | Histórico, Relatórios & Handoff | `lib/views/placeholders/provider_settings_rules_view.dart` | Dev 5 | `feature/prestador-historico` |

### Fluxo de Branches e Responsabilidades

| Branch | Papel no Fluxo Git | Responsável | Escopo Principal |
| :--- | :--- | :--- | :--- |
| `main` | Branch estável de entrega / Demo Day | Dev 1 (Tech Lead) | Versão homologada e pronta para apresentação |
| `dev` | Branch de integração contínua da equipe | Dev 1 (Tech Lead) | `main.dart`, `core/`, `state/`, `models/`, `widgets/`, Telas 1 e 2 + integração |
| `feature/home-perfil` | Feature branch criada a partir de `dev` | Dev 2 | Tela 3 (`home_customer_view.dart`) e Tela 4 (`profile_switch_view.dart`) |
| `feature/catalogo-grid` | Feature branch criada a partir de `dev` | Dev 3 | Telas 5, 6 e 7 (catálogo, detalhes e grid 48x48 dp com trava de slot) |
| `feature/checkout` | Feature branch criada a partir de `dev` | Dev 4 | Telas 8 e 9 (resumo, transparência de cancelamento e salvar na agenda) |
| `feature/prestador-historico` | Feature branch criada a partir de `dev` | Dev 5 | Telas 10, 11, 12, 13 e 14 (timeline vertical, status, histórico, avaliação e regras) |

**Regra de Colaboração Git:** cada desenvolvedor deve criar ou atualizar sua `feature/*` a partir de `dev`, executar análise estática e testes antes do *Pull Request* para `dev`, e manter `pubspec.lock` versionado (builds determinísticos). Arquivos de IDE, caches e segredos são bloqueados automaticamente pelo `.gitignore`.

---

### Credenciais de Login para Testes

| Perfil | E-mail | Senha | Observação |
| :--- | :--- | :--- | :--- |
| **Cliente Teste** | `cliente@agendafacil.com` | `123456` | Acesso completo ao funil de cliente sem rótulos de teste/dev |
| **Prestador Teste** | `prestador@agendafacil.com` | `123456` | Abre diretamente o painel operacional em linha do tempo vertical |
| **Visitante** | *(Botão "Entrar como Visitante")* | — | Autenticação progressiva sem cadastro prévio |

---

## Pré-requisitos e Execução Local

### Pré-requisitos

* **Flutter SDK** instalado e configurado no `PATH` (compatível com **Dart SDK `>=3.2.0 <4.0.0`** definido em `pubspec.yaml`)
* **Git**
* **Emulador Android / Simulador iOS**, dispositivo físico com depuração USB ativada ou target desktop habilitado (`flutter devices`)

### Passo a Passo para Rodar o Projeto

1. **Clonar o repositório e acessar a pasta do projeto:**

   ```bash
   git clone <url-do-repositorio>
   cd <pasta-do-projeto>
   ```

2. **Baixar as dependências travadas pelo `pubspec.lock`:**

   ```bash
   flutter pub get
   ```

3. **Executar a análise estática de código e lint (`flutter_lints`):**

   ```bash
   flutter analyze
   ```

4. **Rodar a suíte de testes automatizados (unitários e de widget):**

   ```bash
   flutter test
   ```

5. **Executar a aplicação no dispositivo ou emulador conectado:**

   ```bash
   flutter run
   ```

---

## Documentação de Referência

* [Manual de Diretrizes de Projeto, Design System e Arquitetura — AgendaFácil](./Manual_de_Diretrizes_de_Projeto_Design_System_e_Arquitetura_%20AgendaFácil.md)
* [Diretrizes de Análise Estática (`analysis_options.yaml`)](./analysis_options.yaml)
* [Manifesto de Dependências (`pubspec.yaml`)](./pubspec.yaml)

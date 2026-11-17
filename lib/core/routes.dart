import 'package:flutter/material.dart';

import '../views/home_customer_view.dart';
import '../views/login_view.dart';
import '../views/placeholders/appointment_status_view.dart';
import '../views/placeholders/catalog_services_view.dart';
import '../views/placeholders/checkout_view.dart';
import '../views/placeholders/confirmation_success_view.dart';
import '../views/placeholders/customer_history_view.dart';
import '../views/placeholders/professional_detail_view.dart';
import '../views/placeholders/profile_switch_view.dart';
import '../views/placeholders/provider_settings_rules_view.dart';
import '../views/placeholders/provider_timeline_view.dart';
import '../views/placeholders/rating_review_view.dart';
import '../views/placeholders/slot_selector_view.dart';
import '../views/splash_view.dart';
import 'theme.dart';

/// Constantes de rotas nomeadas das 14 telas oficiais do AgendaFácil.
abstract final class AppRoutes {
  /// Tela 1: Splash Screen.
  static const String splash = '/';

  /// Tela 2: Login Progressivo.
  static const String login = '/login';

  /// Tela 3: Home / Dashboard do Cliente.
  static const String homeCustomer = '/home-customer';

  /// Tela 4: Perfil e Alternância de Modo.
  static const String profileSwitch = '/profile-switch';

  /// Tela 5: Catálogo de Serviços.
  static const String catalogServices = '/catalog-services';

  /// Tela 6: Detalhes do Profissional / Estúdio.
  static const String professionalDetail = '/professional-detail';

  /// Tela 7: Seletor de Data e Grid de Horários.
  static const String slotSelector = '/slot-selector';

  /// Tela 8: Checkout e Resumo da Reserva.
  static const String checkout = '/checkout';

  /// Tela 9: Confirmação e Salvar na Agenda.
  static const String confirmationSuccess = '/confirmation-success';

  /// Tela 10: Painel da Agenda do Prestador.
  static const String providerTimeline = '/provider-timeline';

  /// Tela 11: Controle de Status do Atendimento.
  static const String appointmentStatus = '/appointment-status';

  /// Tela 12: Histórico Unificado de Reservas.
  static const String customerHistory = '/customer-history';

  /// Tela 13: Tela de Avaliação do Serviço.
  static const String ratingReview = '/rating-review';

  /// Tela 14: Configuração de Regras e Políticas.
  static const String providerSettingsRules = '/provider-settings-rules';

  /// Alias compatível para [catalogServices].
  static const String catalog = catalogServices;

  /// Alias compatível para [professionalDetail].
  static const String serviceDetail = professionalDetail;

  /// Alias compatível para [confirmationSuccess].
  static const String bookingSuccess = confirmationSuccess;

  /// Alias compatível para [customerHistory].
  static const String customerAppointments = customerHistory;

  /// Alias compatível para [profileSwitch].
  static const String customerProfile = profileSwitch;

  /// Alias compatível para [appointmentStatus].
  static const String providerAppointmentDetail = appointmentStatus;

  /// Alias compatível para [providerSettingsRules].
  static const String providerServices = providerSettingsRules;

  /// Alias compatível para [providerSettingsRules].
  static const String providerMetrics = providerSettingsRules;
}

/// Metadado descritivo de cada tela para rastreabilidade da Matriz 4.4 do Manual.
class RouteDescriptor {
  /// Cria um descritor para o catálogo oficial de rotas.
  const RouteDescriptor({
    required this.screenNumber,
    required this.title,
    required this.routeName,
    required this.assignedDev,
    required this.gitBranch,
  });

  /// Número sequencial da tela (1 a 14).
  final int screenNumber;

  /// Título oficial da tela conforme Seção 4 do Manual.
  final String title;

  /// Caminho da rota nomeada correspondente.
  final String routeName;

  /// Desenvolvedor responsável conforme a Matriz 4.4 do Manual.
  final String assignedDev;

  /// Branch Git designada para a entrega da tela.
  final String gitBranch;
}

/// Mapeamento centralizado de rotas nomeadas e transições do aplicativo.
abstract final class AppRouter {
  /// Lista ordenada das 14 telas oficiais com atribuição de desenvolvedor e branch.
  static const List<RouteDescriptor> catalog = [
    RouteDescriptor(
      screenNumber: 1,
      title: 'Splash Screen',
      routeName: AppRoutes.splash,
      assignedDev: 'Dev 1 (Tech Lead)',
      gitBranch: 'main / dev',
    ),
    RouteDescriptor(
      screenNumber: 2,
      title: 'Login Progressivo',
      routeName: AppRoutes.login,
      assignedDev: 'Dev 1 (Tech Lead)',
      gitBranch: 'main / dev',
    ),
    RouteDescriptor(
      screenNumber: 3,
      title: 'Home / Dashboard do Cliente',
      routeName: AppRoutes.homeCustomer,
      assignedDev: 'Dev 2',
      gitBranch: 'feature/home-perfil',
    ),
    RouteDescriptor(
      screenNumber: 4,
      title: 'Perfil e Alternância de Modo',
      routeName: AppRoutes.profileSwitch,
      assignedDev: 'Dev 2',
      gitBranch: 'feature/home-perfil',
    ),
    RouteDescriptor(
      screenNumber: 5,
      title: 'Catálogo de Serviços',
      routeName: AppRoutes.catalogServices,
      assignedDev: 'Dev 3',
      gitBranch: 'feature/catalogo-grid',
    ),
    RouteDescriptor(
      screenNumber: 6,
      title: 'Detalhes do Profissional / Estúdio',
      routeName: AppRoutes.professionalDetail,
      assignedDev: 'Dev 3',
      gitBranch: 'feature/catalogo-grid',
    ),
    RouteDescriptor(
      screenNumber: 7,
      title: 'Seletor de Data e Grid de Horários',
      routeName: AppRoutes.slotSelector,
      assignedDev: 'Dev 3',
      gitBranch: 'feature/catalogo-grid',
    ),
    RouteDescriptor(
      screenNumber: 8,
      title: 'Checkout e Resumo da Reserva',
      routeName: AppRoutes.checkout,
      assignedDev: 'Dev 4',
      gitBranch: 'feature/checkout',
    ),
    RouteDescriptor(
      screenNumber: 9,
      title: 'Confirmação e Salvar na Agenda',
      routeName: AppRoutes.confirmationSuccess,
      assignedDev: 'Dev 4',
      gitBranch: 'feature/checkout',
    ),
    RouteDescriptor(
      screenNumber: 10,
      title: 'Painel da Agenda do Prestador',
      routeName: AppRoutes.providerTimeline,
      assignedDev: 'Dev 5',
      gitBranch: 'feature/prestador-historico',
    ),
    RouteDescriptor(
      screenNumber: 11,
      title: 'Controle de Status do Atendimento',
      routeName: AppRoutes.appointmentStatus,
      assignedDev: 'Dev 5',
      gitBranch: 'feature/prestador-historico',
    ),
    RouteDescriptor(
      screenNumber: 12,
      title: 'Histórico Unificado de Reservas',
      routeName: AppRoutes.customerHistory,
      assignedDev: 'Dev 5',
      gitBranch: 'feature/prestador-historico',
    ),
    RouteDescriptor(
      screenNumber: 13,
      title: 'Tela de Avaliação do Serviço',
      routeName: AppRoutes.ratingReview,
      assignedDev: 'Dev 5',
      gitBranch: 'feature/prestador-historico',
    ),
    RouteDescriptor(
      screenNumber: 14,
      title: 'Configuração de Regras e Políticas',
      routeName: AppRoutes.providerSettingsRules,
      assignedDev: 'Dev 5',
      gitBranch: 'feature/prestador-historico',
    ),
  ];

  /// Retorna o [RouteDescriptor] associado a [screenNumber], se existir.
  static RouteDescriptor? descriptorFor(int screenNumber) {
    for (final descriptor in catalog) {
      if (descriptor.screenNumber == screenNumber) {
        return descriptor;
      }
    }
    return null;
  }

  /// Tabela oficial das 14 rotas nomeadas utilizada pelo `MaterialApp`.
  static Map<String, WidgetBuilder> get routes => {
        AppRoutes.splash: (_) => const SplashView(),
        AppRoutes.login: (_) => const LoginView(),
        AppRoutes.homeCustomer: (_) => const HomeCustomerView(),
        AppRoutes.profileSwitch: (_) => const ProfileSwitchView(),
        AppRoutes.catalogServices: (_) => const CatalogServicesView(),
        AppRoutes.professionalDetail: (_) => const ProfessionalDetailView(),
        AppRoutes.slotSelector: (_) => const SlotSelectorView(),
        AppRoutes.checkout: (_) => const CheckoutView(),
        AppRoutes.confirmationSuccess: (_) => const ConfirmationSuccessView(),
        AppRoutes.providerTimeline: (_) => const ProviderTimelineView(),
        AppRoutes.appointmentStatus: (_) => const AppointmentStatusView(),
        AppRoutes.customerHistory: (_) => const CustomerHistoryView(),
        AppRoutes.ratingReview: (_) => const RatingReviewView(),
        AppRoutes.providerSettingsRules: (_) =>
            const ProviderSettingsRulesView(),
      };

  /// Gera transições suaves para entrada no fluxo e fallback seguro.
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final builder = routes[settings.name];

    if (builder != null &&
        (settings.name == AppRoutes.login ||
            settings.name == AppRoutes.homeCustomer)) {
      return PageRouteBuilder<void>(
        settings: settings,
        transitionDuration: AppDurations.routeTransition,
        pageBuilder: (context, _, __) => builder(context),
        transitionsBuilder: (_, animation, __, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.03),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      );
    }

    if (builder != null) {
      return MaterialPageRoute<void>(
        settings: settings,
        builder: builder,
      );
    }

    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => const HomeCustomerView(),
    );
  }
}

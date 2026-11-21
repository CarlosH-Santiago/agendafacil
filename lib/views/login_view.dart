import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/routes.dart';
import '../core/theme.dart';
import '../state/app_state.dart';
import '../widgets/primary_cta_button.dart';
import 'home_customer_view.dart';

/// Tela 2 — Login progressivo com destaque para entrada imediata como visitante.
///
/// Materializa o acesso sem cadastro obrigatório (opt-out login), inclui botão
/// explícito de retorno à Tela 1 (Heurística 3) e seletor bilateral acessível
/// com alvos >= 48x48 dp.
class LoginView extends StatefulWidget {
  /// Cria a tela de autenticação progressiva [LoginView].
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  UserProfile _selectedProfile = UserProfile.cliente;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleBackToSplash() {
    HapticFeedback.selectionClick();
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      navigator.pushReplacementNamed(AppRoutes.splash);
    }
  }

  void _enterAsGuest() {
    HapticFeedback.selectionClick();
    final appState = AppStateScope.read(context);
    appState.entrarComoVisitante();
    Navigator.of(context).pushReplacementNamed(AppRoutes.homeCustomer);
  }

  void _applyTestAccount(TestAccount account) {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    setState(() {
      _selectedProfile = account.perfil;
      _emailController.text = account.email;
      _passwordController.text = account.senha;
    });
  }

  void _submitCredentials() {
    HapticFeedback.selectionClick();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final appState = AppStateScope.read(context);
    final authenticated = appState.autenticarComCredenciais(
      _emailController.text,
      _passwordController.text,
      perfil: _selectedProfile,
    );

    if (!authenticated) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.error,
            content: Text(
              'Senha incorreta para a conta de teste. Use 123456.',
            ),
          ),
        );
      return;
    }

    if (_selectedProfile == UserProfile.prestador) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          settings: const RouteSettings(name: AppRoutes.homeCustomer),
          builder: (_) => const HomeCustomerView(),
        ),
        (route) => false,
      );
      Navigator.of(context).pushNamed(AppRoutes.providerTimeline);
      return;
    }

    Navigator.of(context).pushReplacementNamed(AppRoutes.homeCustomer);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Voltar para boas-vindas',
          constraints: const BoxConstraints(
            minWidth: AppDimensions.minTouchTarget,
            minHeight: AppDimensions.minTouchTarget,
          ),
          onPressed: _handleBackToSplash,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Entrar no AgendaFácil'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Acesse sua conta',
                style: textTheme.headlineMedium,
              ),
              const SizedBox(height: AppDimensions.spacingXs),
              Text(
                'Explore horários livres e valores como visitante sem cadastro prévio ou entre com seu e-mail.',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: AppDimensions.spacingMd),
              // Cartão destacado de Login Progressivo (Autenticação Opcional).
              Container(
                padding: const EdgeInsets.all(AppDimensions.spacingSm),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                  border: Border.all(
                    color: AppColors.primary.withAlpha(72),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'Acesso Rápido',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spacingXs),
                        Expanded(
                          child: Text(
                            'Sem cadastro obrigatório',
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Quer consultar horários livres e agendar em menos de 45 segundos?',
                      style: textTheme.titleMedium?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingSm),
                    PrimaryCtaButton(
                      label: 'Entrar como Visitante',
                      icon: Icons.explore_rounded,
                      onPressed: _enterAsGuest,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.spacingMd),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'ou entre com sua conta',
                      style: textTheme.bodyMedium,
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingSm),
              // Seletor bilateral com altura mínima >= 48 dp.
              SegmentedButton<UserProfile>(
                style: SegmentedButton.styleFrom(
                  minimumSize: const Size(
                    AppDimensions.minTouchTarget,
                    AppDimensions.minTouchTarget,
                  ),
                  tapTargetSize: MaterialTapTargetSize.padded,
                ),
                segments: const [
                  ButtonSegment<UserProfile>(
                    value: UserProfile.cliente,
                    icon: Icon(Icons.person_outline_rounded),
                    label: Text('Sou Cliente'),
                  ),
                  ButtonSegment<UserProfile>(
                    value: UserProfile.prestador,
                    icon: Icon(Icons.storefront_outlined),
                    label: Text('Sou Prestador'),
                  ),
                ],
                selected: {_selectedProfile},
                onSelectionChanged: (selection) {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedProfile = selection.first;
                  });
                },
              ),
              const SizedBox(height: AppDimensions.spacingSm),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        hintText: 'nome@exemplo.com',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.isEmpty) {
                          return 'Informe seu e-mail para continuar.';
                        }
                        if (!text.contains('@') || !text.contains('.')) {
                          return 'Digite um endereço de e-mail válido.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDimensions.spacingSm),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submitCredentials(),
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        hintText: 'Mínimo de 4 caracteres',
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          tooltip: _obscurePassword
                              ? 'Mostrar senha'
                              : 'Ocultar senha',
                          constraints: const BoxConstraints(
                            minWidth: AppDimensions.minTouchTarget,
                            minHeight: AppDimensions.minTouchTarget,
                          ),
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if ((value ?? '').length < 4) {
                          return 'A senha precisa ter pelo menos 4 caracteres.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppDimensions.spacingSm),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.controlRadius,
                        ),
                        border: Border.all(color: AppColors.outline),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Contas de teste disponíveis (senha: 123456)',
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: AppDimensions.spacingXs,
                            runSpacing: AppDimensions.spacingXs,
                            children: AppState.contasTeste.map((account) {
                              return ActionChip(
                                materialTapTargetSize:
                                    MaterialTapTargetSize.padded,
                                avatar: Icon(
                                  account.perfil == UserProfile.prestador
                                      ? Icons.storefront_outlined
                                      : Icons.person_outline_rounded,
                                  size: 18,
                                  color: AppColors.primaryDark,
                                ),
                                label: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  child: Text(account.rotulo),
                                ),
                                onPressed: () => _applyTestAccount(account),
                              );
                            }).toList(growable: false),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Cliente: ${AppState.contaClienteTeste.email}\n'
                            'Prestador: ${AppState.contaPrestadorTeste.email}',
                            style: textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingMd),
                    PrimaryCtaButton(
                      label: _selectedProfile == UserProfile.prestador
                          ? 'Entrar como Prestador'
                          : 'Entrar com E-mail',
                      icon: Icons.login_rounded,
                      isOutlined: true,
                      onPressed: _submitCredentials,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

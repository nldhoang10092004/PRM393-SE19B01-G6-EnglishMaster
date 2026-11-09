import 'package:english_master/core/widgets/chunky_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/widgets/mascot_mimi.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_provider.dart';

/// Login with email/username + password.
/// On success [AuthProvider] flips to authenticated and the root gate shows
/// the main app, so this screen does not navigate by itself.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifier = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    // AuthProvider is shared by all auth screens: drop errors left by the previous screen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AuthProvider>().clearError();
    });
  }

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    await context.read<AuthProvider>().login(_identifier.text, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppPalette.of(context).primary,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppPalette.of(context).primaryEdge,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Text(
                            AppStrings.brandInitials,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: AppPalette.of(context).onPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          AppStrings.appName,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Center(child: MascotMimi()),
                    Text(
                      AppStrings.welcomeBack,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.mimiWaiting,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppPalette.of(context).inkMuted,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      AppStrings.emailOrUsername,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppPalette.of(context).ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      key: const Key('login_identifier'),
                      controller: _identifier,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(),
                      validator: (v) => Validators.required(
                        v,
                        field: AppStrings.emailOrUsername,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      AppStrings.password,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppPalette.of(context).ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      key: const Key('login_password'),
                      controller: _password,
                      obscureText: _obscure,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) =>
                          Validators.required(v, field: AppStrings.password),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.pushNamed(
                          context,
                          AppRoutes.forgotPassword,
                        ),
                        child: const Text(AppStrings.forgotPasswordLink),
                      ),
                    ),
                    if (auth.error != null) ...[
                      Text(
                        auth.error!,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                      const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 32),
                    ChunkyButton(
                      key: const Key('login_submit'),
                      onPressed: auth.isBusy ? null : _submit,
                      child: auth.isBusy
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(AppStrings.login),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        auth.clearError();
                        Navigator.pushNamed(context, AppRoutes.register);
                      },
                      child: const Text(AppStrings.signupPrompt),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

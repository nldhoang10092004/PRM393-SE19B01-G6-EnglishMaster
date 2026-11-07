import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_provider.dart';

/// Two-step sign up: request an OTP by e-mail, then submit the form with it.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _otp = TextEditingController();
  bool _otpSent = false;

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
    for (final c in [_email, _username, _password, _confirm, _otp]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final emailError = Validators.email(_email.text);
    if (emailError != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(emailError)));
      return;
    }
    final ok = await context.read<AuthProvider>().sendOtp(_email.text);
    if (!mounted) return;
    if (ok) {
      setState(() => _otpSent = true);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text(AppStrings.otpSent)));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await context.read<AuthProvider>().register(
      email: _email.text,
      username: _username.text,
      password: _password.text,
      otp: _otp.text,
    );
    // On success the root gate shows the main app; close this route.
    if (ok && mounted) Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.createAccount)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: AppStrings.email,
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _username,
                  decoration: const InputDecoration(
                    labelText: AppStrings.username,
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) =>
                      Validators.required(v, field: AppStrings.username),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: AppStrings.password,
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: Validators.password,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirm,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: AppStrings.confirmPassword,
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (v) =>
                      Validators.confirmPassword(v, _password.text),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _otp,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: AppStrings.otpCode,
                          prefixIcon: Icon(Icons.pin_outlined),
                        ),
                        validator: Validators.otp,
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: auth.isBusy ? null : _sendOtp,
                      child: Text(
                        _otpSent ? AppStrings.resend : AppStrings.sendOtp,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (auth.error != null) ...[
                  Text(
                    auth.error!,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  const SizedBox(height: 12),
                ],
                FilledButton(
                  onPressed: auth.isBusy ? null : _submit,
                  child: auth.isBusy
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(AppStrings.register),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

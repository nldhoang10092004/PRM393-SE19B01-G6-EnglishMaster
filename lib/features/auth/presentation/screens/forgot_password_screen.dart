import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/validators.dart';
import '../providers/auth_provider.dart';

/// Requests a password reset e-mail.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await context.read<AuthProvider>().forgotPassword(_email.text);
    if (!mounted || !ok) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('If the email exists, a reset link has been sent.')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot password')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Enter your account email and we will send you a reset link.'),
              const SizedBox(height: 16),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                validator: Validators.email,
              ),
              const SizedBox(height: 16),
              if (auth.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(auth.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
              FilledButton(onPressed: auth.isBusy ? null : _submit, child: const Text('Send reset link')),
            ],
          ),
        ),
      ),
    );
  }
}

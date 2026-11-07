import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/validators.dart';
import '../providers/profile_provider.dart';

/// Validated current/new/confirmation password form.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _current.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final ok = await context.read<ProfileProvider>().changePassword(
      _current.text,
      _password.text,
      _confirm.text,
    );
    if (ok && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Password changed')));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ProfileProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Change password')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _current,
              enabled: !state.busy,
              obscureText: _obscure,
              decoration: const InputDecoration(labelText: 'Current password'),
              validator: (v) =>
                  Validators.required(v, field: 'Current password'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _password,
              enabled: !state.busy,
              obscureText: _obscure,
              decoration: const InputDecoration(labelText: 'New password'),
              validator: Validators.password,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirm,
              enabled: !state.busy,
              obscureText: _obscure,
              decoration: const InputDecoration(
                labelText: 'Confirm new password',
              ),
              validator: (v) => Validators.confirmPassword(v, _password.text),
            ),
            Row(
              children: [
                Checkbox(
                  value: !_obscure,
                  onChanged: (value) =>
                      setState(() => _obscure = !(value ?? false)),
                ),
                const Text('Show passwords'),
              ],
            ),
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  state.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: state.busy ? null : _save,
              child: Text(state.busy ? 'Saving…' : 'Change password'),
            ),
          ],
        ),
      ),
    );
  }
}

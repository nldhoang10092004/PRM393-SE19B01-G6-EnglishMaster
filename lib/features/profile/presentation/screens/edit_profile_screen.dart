import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/utils/validators.dart';
import '../../data/models/user_profile.dart';
import '../providers/profile_provider.dart';

/// Edits fields actually persisted by the profile service.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  DateTime? _dob;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final profile = context.read<ProfileProvider>().profile;
    if (profile != null) {
      _name.text = profile.fullName;
      _phone.text = profile.phone;
      _address.text = profile.address;
      _dob = profile.dob;
    }
    _initialized = true;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final state = context.read<ProfileProvider>();
    final existing = state.profile;
    if (existing == null) return;
    final ok = await state.update(
      UserProfile(
        accountId: existing.accountId,
        email: existing.email,
        fullName: _name.text,
        phone: _phone.text,
        address: _address.text,
        dob: _dob,
      ),
    );
    if (ok && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Profile updated')));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ProfileProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              enabled: !state.busy,
              maxLength: 100,
              decoration: const InputDecoration(labelText: 'Full name'),
              validator: (value) =>
                  Validators.required(value, field: 'Full name'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phone,
              enabled: !state.busy,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Phone'),
              validator: (value) =>
                  value == null ||
                      value.trim().isEmpty ||
                      RegExp(r'^[0-9]{9,11}$').hasMatch(value.trim())
                  ? null
                  : 'Use 9–11 digits',
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _address,
              enabled: !state.busy,
              maxLength: 255,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date of birth'),
              subtitle: Text(_dob?.toString().split(' ').first ?? 'Not set'),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: state.busy
                  ? null
                  : () async {
                      final today = DateUtils.dateOnly(DateTime.now());
                      final last = today.subtract(const Duration(days: 1));
                      final first =
                          DateTime(today.year - 120).isBefore(DateTime(1900))
                          ? DateTime(1900)
                          : DateTime(today.year - 120);
                      final initial =
                          _dob != null &&
                              !_dob!.isBefore(first) &&
                              !_dob!.isAfter(last)
                          ? _dob!
                          : DateTime(today.year - 18);
                      final date = await showDatePicker(
                        context: context,
                        initialDate: initial,
                        firstDate: first,
                        lastDate: last,
                      );
                      if (mounted && date != null) setState(() => _dob = date);
                    },
            ),
            const SizedBox(height: 8),
            const Text(
              'Existing phone, address and birthday cannot be cleared by this API.',
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
              child: Text(state.busy ? 'Saving…' : 'Save changes'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:english_master/core/widgets/app_top_bar.dart';
import 'package:english_master/core/widgets/chunky_button.dart';
import 'package:flutter/material.dart';

import '../../../../core/layout/responsive.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/l10n/app_strings.dart';
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppStrings.profileUpdated)));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ProfileProvider>();
    return Scaffold(
      appBar: const AppTopBar(title: Text(AppStrings.editProfile)),
      body: Form(
        key: _form,
        child: ListView(
          padding: readablePadding(
            context,
            horizontal: 16,
            top: 16,
            bottom: 16,
            maxWidth: 560,
          ),
          children: [
            TextFormField(
              controller: _name,
              enabled: !state.busy,
              maxLength: 100,
              decoration: const InputDecoration(labelText: AppStrings.fullName),
              validator: (value) =>
                  Validators.required(value, field: AppStrings.fullName),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phone,
              enabled: !state.busy,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: AppStrings.phone),
              validator: (value) =>
                  value == null ||
                      value.trim().isEmpty ||
                      RegExp(r'^[0-9]{9,11}$').hasMatch(value.trim())
                  ? null
                  : AppStrings.phoneDigits,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _address,
              enabled: !state.busy,
              maxLength: 255,
              decoration: const InputDecoration(labelText: AppStrings.address),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(AppStrings.dateOfBirth),
              subtitle: Text(
                _dob == null
                    ? AppStrings.notSet
                    : DateFormat.yMd('vi').format(_dob!),
              ),
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
            const Text(AppStrings.cannotClearProfile),
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  state.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const SizedBox(height: 24),
            ChunkyButton(
              onPressed: state.busy ? null : _save,
              child: Text(
                state.busy ? AppStrings.saving : AppStrings.saveChanges,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

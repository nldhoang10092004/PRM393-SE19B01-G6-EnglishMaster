import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

import '../config/app_config.dart';
import 'app_network_image.dart';

/// Shared, cached avatar with a safe initial for missing or broken images.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    this.url,
    required this.name,
    this.radius = 24,
    this.colors,
  });
  final String? url;
  final String name;
  final double radius;
  final SkillColors? colors;

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(url?.trim() ?? '');
    final resolved = uri == null || (url?.trim().isEmpty ?? true)
        ? null
        : Uri.parse(AppConfig.apiBaseUrl).resolveUri(uri);
    final valid = resolved?.scheme == 'http' || resolved?.scheme == 'https';
    final fallback = name.trim().isEmpty
        ? const Icon(Icons.person_rounded)
        : Text(name.trim().characters.first.toUpperCase());
    return CircleAvatar(
      radius: radius,
      backgroundColor:
          colors?.background ?? Theme.of(context).colorScheme.primaryContainer,
      foregroundColor:
          colors?.ink ?? Theme.of(context).colorScheme.onPrimaryContainer,
      child: valid
          ? ClipOval(
              child: AppNetworkImage(
                url: resolved.toString(),
                width: radius * 2,
                height: radius * 2,
                error: Center(child: fallback),
              ),
            )
          : fallback,
    );
  }
}

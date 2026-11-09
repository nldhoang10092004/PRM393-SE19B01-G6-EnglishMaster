import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../theme/app_theme.dart';

/// Exports a scan-friendly PNG with a white quiet zone into the system gallery.
class QrGallery {
  QrGallery._();

  /// Returns false when gallery access is denied; write errors are propagated.
  static Future<bool> save(String data) async {
    if (!await Gal.hasAccess() && !await Gal.requestAccess()) return false;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, 1024, 1024),
      Paint()..color = AppTheme.qrPaper,
    );
    canvas.translate(64, 64);
    QrPainter(
      data: data,
      version: QrVersions.auto,
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: AppTheme.qrInk,
      ),
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: AppTheme.qrInk,
      ),
    ).paint(canvas, const Size(896, 896));
    final picture = recorder.endRecording();
    final image = await picture.toImage(1024, 1024);
    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) throw StateError('PNG encoding failed');
      await Gal.putImageBytes(
        bytes.buffer.asUint8List(),
        name: 'EnglishMaster-QR',
      );
      return true;
    } finally {
      image.dispose();
      picture.dispose();
    }
  }
}

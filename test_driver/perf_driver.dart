import 'package:flutter_driver/flutter_driver.dart';
import 'package:integration_test/integration_test_driver.dart';

/// Writes the frame build/raster summary of every traced phase to
/// `build/PHASE.timeline_summary.json`.
Future<void> main() {
  return integrationDriver(
    responseDataCallback: (data) async {
      if (data == null) return;
      for (final phase in const ['home', 'cards', 'study']) {
        final raw = data['${phase}_timeline'];
        if (raw == null) continue;
        final timeline = Timeline.fromJson(raw as Map<String, dynamic>);
        await TimelineSummary.summarize(timeline)
            .writeTimelineToFile(phase, pretty: true, includeSummary: true);
      }
    },
  );
}

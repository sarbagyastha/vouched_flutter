import 'package:flutter/services.dart';

import 'src/model/job_response.dart';

export 'src/model/card_detail_result.dart';
export 'src/model/job_response.dart';
export 'src/vouched_scanner.dart';

class Vouched {
  const Vouched._();

  static const MethodChannel channel = MethodChannel(
    'com.acmesoftware.vouched',
  );

  static Future<void> pauseCamera() => channel.invokeMethod('pauseCamera');

  static Future<void> resumeCamera() => channel.invokeMethod('resumeCamera');

  static Iterable<Insight> extractInsights(JobResponse response) sync* {
    if (response.result?.confidences != null) {
      final signals = response.signals;
      for (final signal in signals) {
        if (signal.isPublicProperty) {
          yield _insightsMap[signal.type] ?? Insight.unknown;
        }
      }
    }
  }
}

enum Insight {
  unknown,
  nonGlare,
  quality,
  brightness,
  face,
  glasses,
}

const Map<String, Insight> _insightsMap = {
  'quality': Insight.quality,
  'brightness': Insight.brightness,
  'nonglare': Insight.nonGlare,
  'glasses': Insight.glasses,
  'face': Insight.face,
};

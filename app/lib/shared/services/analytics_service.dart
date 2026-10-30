import 'package:flutter/foundation.dart';

class AnalyticsService {
  static void logEvent(String name, [Map<String, dynamic>? parameters]) {
    debugPrint('Analytics Event: $name, Params: $parameters');
  }
}

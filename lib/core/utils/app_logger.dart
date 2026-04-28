// lib/core/utils/app_logger.dart
//
// Usage:
//   AppLogger.info('Recipes loaded');
//   AppLogger.debug('User tapped', tag: 'HomePage');
//   AppLogger.warning('No location found');
//   AppLogger.error('API failed', error: e, stack: s);

import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  // Only logs in debug builds. Use for noisy dev-only output.
  static void debug(String msg, {String tag = 'Debug'}) {
    if (kDebugMode) dev.log(msg, name: tag);
  }

  // General info — visible in debug and profile builds.
  static void info(String msg, {String tag = 'App'}) {
    dev.log(msg, name: tag, level: 800);
  }

  // Something unexpected but non-fatal.
  static void warning(String msg, {String tag = 'Warning'}) {
    dev.log('⚠️ $msg', name: tag, level: 900);
  }

  // Errors — always logged, optionally with the thrown object and stack.
  static void error(
      String msg, {
        Object? error,
        StackTrace? stack,
        String tag = 'Error',
      }) {
    dev.log('❌ $msg', name: tag, error: error, stackTrace: stack, level: 1000);
  }
}
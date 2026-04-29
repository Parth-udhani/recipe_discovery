// lib/core/utils/app_logger.dart
//
// Colorful, structured logger for development.
// Colors are visible in Android Studio / VS Code debug consoles.
//
// Levels:
//   debug   → grey    (verbose dev info, kDebugMode only)
//   info    → cyan    (key lifecycle events)
//   success → green   (successful API/cache operations)
//   warning → yellow  (non-fatal issues, cache fallbacks)
//   error   → red     (failures)

import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  // ANSI color codes
  static const _reset   = '\x1B[0m';
  static const _grey    = '\x1B[90m';
  static const _cyan    = '\x1B[36m';
  static const _green   = '\x1B[32m';
  static const _yellow  = '\x1B[33m';
  static const _red     = '\x1B[31m';
  static const _bold    = '\x1B[1m';

  /// Grey — noisy dev-only output. Stripped in release builds.
  static void debug(String msg, {String tag = 'DBG'}) {
    if (!kDebugMode) return;
    dev.log('$_grey⬡ $msg$_reset', name: _tag(tag));
  }

  /// Cyan — key lifecycle events (init, navigation, state transitions).
  static void info(String msg, {String tag = 'APP'}) {
    if (!kDebugMode) return;
    dev.log('$_cyan$_bold◆ $msg$_reset', name: _tag(tag), level: 800);
  }

  /// Green — confirmed successes (API response received, cache written, etc.).
  static void success(String msg, {String tag = 'OK '}) {
    if (!kDebugMode) return;
    dev.log('$_green✔ $msg$_reset', name: _tag(tag), level: 800);
  }

  /// Yellow — non-fatal warnings (offline fallback, cache miss, no location).
  static void warning(String msg, {String tag = 'WRN'}) {
    if (!kDebugMode) return;
    dev.log('$_yellow⚠ $msg$_reset', name: _tag(tag), level: 900);
  }

  /// Red — errors. Always emitted (debug + profile builds). Includes optional
  /// thrown object and stack trace so the IDE can deep-link to the source.
  static void error(
      String msg, {
        Object? error,
        StackTrace? stack,
        String tag = 'ERR',
      }) {
    dev.log(
      '$_red$_bold✖ $msg$_reset',
      name: _tag(tag),
      error: error,
      stackTrace: stack,
      level: 1000,
    );
  }

  // ── Network helpers (call these instead of raw info/success) ──────────────

  /// Log an outgoing HTTP request.
  static void request(String method, String url, {String tag = 'NET'}) {
    if (!kDebugMode) return;
    dev.log('$_cyan↑ $method $url$_reset', name: _tag(tag), level: 800);
  }

  /// Log a successful HTTP response.
  static void response(int status, String url, {int? count, String tag = 'NET'}) {
    if (!kDebugMode) return;
    final extra = count != null ? ' · ${count} items' : '';
    dev.log('$_green↓ $status $url$extra$_reset', name: _tag(tag), level: 800);
  }

  // ── Private ───────────────────────────────────────────────────────────────

  static String _tag(String raw) => raw.padRight(3).substring(0, 3).toUpperCase();
}
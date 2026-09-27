import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preferências do app (tema, unidades, presença, notif).
class AppPrefs {
  const AppPrefs({
    this.themeMode = ThemeMode.dark,
    this.distanceInKm = false,
    this.showInPresence = true,
    this.notificationsEnabled = true,
  });

  final ThemeMode themeMode;
  final bool distanceInKm;
  final bool showInPresence;
  final bool notificationsEnabled;

  AppPrefs copyWith({
    ThemeMode? themeMode,
    bool? distanceInKm,
    bool? showInPresence,
    bool? notificationsEnabled,
  }) {
    return AppPrefs(
      themeMode: themeMode ?? this.themeMode,
      distanceInKm: distanceInKm ?? this.distanceInKm,
      showInPresence: showInPresence ?? this.showInPresence,
      notificationsEnabled:
          notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  static String _themeKey(ThemeMode m) => switch (m) {
        ThemeMode.light => 'light',
        ThemeMode.system => 'system',
        ThemeMode.dark => 'dark',
      };

  static ThemeMode _parseTheme(String? raw) => switch (raw) {
        'light' => ThemeMode.light,
        'system' => ThemeMode.system,
        _ => ThemeMode.dark,
      };
}

class AppPrefsStore extends Notifier<AppPrefs> {
  static const _kTheme = 'prefs.theme';
  static const _kKm = 'prefs.distance_km';
  static const _kPresence = 'prefs.show_presence';
  static const _kNotif = 'prefs.notifications';

  @override
  AppPrefs build() {
    unawaited(_load());
    return const AppPrefs();
  }

  Future<void> _load() async {
    try {
      final p = await SharedPreferences.getInstance();
      state = AppPrefs(
        themeMode: AppPrefs._parseTheme(p.getString(_kTheme)),
        distanceInKm: p.getBool(_kKm) ?? false,
        showInPresence: p.getBool(_kPresence) ?? true,
        notificationsEnabled: p.getBool(_kNotif) ?? true,
      );
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_kTheme, AppPrefs._themeKey(state.themeMode));
      await p.setBool(_kKm, state.distanceInKm);
      await p.setBool(_kPresence, state.showInPresence);
      await p.setBool(_kNotif, state.notificationsEnabled);
    } catch (_) {}
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    unawaited(_save());
  }

  void setDistanceInKm(bool v) {
    state = state.copyWith(distanceInKm: v);
    unawaited(_save());
  }

  void setShowInPresence(bool v) {
    state = state.copyWith(showInPresence: v);
    unawaited(_save());
  }

  void setNotificationsEnabled(bool v) {
    state = state.copyWith(notificationsEnabled: v);
    unawaited(_save());
  }
}

final appPrefsProvider =
    NotifierProvider<AppPrefsStore, AppPrefs>(AppPrefsStore.new);

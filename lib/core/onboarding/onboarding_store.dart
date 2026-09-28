import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// v3 = onboarding redesign premium (set 2026-09-27).
/// Trocar a chave força o fluxo a aparecer de novo após update do APK.
const _kDone = 'nadaaqui.onboarding.v3.done';
const _kUnit = 'nadaaqui.onboarding.distance_unit';
const _kPace = 'nadaaqui.onboarding.pace';
const _kPaceSec = 'nadaaqui.onboarding.pace_seconds';

enum DistanceUnit { meters, yards }

enum PaceBase { fifty, hundred }

class OnboardingPrefs {
  const OnboardingPrefs({
    this.done = false,
    this.unit = DistanceUnit.meters,
    this.paceBase = PaceBase.hundred,
    this.paceSeconds = 90,
    this.hydrated = false,
  });

  final bool done;
  final DistanceUnit unit;
  final PaceBase paceBase;
  final int paceSeconds;
  final bool hydrated;

  OnboardingPrefs copyWith({
    bool? done,
    DistanceUnit? unit,
    PaceBase? paceBase,
    int? paceSeconds,
    bool? hydrated,
  }) {
    return OnboardingPrefs(
      done: done ?? this.done,
      unit: unit ?? this.unit,
      paceBase: paceBase ?? this.paceBase,
      paceSeconds: paceSeconds ?? this.paceSeconds,
      hydrated: hydrated ?? this.hydrated,
    );
  }
}

class OnboardingStore extends Notifier<OnboardingPrefs> with ChangeNotifier {
  @override
  OnboardingPrefs build() {
    unawaited(_restore());
    return const OnboardingPrefs();
  }

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final done = prefs.getBool(_kDone) ?? false;
      final unitRaw = prefs.getString(_kUnit);
      final paceRaw = prefs.getString(_kPace);
      final paceSec = prefs.getInt(_kPaceSec) ?? 90;
      state = OnboardingPrefs(
        done: done,
        unit: unitRaw == 'yards' ? DistanceUnit.yards : DistanceUnit.meters,
        paceBase: paceRaw == '50m' ? PaceBase.fifty : PaceBase.hundred,
        paceSeconds: paceSec.clamp(25, 180),
        hydrated: true,
      );
      notifyListeners();
    } catch (_) {
      state = const OnboardingPrefs(hydrated: true);
      notifyListeners();
    }
  }

  Future<void> setUnit(DistanceUnit unit) async {
    state = state.copyWith(unit: unit);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kUnit,
      unit == DistanceUnit.yards ? 'yards' : 'meters',
    );
  }

  Future<void> setPaceBase(PaceBase base) async {
    state = state.copyWith(paceBase: base);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kPace,
      base == PaceBase.fifty ? '50m' : '100m',
    );
  }

  Future<void> setPaceSeconds(int seconds) async {
    state = state.copyWith(paceSeconds: seconds.clamp(25, 180));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kPaceSec, state.paceSeconds);
  }

  Future<void> complete() async {
    state = state.copyWith(done: true, hydrated: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDone, true);
    notifyListeners();
  }

  Future<void> reset() async {
    state = state.copyWith(done: false, hydrated: true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kDone);
    notifyListeners();
  }
}

final onboardingStoreProvider =
    NotifierProvider<OnboardingStore, OnboardingPrefs>(OnboardingStore.new);

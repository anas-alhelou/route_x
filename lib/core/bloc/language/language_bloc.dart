import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routex_mobile/core/services/local/app_preferences_service.dart';

part 'language_event.dart';
part 'language_state.dart';

/// Global Bloc that manages the app-wide locale (en ↔ ar).
///
/// Provided at the root of the widget tree via `MultiBlocProvider`
/// so that any screen can `context.read<LanguageBloc>().add(ToggleLanguageEvent())`.
class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  /// With [preferences] the chosen language survives an app restart: it is
  /// read here, before the first frame, and written on every change. Without
  /// it (tests) the bloc starts in English and keeps nothing.
  LanguageBloc({AppPreferencesService? preferences})
      : _preferences = preferences,
        super(_initialState(preferences)) {
    on<ToggleLanguageEvent>(_onToggleLanguage);
  }

  final AppPreferencesService? _preferences;

  static LanguageState _initialState(AppPreferencesService? preferences) {
    final saved = preferences?.getLanguageCode();
    return saved == 'ar' || saved == 'en'
        ? LanguageState(languageCode: saved!)
        : LanguageState.initial();
  }

  void _onToggleLanguage(
    ToggleLanguageEvent event,
    Emitter<LanguageState> emit,
  ) {
    final newCode = state.languageCode == 'en' ? 'ar' : 'en';
    emit(state.copyWith(languageCode: newCode));
    unawaited(_preferences?.setLanguageCode(newCode));
  }
}

// lib/core/bloc/theme/theme_cubit.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:routex_mobile/core/services/local/usecases/get_theme_usecase.dart';
import 'package:routex_mobile/core/services/local/usecases/set_theme_usecase.dart';
import 'package:routex_mobile/core/usecases/base_usecase.dart';

/// Global Cubit holding the user's theme preference.
///
/// Provided at the root next to [LanguageBloc]. Persists through
/// [SetThemeUseCase] as "light" | "dark" | "system" ([ThemeMode.name]), and
/// starts on [ThemeMode.light] (the Figma design) until [load] restores the
/// saved value. Dark and system are opt-in from Settings.
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit({
    required GetThemeUseCase getThemeUseCase,
    required SetThemeUseCase setThemeUseCase,
  })  : _getThemeUseCase = getThemeUseCase,
        _setThemeUseCase = setThemeUseCase,
        super(ThemeMode.light);

  final GetThemeUseCase _getThemeUseCase;
  final SetThemeUseCase _setThemeUseCase;

  Future<void> load() async {
    final result = await _getThemeUseCase(const NoParams());
    result.fold(
      (_) {},
      (saved) => emit(
        ThemeMode.values.firstWhere(
          (mode) => mode.name == saved,
          orElse: () => ThemeMode.light,
        ),
      ),
    );
  }

  /// Saves and applies [mode]; returns whether it was persisted.
  Future<bool> setMode(ThemeMode mode) async {
    final result = await _setThemeUseCase(SetThemeParams(themeMode: mode.name));
    return result.fold((_) => false, (saved) {
      if (saved) emit(mode);
      return saved;
    });
  }
}

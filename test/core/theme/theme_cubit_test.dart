import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:routex_mobile/core/bloc/theme/theme_cubit.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/services/local/usecases/get_theme_usecase.dart';
import 'package:routex_mobile/core/services/local/usecases/set_theme_usecase.dart';
import 'package:routex_mobile/core/usecases/base_usecase.dart';

class _MockGet extends Mock implements GetThemeUseCase {}

class _MockSet extends Mock implements SetThemeUseCase {}

void main() {
  late _MockGet get;
  late _MockSet set;

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(const SetThemeParams(themeMode: 'light'));
  });

  setUp(() {
    get = _MockGet();
    set = _MockSet();
  });

  ThemeCubit build() => ThemeCubit(getThemeUseCase: get, setThemeUseCase: set);

  test('starts on light (the Figma design)', () {
    expect(build().state, ThemeMode.light);
  });

  test('load restores the saved mode', () async {
    when(() => get(any())).thenAnswer((_) async => const Right('dark'));
    final cubit = build();
    await cubit.load();
    expect(cubit.state, ThemeMode.dark);
  });

  test('load falls back to light for unknown or missing values', () async {
    when(() => get(any())).thenAnswer((_) async => const Right('banana'));
    final cubit = build();
    await cubit.load();
    expect(cubit.state, ThemeMode.light);

    when(() => get(any())).thenAnswer((_) async => const Right(null));
    await cubit.load();
    expect(cubit.state, ThemeMode.light);
  });

  test('load keeps light when reading fails', () async {
    when(() => get(any())).thenAnswer((_) async => const Left(CacheFailure('x')));
    final cubit = build();
    await cubit.load();
    expect(cubit.state, ThemeMode.light);
  });

  test('setMode persists the name and emits only on success', () async {
    when(() => set(any())).thenAnswer((_) async => const Right(true));
    final cubit = build();
    expect(await cubit.setMode(ThemeMode.system), isTrue);
    expect(cubit.state, ThemeMode.system);
    verify(() => set(any(that: isA<SetThemeParams>().having((p) => p.themeMode, 'themeMode', 'system')))).called(1);

    when(() => set(any())).thenAnswer((_) async => const Left(CacheFailure('x')));
    expect(await cubit.setMode(ThemeMode.dark), isFalse);
    expect(cubit.state, ThemeMode.system);
  });
}

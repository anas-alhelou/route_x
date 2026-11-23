import 'package:flutter_test/flutter_test.dart';
import 'package:routex_mobile/core/bloc/language/language_bloc.dart';
import 'package:routex_mobile/core/config/constants/preference_keys.dart';
import 'package:routex_mobile/core/services/local/app_preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('without preferences it starts in English and toggles', () async {
    final bloc = LanguageBloc();
    expect(bloc.state.languageCode, 'en');
    bloc.add(ToggleLanguageEvent());
    await Future<void>.delayed(Duration.zero);
    expect(bloc.state.languageCode, 'ar');
    await bloc.close();
  });

  test('starts in the saved language', () async {
    SharedPreferences.setMockInitialValues({
      PreferenceKeys.languageCode: 'ar',
    });
    final prefs = await SharedPreferences.getInstance();
    final bloc = LanguageBloc(preferences: AppPreferencesServiceImpl(prefs: prefs));
    expect(bloc.state.languageCode, 'ar');
    await bloc.close();
  });

  test('ignores a saved value it does not support', () async {
    SharedPreferences.setMockInitialValues({
      PreferenceKeys.languageCode: 'fr',
    });
    final prefs = await SharedPreferences.getInstance();
    final bloc = LanguageBloc(preferences: AppPreferencesServiceImpl(prefs: prefs));
    expect(bloc.state.languageCode, 'en');
    await bloc.close();
  });

  test('a toggle is saved so the next launch restores it', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final service = AppPreferencesServiceImpl(prefs: prefs);
    final bloc = LanguageBloc(preferences: service);
    bloc.add(ToggleLanguageEvent());
    await Future<void>.delayed(Duration.zero);
    expect(prefs.getString(PreferenceKeys.languageCode), 'ar');
    expect(LanguageBloc(preferences: service).state.languageCode, 'ar');
    await bloc.close();
  });
}

// lib/features/main_layout/presentation/cubit/main_layout_cubit.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'main_layout_state.dart';

/// Cubit responsible for managing the active bottom-navigation tab.
///
/// Default tab is **index 0 (Home)**.
class MainLayoutCubit extends Cubit<MainLayoutState> {
  MainLayoutCubit() : super(const MainLayoutState(currentTabIndex: 0));

  /// Switch to [index] and preserve state via [IndexedStack].
  void changeTab(int index) {
    if (index == state.currentTabIndex) return;
    emit(state.copyWith(currentTabIndex: index, isBottomNavVisible: true));
  }

  /// Show or hide the floating bottom navigation bar.
  void setBottomNavVisible(bool visible) {
    if (state.isBottomNavVisible == visible) return;
    emit(state.copyWith(isBottomNavVisible: visible));
  }
}

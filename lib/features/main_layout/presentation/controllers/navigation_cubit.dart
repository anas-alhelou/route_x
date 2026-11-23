// lib/features/main_layout/presentation/controllers/navigation_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';

/// Lightweight navigation cubit that tracks the selected tab index.
///
/// Default tab: **1 (Route/Fleet)** — as per Figma specification.
/// Use [MainLayoutCubit] for the canonical, Equatable-backed version.
/// This cubit remains for backwards compatibility with existing usages.
class NavigationCubit extends Cubit<int> {
  /// Starts on the Route tab (index 1) per Figma design.
  NavigationCubit() : super(1);

  /// Emit [index] to switch the active navigation tab.
  void changeTab(int index) => emit(index);
}

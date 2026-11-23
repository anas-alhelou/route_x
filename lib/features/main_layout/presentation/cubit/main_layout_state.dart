// lib/features/main_layout/presentation/cubit/main_layout_state.dart
part of 'main_layout_cubit.dart';

/// Immutable state for [MainLayoutCubit].
///
/// Holds the currently selected bottom-nav [currentTabIndex].
/// Index mapping:
///   0 → Home
///   1 → Route  ← default
///   2 → Orders
///   3 → Settings
final class MainLayoutState extends Equatable {
  const MainLayoutState({
    required this.currentTabIndex,
    this.isBottomNavVisible = true,
  });

  final int currentTabIndex;
  final bool isBottomNavVisible;

  MainLayoutState copyWith({
    int? currentTabIndex,
    bool? isBottomNavVisible,
  }) {
    return MainLayoutState(
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      isBottomNavVisible: isBottomNavVisible ?? this.isBottomNavVisible,
    );
  }

  @override
  List<Object> get props => [currentTabIndex, isBottomNavVisible];
}

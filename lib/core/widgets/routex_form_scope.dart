// lib/core/widgets/routex_form_scope.dart

import 'package:flutter/widgets.dart';

/// Wipes the validation errors of every field in one form at once.
///
/// A form reports its problems only when the user presses its action button
/// (Login / Next / Save). From then on the fields own a red border and a red
/// message each, and nothing used to take them away again: tapping into the
/// *next* field left the previous ones still red, and fixing a value could
/// leave a stale message behind. This controller is the single place a form
/// can say "the user is working on it again, drop the errors".
///
/// [RouteXTextField] registers itself on mount and asks the scope to clear
/// **every** registered field the moment *any* of them gains focus — the
/// fields are siblings, so a message under "Password" has nothing useful to say
/// while the user is typing in "Email".
///
/// Fields that are not inside a [RouteXFormScope] simply have no controller to
/// talk to and behave exactly as before, so this stays opt-in per form.
class RouteXFormController extends ChangeNotifier {
  /// Clears one field's error state. Supplied by `RouteXTextField`.
  final List<VoidCallback> _clearers = [];

  /// Registers [clear]; called on the field's mount and on every scope swap.
  void register(void Function() clear) => _clearers.add(clear);

  /// Removes a previously registered [clear]; called on unmount.
  void unregister(void Function() clear) => _clearers.remove(clear);

  /// Wipes every registered field's error.
  ///
  /// Iterates a copy because a field that disappears while it is being cleared
  /// unregisters itself, which would otherwise mutate the list mid-loop.
  void clearAllErrors() {
    for (final clear in List.of(_clearers)) {
      clear();
    }
  }

  @visibleForTesting
  int get registeredCount => _clearers.length;
}

/// Scopes a set of fields to a single [RouteXFormController].
///
/// Wrap the children of a `Form` with it:
///
/// ```dart
/// RouteXFormScope(
///   child: Form(key: _formKey, child: Column(children: [ ... ])),
/// )
/// ```
///
/// The scope is a plain [InheritedWidget] rather than an `InheritedNotifier`:
/// clearing errors calls `setState` on the fields themselves, so notifying
/// here would only rebuild the whole subtree a second time for nothing.
class RouteXFormScope extends StatefulWidget {
  const RouteXFormScope({super.key, required this.child});

  /// The form whose fields share one error state.
  final Widget child;

  /// The scope [context] is inside, or null when the form is not scoped.
  static RouteXFormController? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_RouteXFormScopeInherited>()
      ?.controller;

  @override
  State<RouteXFormScope> createState() => _RouteXFormScopeState();
}

class _RouteXFormScopeState extends State<RouteXFormScope> {
  final RouteXFormController _controller = RouteXFormController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _RouteXFormScopeInherited(
      controller: _controller,
      child: widget.child,
    );
  }
}

class _RouteXFormScopeInherited extends InheritedWidget {
  const _RouteXFormScopeInherited({
    required this.controller,
    required super.child,
  });

  final RouteXFormController controller;

  @override
  bool updateShouldNotify(_RouteXFormScopeInherited oldWidget) =>
      oldWidget.controller != controller;
}

// lib/features/home/domain/failures/home_failures.dart

/// The failure contract Home's repositories return.
///
/// Home raises the shared app-level failures from `core/errors/failures.dart`
/// rather than feature-local ones: every case a Home repository can produce —
/// a server error, a network failure, a rejected session — is one the rest of
/// the app already understands and renders. A second `Failure` hierarchy scoped
/// to this feature would be a second source of truth for the same conditions.
///
/// This file is therefore the feature's single import point for that contract,
/// so a genuinely Home-specific failure — if one is ever needed — gets a home
/// here instead of being bolted onto the shared types.
library;

export 'package:routex_mobile/core/errors/failures.dart';

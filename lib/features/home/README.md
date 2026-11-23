# Home

The driver's dashboard: today's shift overview, fleet setup checklist, fleet
search, and the online toggle.

## Structure

```
lib/features/home/
├── domain/
│   ├── entities/        # 8 value objects the screen renders
│   ├── repositories/    # abstract contracts (+ the fleet-request store)
│   ├── usecases/        # 5 business operations
│   ├── value_objects/   # FleetCode
│   └── failures/        # the feature's import point for the failure contract
│
├── data/
│   ├── models/          # wire/DTO models (fromJson/toJson)
│   ├── datasources/     # local implementations + the remote contract
│   ├── stores/          # in-memory FleetRequestStore
│   └── repositories/    # 4 impls satisfying the domain contracts
│
├── presentation/
│   ├── bloc/            # home, find-fleet, enter-fleet-code, delivery_dashboard
│   ├── routes/          # HomeRoutes — the GoRoutes this feature owns
│   ├── navigation/      # HomeNavigator — how the dashboard reaches them
│   ├── pages/           # pages
│   └── widgets/         # widgets, incl. the go_online/ sheet
│
└── README.md
```

## Layering

`presentation → domain ← data`. The blocs depend only on `domain` contracts;
the `data` implementations satisfy them; nothing in `presentation` imports
`data` directly.

- **Routes are feature-owned.** `app_router.dart` spreads `HomeRoutes.routes`
  into its top-level list, so Home declares *which* pages it exposes and the app
  router only mounts them. `HomeNavigator` reaches those same routes by
  `RoutersName`, so a page is never pushed by a path string that has drifted from
  its declared entry.
- **Every repository returns `Either<Failure, T>`.** The shared failure contract
  lives in `core/errors/failures.dart`; `domain/failures/home_failures.dart` is
  the single import point for it inside this feature.

## Current state

The feature is fully wired against **local** data sources so the dashboard runs
end-to-end without a backend. The remote path is *contracted* but not yet
implemented:

- `HomeRemoteDataSource` declares the three operations the local sources
  currently satisfy.
- `ApiEndpoints` does not yet register any Home path (only auth and orders), so
  there is no Dio-backed `HomeRemoteDataSourceImpl`.

The `Either<Failure, T>` signatures in `domain/repositories` and the
`HomeRemoteDataSource` contract are deliberately the shapes a network
implementation will honour, so swapping a local source for a remote one changes
nothing above the data layer.

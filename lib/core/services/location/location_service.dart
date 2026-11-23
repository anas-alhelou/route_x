// lib/core/services/location/location_service.dart
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'user_location.dart';

/// Contract for accessing geolocation data, caching, and location update streams.
abstract class LocationService {
  /// Returns the current user location.
  ///
  /// Results are cached for [cacheDuration] (default 5 minutes) to conserve battery
  /// and minimize GPS queries. Set [forceRefresh] to true to bypass cache.
  /// Gracefully falls back to the last known location or null if offline/permission denied.
  Future<UserLocation?> getCurrentLocation({bool forceRefresh = false});

  /// Retrieves the last recorded location without turning on the GPS sensor.
  Future<UserLocation?> getLastKnownLocation();

  /// Stream of location updates as the user moves (filtered by distance threshold).
  Stream<UserLocation> get onLocationChanged;

  /// Returns true if location permission has been granted by the user.
  Future<bool> hasPermission();

  /// Returns true if the device's location service is toggled on.
  Future<bool> isLocationServiceEnabled();

  /// Disposes internal stream controllers and subscriptions.
  void dispose();
}

/// Production implementation of [LocationService] using [Geolocator].
class LocationServiceImpl implements LocationService {
  LocationServiceImpl({
    this.cacheDuration = const Duration(minutes: 5),
    this.distanceFilter = 300,
  });

  /// Cache TTL to prevent frequent GPS lookups.
  final Duration cacheDuration;

  /// Minimum distance in meters before a location update event is broadcast.
  final int distanceFilter;

  UserLocation? _cachedLocation;
  DateTime? _lastFetchTime;

  StreamController<UserLocation>? _locationController;
  StreamSubscription<Position>? _positionSubscription;

  @override
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> hasPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<UserLocation?> getLastKnownLocation() async {
    try {
      final position = await Geolocator.getLastKnownPosition();
      if (position != null) {
        return _mapPosition(position);
      }
    } catch (_) {
      // Offline or permission issue — return cached or null
    }
    return _cachedLocation;
  }

  @override
  Future<UserLocation?> getCurrentLocation({bool forceRefresh = false}) async {
    // 1. Return valid cache if still fresh
    if (!forceRefresh &&
        _cachedLocation != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < cacheDuration) {
      return _cachedLocation;
    }

    // 2. Check service & permission without throwing
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      return await getLastKnownLocation();
    }

    final hasPerm = await hasPermission();
    if (!hasPerm) {
      return await getLastKnownLocation();
    }

    // 3. Query current location with timeLimit for offline resilience
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 7),
        ),
      );

      final userLoc = _mapPosition(position);
      _cachedLocation = userLoc;
      _lastFetchTime = DateTime.now();
      return userLoc;
    } catch (_) {
      // Offline, timeout, or location error: fall back to last known or cache
      final lastKnown = await getLastKnownLocation();
      if (lastKnown != null) {
        _cachedLocation = lastKnown;
        _lastFetchTime = DateTime.now();
        return lastKnown;
      }
      return _cachedLocation;
    }
  }

  @override
  Stream<UserLocation> get onLocationChanged {
    if (_locationController == null || _locationController!.isClosed) {
      _locationController = StreamController<UserLocation>.broadcast();
      _startListening();
    }
    return _locationController!.stream;
  }

  void _startListening() {
    _positionSubscription?.cancel();
    try {
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.medium,
          distanceFilter: distanceFilter,
        ),
      ).listen(
        (position) {
          final userLoc = _mapPosition(position);
          _cachedLocation = userLoc;
          _lastFetchTime = DateTime.now();
          if (_locationController != null && !_locationController!.isClosed) {
            _locationController!.add(userLoc);
          }
        },
        onError: (_) {
          // Suppress stream errors so callers aren't crashed by connectivity loss
        },
      );
    } catch (_) {
      // Failed to start stream (e.g. permission or service disabled)
    }
  }

  UserLocation _mapPosition(Position pos) {
    return UserLocation(
      latitude: pos.latitude,
      longitude: pos.longitude,
      timestamp: pos.timestamp,
      altitude: pos.altitude,
      accuracy: pos.accuracy,
      speed: pos.speed,
    );
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _locationController?.close();
    _locationController = null;
  }
}

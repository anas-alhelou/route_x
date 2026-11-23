// lib/features/home/data/repositories/home_dashboard_repository_impl.dart
import 'dart:async';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/core/network/exception_mapper.dart';
import 'package:routex_mobile/features/home/data/datasources/home_dashboard_local_data_source.dart';
import 'package:routex_mobile/features/home/data/datasources/home_dashboard_remote_data_source.dart';
import 'package:routex_mobile/features/home/domain/entities/driver_entity.dart';
import 'package:routex_mobile/features/home/domain/entities/driver_status_entity.dart';
import 'package:routex_mobile/features/home/domain/entities/home_stats_entity.dart';
import 'package:routex_mobile/features/home/domain/entities/location_entity.dart';
import 'package:routex_mobile/features/home/domain/entities/upcoming_ride_entity.dart';
import 'package:routex_mobile/features/home/domain/repositories/home_dashboard_repository.dart';

/// Data-layer implementation of [HomeDashboardRepository].
///
/// Every read is cache-first: a cache hit is returned without touching the
/// network, and a miss fetches remote, converts model to entity, and writes the
/// entity back to the cache before returning it. Every error — a `Failure`
/// thrown by a data source, a transport error, or anything unexpected — is
/// mapped to a `Failure` in [_guard] so the domain never sees a raw exception.
class HomeDashboardRepositoryImpl implements HomeDashboardRepository {
  const HomeDashboardRepositoryImpl({
    required HomeDashboardRemoteDataSource remoteDataSource,
    required HomeDashboardLocalDataSource localDataSource,
    ExceptionMapper exceptionMapper = const ExceptionMapper(),
  })  : _remote = remoteDataSource,
        _local = localDataSource,
        _mapper = exceptionMapper;

  final HomeDashboardRemoteDataSource _remote;
  final HomeDashboardLocalDataSource _local;
  final ExceptionMapper _mapper;

  @override
  Future<Either<Failure, DriverEntity>> getDriverProfile() => _guard(() async {
        final cached = await _local.getCachedDriver();
        if (cached != null) return cached;

        final entity = (await _remote.getDriverProfile()).toEntity();
        await _local.cacheDriver(entity);
        return entity;
      });

  @override
  Future<Either<Failure, HomeStatsEntity>> getHomeStats() => _guard(() async {
        final cached = await _local.getCachedHomeStats();
        if (cached != null) return cached;

        final entity = (await _remote.getHomeStats()).toEntity();
        await _local.cacheHomeStats(entity);
        return entity;
      });

  @override
  Future<Either<Failure, List<UpcomingRideEntity>>> getUpcomingRides() =>
      _guard(() async {
        final cached = await _local.getCachedUpcomingRides();
        if (cached != null) return cached;

        final entities =
            (await _remote.getUpcomingRides()).map((m) => m.toEntity()).toList();
        await _local.cacheUpcomingRides(entities);
        return entities;
      });

  @override
  Future<Either<Failure, DriverStatusEntity>> updateDriverStatus({
    required DriverStatus status,
    Duration? onlineForDuration,
  }) =>
      _guard(() async {
        final entity = (await _remote.updateDriverStatus(
          status: status,
          onlineForDuration: onlineForDuration,
        ))
            .toEntity();
        await _local.cacheDriverStatus(entity);
        return entity;
      });

  @override
  Future<Either<Failure, LocationEntity>> getCurrentLocation() =>
      _guard(() async {
        final cached = await _local.getCachedLocation();
        if (cached != null) return cached;

        final entity = (await _remote.getCurrentLocation()).toEntity();
        await _local.cacheLocation(entity);
        return entity;
      });

  @override
  Future<Either<Failure, DriverStatusEntity>> getCurrentStatus() =>
      _guard(() async {
        final cached = await _local.getCachedDriverStatus();
        if (cached != null) return cached;

        final entity = (await _remote.getCurrentStatus()).toEntity();
        await _local.cacheDriverStatus(entity);
        return entity;
      });

  @override
  Future<Either<Failure, void>> refreshHomeData() => _guard(() async {
        await _remote.refreshHomeData();

        await _local.cacheDriver((await _remote.getDriverProfile()).toEntity());
        await _local.cacheHomeStats((await _remote.getHomeStats()).toEntity());
        await _local.cacheUpcomingRides(
          (await _remote.getUpcomingRides()).map((m) => m.toEntity()).toList(),
        );
        await _local.cacheDriverStatus(
          (await _remote.getCurrentStatus()).toEntity(),
        );
        await _local.cacheLocation(
          (await _remote.getCurrentLocation()).toEntity(),
        );
      });

  /// Runs [body] and funnels every failure mode into a `Failure`.
  ///
  /// A `Failure` thrown by a data source is already correct and is passed
  /// through. Transport-level errors are named by kind — a dropped socket and a
  /// slow server are different messages to the driver — and any HTTP error is
  /// handed to [ExceptionMapper], which knows the backend envelope. Anything
  /// else is unexpected and mapped to [GenericFailure].
  Future<Either<Failure, T>> _guard<T>(Future<T> Function() body) async {
    try {
      return Right(await body());
    } on Failure catch (failure) {
      return Left(failure);
    } on SocketException {
      return const Left(NetworkFailure());
    } on TimeoutException {
      return const Left(NetworkFailure(ExceptionMapper.requestTimeoutKey));
    } on DioException catch (error) {
      return Left(_mapper.map(error));
    } catch (error) {
      return Left(GenericFailure(error.toString()));
    }
  }
}

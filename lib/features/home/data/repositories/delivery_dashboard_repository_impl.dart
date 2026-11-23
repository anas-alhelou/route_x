// lib/features/home/data/repositories/delivery_dashboard_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:routex_mobile/core/errors/failures.dart';
import 'package:routex_mobile/features/home/data/datasources/delivery_dashboard_local_data_source.dart';
import 'package:routex_mobile/features/home/domain/entities/delivery_data.dart';
import 'package:routex_mobile/features/home/domain/repositories/delivery_dashboard_repository.dart';

class DeliveryDashboardRepositoryImpl implements DeliveryDashboardRepository {
  const DeliveryDashboardRepositoryImpl({required this.localDataSource});

  final DeliveryDashboardLocalDataSource localDataSource;

  @override
  Future<Either<Failure, DeliveryDashboard>> getDeliveryDashboard({
    DeliveryScenario? scenario,
  }) async {
    try {
      final model = await localDataSource.getDashboard(scenario: scenario);
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DeliveryDashboard>> switchScenario(
    DeliveryScenario scenario,
  ) async {
    try {
      final model = await localDataSource.switchScenario(scenario);
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

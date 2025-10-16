import '../../core/datasources/station_remote_datasource.dart';
import '../../core/models/station.dart';
import '../../core/repositories/station_repository.dart';
import '../../core/utils/exceptions.dart';

/// Concrete implementation of `StationRepository`.
class StationRepositoryImpl implements StationRepository {
  final StationRemoteDataSource remoteDataSource;

  StationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Station>> getStations() async {
    try {
      final stationModels = await remoteDataSource.fetchAllStations();
      return stationModels.map((model) => model.toEntity()).toList();
    } on DataFetchException {
      rethrow; // Re-throw specific exceptions
    } catch (e) {
      throw DataFetchException('An unexpected error occurred: ${e.toString()}');
    }
  }

  @override
  Stream<List<Station>> streamStations() {
    try {
      return remoteDataSource
          .streamStations()
          .map((models) => models.map((model) => model.toEntity()).toList());
    } on DataFetchException {
      rethrow; // Re-throw specific exceptions
    } catch (e) {
      throw DataFetchException('An unexpected error occurred while streaming stations: ${e.toString()}');
    }
  }
}
import '../models/station.dart';

/// Abstract class defining the contract for station data operations.
abstract class StationRepository {
  /// Fetches all available stations.
  /// Throws [DataFetchException] if data fetching fails.
  Future<List<Station>> getStations();

  /// Streams real-time updates of all stations.
  /// Throws [DataFetchException] if stream establishment fails.
  Stream<List<Station>> streamStations();
}
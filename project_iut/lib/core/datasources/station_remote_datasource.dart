import 'package:supabase_flutter/supabase_flutter.dart';
import  '../../core/models/station_model.dart';
import '../../core/utils/exceptions.dart';

/// Abstract class defining the remote data source operations for stations.
abstract class StationRemoteDataSource {
  Future<List<StationModel>> fetchAllStations();
  Stream<List<StationModel>> streamStations();
}

/// Concrete implementation of `StationRemoteDataSource` using Supabase.
class StationRemoteDataSourceImpl implements StationRemoteDataSource {
  final SupabaseClient supabaseClient;

  StationRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<StationModel>> fetchAllStations() async {
    try {
      final response = await supabaseClient
          .from('stations')
          .select()
          .order('name', ascending: true);

      return response
          .map<StationModel>((json) => StationModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw DataFetchException('Supabase error: ${e.message}');
    } catch (e) {
      throw DataFetchException(e.toString());
    }
  }

  @override
  Stream<List<StationModel>> streamStations() {
    try {
      return supabaseClient
          .from('stations')
          .stream(primaryKey: ['id'])
          .order('name', ascending: true)
          .map((data) =>
              data.map((json) => StationModel.fromJson(json)).toList());
    } on PostgrestException catch (e) {
      throw DataFetchException('Supabase stream error: ${e.message}');
    } catch (e) {
      throw DataFetchException('Failed to establish station stream: ${e.toString()}');
    }
  }
}
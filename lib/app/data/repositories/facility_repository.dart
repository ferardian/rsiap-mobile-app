import '../models/facility_model.dart';
import '../services/api_service.dart';
import '../../../core/constants/api_config.dart';

class FacilityRepository {
  final ApiService _apiService;

  FacilityRepository(this._apiService);

  Future<List<FacilityModel>> getFacilities() async {
    try {
      final response = await _apiService.client.get(ApiConfig.facility);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => FacilityModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching facilities: $e');
      return [];
    }
  }
}

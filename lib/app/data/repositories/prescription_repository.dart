import 'package:dio/dio.dart';
import '../services/api_service.dart';

class PrescriptionRepository {
  final ApiService _apiService;

  PrescriptionRepository(this._apiService);

  Future<Map<String, dynamic>> getPrescriptionDetails(String noResep) async {
    try {
      final response = await _apiService.client.get('/farmasi/resep/$noResep');
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data ?? {'message': e.message};
    }
  }
}

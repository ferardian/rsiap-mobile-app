import 'package:dio/dio.dart';
import '../../../../core/constants/api_config.dart';
import '../services/api_service.dart';

class BookingRepository {
  final ApiService _apiService;

  BookingRepository(this._apiService);

  // Fetch Schedules (Jadwal Dokter)
  Future<List<dynamic>> fetchSchedules(
    List<String> kodePoli,
    String day,
  ) async {
    try {
      final response = await _apiService.client.post(
        ApiConfig.jadwalSearch,
        data: {
          "filters": [
            {"field": "kd_poli", "operator": "in", "value": kodePoli},
            {"field": "hari_kerja", "operator": "=", "value": day},
          ],
          "includes": [
            {"relation": "dokter.spesialis"},
            {"relation": "dokter.pegawai"}, // For fetching photos
          ],
        },
      );
      return response.data['data'];
    } on DioException catch (e) {
      throw e.response?.data ?? {'message': e.message};
    }
  }

  // Submit Booking
  Future<Map<String, dynamic>> submitBooking(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.client.post(
        ApiConfig.bookingRegistrasi,
        data: data,
      );
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data ?? {'message': e.message};
    }
  }
}

import 'package:dio/dio.dart';
import '../services/api_service.dart';
import '../../../core/constants/api_config.dart';

class MedicalRecordRepository {
  final ApiService _apiService;

  MedicalRecordRepository(this._apiService);

  Future<Map<String, dynamic>> getLabHistory(
    String noRkmMedis, {
    String? tanggalDari,
    String? tanggalSampai,
  }) async {
    try {
      final response = await _apiService.client.get(
        '/erm/riwayat-lab',
        queryParameters: {
          'no_rkm_medis': noRkmMedis,
          'tanggal_dari': tanggalDari,
          'tanggal_sampai': tanggalSampai,
          'sort': 'tgl_periksa:desc',
          'limit': 100, // Get more by default since we filter by year
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data ?? {'message': e.message};
    }
  }

  Future<Map<String, dynamic>> getRadiologyHistory(
    String noRkmMedis, {
    String? tanggalDari,
    String? tanggalSampai,
  }) async {
    try {
      final filters = [
        {"field": "no_rkm_medis", "operator": "=", "value": noRkmMedis},
        {"field": "stts", "operator": "=", "value": "Sudah"},
      ];

      if (tanggalDari != null) {
        filters.add({
          "field": "tgl_registrasi",
          "operator": ">=",
          "value": tanggalDari,
        });
      }
      if (tanggalSampai != null) {
        filters.add({
          "field": "tgl_registrasi",
          "operator": "<=",
          "value": tanggalSampai,
        });
      }

      // Use booking search but filter for completed and include radiology
      final response = await _apiService.client.post(
        ApiConfig.bookingSearch,
        queryParameters: {
          'include':
              'periksaRadiologi,dokter,poliklinik,periksaRadiologi.gambarRadiologi,periksaRadiologi.hasilRadiologi',
        },
        data: {
          "filters": filters,
          "sort": [
            {"field": "tgl_registrasi", "direction": "desc"},
          ],
        },
      );

      // We need to filter client-side to ensure 'periksaRadiologi' is not empty
      // Because API returns all completed visits
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data ?? {'message': e.message};
    }
  }
}

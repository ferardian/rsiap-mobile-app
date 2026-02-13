import '../services/api_service.dart';
import '../../../core/constants/api_config.dart';
import 'package:dio/dio.dart';

class PoliQueueRepository {
  final ApiService _apiService;

  PoliQueueRepository(this._apiService);

  Future<List<dynamic>> getAntrianSummary() async {
    try {
      final response = await _apiService.client.get(
        ApiConfig.poliklinikAntrianSummary,
      );

      final data = response.data;
      if (data == null) {
        throw 'Data tidak ditemukan dari server';
      }

      if (data is Map && data['success'] == true) {
        return List<dynamic>.from(data['data'] ?? []);
      }

      throw data is Map
          ? (data['message'] ?? 'Gagal mengambil data antrian')
          : 'Format data tidak valid';
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data is Map) {
        throw e.response?.data['message'] ?? e.message;
      }
      throw e.message ?? 'Terjadi kesalahan koneksi';
    } catch (e) {
      throw e.toString();
    }
  }
}

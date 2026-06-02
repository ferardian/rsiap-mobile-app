import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:rsiap_mobile_app/app/data/services/api_service.dart';

class VaccinationRepository {
  final ApiService _apiService = Get.find<ApiService>();

  Future<List<dynamic>> getVaccinationHistory(
    String noRkmMedis,
    String tglLahir,
  ) async {
    try {
      final response = await _apiService.client.post(
        'vaccination/history',
        data: {'no_rkm_medis': noRkmMedis, 'tgl_lahir': tglLahir},
      );
      return response.data['data'];
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Gagal memuat data imunisasi';
    }
  }

  Future<dynamic> addVaccinationRecord(
    String noRkmMedis,
    int masterId,
    String tglPemberian,
    String? catatan,
  ) async {
    try {
      final response = await _apiService.client.post(
        'vaccination',
        data: {
          'no_rkm_medis': noRkmMedis,
          'master_imunisasi_id': masterId,
          'tgl_pemberian': tglPemberian,
          'catatan': catatan,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Gagal menyimpan data imunisasi';
    }
  }
}

import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../services/api_service.dart';
import '../../../core/constants/api_config.dart';

class AppointmentRepository {
  final ApiService _apiService;

  AppointmentRepository(this._apiService);

  Future<Map<String, dynamic>> cancelAppointment(String noRawat) async {
    try {
      final box = GetStorage();
      final token = box.read('token');

      final response = await _apiService.client.post(
        ApiConfig.bookingBatal,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        data: {'no_rawat': noRawat},
      );

      return response.data;
    } on DioException catch (e) {
      throw e.response?.data ?? {'message': e.message};
    }
  }

  Future<Map<String, dynamic>> getActiveAppointments(String noRkmMedis) async {
    try {
      final today = DateTime.now().toString().substring(0, 10);

      final box = GetStorage();
      final token = box.read('token');

      final response = await _apiService.client.post(
        ApiConfig.bookingSearch,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
        queryParameters: {
          'include': 'dokter.spesialis,caraBayar,pasien,poliklinik',
        },
        data: {
          "sort": [
            {"field": "tgl_registrasi", "direction": "desc"},
          ],
          "filters": [
            {"field": "no_rkm_medis", "operator": "=", "value": noRkmMedis},
            {"field": "tgl_registrasi", "operator": ">=", "value": today},
            // Remove 'stts' filter to get all statuses (Belum, Periksa, Sudah, etc.)
            // We will filter out 'Batal' explicitly if needed, or handle in UI
            {"field": "stts", "operator": "!=", "value": "Batal"},
          ],
        },
      );

      // Note: Backend might already include 'jadwal' natively now.
      // But we keep this logic to be safe or if 'jadwal' is missing.

      List<Map<String, dynamic>> appointments = List<Map<String, dynamic>>.from(
        response.data['data'],
      );

      // Enrich with schedule data
      for (var i = 0; i < appointments.length; i++) {
        // If 'jadwal' is already present (from backend), skip enrichment or use it.
        if (appointments[i]['jadwal'] != null) {
          appointments[i]['jadwal_enrich'] = appointments[i]['jadwal'];
          continue;
        }

        try {
          final tgl = DateTime.parse(appointments[i]['tgl_registrasi']);
          final dayName = _getDayName(tgl);
          final kdPoli = appointments[i]['kd_poli'];
          final kdDokter = appointments[i]['kd_dokter'];

          final jadwalResponse = await _apiService.client.post(
            ApiConfig.jadwalSearch,
            data: {
              "filters": [
                {"field": "kd_poli", "operator": "=", "value": kdPoli},
                {"field": "hari_kerja", "operator": "=", "value": dayName},
                {"field": "kd_dokter", "operator": "=", "value": kdDokter},
              ],
            },
          );

          if (jadwalResponse.data['data'] != null &&
              (jadwalResponse.data['data'] as List).isNotEmpty) {
            appointments[i]['jadwal_enrich'] = jadwalResponse.data['data'][0];
          }
        } catch (e) {
          print('Failed to enrich schedule for appointment $i: $e');
        }
      }

      return {'data': appointments};
    } on DioException catch (e) {
      throw e.response?.data ?? {'message': e.message};
    }
  }

  String _getDayName(DateTime date) {
    List<String> days = [
      'SENIN',
      'SELASA',
      'RABU',
      'KAMIS',
      'JUMAT',
      'SABTU',
      'MINGGU',
    ];
    return days[date.weekday - 1];
  }

  Future<Map<String, dynamic>> getQueueStatus(
    String kdPoli,
    String kdDokter,
    String? noReg,
  ) async {
    try {
      final response = await _apiService.client.post(
        '/public/antrian-poli/status',
        data: {
          'kd_poli': kdPoli,
          'kd_dokter': kdDokter,
          if (noReg != null) 'no_reg': noReg,
        },
      );

      if (response.data != null && response.data['success'] == true) {
        return response.data['data'];
      }
      return {'current_queue': 0, 'total_queue': 0};
    } catch (e) {
      print('Error fetching queue status: $e');
      return {'current_queue': 0, 'total_queue': 0};
    }
  }
}

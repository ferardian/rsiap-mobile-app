import 'package:dio/dio.dart';
import '../services/api_service.dart';
import '../../../core/constants/api_config.dart';

class ScheduleRepository {
  final ApiService _apiService;

  ScheduleRepository(this._apiService);

  Future<Map<String, dynamic>> getSchedules({
    String? day,
    String? poli,
    String? search,
  }) async {
    final filters = <Map<String, dynamic>>[];

    if (day != null && day.isNotEmpty) {
      filters.add({'field': 'hari_kerja', 'operator': '=', 'value': day});
    }

    if (poli != null && poli.isNotEmpty) {
      filters.add({'field': 'kd_poli', 'operator': '=', 'value': poli});
    }

    if (search != null && search.isNotEmpty) {
      filters.add({
        'field': 'dokter.nm_dokter',
        'operator': 'like',
        'value': '%$search%',
      });
    }

    try {
      final response = await _apiService.client.post(
        ApiConfig.jadwalSearch,
        data: {
          'filters': filters,
          'sort': [
            {'field': 'hari_kerja', 'direction': 'asc'},
            {'field': 'kd_poli', 'direction': 'asc'},
          ],
        },
        queryParameters: {'include': 'dokter.spesialis,poliklinik'},
      );

      return response.data;
    } on DioException catch (e) {
      throw e.response?.data ?? {'message': e.message};
    }
  }
}

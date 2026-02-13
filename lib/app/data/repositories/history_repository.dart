import '../services/api_service.dart';

class HistoryRepository {
  final ApiService _apiService;

  HistoryRepository(this._apiService);

  Future<Map<String, dynamic>> getHistory({
    required String noRkmMedis,
    int page = 1,
    int limit = 15,
  }) async {
    // Determine the start date for filtering (e.g., last 5 years or all time)
    // For now, we'll just filter by no_rkm_medis and status
    // We want to exclude 'Belum' (waiting) and 'Batal' (cancelled) usually,
    // but the requirement says "Past medical examinations".
    // Let's filter stts != 'Belum' to show processed registrations.

    final response = await _apiService.client.post(
      '/registrasi/periksa/search',
      queryParameters: {
        'page': page,
        'limit': limit,
        'include': 'dokter.spesialis,poliklinik,pemeriksaanRalan',
      },
      data: {
        'filters': [
          {'field': 'no_rkm_medis', 'operator': '=', 'value': noRkmMedis},
          {'field': 'stts', 'operator': '!=', 'value': 'Belum'},
          {'field': 'stts', 'operator': '!=', 'value': 'Batal'},
        ],
        'sort': [
          {'field': 'tgl_registrasi', 'direction': 'desc'},
          {'field': 'jam_reg', 'direction': 'desc'},
        ],
      },
    );

    return response.data;
  }
}

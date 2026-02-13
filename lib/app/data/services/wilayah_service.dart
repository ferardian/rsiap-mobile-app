import 'package:rsiap_mobile_app/app/data/services/api_service.dart';

class WilayahService {
  final ApiService _apiService = ApiService();

  Future<List<dynamic>> getPropinsi() async {
    try {
      final response = await _apiService.client.get('/wilayah/propinsi');
      if (response.statusCode == 200) {
        final List<dynamic> rawData = response.data['message'] ?? [];
        return rawData.map((e) {
          return {'kd_prop': e['kd_prop'].toString(), 'nm_prop': e['nm_prop']};
        }).toList();
      }
      return [];
    } catch (e) {
      print('Failed to load propinsi: $e');
      return [];
    }
  }

  Future<List<dynamic>> getKabupaten({String? kdProp}) async {
    try {
      final response = await _apiService.client.get(
        '/wilayah/kabupaten',
        queryParameters: kdProp != null ? {'kd_prop': kdProp} : {},
      );
      if (response.statusCode == 200) {
        final List<dynamic> rawData = response.data['message'] ?? [];
        return rawData.map((e) {
          return {'kd_kab': e['kd_kab'].toString(), 'nm_kab': e['nm_kab']};
        }).toList();
      }
      return [];
    } catch (e) {
      print('Failed to load kabupaten: $e');
      return [];
    }
  }

  Future<List<dynamic>> getKecamatan({String? kdKab}) async {
    try {
      final response = await _apiService.client.get(
        '/wilayah/kecamatan',
        queryParameters: kdKab != null ? {'kd_kab': kdKab} : {},
      );
      if (response.statusCode == 200) {
        final List<dynamic> rawData = response.data['message'] ?? [];
        return rawData.map((e) {
          return {'kd_kec': e['kd_kec'].toString(), 'nm_kec': e['nm_kec']};
        }).toList();
      }
      return [];
    } catch (e) {
      print('Failed to load kecamatan: $e');
      return [];
    }
  }

  Future<List<dynamic>> getKelurahan({String? kdKec}) async {
    try {
      final response = await _apiService.client.get(
        '/wilayah/kelurahan',
        queryParameters: kdKec != null ? {'kd_kec': kdKec} : {},
      );
      if (response.statusCode == 200) {
        final List<dynamic> rawData = response.data['message'] ?? [];
        return rawData.map((e) {
          return {'kd_kel': e['kd_kel'].toString(), 'nm_kel': e['nm_kel']};
        }).toList();
      }
      return [];
    } catch (e) {
      print('Failed to load kelurahan: $e');
      return [];
    }
  }
}

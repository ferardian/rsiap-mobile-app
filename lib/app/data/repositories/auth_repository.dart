import 'package:dio/dio.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../../../core/constants/api_config.dart';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository(this._apiService);

  Future<Map<String, dynamic>> login(String noRkmMedis, String password) async {
    try {
      final response = await _apiService.client.post(
        ApiConfig.login,
        data: {'no_rkm_medis': noRkmMedis, 'password': password},
      );
      return response.data;
    } on DioException catch (e) {
      throw e.response?.data ?? {'message': e.message};
    }
  }

  Future<User> getUserDetail(String token) async {
    try {
      final response = await _apiService.client.get(
        ApiConfig.userDetail,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      // Access 'data' field since rsiap_mobile code indicates response.body['data']
      final data = response.data['data'];
      return User.fromJson(data);
    } on DioException catch (e) {
      throw e.response?.data ?? {'message': e.message};
    }
  }
}

import 'package:dio/dio.dart';
import '../services/api_service.dart';
import '../../../core/constants/api_config.dart';
import '../models/slider_model.dart';

class SliderRepository {
  final ApiService _apiService;

  SliderRepository(this._apiService);

  Future<List<SliderModel>> getSliders() async {
    try {
      final response = await _apiService.client.get(ApiConfig.slider);

      if (response.data['data'] != null) {
        return (response.data['data'] as List)
            .map((e) => SliderModel.fromJson(e))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw e.response?.data ?? {'message': e.message};
    }
  }
}

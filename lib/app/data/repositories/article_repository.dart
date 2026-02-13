import 'package:rsiap_mobile_app/app/data/models/article_model.dart';
import 'package:rsiap_mobile_app/app/data/services/api_service.dart';
import 'package:rsiap_mobile_app/core/constants/api_config.dart';

class ArticleRepository {
  final ApiService _apiService;

  ArticleRepository(this._apiService);

  Future<List<ArticleModel>> getArticles() async {
    try {
      final response = await _apiService.client.get(ApiConfig.article);
      final List<dynamic> data = response.data['data'];
      return data.map((json) => ArticleModel.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
}

import 'package:get/get.dart';
import '../controllers/history_controller.dart';
import '../../../data/repositories/history_repository.dart';
import '../../../data/services/api_service.dart';

class HistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HistoryRepository>(
      () => HistoryRepository(Get.find<ApiService>()),
    );
    Get.lazyPut<HistoryController>(
      () => HistoryController(Get.find<HistoryRepository>()),
    );
  }
}

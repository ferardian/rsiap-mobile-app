import 'package:get/get.dart';
import '../controllers/poli_queue_controller.dart';
import '../../../data/repositories/poli_queue_repository.dart';
import '../../../data/services/api_service.dart';

class PoliQueueBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PoliQueueRepository>(
      () => PoliQueueRepository(Get.find<ApiService>()),
    );
    Get.lazyPut<PoliQueueController>(() => PoliQueueController());
  }
}

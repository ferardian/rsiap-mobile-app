import 'package:get/get.dart';
import '../controllers/schedule_controller.dart';
import '../../../data/repositories/schedule_repository.dart';
import '../../../data/services/api_service.dart';

class ScheduleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ScheduleRepository>(
      () => ScheduleRepository(Get.find<ApiService>()),
    );
    Get.lazyPut<ScheduleController>(
      () => ScheduleController(Get.find<ScheduleRepository>()),
    );
  }
}

import 'package:get/get.dart';
import '../../../data/services/api_service.dart';
import '../../../data/repositories/appointment_repository.dart';
import '../../../data/repositories/slider_repository.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AppointmentRepository>(
      () => AppointmentRepository(Get.find<ApiService>()),
    );
    Get.lazyPut<SliderRepository>(
      () => SliderRepository(Get.find<ApiService>()),
    );
    Get.lazyPut<HomeController>(() => HomeController());
  }
}

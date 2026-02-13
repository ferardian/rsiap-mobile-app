import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../../home/controllers/home_controller.dart';
import '../../../data/services/api_service.dart';
import '../../../data/repositories/appointment_repository.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../history/controllers/history_controller.dart';
import '../../../data/repositories/history_repository.dart';
import '../../schedule/controllers/schedule_controller.dart';
import '../../../data/repositories/schedule_repository.dart';
import '../../../data/repositories/slider_repository.dart';
import '../../../data/repositories/article_repository.dart';
import '../../../data/repositories/facility_repository.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<AppointmentRepository>(
      () => AppointmentRepository(Get.find<ApiService>()),
    );
    Get.lazyPut<SliderRepository>(
      () => SliderRepository(Get.find<ApiService>()),
    );
    Get.lazyPut<ArticleRepository>(
      () => ArticleRepository(Get.find<ApiService>()),
    );
    Get.lazyPut<FacilityRepository>(
      () => FacilityRepository(Get.find<ApiService>()),
    );
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<HistoryRepository>(
      () => HistoryRepository(Get.find<ApiService>()),
    );
    Get.lazyPut<HistoryController>(
      () => HistoryController(Get.find<HistoryRepository>()),
    );
    Get.lazyPut<ScheduleRepository>(
      () => ScheduleRepository(Get.find<ApiService>()),
    );
    Get.lazyPut<ScheduleController>(
      () => ScheduleController(Get.find<ScheduleRepository>()),
    );
  }
}

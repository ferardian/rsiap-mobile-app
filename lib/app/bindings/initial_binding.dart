import 'package:get/get.dart';
import '../data/services/api_service.dart';
import '../data/repositories/prescription_repository.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ApiService(), permanent: true);
    Get.lazyPut(
      () => PrescriptionRepository(Get.find<ApiService>()),
      fenix: true,
    );
  }
}

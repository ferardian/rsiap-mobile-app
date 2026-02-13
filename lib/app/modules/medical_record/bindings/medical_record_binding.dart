import 'package:get/get.dart';
import '../../../../app/data/repositories/medical_record_repository.dart';
import '../controllers/medical_record_controller.dart';
import '../../../../app/data/services/api_service.dart';

class MedicalRecordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MedicalRecordRepository>(
      () => MedicalRecordRepository(Get.find<ApiService>()),
    );
    Get.lazyPut<MedicalRecordController>(
      () => MedicalRecordController(Get.find<MedicalRecordRepository>()),
    );
  }
}

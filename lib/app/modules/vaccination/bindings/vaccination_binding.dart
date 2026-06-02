import 'package:get/get.dart';
import '../controllers/vaccination_controller.dart';

class VaccinationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VaccinationController>(() => VaccinationController());
  }
}

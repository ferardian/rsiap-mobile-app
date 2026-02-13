import 'package:get/get.dart';
import '../../../../app/data/repositories/booking_repository.dart';
import '../../../../app/data/services/api_service.dart';
import '../controllers/booking_controller.dart';

class BookingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BookingRepository>(
      () => BookingRepository(Get.find<ApiService>()),
    );
    Get.lazyPut<BookingController>(() => BookingController());
  }
}

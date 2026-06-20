import 'package:get/get.dart';
import '../controllers/forgot_account_controller.dart';

class ForgotAccountBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ForgotAccountController>(
      () => ForgotAccountController(),
    );
  }
}

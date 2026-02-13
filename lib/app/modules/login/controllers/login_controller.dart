import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:in_app_update/in_app_update.dart';
import 'package:flutter/foundation.dart'; // for kDebugMode

import 'package:rsiap_mobile_app/app/data/repositories/auth_repository.dart';
import 'package:rsiap_mobile_app/app/routes/app_pages.dart';

class LoginController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();
  final _box = GetStorage();

  final noRkmMedisController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final isObscure = true.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    _checkForUpdate();
    // Check if already logged in
    if (_box.hasData('token')) {
      Get.offAllNamed(Routes.HOME);
    }
  }

  Future<void> _checkForUpdate() async {
    if (kDebugMode) {
      return;
    }

    try {
      final updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (updateInfo.immediateUpdateAllowed) {
          await InAppUpdate.performImmediateUpdate();
        } else if (updateInfo.flexibleUpdateAllowed) {
          await InAppUpdate.startFlexibleUpdate().then((result) {
            if (result == AppUpdateResult.success) {
              InAppUpdate.completeFlexibleUpdate();
            }
          });
        }
      }
    } catch (e) {
      print('Error checking for update: $e');
    }
  }

  @override
  void onClose() {
    noRkmMedisController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void toggleObscure() => isObscure.toggle();

  Future<void> login() async {
    if (noRkmMedisController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Nomor Rekam Medis dan Password tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      final response = await _authRepository.login(
        noRkmMedisController.text,
        passwordController.text,
      );

      // Assuming response contains 'access_token'
      final String token = response['access_token'];

      // Save token for API Interceptor
      await _box.write('token', token);

      // Fetch user details
      final user = await _authRepository.getUserDetail(token);

      await _box.write('user', user.toJson());

      // Subscribe to FCM Topics
      FirebaseMessaging.instance.subscribeToTopic('pasien');
      final topicName = "pasien_${user.noRkmMedis.replaceAll('/', '')}";
      await FirebaseMessaging.instance.subscribeToTopic(topicName);
      print("[FCM] Subscribed to topic on login: $topicName");

      Get.offAllNamed(Routes.HOME);
    } catch (e) {
      Get.snackbar(
        'Login Gagal',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

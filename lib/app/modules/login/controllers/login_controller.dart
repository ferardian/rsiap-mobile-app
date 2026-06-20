import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart' as dio;
import 'package:firebase_core/firebase_core.dart';
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
    // Check if already logged in (ignore guest status to allow login screen on next launch)
    if (_box.hasData('token')) {
      Get.offAllNamed(Routes.HOME);
    }
  }

  void loginAsGuest() {
    _box.write('is_guest', true);
    Get.offAllNamed(Routes.HOME);
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
      await _box.remove('is_guest');

      // Fetch user details
      final user = await _authRepository.getUserDetail(token);

      await _box.write('user', user.toJson());

      // Subscribe to FCM Topics
      if (Firebase.apps.isNotEmpty) {
        try {
          await FirebaseMessaging.instance.subscribeToTopic('pasien');
          final topicName = "pasien_${user.noRkmMedis.replaceAll('/', '')}";
          await FirebaseMessaging.instance.subscribeToTopic(topicName);
          print("[FCM] Subscribed to topic on login: $topicName");
        } catch (e) {
          print("[FCM] Failed to subscribe to topic on login: $e");
        }
      } else {
        print("[FCM] Skip subscribe on login: Firebase is not initialized");
      }

      Get.offAllNamed(Routes.HOME);
    } catch (e) {
      String errorMessage = 'Terjadi kesalahan sistem';

      if (e is Map && e['message'] != null) {
        errorMessage = e['message'].toString();
      } else if (e is dio.DioException) {
        if (e.response != null && e.response!.data != null) {
          if (e.response!.data is Map && e.response!.data['message'] != null) {
            errorMessage = e.response!.data['message'].toString();
          } else {
            errorMessage = e.response!.data.toString();
          }
        } else {
          errorMessage = e.message ?? 'Kesalahan koneksi';
        }
      } else {
        errorMessage = e.toString();
      }

      Get.snackbar(
        'Login Gagal',
        errorMessage,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade900,
        icon: Icon(Icons.error_outline, color: Colors.red.shade700, size: 28),
        shouldIconPulse: true,
        margin: const EdgeInsets.all(20),
        borderRadius: 12,
        duration: const Duration(seconds: 4),
        isDismissible: true,
        boxShadows: [
          BoxShadow(
            color: Colors.red.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        titleText: Text(
          'Login Gagal',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.red.shade800,
            fontSize: 15,
          ),
        ),
        messageText: Text(
          errorMessage,
          style: GoogleFonts.poppins(
            color: Colors.red.shade700,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }
}

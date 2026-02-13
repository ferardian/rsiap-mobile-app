import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response; // Avoid conflict with Dio Response
import 'package:get_storage/get_storage.dart';
import '../../../core/constants/api_config.dart';

class ApiService {
  late dio.Dio _dio;

  ApiService() {
    final box = GetStorage();
    String activeDomain = box.read('active_domain') ?? ApiConfig.primaryDomain;

    _dio = dio.Dio(
      dio.BaseOptions(
        baseUrl: ApiConfig.getBaseUrl(activeDomain),
        connectTimeout: const Duration(seconds: 10), // Faster detection
        receiveTimeout: const Duration(seconds: 30), // Stay long for data
        responseType: dio.ResponseType.json,
      ),
    );

    _dio.interceptors.add(
      dio.InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = box.read('token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Accept'] = 'application/json';
          options.headers['X-App-Type'] = 'mobile';
          return handler.next(options);
        },
        onError: (dio.DioException e, handler) async {
          // Trigger failover on timeout or connection error
          if (e.type == dio.DioExceptionType.connectionTimeout ||
              e.type == dio.DioExceptionType.receiveTimeout ||
              e.type == dio.DioExceptionType.connectionError) {
            String currentUrl = _dio.options.baseUrl;
            String? newDomain;

            if (currentUrl.contains(ApiConfig.primaryDomain)) {
              newDomain = ApiConfig.backupDomain;
            } else if (currentUrl.contains(ApiConfig.backupDomain)) {
              newDomain = ApiConfig.primaryDomain; // Try switching back
            }

            if (newDomain != null) {
              // CAUTION: FormData (Multipart) cannot be easily retried because it's a stream
              // that gets exhausted after the first attempt.
              if (e.requestOptions.data is dio.FormData) {
                print(
                  "🌐 FAILOVER: Cannot auto-retry FormData. Showing manual switch snackbar.",
                );
                _showFailoverSnackbar(newDomain);
                return handler.next(e);
              }

              print("🌐 FAILOVER: Switching to $newDomain");

              // Update Active Domain
              box.write('active_domain', newDomain);
              _dio.options.baseUrl = ApiConfig.getBaseUrl(newDomain);

              // Retry Request with fresh options
              final options = e.requestOptions;
              options.baseUrl = _dio.options.baseUrl;

              // Temporary reduce timeout for the failover attempt
              final originalTimeout = _dio.options.connectTimeout;
              _dio.options.connectTimeout = const Duration(seconds: 10);

              try {
                final response = await _dio.fetch(options);
                return handler.resolve(response);
              } catch (retryError) {
                _showFailoverSnackbar(
                  newDomain == ApiConfig.primaryDomain
                      ? ApiConfig.backupDomain
                      : ApiConfig.primaryDomain,
                );
                return handler.next(e);
              } finally {
                _dio.options.connectTimeout = originalTimeout;
              }
            }
          }
          return handler.next(e);
        },
      ),
    );

    _dio.interceptors.add(
      dio.LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );
  }

  void _showFailoverSnackbar(String targetDomain) {
    if (Get.isSnackbarOpen) return;

    Get.snackbar(
      'Koneksi Bermasalah',
      'Gagal terhubung ke server. Ketuk untuk coba pindah server manual.',
      mainButton: TextButton(
        onPressed: () {
          final box = GetStorage();
          box.write('active_domain', targetDomain);
          client.options.baseUrl = ApiConfig.getBaseUrl(targetDomain);
          Get.back();
          Get.snackbar(
            'Server Dipindah',
            'Mencoba menggunakan server cadangan...',
          );
        },
        child: const Text(
          'PINDAH',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Colors.red[800],
      colorText: Colors.white,
      duration: const Duration(seconds: 8),
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  dio.Dio get client => _dio;
}

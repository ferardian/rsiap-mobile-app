import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../../core/constants/api_config.dart';

class ForgotAccountController extends GetxController {
  final AuthRepository _authRepository = Get.find<AuthRepository>();

  final nikController = TextEditingController();
  final dobController = TextEditingController();
  final selectedDate = Rxn<DateTime>();

  final isLoading = false.obs;

  String get formattedDate {
    if (selectedDate.value == null) return '';
    return DateFormat('yyyy-MM-dd').format(selectedDate.value!);
  }

  String get displayDate {
    if (selectedDate.value == null) return 'Pilih Tanggal Lahir';
    return DateFormat('dd MMMM yyyy', 'id_ID').format(selectedDate.value!);
  }

  @override
  void onClose() {
    nikController.dispose();
    dobController.dispose();
    super.onClose();
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? DateTime(1995, 1, 1),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      locale: const Locale('id', 'ID'),
    );
    if (picked != null) {
      selectedDate.value = picked;
      dobController.text = DateFormat('dd MMMM yyyy', 'id_ID').format(picked);
    }
  }

  Future<void> hubungiPendaftaranWA() async {
    final String message = "Halo Admin Pendaftaran, saya lupa Nomor Rekam Medis saya untuk masuk ke aplikasi RSIAP Mobile. Mohon bantuannya untuk verifikasi data saya.";
    final String encodedMessage = Uri.encodeComponent(message);
    final Uri waUri = Uri.parse("${ApiConfig.waUrl}?text=$encodedMessage");

    try {
      if (!await launchUrl(waUri, mode: LaunchMode.externalApplication)) {
        Get.snackbar(
          'Gagal',
          'Tidak dapat membuka aplikasi WhatsApp',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> checkAccount(BuildContext context) async {
    final nik = nikController.text.trim();
    if (nik.isEmpty) {
      Get.snackbar(
        'Peringatan',
        'NIK / Nomor KTP tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (selectedDate.value == null) {
      Get.snackbar(
        'Peringatan',
        'Silakan pilih tanggal lahir Anda',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      final response = await _authRepository.forgotAccount(nik, formattedDate);
      isLoading.value = false;

      final data = response['data'];
      final name = data['nm_pasien'] ?? '-';
      final maskedRM = data['no_rkm_medis'] ?? '-';
      final maskedPhone = data['no_tlp'] ?? '-';

      _showSuccessDialog(context, name, maskedRM, maskedPhone);
    } catch (e) {
      isLoading.value = false;
      String errorMessage = 'NIK atau Tanggal Lahir tidak cocok dengan data kami.';
      if (e is Map && e['message'] != null) {
        errorMessage = e['message'].toString();
      }
      _showErrorDialog(context, errorMessage);
    }
  }

  void _showSuccessDialog(BuildContext context, String name, String rm, String phone) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_outline_rounded,
                  color: Colors.green.shade600,
                  size: 44,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Akun Ditemukan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('Nama Pasien', name),
                    const Divider(height: 16),
                    _buildInfoRow('Nomor RM', rm, isBold: true),
                    if (phone != '-') ...[
                      const Divider(height: 16),
                      _buildInfoRow('Nomor Telepon', phone),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Gunakan Nomor RM di atas untuk masuk ke akun Anda. Password Anda adalah Tanggal Lahir Anda (format: DDMMYYYY).',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back(); // Close dialog
                        Get.back(); // Go back to login screen
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: const Text('Ke Halaman Login', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  color: Colors.red.shade600,
                  size: 44,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Data Tidak Cocok',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),
              const Text(
                'Jika Anda masih kesulitan atau lupa data Anda, silakan hubungi bagian pendaftaran melalui WhatsApp.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Get.back(); // Close dialog
                  hubungiPendaftaranWA();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  elevation: 1,
                ),
                icon: Image.asset(
                  'assets/icons/wa.png',
                  width: 22,
                  height: 22,
                  color: Colors.white,
                ),
                label: const Text(
                  'Hubungi Pendaftaran via WA',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Coba Lagi', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart' as dio;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/wilayah_service.dart'; // Added
import '../../../../core/values/colors.dart';

class RegisterController extends GetxController {
  final _apiService = Get.find<ApiService>();
  final _picker = ImagePicker();

  final _wilayahService = WilayahService(); // Import this

  // Stepper State
  final currentStep = 0.obs;
  final isLoading = false.obs;

  // Step 1: NIK
  final nikController = TextEditingController();

  // Step 2: OTP
  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  final receivedOtp = RxnString(); // Temporary for dev/testing
  final regToken = RxnString(); // Token from verified OTP
  final isOtpSent = false.obs;

  // Step 3: Biodata
  final nameController = TextEditingController();
  final dobController = TextEditingController();
  final motherNameController = TextEditingController();
  final addressController = TextEditingController();
  final emailController = TextEditingController();
  final gender = 'L'.obs;
  final pobController = TextEditingController(); // Place of Birth

  // Address Dropdowns
  final propinsiList = <dynamic>[].obs;
  final kabupatenList = <dynamic>[].obs;
  final kecamatanList = <dynamic>[].obs;
  final kelurahanList = <dynamic>[].obs;

  final selectedPropinsi = Rxn<String>();
  final selectedKabupaten = Rxn<String>();
  final selectedKecamatan = Rxn<String>();
  final selectedKelurahan = Rxn<String>();

  final selectedPropinsiName = Rxn<String>();
  final selectedKabupatenName = Rxn<String>();
  final selectedKecamatanName = Rxn<String>();
  final selectedKelurahanName = Rxn<String>();

  // PJ Data
  final pjNameController = TextEditingController();
  final pjRelation = 'AYAH'.obs; // AYAH, IBU, SUAMI, ISTRI, SAUDARA, ANAK
  final pjAddressController = TextEditingController();

  // Step 4: KTP
  final ktpFile = Rxn<XFile>();
  final isOcrBypassed = false.obs;


  // Result
  final regResult = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    fetchPropinsi();
    phoneController.addListener(() {
      isOtpSent.value = false;
      regToken.value = null;
      receivedOtp.value = null;
      otpController.clear();
    });
  }

  @override
  void onClose() {
    nikController.dispose();
    phoneController.dispose();
    otpController.dispose();
    nameController.dispose();
    dobController.dispose();
    motherNameController.dispose();
    addressController.dispose();
    emailController.dispose();
    pobController.dispose();
    pjNameController.dispose();
    pjAddressController.dispose();
    super.onClose();
  }

  // --- Wilayah Fetching ---
  void fetchPropinsi() async {
    try {
      final data = await _wilayahService.getPropinsi();
      propinsiList.assignAll(data);
    } catch (e) {
      print("Error fetching propinsi: $e");
    }
  }

  void fetchKabupaten(String kdProp) async {
    selectedKabupaten.value = null;
    selectedKecamatan.value = null;
    selectedKelurahan.value = null;
    selectedKabupatenName.value = null;
    selectedKecamatanName.value = null;
    selectedKelurahanName.value = null;
    kabupatenList.clear();
    kecamatanList.clear();
    kelurahanList.clear();

    try {
      isLoading.value = true;
      final data = await _wilayahService.getKabupaten(kdProp: kdProp);
      kabupatenList.assignAll(data);
    } catch (e) {
      print("Error fetching kabupaten: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void fetchKecamatan(String kdKab) async {
    selectedKecamatan.value = null;
    selectedKelurahan.value = null;
    selectedKecamatanName.value = null;
    selectedKelurahanName.value = null;
    kecamatanList.clear();
    kelurahanList.clear();

    try {
      isLoading.value = true;
      final data = await _wilayahService.getKecamatan(kdKab: kdKab);
      kecamatanList.assignAll(data);
    } catch (e) {
      print("Error fetching kecamatan: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void fetchKelurahan(String kdKec) async {
    selectedKelurahan.value = null;
    selectedKelurahanName.value = null;
    kelurahanList.clear();

    try {
      isLoading.value = true;
      final data = await _wilayahService.getKelurahan(kdKec: kdKec);
      kelurahanList.assignAll(data);
    } catch (e) {
      print("Error fetching kelurahan: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void nextStep() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (currentStep.value < 3) {
      currentStep.value++;
    }
  }

  void previousStep() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  // --- Step 1 Actions ---
  Future<void> checkNik() async {
    if (nikController.text.length != 16) {
      Get.snackbar(
        'Error',
        'NIK harus 16 digit',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      final response = await _apiService.client.post(
        'pasien/auth/register/cek-nik',
        data: {'nik': nikController.text},
      );

      if (response.data['success'] == true) {
        nextStep();
      } else {
        Get.defaultDialog(
          title: 'NIK Terdaftar',
          middleText: response.data['message'] ?? 'NIK sudah terdaftar.',
          textConfirm: 'Ke Halaman Login',
          onConfirm: () => Get.back(),
          confirmTextColor: Colors.white,
          buttonColor: AppColors.primary,
        );
      }
    } catch (e) {
      String errorMessage = "Terjadi kesalahan koneksi";
      bool isNikRegistered = false;

      if (e is dio.DioException && e.response != null) {
        final data = e.response?.data;
        if (data != null && data is Map) {
          errorMessage = data['message'] ?? e.message ?? "Terjadi kesalahan";
          if (data['error'] == 'nik_already_registered') {
            isNikRegistered = true;
          }
        } else {
          errorMessage = e.message ?? "Terjadi kesalahan";
        }
      } else {
        errorMessage = e.toString();
      }

      if (isNikRegistered) {
        Get.dialog(
          Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.assignment_ind_outlined,
                      size: 48,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'NIK Terdaftar',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    errorMessage,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(
                              color: AppColors.textSecondary.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            'Tutup',
                            style: GoogleFonts.poppins(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Get.back(); // Close Dialog
                            Get.back(); // Back to Login
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Login',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          barrierDismissible: false,
        );
      } else {
        _handleError(e, "Gagal mengecek NIK");
      }
    } finally {
      isLoading.value = false;
    }
  }

  // --- Step 2 Actions ---
  Future<void> sendOtp() async {
    if (phoneController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Nomor telepon harus diisi',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      final response = await _apiService.client.post(
        'pasien/auth/register/send-otp',
        data: {'no_telp': phoneController.text},
      );

      if (response.data['success'] == true) {
        receivedOtp.value = response.data['data']['otp']?.toString(); // Debug
        isOtpSent.value = true;
        Get.snackbar(
          'Sukses',
          'OTP berhasil dikirim via WhatsApp',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          response.data['message'] ?? 'Gagal mengirim OTP',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (e is dio.DioException && e.response?.statusCode == 429) {
        _handleError(e, 'Terlalu banyak permintaan OTP. Tunggu beberapa saat.');
      } else {
        _handleError(e, 'Gagal mengirim OTP.');
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyOtp() async {
    if (otpController.text.length != 6) {
      Get.snackbar(
        'Error',
        'OTP harus 6 digit',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      final response = await _apiService.client.post(
        'pasien/auth/register/verify-otp',
        data: {'no_telp': phoneController.text, 'otp': otpController.text},
      );

      if (response.data['success'] == true) {
        regToken.value = response.data['data']['token'];
        Get.snackbar(
          'Sukses',
          'Verifikasi Berhasil!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        nextStep();
      } else {
        Get.snackbar(
          'Error',
          'OTP Salah atau Kadaluarsa',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      _handleError(e, 'Gagal verifikasi OTP');
    } finally {
      isLoading.value = false;
    }
  }

  // --- Step 3 Actions ---
  void validateBiodata() {
    if (nameController.text.isEmpty ||
        dobController.text.isEmpty ||
        motherNameController.text.isEmpty ||
        addressController.text.isEmpty ||
        pobController.text.isEmpty ||
        pjNameController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Harap isi semua data wajib (*)',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    nextStep();
  }

  // --- Step 4 Actions ---
  Future<void> pickKtp() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50, // Reduced from 80 to ensure size < 2MB
    );
    if (image != null) {
      final isValid = await _verifyNikFromImage(image);
      if (isValid) {
        isOcrBypassed.value = false;
        ktpFile.value = image;
      } else {
        await _showBypassDialog(image);
      }
    }
  }

  Future<bool> _verifyNikFromImage(XFile image) async {
    try {
      isLoading.value = true;
      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer = TextRecognizer(
        script: TextRecognitionScript.latin,
      );
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );

      // Clean whitespaces and do character correction (e.g. O->0, I/l->1) to make it robust
      String fullText = recognizedText.text
          .replaceAll(RegExp(r'\s+'), '')
          .replaceAll(RegExp(r'[oO]'), '0')
          .replaceAll(RegExp(r'[iIlL]'), '1');
      await textRecognizer.close();

      String targetNik = nikController.text;

      // Look for 16-digit sequences in the text
      RegExp nikRegex = RegExp(r'\d{16}');
      Iterable<RegExpMatch> matches = nikRegex.allMatches(fullText);

      bool foundMatchingNik = false;
      for (var match in matches) {
        if (match.group(0) == targetNik) {
          foundMatchingNik = true;
          break;
        }
      }

      if (!foundMatchingNik) {
        return false;
      }

      Get.snackbar(
        'Verifikasi Berhasil',
        'NIK terdeteksi cocok dengan dokumen.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      print("OCR Error: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _showBypassDialog(XFile image) async {
    await Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  size: 48,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Verifikasi Tidak Berhasil',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'NIK (${nikController.text}) tidak terdeteksi pada foto. Anda dapat mengambil ulang foto dengan posisi lebih jelas, atau tetap menggunakan foto ini jika data sudah benar.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  color: AppColors.textSecondary,
                  height: 1.5,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back(); // Close Dialog
                        pickKtp(); // Trigger camera again
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Ambil Ulang Foto',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        isOcrBypassed.value = true;
                        ktpFile.value = image;
                        Get.back(); // Close Dialog
                        Get.snackbar(
                          'Foto Disimpan',
                          'Foto KTP disimpan tanpa verifikasi otomatis.',
                          backgroundColor: Colors.orange,
                          colorText: Colors.white,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: AppColors.textSecondary.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        'Tetap Gunakan Foto Ini',
                        style: GoogleFonts.poppins(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  Future<void> submitRegistration() async {
    if (ktpFile.value == null) {
      Get.snackbar(
        'Error',
        'Harap ambil foto KTP',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (regToken.value == null) {
      Get.snackbar(
        'Error',
        'Token pendaftaran hilang. Harap ulangi verifikasi OTP.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      // Prepare Data
      final dataMap = {
        'reg_token': regToken.value,
        'nik': nikController.text,
        'nm_pasien': nameController.text,
        'jk': gender.value,
        'tmp_lahir': pobController.text, // Added
        'tgl_lahir': dobController.text,
        'no_telp': phoneController.text,
        'alamat': addressController.text,
        'nm_ibu': motherNameController.text,
        'email': emailController.text.isEmpty
            ? 'pasien@rsia.com'
            : emailController.text,
        // PJ
        'namakeluarga': pjNameController.text,
        'keluarga': pjRelation.value,
        'alamatpj': pjAddressController.text.isEmpty
            ? addressController.text
            : pjAddressController.text,

        // Address IDs (Send only if selected)
        if (selectedKelurahan.value != null) 'kd_kel': selectedKelurahan.value,
        if (selectedKecamatan.value != null) 'kd_kec': selectedKecamatan.value,
        if (selectedKabupaten.value != null) 'kd_kab': selectedKabupaten.value,
        if (selectedPropinsi.value != null) 'kd_prop': selectedPropinsi.value,
      };

      // FormData for File Upload
      final formData = dio.FormData.fromMap(dataMap);

      // Attach KTP
      formData.files.add(
        MapEntry(
          'ktp_image',
          await dio.MultipartFile.fromFile(
            ktpFile.value!.path,
            filename: 'ktp_${nikController.text}.jpg',
          ),
        ),
      );

      print("🚀 SUBMIT: Starting registration submission...");
      final response = await _apiService.client.post(
        'pasien/auth/register',
        data: formData,
      );
      print("🚀 SUBMIT: Received response: ${response.statusCode}");

      if (response.data['success'] == true) {
        regResult.value = response.data['data'];
        Get.snackbar(
          'Sukses',
          'Pendaftaran berhasil!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        print("❌ SUBMIT: Registration failed: ${response.data['message']}");
        Get.snackbar(
          'Error',
          response.data['message'] ?? 'Pendaftaran gagal',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("❌ SUBMIT: Exception occurred: $e");
      _handleError(e, 'Terjadi kesalahan sistem saat mendaftar');
    } finally {
      isLoading.value = false;
    }
  }

  // --- Support Methods ---
  void _handleError(dynamic e, String defaultMessage) {
    String errorMessage = defaultMessage;

    if (e is dio.DioException) {
      print("📡 ERROR [${e.type}]: ${e.message}");
      print("📡 ERROR DATA: ${e.response?.data}");

      switch (e.type) {
        case dio.DioExceptionType.connectionTimeout:
        case dio.DioExceptionType.sendTimeout:
        case dio.DioExceptionType.receiveTimeout:
          errorMessage =
              "Koneksi lambat (Timeout). Silakan coba lagi atau pindah server.";
          break;
        case dio.DioExceptionType.connectionError:
          errorMessage =
              "Gagal terhubung ke server. Periksa koneksi internet Anda.";
          break;
        case dio.DioExceptionType.badResponse:
          final data = e.response?.data;
          if (data != null && data is Map) {
            errorMessage = data['message'] ?? defaultMessage;
          }
          break;
        default:
          errorMessage = "Terjadi kesalahan jaringan: ${e.message}";
      }
    } else {
      errorMessage = e.toString();
    }

    if (Get.isSnackbarOpen) {
      // Avoid overlapping but ensure this one is seen if it's the final error
      Get.closeCurrentSnackbar();
    }

    Get.snackbar(
      'Gagal',
      errorMessage,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 8),
      snackPosition: SnackPosition.TOP,
    );
  }
}

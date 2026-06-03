import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_pages.dart';
import '../../../../app/data/repositories/booking_repository.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:get_storage/get_storage.dart';

import '../../../../app/data/services/family_member_service.dart';

class BookingController extends GetxController {
  final BookingRepository _repository = Get.find<BookingRepository>();
  final FamilyMemberService _familyService = FamilyMemberService();
  final _box = GetStorage();

  get user => _box.read('user');

  // Selected Data
  var selectedPoli = {}.obs;
  var selectedPatient = {}.obs; // To store selected patient (self or family)

  // Family Members
  var familyMembers = <dynamic>[].obs;
  var selectedDate = DateTime.now().obs;
  var selectedDoctor = {}.obs;
  var selectedSchedule = {}.obs;

  // Schedules
  var schedules = <dynamic>[].obs;
  var isLoadingSchedules = false.obs;
  var isLoadingSubmit = false.obs;

  // Dynamic Poliklinik List
  var poliklinikList = <Map<String, dynamic>>[].obs;
  var isLoadingPoli = false.obs;
  var isErrorPoli = false.obs;

  Future<void> fetchPoliklinikList() async {
    isLoadingPoli.value = true;
    isErrorPoli.value = false;
    poliklinikList.clear();

    try {
      final rawPolikliniks = await _repository.fetchPolikliniks();
      
      final anakCodes = <String>[];
      final kandunganCodes = <String>[];

      for (var poli in rawPolikliniks) {
        final status = poli['status']?.toString() ?? '0';
        if (status != '1') continue;

        final nmPoli = (poli['nm_poli'] ?? '').toString().toLowerCase();
        final kdPoli = (poli['kd_poli'] ?? '').toString();

        if (nmPoli.contains('anak') || nmPoli.contains('bayi') || nmPoli.contains('bbl')) {
          anakCodes.add(kdPoli);
        } else if (nmPoli.contains('kandungan') || nmPoli.contains('kebidanan') || nmPoli.contains('obgyn')) {
          kandunganCodes.add(kdPoli);
        }
      }

      final List<Map<String, dynamic>> mappedList = [];

      if (anakCodes.isNotEmpty) {
        mappedList.add({
          'title': 'Poliklinik Anak',
          'icon': Icons.child_care,
          'color': Colors.blue,
          'description': 'Layanan kesehatan khusus anak.',
          'kode_poli': anakCodes,
        });
      }

      if (kandunganCodes.isNotEmpty) {
        mappedList.add({
          'title': 'Poliklinik Kandungan',
          'icon': Icons.pregnant_woman,
          'color': Colors.pink,
          'description': 'Layanan kesehatan ibu dan kandungan.',
          'kode_poli': kandunganCodes,
        });
      }

      poliklinikList.assignAll(mappedList);
    } catch (e) {
      print("Error fetching polikliniks: $e");
      isErrorPoli.value = true;
    } finally {
      isLoadingPoli.value = false;
    }
  }

  // Helper to format date
  String get formattedDate =>
      DateFormat('yyyy-MM-dd').format(selectedDate.value);

  // Helper to get Indonesian day name
  String get dayName {
    List<String> days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    return days[selectedDate.value.weekday - 1]; // weekday is 1-7
  }

  @override
  void onInit() {
    super.onInit();
    fetchFamilyMembers();
    fetchPoliklinikList();
    // Default to self
    final user = _box.read('user');
    if (user != null) {
      selectedPatient.assignAll({
        'nm_pasien': user['nama'],
        'no_rkm_medis': user['no_rkm_medis'],
        'hubungan': 'Diri Sendiri',
        'jk': user['jenis_kelamin'] ?? '-',
      });
    }
  }

  Future<void> fetchFamilyMembers() async {
    try {
      final data = await _familyService.fetchFamilyMembers();
      familyMembers.assignAll(data);
    } catch (e) {
      print("Error fetching family members: $e");
    }
  }

  void selectPoli(Map<String, dynamic> poli) {
    selectedPoli.value = poli;
    fetchSchedules();
  }

  void selectDate(DateTime date) {
    selectedDate.value = date;
    fetchSchedules();
  }

  void selectDoctor(
    Map<String, dynamic> doctor,
    Map<String, dynamic> schedule,
  ) {
    selectedDoctor.value = doctor;
    selectedSchedule.value = schedule;
  }

  Future<void> fetchSchedules() async {
    if (selectedPoli.isEmpty) return;

    isLoadingSchedules.value = true;
    schedules.clear();
    try {
      final kodePoli = List<String>.from(selectedPoli['kode_poli']);
      final result = await _repository.fetchSchedules(kodePoli, dayName);
      schedules.assignAll(result);
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat jadwal dokter: $e');
    } finally {
      isLoadingSchedules.value = false;
    }
  }

  Future<void> submitBooking() async {
    if (selectedPoli.isEmpty ||
        selectedDoctor.isEmpty ||
        selectedSchedule.isEmpty ||
        selectedPatient.isEmpty) {
      Get.snackbar('Error', 'Mohon lengkapi data booking');
      return;
    }

    // Gender Validation for Obgyn
    final poliName = (selectedPoli['nm_poli'] ?? selectedPoli['title'])
        .toString()
        .toLowerCase();
    var gender = selectedPatient['jk']?.toString().toUpperCase();

    // Fallback if gender is missing (e.g. state not updated after hot reload)
    if (gender == null || gender == 'NULL' || gender == '-') {
      if (selectedPatient['hubungan'] == 'Diri Sendiri') {
        final user = _box.read('user');
        gender = user['jenis_kelamin']?.toString().toUpperCase();
      }
    }

    print("DEBUG: Poli: $poliName, Gender: $gender");

    // Check if patient is Male
    final isMale = gender == 'L' || gender == 'LAKI-LAKI';

    if ((poliName.contains('kandungan') || poliName.contains('obgyn')) &&
        isMale) {
      _showErrorDialog(
        'Pasien Laki-laki tidak dapat mendaftar di Poli Kandungan.',
      );
      return;
    }

    isLoadingSubmit.value = true;
    try {
      // Use selected patient (self or family)
      final noRkmMedis = selectedPatient['no_rkm_medis'];

      final data = {
        "no_rkm_medis": noRkmMedis,
        "tanggal_periksa": formattedDate,
        "kd_dokter": selectedDoctor['kd_dokter'],
        "kd_poli": selectedSchedule['kd_poli'],
        "kd_pj":
            "A03", // Default Umum/Bayar Sendiri? Or need to select? existing app defaults to A03
        "limit_reg": "1",
      };

      await _repository.submitBooking(data);
      Get.offAllNamed(Routes.HOME); // Go back to home
      Get.snackbar(
        'Berhasil',
        'Booking berhasil dibuat!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print("DEBUG: Booking Error caught: $e");
      String errorMessage = 'Terjadi kesalahan tidak diketahui.';
      
      if (e is Map) {
        errorMessage = e['message']?.toString() ?? e['error']?.toString() ?? errorMessage;
      } else {
        errorMessage = e.toString();
      }

      _showErrorDialog(errorMessage);
    } finally {
      isLoadingSubmit.value = false;
    }
  }

  void _showErrorDialog(String message) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                  Icons.error_outline,
                  color: Colors.red.shade400,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Booking Gagal',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Tutup',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

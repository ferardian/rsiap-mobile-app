import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import '../../../../core/values/colors.dart';
import '../../../../app/data/repositories/medical_record_repository.dart';
import '../../home/controllers/home_controller.dart';

class MedicalRecordController extends GetxController {
  final MedicalRecordRepository _repository;
  final HomeController _homeController = Get.find<HomeController>();

  MedicalRecordController(this._repository);

  final labHistory = <Map<String, dynamic>>[].obs;
  final radiologyHistory = <Map<String, dynamic>>[].obs;

  final isLoadingLab = false.obs;
  final isLoadingRadiology = false.obs;

  // Filter Logic - Lab
  final searchQuery = ''.obs;
  final startDate = Rxn<DateTime>();
  final endDate = Rxn<DateTime>();

  String get currentLabPeriod {
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');
    final start = startDate.value ?? DateTime(DateTime.now().year, 1, 1);
    final end = endDate.value ?? DateTime.now();
    return '${dateFormat.format(start)} - ${dateFormat.format(end)}';
  }

  // Filter Logic - Radiology
  final radiologySearchQuery = ''.obs;
  final radiologyStartDate = Rxn<DateTime>();
  final radiologyEndDate = Rxn<DateTime>();

  String get currentRadiologyPeriod {
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');
    final start =
        radiologyStartDate.value ?? DateTime(DateTime.now().year, 1, 1);
    final end = radiologyEndDate.value ?? DateTime.now();
    return '${dateFormat.format(start)} - ${dateFormat.format(end)}';
  }

  List<Map<String, dynamic>> get filteredLabHistory {
    return labHistory.where((item) {
      // 1. Search Query Filter
      final query = searchQuery.value.toLowerCase();
      final doctor = (item['dokter']?['nm_dokter'] ?? '').toLowerCase();
      final status = (item['status'] ?? '').toLowerCase();

      bool matchesSearch = true;
      if (query.isNotEmpty) {
        bool matchDoctorOrStatus =
            doctor.contains(query) || status.contains(query);
        bool matchExam = false;
        final details = item['detail_periksa_lab'] as List?;
        if (details != null) {
          matchExam = details.any((detail) {
            final exam = (detail['template']?['Pemeriksaan'] ?? '')
                .toLowerCase();
            return exam.contains(query);
          });
        }
        matchesSearch = matchDoctorOrStatus || matchExam;
      }

      if (!matchesSearch) return false;

      // 2. Date Range Filter
      if (startDate.value != null && endDate.value != null) {
        final tglRaw = item['tgl_periksa'] ?? '';
        if (tglRaw.isEmpty) return false;
        try {
          final examDate = DateTime.parse(tglRaw);
          // Compare only dates (ignoring time)
          final dateOnly = DateTime(
            examDate.year,
            examDate.month,
            examDate.day,
          );
          final startOnly = DateTime(
            startDate.value!.year,
            startDate.value!.month,
            startDate.value!.day,
          );
          final endOnly = DateTime(
            endDate.value!.year,
            endDate.value!.month,
            endDate.value!.day,
          );

          if (dateOnly.isBefore(startOnly) || dateOnly.isAfter(endOnly)) {
            return false;
          }
        } catch (e) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  List<Map<String, dynamic>> get filteredRadiologyHistory {
    return radiologyHistory.where((item) {
      // 1. Search Query Filter
      final query = radiologySearchQuery.value.toLowerCase();
      final dokter = (item['dokter']?['nm_dokter'] ?? '').toLowerCase();
      final poli = (item['poliklinik']?['nm_poli'] ?? '').toLowerCase();

      bool matchesSearch = true;
      if (query.isNotEmpty) {
        bool matchDokterOrPoli = dokter.contains(query) || poli.contains(query);
        bool matchExam = false;
        final details = item['periksaRadiologi'] as List?;
        if (details != null) {
          matchExam = details.any((detail) {
            final exam = (detail['kd_jenis_prw'] ?? '').toLowerCase();
            return exam.contains(query);
          });
        }
        matchesSearch = matchDokterOrPoli || matchExam;
      }

      if (!matchesSearch) return false;

      // 2. Date Range Filter (Client-side sync fallback)
      if (radiologyStartDate.value != null && radiologyEndDate.value != null) {
        final tglRaw = item['tgl_registrasi'] ?? '';
        if (tglRaw.isEmpty) return false;
        try {
          final examDate = DateTime.parse(tglRaw);
          final dateOnly = DateTime(
            examDate.year,
            examDate.month,
            examDate.day,
          );
          final startOnly = DateTime(
            radiologyStartDate.value!.year,
            radiologyStartDate.value!.month,
            radiologyStartDate.value!.day,
          );
          final endOnly = DateTime(
            radiologyEndDate.value!.year,
            radiologyEndDate.value!.month,
            radiologyEndDate.value!.day,
          );

          if (dateOnly.isBefore(startOnly) || dateOnly.isAfter(endOnly)) {
            return false;
          }
        } catch (e) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void resetFilters() {
    searchQuery.value = '';
    startDate.value = null;
    endDate.value = null;
    fetchLabHistory(); // Re-fetch default range data
  }

  void resetRadiologyFilters() {
    radiologySearchQuery.value = '';
    radiologyStartDate.value = null;
    radiologyEndDate.value = null;
    fetchRadiologyHistory(); // Re-fetch default range data
  }

  Future<void> selectDateRange(BuildContext context) async {
    final config = CalendarDatePicker2WithActionButtonsConfig(
      calendarType: CalendarDatePicker2Type.range,
      selectedDayHighlightColor: AppColors.primary,
      weekdayLabelTextStyle: GoogleFonts.poppins(
        color: Colors.black87,
        fontWeight: FontWeight.bold,
      ),
      controlsTextStyle: GoogleFonts.poppins(
        color: Colors.black,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
      selectedDayTextStyle: GoogleFonts.poppins(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      dayTextStyle: GoogleFonts.poppins(color: Colors.black87),
      cancelButtonTextStyle: GoogleFonts.poppins(
        color: AppColors.error,
        fontWeight: FontWeight.bold,
      ),
      okButtonTextStyle: GoogleFonts.poppins(
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
      ),
      centerAlignModePicker: true,
      customModePickerIcon: const SizedBox(),
    );

    final values = await showCalendarDatePicker2Dialog(
      context: context,
      config: config,
      dialogSize: const Size(325, 400),
      borderRadius: BorderRadius.circular(20),
      value: [startDate.value, endDate.value],
    );

    if (values != null && values.isNotEmpty) {
      if (values.length == 1) {
        startDate.value = values[0];
        endDate.value = values[0];
      } else if (values.length == 2) {
        startDate.value = values[0];
        endDate.value = values[1];
      }
      fetchLabHistory(); // Re-fetch data for the selected range
    }
  }

  Future<void> selectRadiologyDateRange(BuildContext context) async {
    final config = CalendarDatePicker2WithActionButtonsConfig(
      calendarType: CalendarDatePicker2Type.range,
      selectedDayHighlightColor: AppColors.primary,
      weekdayLabelTextStyle: GoogleFonts.poppins(
        color: Colors.black87,
        fontWeight: FontWeight.bold,
      ),
      controlsTextStyle: GoogleFonts.poppins(
        color: Colors.black,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
      selectedDayTextStyle: GoogleFonts.poppins(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      dayTextStyle: GoogleFonts.poppins(color: Colors.black87),
      cancelButtonTextStyle: GoogleFonts.poppins(
        color: AppColors.error,
        fontWeight: FontWeight.bold,
      ),
      okButtonTextStyle: GoogleFonts.poppins(
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
      ),
      centerAlignModePicker: true,
      customModePickerIcon: const SizedBox(),
    );

    final values = await showCalendarDatePicker2Dialog(
      context: context,
      config: config,
      dialogSize: const Size(325, 400),
      borderRadius: BorderRadius.circular(20),
      value: [radiologyStartDate.value, radiologyEndDate.value],
    );

    if (values != null && values.isNotEmpty) {
      if (values.length == 1) {
        radiologyStartDate.value = values[0];
        radiologyEndDate.value = values[0];
      } else if (values.length == 2) {
        radiologyStartDate.value = values[0];
        radiologyEndDate.value = values[1];
      }
      fetchRadiologyHistory(); // Re-fetch data for the selected range
    }
  }

  void setQuickRange(String range) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (range) {
      case 'Hari Ini':
        startDate.value = today;
        endDate.value = today;
        break;
      case '7 Hari Terakhir':
        startDate.value = today.subtract(const Duration(days: 7));
        endDate.value = today;
        break;
      case '30 Hari Terakhir':
        startDate.value = today.subtract(const Duration(days: 30));
        endDate.value = today;
        break;
      case 'Bulan Ini':
        startDate.value = DateTime(now.year, now.month, 1);
        endDate.value = today;
        break;
      default:
        resetFilters();
    }
  }

  // Single Expand Logic
  final Map<int, ExpansionTileController> labTileControllers = {};
  final expandedLabIndex = Rxn<int>();

  @override
  void onInit() {
    super.onInit();
    // Don't auto-fetch, fetch when view opens
  }

  Future<void> fetchLabHistory() async {
    isLoadingLab.value = true;
    expandedLabIndex.value = null;
    labTileControllers.clear();
    try {
      final noRkmMedis = _homeController.user.value?.noRkmMedis;
      if (noRkmMedis == null) return;

      final dateFormat = DateFormat('yyyy-MM-dd');

      // Default to current year if no filter is active
      final start = startDate.value ?? DateTime(DateTime.now().year, 1, 1);
      final end = endDate.value ?? DateTime.now();

      final startStr = dateFormat.format(start);
      final endStr = dateFormat.format(end);

      final response = await _repository.getLabHistory(
        noRkmMedis,
        tanggalDari: startStr,
        tanggalSampai: endStr,
      );

      if (response['data'] != null) {
        labHistory.assignAll(List<Map<String, dynamic>>.from(response['data']));
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat riwayat laboratorium: $e');
    } finally {
      isLoadingLab.value = false;
    }
  }

  Future<void> fetchRadiologyHistory() async {
    isLoadingRadiology.value = true;
    try {
      final noRkmMedis = _homeController.user.value?.noRkmMedis;
      if (noRkmMedis == null) return;

      final dateFormat = DateFormat('yyyy-MM-dd');

      // Default to current year if no filter is active
      final start =
          radiologyStartDate.value ?? DateTime(DateTime.now().year, 1, 1);
      final end = radiologyEndDate.value ?? DateTime.now();

      final startStr = dateFormat.format(start);
      final endStr = dateFormat.format(end);

      final response = await _repository.getRadiologyHistory(
        noRkmMedis,
        tanggalDari: startStr,
        tanggalSampai: endStr,
      );

      if (response['data'] != null) {
        final allVisits = List<Map<String, dynamic>>.from(response['data']);

        // Filter only visits with radiology results
        final radVisits = allVisits.where((visit) {
          final rads = visit['periksaRadiologi'];
          return rads != null && (rads as List).isNotEmpty;
        }).toList();

        radiologyHistory.assignAll(radVisits);
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat riwayat radiologi: $e');
    } finally {
      isLoadingRadiology.value = false;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/family_member_service.dart';

class FamilyMemberController extends GetxController {
  final FamilyMemberService _service = FamilyMemberService();

  var familyMembers = <dynamic>[].obs;
  var isLoading = false.obs;
  var isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFamilyMembers();
  }

  Future<void> fetchFamilyMembers() async {
    isLoading.value = true;
    try {
      final data = await _service.fetchFamilyMembers();
      familyMembers.assignAll(data);
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data keluarga: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addFamilyMember({
    required String noRkmMedis,
    required String tglLahir,
    required String hubungan,
  }) async {
    if (noRkmMedis.isEmpty || tglLahir.isEmpty || hubungan.isEmpty) {
      Get.snackbar('Error', 'Mohon lengkapi semua data');
      return;
    }

    isSubmitting.value = true;
    try {
      await _service.addFamilyMember(
        noRkmMedis: noRkmMedis,
        tglLahir: tglLahir,
        hubungan: hubungan,
      );

      Get.back(); // Close dialog/bottom sheet
      Get.snackbar(
        'Berhasil',
        'Anggota keluarga berhasil ditambahkan',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      fetchFamilyMembers(); // Refresh list
    } catch (e) {
      Get.snackbar(
        'Gagal',
        e.toString().replaceAll('Exception:', '').trim(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> deleteFamilyMember(String noRkmMedis) async {
    try {
      await _service.deleteFamilyMember(noRkmMedis);
      Get.snackbar(
        'Berhasil',
        'Anggota keluarga berhasil dihapus',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      fetchFamilyMembers();
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus anggota keluarga: $e');
    }
  }
}

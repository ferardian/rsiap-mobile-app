import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'api_service.dart';

class FamilyMemberService {
  final ApiService _apiService = Get.put(ApiService());

  // Fetch Family Members
  Future<List<dynamic>> fetchFamilyMembers() async {
    try {
      final response = await _apiService.client.get('pasien/keluarga');

      if (response.statusCode == 200 && response.data['success']) {
        return response.data['data'];
      } else {
        throw response.data['message'] ?? 'Gagal memuat data keluarga';
      }
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Terjadi kesalahan koneksi';
    } catch (e) {
      throw e.toString();
    }
  }

  // Add Family Member
  Future<Map<String, dynamic>> addFamilyMember({
    required String noRkmMedis,
    required String tglLahir, // Format: YYYY-MM-DD
    required String hubungan,
  }) async {
    try {
      final response = await _apiService.client.post(
        'pasien/keluarga',
        data: {
          'no_rkm_medis_keluarga': noRkmMedis,
          'tgl_lahir_keluarga': tglLahir,
          'hubungan': hubungan,
        },
      );

      if (response.statusCode == 200 && response.data['success']) {
        return response.data['data'];
      } else {
        throw response.data['message'] ?? 'Gagal menambahkan anggota keluarga';
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 422 && e.response?.data['errors'] != null) {
        final errors = e.response!.data['errors'] as Map<String, dynamic>;
        if (errors.isNotEmpty) {
          final firstErrorList = errors.values.first as List;
          if (firstErrorList.isNotEmpty) {
            throw firstErrorList.first;
          }
        }
      }
      throw e.response?.data['message'] ?? 'Terjadi kesalahan koneksi';
    } catch (e) {
      throw e.toString();
    }
  }

  // Delete Family Member
  Future<bool> deleteFamilyMember(String noRkmMedis) async {
    try {
      final response = await _apiService.client.delete(
        'pasien/keluarga',
        data: {'no_rkm_medis_keluarga': noRkmMedis},
      );

      if (response.statusCode == 200 && response.data['success']) {
        return true;
      } else {
        throw response.data['message'] ?? 'Gagal menghapus anggota keluarga';
      }
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Terjadi kesalahan koneksi';
    } catch (e) {
      throw e.toString();
    }
  }
}

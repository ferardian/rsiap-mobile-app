import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/values/colors.dart';
import '../../../common/widgets/custom_text_field.dart';
import '../../../common/widgets/searchable_selection_field.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Daftar Pasien Baru',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white, // Prevents Material 3 color shift
        scrolledUnderElevation: 0, // Keeps it flat when scrolled under
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.regResult.value != null) {
          return _buildSuccessView();
        }
        return Column(
          children: [
            _buildProgressIndicator(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _buildCurrentStep(),
              ),
            ),
            _buildBottomButtons(),
          ],
        );
      }),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      child: Row(
        children: List.generate(4, (index) {
          final isActive = controller.currentStep.value >= index;
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? AppColors.primary
                        : Colors.grey.withOpacity(0.2),
                    border: isActive
                        ? Border.all(color: AppColors.primary, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: isActive && controller.currentStep.value > index
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : Text(
                            '${index + 1}',
                            style: GoogleFonts.poppins(
                              color: isActive
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),
                if (index < 3)
                  Expanded(
                    child: Container(
                      height: 3,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: controller.currentStep.value > index
                            ? AppColors.primary
                            : Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (controller.currentStep.value) {
      case 0:
        return _buildNikStep();
      case 1:
        return _buildOtpStep();
      case 2:
        return _buildBiodataStep();
      case 3:
        return _buildKtpStep();
      default:
        return _buildNikStep();
    }
  }

  Widget _buildNikStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          'Validasi NIK',
          'Harap masukkan NIK sesuai KTP Anda. Kami akan memeriksa apakah Anda sudah pernah berobat sebelumnya.',
        ),
        const SizedBox(height: 32),
        CustomTextField(
          controller: controller.nikController,
          label: 'Nomor Induk Kependudukan (NIK)',
          hint: '16 digit angka',
          keyboardType: TextInputType.number,
          prefixIcon: const Icon(
            Icons.badge_outlined,
            color: AppColors.primary,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(16),
          ],
        ),
        const SizedBox(height: 20),
        _buildInfoCard(
          'Kenapa NIK diperlukan?',
          'NIK digunakan sebagai kunci unik pasien di seluruh sistem kesehatan Indonesia untuk menghindari data ganda.',
        ),
      ],
    );
  }

  Widget _buildOtpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          'Verifikasi Nomor HP',
          'Kami akan mengirimkan kode verifikasi (OTP) melalui WhatsApp ke nomor HP Anda.',
        ),
        const SizedBox(height: 32),
        CustomTextField(
          controller: controller.phoneController,
          label: 'Nomor WhatsApp',
          hint: 'Contoh: 08123456789',
          keyboardType: TextInputType.phone,
          prefixIcon: const Icon(Icons.phone_android, color: AppColors.primary),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: controller.isLoading.value ? null : controller.sendOtp,
              child: Text(
                'Kirim Kode OTP',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: controller.otpController,
          label: 'Kode Verifikasi (6 Digit)',
          hint: '******',
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 8,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
        ),
      ],
    );
  }

  Widget _buildBiodataStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          'Biodata Pasien',
          'Harap isi biodata dengan lengkap dan benar sesuai dengan data di KTP atau Kartu Keluarga.',
        ),
        const SizedBox(height: 32),
        CustomTextField(
          controller: controller.nameController,
          label: 'Nama Lengkap',
          hint: 'Contoh: BUDI SANTOSO',
          prefixIcon: const Icon(
            Icons.person_outline,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 20),
        const SizedBox(height: 20),
        CustomTextField(
          controller: controller.pobController,
          label: 'Tempat Lahir',
          hint: 'Kota kelahiran sesuai KTP',
          prefixIcon: const Icon(Icons.location_city, color: AppColors.primary),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: Get.context!,
              initialDate: DateTime.now().subtract(
                const Duration(days: 365 * 20),
              ),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              controller.dobController.text = date.toString().substring(0, 10);
            }
          },
          child: AbsorbPointer(
            child: CustomTextField(
              controller: controller.dobController,
              label: 'Tanggal Lahir',
              hint: 'YYYY-MM-DD',
              prefixIcon: const Icon(
                Icons.calendar_today_outlined,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Jenis Kelamin',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Row(
          children: [
            Expanded(
              child: Obx(
                () => RadioListTile<String>(
                  title: const Text('Laki-laki'),
                  value: 'L',
                  groupValue: controller.gender.value,
                  onChanged: (val) => controller.gender.value = val!,
                ),
              ),
            ),
            Expanded(
              child: Obx(
                () => RadioListTile<String>(
                  title: const Text('Perempuan'),
                  value: 'P',
                  groupValue: controller.gender.value,
                  onChanged: (val) => controller.gender.value = val!,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: controller.motherNameController,
          label: 'Nama Ibu Kandung',
          hint: 'Diperlukan untuk verifikasi rekam medis',
          prefixIcon: const Icon(
            Icons.favorite_border,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: controller.emailController,
          label: 'Email (Opsional)',
          hint: 'Contoh: pasien@email.com',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(
            Icons.email_outlined,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 32),
        _buildStepHeader('Alamat Lengkap', 'Harap isi alamat sesuai KTP Anda.'),
        const SizedBox(height: 20),
        CustomTextField(
          controller: controller.addressController,
          label: 'Alamat Jalan',
          hint: 'Nama jalan, No rumah, RT/RW',
          maxLines: 2,
          prefixIcon: const Icon(Icons.home, color: AppColors.primary),
        ),
        const SizedBox(height: 20),
        // GEOGRAPHIC SELECTION (Searchable)
        // REPLACE WITH SEARCHABLE
        Obx(
          () => SearchableSelectionField(
            label: 'Propinsi',
            hint: 'Pilih Propinsi',
            prefixIcon: Icons.map,
            selectedValue: controller.selectedPropinsi.value,
            selectedLabel: controller.selectedPropinsiName.value,
            items: controller.propinsiList,
            itemValueKey: 'kd_prop',
            itemLabelKey: 'nm_prop',
            isLoading: controller.isLoading.value,
            onSelected: (val) {
              controller.selectedPropinsi.value = val;
              final item = controller.propinsiList.firstWhere(
                (e) => e['kd_prop'].toString() == val,
              );
              controller.selectedPropinsiName.value = item['nm_prop'];
              controller.fetchKabupaten(val);
            },
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => SearchableSelectionField(
            label: 'Kabupaten/Kota',
            hint: 'Pilih Kabupaten',
            prefixIcon: Icons.location_city,
            selectedValue: controller.selectedKabupaten.value,
            selectedLabel: controller.selectedKabupatenName.value,
            items: controller.kabupatenList,
            itemValueKey: 'kd_kab',
            itemLabelKey: 'nm_kab',
            isLoading: controller.isLoading.value,
            onSelected: (val) {
              controller.selectedKabupaten.value = val;
              final item = controller.kabupatenList.firstWhere(
                (e) => e['kd_kab'].toString() == val,
              );
              controller.selectedKabupatenName.value = item['nm_kab'];
              controller.fetchKecamatan(val);
            },
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => SearchableSelectionField(
            label: 'Kecamatan',
            hint: 'Pilih Kecamatan',
            prefixIcon: Icons.holiday_village,
            selectedValue: controller.selectedKecamatan.value,
            selectedLabel: controller.selectedKecamatanName.value,
            items: controller.kecamatanList,
            itemValueKey: 'kd_kec',
            itemLabelKey: 'nm_kec',
            isLoading: controller.isLoading.value,
            onSelected: (val) {
              controller.selectedKecamatan.value = val;
              final item = controller.kecamatanList.firstWhere(
                (e) => e['kd_kec'].toString() == val,
              );
              controller.selectedKecamatanName.value = item['nm_kec'];
              controller.fetchKelurahan(val);
            },
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => SearchableSelectionField(
            label: 'Kelurahan',
            hint: 'Pilih Kelurahan',
            prefixIcon: Icons.home_work,
            selectedValue: controller.selectedKelurahan.value,
            selectedLabel: controller.selectedKelurahanName.value,
            items: controller.kelurahanList,
            itemValueKey: 'kd_kel',
            itemLabelKey: 'nm_kel',
            isLoading: controller.isLoading.value,
            onSelected: (val) {
              controller.selectedKelurahan.value = val;
              final item = controller.kelurahanList.firstWhere(
                (e) => e['kd_kel'].toString() == val,
              );
              controller.selectedKelurahanName.value = item['nm_kel'];
            },
          ),
        ),

        const SizedBox(height: 32),
        _buildStepHeader(
          'Penanggung Jawab',
          'Keluarga atau kerabat yang bisa dihubungi dalam keadaan darurat.',
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: controller.pjNameController,
          label: 'Nama Penanggung Jawab',
          hint: 'Nama Ayah/Ibu/Suami/Istri',
          prefixIcon: const Icon(Icons.person, color: AppColors.primary),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Hubungan',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            prefixIcon: const Icon(Icons.people, color: AppColors.primary),
          ),
          value: controller.pjRelation.value,
          items: ['AYAH', 'IBU', 'SUAMI', 'ISTRI', 'SAUDARA', 'ANAK'].map((
            String val,
          ) {
            return DropdownMenuItem(value: val, child: Text(val));
          }).toList(),
          onChanged: (val) => controller.pjRelation.value = val!,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: controller.pjAddressController,
          label: 'Alamat Penanggung Jawab',
          hint: 'Kosongkan jika sama dengan alamat pasien',
          maxLines: 2,
          prefixIcon: const Icon(Icons.home, color: AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildKtpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader(
          'Unggah Foto Identitas',
          'Harap ambil foto KTP asli Anda dengan jelas. Khusus untuk pasien anak/bayi, silakan ambil foto Kartu Keluarga (KK) pada bagian nama pasien.',
        ),
        const SizedBox(height: 32),
        GestureDetector(
          onTap: controller.pickKtp,
          child: Obx(() {
            if (controller.ktpFile.value == null) {
              return Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.camera_alt_outlined,
                      size: 64,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Ambil Foto Identitas',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      File(controller.ktpFile.value!.path),
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: const Icon(
                          Icons.refresh,
                          color: AppColors.primary,
                        ),
                        onPressed: controller.pickKtp,
                      ),
                    ),
                  ),
                ],
              );
            }
          }),
        ),
        const SizedBox(height: 24),
        _buildInfoCard(
          'Keamanan Data',
          'Foto KTP Anda dienkripsi dan hanya digunakan untuk kepentingan administrasi medis di Rumah Sakit.',
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (controller.currentStep.value > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Kembali'),
              ),
            ),
          if (controller.currentStep.value > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: AppColors.primaryGradient,
              ),
              child: ElevatedButton(
                onPressed: controller.isLoading.value ? null : _handleNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        controller.currentStep.value == 3
                            ? 'Kirim Pendaftaran'
                            : 'Lanjutkan',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNext() {
    switch (controller.currentStep.value) {
      case 0:
        controller.checkNik();
        break;
      case 1:
        controller.verifyOtp();
        break;
      case 2:
        controller.validateBiodata();
        break;
      case 3:
        controller.submitRegistration();
        break;
    }
  }

  Widget _buildStepHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  content,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    final data = controller.regResult.value!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.green,
              child: Icon(Icons.check, color: Colors.white, size: 64),
            ),
            const SizedBox(height: 24),
            Text(
              'Pendaftaran Berhasil!',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Data Anda telah tersimpan di sistem kami. Harap simpan Nomor Rekam Medis (RM) di bawah ini:',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
              ),
              child: Column(
                children: [
                  Text(
                    'NOMOR REKAM MEDIS (RM)',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    data['no_rkm_medis'] ?? '---',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Kembali ke Login',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

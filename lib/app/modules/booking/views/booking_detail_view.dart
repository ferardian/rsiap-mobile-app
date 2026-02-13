import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/values/colors.dart';
import '../controllers/booking_controller.dart';
import 'package:rsiap_mobile_app/app/common/widgets/horizontal_calendar.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../profile/views/family_member_view.dart';

class BookingDetailView extends GetView<BookingController> {
  const BookingDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.selectedPoli['title'] ?? 'Pilih Jadwal',
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Selection
            Text(
              'Untuk Siapa?',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Obx(() {
              final patient = controller.selectedPatient;
              final name = patient['nm_pasien'] ?? 'Pilih Pasien';
              final rm = patient['no_rkm_medis'] ?? '-';
              final connection = patient['hubungan'] ?? 'Diri Sendiri';

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_outline,
                      color: AppColors.primary,
                    ),
                  ),
                  title: Text(
                    name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    '$connection ($rm)',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_drop_down),
                  onTap: () => _showPatientSelectionBottomSheet(context),
                ),
              );
            }),
            const SizedBox(height: 24),

            // Calendar
            Text(
              'Pilih Tanggal',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // Modern Horizontal Calendar
            Obx(
              () => HorizontalCalendar(
                selectedDate: controller.selectedDate.value,
                daysAhead: 14, // Show next 2 weeks
                onDateSelected: (date) {
                  controller.selectDate(date);
                },
              ),
            ),

            const SizedBox(height: 24),

            // Doctor List
            Obx(
              () => Text(
                'Jadwal Dokter ${controller.dayName}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 12),

            Obx(() {
              if (controller.isLoadingSchedules.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.schedules.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.event_busy,
                          size: 60,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Tidak ada jadwal dokter pada hari ${controller.dayName}.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: controller.schedules.map((schedule) {
                  final doctor = schedule['dokter'];
                  // ignore: unused_local_variable
                  final pegawai = doctor['pegawai'];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: AppColors.primary,
                        ),
                      ),
                      title: Text(
                        doctor['nm_dokter'],
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor['spesialis']['nm_sps'],
                            style: GoogleFonts.poppins(fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time_filled,
                                size: 14,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${schedule['jam_mulai']} - ${schedule['jam_selesai']}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          controller.selectDoctor(doctor, schedule);
                          _showPaymentSelectionDialog(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Pilih',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showPaymentSelectionDialog(BuildContext context) {
    final selectedType = 'Umum'.obs;

    Get.dialog(
      Obx(
        () => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pilih Jenis Pembayaran',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      RadioListTile<String>(
                        title: Text(
                          'Pasien Umum',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Bayar sendiri / Mandiri',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                        value: 'Umum',
                        groupValue: selectedType.value,
                        activeColor: AppColors.primary,
                        onChanged: (val) => selectedType.value = val!,
                      ),
                      Divider(height: 1, color: Colors.grey.shade200),
                      RadioListTile<String>(
                        title: Text(
                          'Pasien BPJS',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          'Menggunakan JKN-KIS',
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                        value: 'BPJS',
                        groupValue: selectedType.value,
                        activeColor: AppColors.primary,
                        onChanged: (val) => selectedType.value = val!,
                      ),
                    ],
                  ),
                ),
                if (selectedType.value == 'BPJS')
                  Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Informasi BPJS',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Peserta BPJS dapat melakukan pendaftaran online melalui aplikasi Mobile JKN.',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.blue.shade900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () async {
                            final Uri url = Uri.parse(
                              'https://play.google.com/store/apps/details?id=app.bpjs.mobile&hl=id',
                            );
                            if (await canLaunchUrl(url)) {
                              await launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          },
                          child: Text(
                            'Buka Mobile JKN',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          'Batal',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: selectedType.value == 'Umum'
                            ? () {
                                Get.back();
                                _showConfirmationDialog(context);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Lanjut',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
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
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    Get.defaultDialog(
      title: 'Konfirmasi Booking',
      titleStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
      content: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Apakah Anda yakin ingin mendaftar ke:',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    controller.selectedDoctor['nm_dokter'],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.formattedDate,
                    style: GoogleFonts.poppins(color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      textConfirm: 'Ya, Daftar',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.primary,
      onConfirm: () {
        Get.back(); // Close dialog
        controller.submitBooking();
      },
    );
  }

  void _showPatientSelectionBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pilih Pasien',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Diri Sendiri
                    _buildPatientOption(
                      name: controller.user?['nama'] ?? 'Pasien',
                      rm: controller.user?['no_rkm_medis'] ?? '-',
                      relation: 'Diri Sendiri',
                      onTap: () {
                        controller.selectedPatient.assignAll({
                          'nm_pasien': controller.user?['nama'] ?? 'Pasien',
                          'no_rkm_medis':
                              controller.user?['no_rkm_medis'] ?? '-',
                          'hubungan': 'Diri Sendiri',
                          'jk': controller.user?['jenis_kelamin'] ?? '-',
                        });
                        Get.back();
                      },
                    ),
                    const Divider(),
                    // Family Members
                    Obx(() {
                      if (controller.familyMembers.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            "Belum ada anggota keluarga",
                            style: GoogleFonts.poppins(color: Colors.grey),
                          ),
                        );
                      }
                      return Column(
                        children: controller.familyMembers.map((member) {
                          final pasien = member['keluarga'];
                          if (pasien == null) return const SizedBox.shrink();

                          return _buildPatientOption(
                            name: pasien['nm_pasien'] ?? 'Anggota Keluarga',
                            rm: pasien['no_rkm_medis'] ?? '-',
                            relation: member['hubungan'] ?? 'Keluarga',
                            onTap: () {
                              controller.selectedPatient.assignAll({
                                'nm_pasien':
                                    pasien['nm_pasien'] ?? 'Anggota Keluarga',
                                'no_rkm_medis': pasien['no_rkm_medis'] ?? '-',
                                'hubungan': member['hubungan'] ?? 'Keluarga',
                                'jk': pasien['jk'] ?? '-',
                              });
                              Get.back();
                            },
                          );
                        }).toList(),
                      );
                    }),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Get.back(); // Close bottom sheet
                          Get.to(() => const FamilyMemberView());
                        },
                        icon: const Icon(Icons.person_add_outlined, size: 20),
                        label: Text(
                          'Tambah Keluarga Baru',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildPatientOption({
    required String name,
    required String rm,
    required String relation,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.person, color: Colors.grey),
      ),
      title: Text(
        name,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '$relation ($rm)',
        style: GoogleFonts.poppins(fontSize: 12),
      ),
      onTap: onTap,
    );
  }
}

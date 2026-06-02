import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:rsiap_mobile_app/core/values/colors.dart';
import '../../controllers/home_controller.dart';

class QueueDetailSheet extends StatelessWidget {
  final Map<String, dynamic> appointment;

  const QueueDetailSheet({Key? key, required this.appointment})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. Get Queue Info
    final int myQueue = int.tryParse(appointment['no_reg'] ?? '0') ?? 0;
    final int currentQueue = appointment['current_queue'] != null
        ? int.tryParse(appointment['current_queue'].toString()) ?? 0
        : 0;

    // Use server-side calculation for remaining queue if available
    final int remainingQueue = appointment['sisa_antrian'] != null
        ? int.tryParse(appointment['sisa_antrian'].toString()) ?? 0
        : (myQueue - currentQueue).clamp(0, 999);

    // 2. Parse Schedule Data for Estimation
    DateTime? estTime;

    if (appointment['jadwal_enrich'] != null) {
      try {
        final jadwal = appointment['jadwal_enrich'];
        final dateStr = appointment['tgl_registrasi'].toString().substring(
          0,
          10,
        );

        // Parse Start & End Time
        final startStr = '$dateStr ${jadwal['jam_mulai']}';
        final startTime = DateTime.parse(startStr);
        final int kuota = int.tryParse(jadwal['kuota'].toString()) ?? 50;

        // Calculate Duration & Avg Time
        final endStr = '$dateStr ${jadwal['jam_selesai']}';
        final endTime = DateTime.parse(endStr);
        final totalDuration = endTime.difference(startTime).inMinutes;
        final avgTimePerPatient =
            totalDuration / kuota; // e.g. 120 mins / 20 px = 6 mins/px

        // Estimate User Time
        // StartTime + (AvgTime * (MyQueue - 1))
        // Subtract 1 because Queue 1 starts AT StartTime (theoretically)
        final minutesToAdd =
            (avgTimePerPatient * (myQueue > 0 ? myQueue - 1 : 0)).round();
        estTime = startTime.add(Duration(minutes: minutesToAdd));
      } catch (e) {
        print("Error calculating estimation: $e");
      }
    }

    // Fallback if calculation failed
    estTime ??= DateTime.now().add(Duration(minutes: remainingQueue * 15));

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Stack(
        children: [
          // Handle bar
          Positioned(
            top: 12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Detail Antrian',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green.shade100),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Aktif',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Hero Section: My Queue Number
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 24,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'NOMOR ANTRIAN ANDA',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.9),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$myQueue',
                        style: GoogleFonts.poppins(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              height: 38,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.blue.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'Sisa $remainingQueue Antrian',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              height: 38,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.green.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.group_outlined,
                                    color: Colors.green.shade700,
                                    size: 13,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Sekarang: $currentQueue',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              color: Colors.orange.shade700,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Estimasi Dipanggil: Pk ${DateFormat('HH:mm').format(estTime)}',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                const SizedBox(height: 24),
                Text(
                  'Status Antrian',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                // Timeline Section
                Builder(
                  builder: (context) {
                    final String status = appointment['stts'] ?? 'Belum';
                    // Status Mapping
                    // 0: Ruang Tunggu (Belum, Tunggu)
                    // 1: Poli (Berkas Diterima, Periksa)
                    // 2: Selesai (Sudah, Dirawat, Pulang)
                    int currentStep = 0;
                    if (['Berkas Diterima', 'Periksa'].contains(status)) {
                      currentStep = 1;
                    } else if ([
                      'Sudah',
                      'Dirawat',
                      'Pulang',
                      'Rujuk',
                    ].contains(status)) {
                      currentStep = 2;
                    }

                    return Column(
                      children: [
                        _buildTimelineStep(
                          isFirst: true,
                          isLast: false,
                          isActive: currentStep >= 0,
                          isFinished: currentStep > 0,
                          title: 'Ruang Tunggu',
                          subtitle: 'Menunggu giliran dipanggil',
                          date: DateFormat('dd MMM yyyy').format(
                            DateTime.parse(appointment['tgl_registrasi']),
                          ),
                        ),
                        _buildTimelineStep(
                          isFirst: false,
                          isLast: false,
                          isActive: currentStep >= 1,
                          isFinished: currentStep > 1,
                          title: appointment['poliklinik']['nm_poli'] ?? 'Poli',
                          subtitle: currentStep == 1
                              ? 'Pemeriksaan sedang berlangsung'
                              : 'Dokter: ${appointment['dokter']['nm_dokter'] ?? '-'}',
                        ),
                        _buildTimelineStep(
                          isFirst: false,
                          isLast: true,
                          isActive: currentStep >= 2,
                          isFinished: currentStep >= 2,
                          title: 'Selesai',
                          subtitle: 'Pelayanan kesehatan Anda telah selesai',
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Action Buttons
                if (appointment['stts'] == 'Belum') ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        _showCancelConfirmation(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red.shade100),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: Colors.red.shade50,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.delete_outline_rounded, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Batalkan Registrasi',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Tutup',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required bool isFirst,
    required bool isLast,
    required bool isActive,
    required bool isFinished,
    required String title,
    required String subtitle,
    String? date,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Line & Indicator
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isFinished
                      ? AppColors.primary
                      : (isActive ? Colors.white : Colors.grey[200]),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isFinished
                        ? AppColors.primary
                        : (isActive ? AppColors.primary : Colors.grey[300]!),
                    width: 2,
                  ),
                ),
                child: isFinished
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : (isActive
                          ? Center(
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            )
                          : null),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isFinished
                        ? AppColors.primary.withOpacity(0.5)
                        : Colors.grey[300],
                    margin: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: isActive || isFinished
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isActive || isFinished
                          ? AppColors.textPrimary
                          : Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (date != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelConfirmation(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Konfirmasi Pembatalan',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah Anda yakin ingin membatalkan registrasi pemeriksaan ini? Tindakan ini tidak dapat dibatalkan.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Kembali',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              final controller = Get.find<HomeController>();
              controller.cancelAppointment(appointment['no_rawat']);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Ya, Batalkan',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

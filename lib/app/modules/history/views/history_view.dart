import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/values/colors.dart';
import '../controllers/history_controller.dart';

class HistoryView extends GetView<HistoryController> {
  const HistoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Riwayat Periksa',
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading:
            false, // Since it's a tab, no back button usually
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.historyList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.historyList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history_toggle_off_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Belum ada riwayat pemeriksaan',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => controller.refreshData(),
                  child: Text(
                    'Refresh',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              100,
            ), // Add padding bottom for floating nav
            itemCount:
                controller.historyList.length +
                (controller.hasMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.historyList.length) {
                // Infinite scroll loader
                controller.fetchHistory();
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final history = controller.historyList[index];
              return _buildHistoryCard(history);
            },
          ),
        );
      }),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> history) {
    final tglRegistrasi = history['tgl_registrasi'] ?? '';
    final jamReg = history['jam_reg'] ?? '';
    final poli = history['poliklinik']?['nm_poli'] ?? 'Poliklinik';
    final dokter = history['dokter']?['nm_dokter'] ?? 'Dokter';
    final status = history['stts'] ?? '-';
    final diagnosa = _extractDiagnosis(history);

    DateTime? date;
    try {
      if (tglRegistrasi.isNotEmpty) {
        date = DateTime.parse(tglRegistrasi);
      }
    } catch (_) {}

    final formattedDate = date != null
        ? DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date)
        : tglRegistrasi;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    formattedDate,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Text(
                  jamReg,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.medical_services_outlined,
                    color: Colors.blue[700],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        poli,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        dokter,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (diagnosa.isNotEmpty) ...[
              const Divider(height: 24),
              Text(
                'Diagnosa/Keluhan:',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                diagnosa,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getStatusColor(status).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(status),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _extractDiagnosis(Map<String, dynamic> history) {
    final pemeriksaan = history['pemeriksaanRalan'];
    if (pemeriksaan != null) {
      // Prioritize diagnosis, then complaints
      // This structure depends on what `pemeriksaanRalan` actually returns.
      // Often it's an object with `keluhan`, `pemeriksaan`, `penilaian_awal` etc.
      // Or sometimes `diagnosa_pasien` is a separate relation.
      // Based on typical schema:
      if (pemeriksaan is Map) {
        return pemeriksaan['keluhan'] ?? pemeriksaan['diagnosa'] ?? '';
      }
    }
    return '';
  }

  Color _getStatusColor(String status) {
    if (status == 'Sudah' || status == 'Selesai') return Colors.green;
    if (status == 'Dirawat') return Colors.orange;
    if (status == 'Rujuk') return Colors.blue;
    if (status == 'Meninggal') return Colors.black;
    return Colors.grey;
  }
}

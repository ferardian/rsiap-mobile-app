import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/values/colors.dart';
import '../controllers/medical_record_controller.dart';

class LabResultView extends GetView<MedicalRecordController> {
  const LabResultView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Trigger fetch on build
    controller.fetchLabHistory();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Hasil Laboratorium',
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Column(
        children: [
          // Search & Filter Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) => controller.searchQuery.value = value,
                    decoration: InputDecoration(
                      hintText: 'Cari Dokter atau Pemeriksaan...',
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                    ),
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () => controller.selectDateRange(context),
                    icon: Obx(
                      () => Icon(
                        Icons.calendar_month_rounded,
                        color: controller.startDate.value != null
                            ? AppColors.primary
                            : Colors.grey[400],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Period Information - Only show when no active filter
          Obx(() {
            if (controller.startDate.value != null) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Periode: ${controller.currentLabPeriod}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }),

          // Active Date Filter Chip
          Obx(() {
            if (controller.startDate.value == null ||
                controller.endDate.value == null) {
              return const SizedBox.shrink();
            }

            final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');
            final rangeText =
                '${dateFormat.format(controller.startDate.value!)} - ${dateFormat.format(controller.endDate.value!)}';

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.15),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.date_range_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      rangeText,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => controller.resetFilters(),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          Expanded(
            child: Obx(() {
              if (controller.isLoadingLab.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final history = controller.filteredLabHistory;

              if (history.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.science_outlined,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        controller.searchQuery.isEmpty
                            ? 'Belum ada riwayat laboratorium'
                            : 'Hasil pencarian tidak ditemukan',
                        style: GoogleFonts.poppins(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final item = history[index];
                  final tglRaw = item['tgl_periksa'] ?? '';
                  final jamRaw = item['jam'] ?? '';
                  final dokter = item['dokter']['nm_dokter'] ?? 'Dokter';
                  final petugas = item['petugas']['nama'] ?? 'Petugas';
                  final status = item['status'] ?? 'Ralan';

                  // Date Formatting
                  String formattedDate = '$tglRaw $jamRaw';
                  try {
                    if (tglRaw.isNotEmpty && jamRaw.isNotEmpty) {
                      final dateObj = DateTime.parse('$tglRaw $jamRaw');
                      formattedDate = DateFormat(
                        'dd MMM yyyy, HH:mm',
                        'id_ID',
                      ).format(dateObj);
                    }
                  } catch (e) {
                    // fallback to raw if parse fails
                  }

                  final isRalan = status == 'Ralan';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        16,
                      ), // Rounded corners
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                            0.04,
                          ), // Softer shadow
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ExpansionTile(
                      controller: () {
                        if (!controller.labTileControllers.containsKey(index)) {
                          controller.labTileControllers[index] =
                              ExpansionTileController();
                        }
                        return controller.labTileControllers[index];
                      }(),
                      onExpansionChanged: (isOpen) {
                        if (isOpen) {
                          final prevIndex = controller.expandedLabIndex.value;
                          if (prevIndex != null && prevIndex != index) {
                            controller.labTileControllers[prevIndex]
                                ?.collapse();
                          }
                          controller.expandedLabIndex.value = index;
                        }
                      },
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12, // More vertical padding
                      ),
                      shape: const Border(),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.science_outlined,
                          color: AppColors.primary,
                          size: 24,
                        ),
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formattedDate,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isRalan
                                  ? Colors.blue.withOpacity(0.1)
                                  : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              status,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isRalan ? Colors.blue : Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          dokter,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(
                                height: 16,
                              ), // Use divider to separate content
                              _buildDetailRow('Petugas', petugas),
                              const SizedBox(height: 12),
                              const Divider(height: 24),
                              Text(
                                'Pemeriksaan:',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (item['detail_periksa_lab'] != null &&
                                  (item['detail_periksa_lab'] as List)
                                      .isNotEmpty)
                                Table(
                                  columnWidths: const {
                                    0: FlexColumnWidth(1.2), // Pemeriksaan
                                    1: FlexColumnWidth(1), // Hasil
                                    2: FlexColumnWidth(0.8), // Rujukan
                                  },
                                  border: TableBorder(
                                    horizontalInside: BorderSide(
                                      color: Colors.grey.withOpacity(0.2),
                                      width: 0.5,
                                    ),
                                  ),
                                  children: [
                                    // Header
                                    TableRow(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          child: Text(
                                            'Pemeriksaan',
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          child: Text(
                                            'Hasil',
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 8,
                                          ),
                                          child: Text(
                                            'Rujukan',
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[600],
                                            ),
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Data Rows
                                    ...(item['detail_periksa_lab'] as List).map((
                                      detail,
                                    ) {
                                      final keterangan =
                                          detail['keterangan'] ?? '';
                                      final isAbnormal =
                                          keterangan == 'L' ||
                                          keterangan == 'H' ||
                                          keterangan == '*';

                                      return TableRow(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8,
                                            ),
                                            child: Text(
                                              detail['template']?['Pemeriksaan'] ??
                                                  'Detail',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8,
                                            ),
                                            child: Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    '${detail['nilai'] ?? ''} ${detail['satuan'] ?? ''}',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: isAbnormal
                                                          ? Colors.red
                                                          : Colors.black,
                                                    ),
                                                  ),
                                                ),
                                                if (keterangan.isNotEmpty) ...[
                                                  const SizedBox(width: 4),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 4,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: isAbnormal
                                                          ? Colors.red
                                                                .withOpacity(
                                                                  0.1,
                                                                )
                                                          : Colors.grey
                                                                .withOpacity(
                                                                  0.1,
                                                                ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4,
                                                          ),
                                                    ),
                                                    child: Text(
                                                      keterangan,
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: isAbnormal
                                                            ? Colors.red
                                                            : Colors.grey[700],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8,
                                            ),
                                            child: Text(
                                              detail['nilai_rujukan'] ?? '-',
                                              style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                color: Colors.grey[600],
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ],
                                )
                              else
                                Text(
                                  'Detail tidak tersedia',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

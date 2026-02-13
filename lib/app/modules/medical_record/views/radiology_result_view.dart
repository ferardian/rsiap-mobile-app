import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/values/colors.dart';
import '../controllers/medical_record_controller.dart';

class RadiologyResultView extends GetView<MedicalRecordController> {
  const RadiologyResultView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.fetchRadiologyHistory();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Hasil Radiologi',
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
                    onChanged: (value) =>
                        controller.radiologySearchQuery.value = value,
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
                    onPressed: () =>
                        controller.selectRadiologyDateRange(context),
                    icon: Obx(
                      () => Icon(
                        Icons.calendar_month_rounded,
                        color: controller.radiologyStartDate.value != null
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
            if (controller.radiologyStartDate.value != null) {
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
                    'Periode: ${controller.currentRadiologyPeriod}',
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
            if (controller.radiologyStartDate.value == null ||
                controller.radiologyEndDate.value == null) {
              return const SizedBox.shrink();
            }

            final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');
            final rangeText =
                '${dateFormat.format(controller.radiologyStartDate.value!)} - ${dateFormat.format(controller.radiologyEndDate.value!)}';

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
                      onTap: () => controller.resetRadiologyFilters(),
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
              if (controller.isLoadingRadiology.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final history = controller.filteredRadiologyHistory;

              if (history.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_search_outlined,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        controller.radiologySearchQuery.isEmpty
                            ? 'Belum ada riwayat radiologi'
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
                  final tgl = item['tgl_registrasi'] ?? '-';
                  final jam = item['jam_reg'] ?? '-';
                  final dokter = item['dokter']?['nm_dokter'] ?? 'Dokter';
                  final poli = item['poliklinik']?['nm_poli'] ?? '-';

                  // Radiology details
                  final radiologiList = item['periksaRadiologi'] as List;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: const Border(),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.indigo.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.image_search,
                          color: Colors.indigo,
                          size: 24,
                        ),
                      ),
                      title: Text(
                        '$tgl $jam',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
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
                              const Divider(height: 16),
                              _buildDetailRow('Poliklinik', poli),
                              const Divider(height: 24),
                              Text(
                                'Pemeriksaan:',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...radiologiList.map((rad) {
                                // Safe access for nested image data - API returns snake_case
                                final gambarList =
                                    (rad['gambar_radiologi'] ??
                                            rad['gambarRadiologi'])
                                        as List?;
                                final hasImage =
                                    gambarList != null && gambarList.isNotEmpty;

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.check_circle_outline,
                                            size: 16,
                                            color: Colors.green,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              '${rad['kd_jenis_prw'] ?? 'Pemeriksaan'} - ${rad['hasil'] ?? 'Hasil belum input'}',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (hasImage) ...[
                                        const SizedBox(height: 8),
                                        ...gambarList!.map((img) {
                                          final fileName =
                                              img['lokasi_gambar'] as String?;
                                          if (fileName == null ||
                                              fileName.isEmpty)
                                            return const SizedBox.shrink();

                                          // Handle URL construction safely
                                          String url;
                                          String rawUrl;
                                          if (fileName.startsWith(
                                            'pages/upload/',
                                          )) {
                                            rawUrl =
                                                'https://sim.rsiaaisyiyah.com/webapps/radiologi/$fileName';
                                          } else {
                                            rawUrl =
                                                'https://sim.rsiaaisyiyah.com/webapps/radiologi/pages/upload/$fileName';
                                          }

                                          url = Uri.encodeFull(rawUrl);

                                          final isPdf = fileName
                                              .toLowerCase()
                                              .endsWith('.pdf');

                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              left: 24,
                                              top: 4,
                                            ),
                                            child: isPdf
                                                ? InkWell(
                                                    onTap: () async {
                                                      final uri = Uri.parse(
                                                        url,
                                                      );
                                                      if (!await launchUrl(
                                                        uri,
                                                        mode: LaunchMode
                                                            .externalApplication,
                                                      )) {
                                                        Get.snackbar(
                                                          'Error',
                                                          'Tidak dapat membuka file',
                                                        );
                                                      }
                                                    },
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 8,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.red
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              8,
                                                            ),
                                                        border: Border.all(
                                                          color: Colors.red
                                                              .withOpacity(0.3),
                                                        ),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .picture_as_pdf,
                                                            size: 16,
                                                            color:
                                                                Colors.red[700],
                                                          ),
                                                          const SizedBox(
                                                            width: 8,
                                                          ),
                                                          Text(
                                                            'Lihat File PDF',
                                                            style:
                                                                GoogleFonts.poppins(
                                                                  fontSize: 11,
                                                                  color: Colors
                                                                      .red[700],
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                          ),
                                                          const SizedBox(
                                                            width: 4,
                                                          ),
                                                          Icon(
                                                            Icons.open_in_new,
                                                            size: 12,
                                                            color:
                                                                Colors.red[700],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                : Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        constraints:
                                                            const BoxConstraints(
                                                              maxHeight: 300,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                          border: Border.all(
                                                            color: Colors
                                                                .grey[300]!,
                                                          ),
                                                        ),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                          child: Image.network(
                                                            url,
                                                            fit: BoxFit.contain,
                                                            loadingBuilder:
                                                                (
                                                                  context,
                                                                  child,
                                                                  loadingProgress,
                                                                ) {
                                                                  if (loadingProgress ==
                                                                      null)
                                                                    return child;
                                                                  return Container(
                                                                    height: 150,
                                                                    width: double
                                                                        .infinity,
                                                                    color: Colors
                                                                        .grey[100],
                                                                    child: Center(
                                                                      child: CircularProgressIndicator(
                                                                        value:
                                                                            loadingProgress.expectedTotalBytes !=
                                                                                null
                                                                            ? loadingProgress.cumulativeBytesLoaded /
                                                                                  loadingProgress.expectedTotalBytes!
                                                                            : null,
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                            errorBuilder:
                                                                (
                                                                  context,
                                                                  error,
                                                                  stackTrace,
                                                                ) {
                                                                  return Container(
                                                                    height: 100,
                                                                    color: Colors
                                                                        .grey[100],
                                                                    child: Center(
                                                                      child: Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Icon(
                                                                            Icons.broken_image,
                                                                            color:
                                                                                Colors.grey[400],
                                                                          ),
                                                                          const SizedBox(
                                                                            height:
                                                                                4,
                                                                          ),
                                                                          Text(
                                                                            'Gagal memuat gambar',
                                                                            style: GoogleFonts.poppins(
                                                                              fontSize: 10,
                                                                              color: Colors.grey,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      InkWell(
                                                        onTap: () {
                                                          Get.to(
                                                            () => Scaffold(
                                                              backgroundColor:
                                                                  Colors.black,
                                                              appBar: AppBar(
                                                                backgroundColor:
                                                                    Colors
                                                                        .black,
                                                                iconTheme:
                                                                    const IconThemeData(
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                elevation: 0,
                                                                title: Text(
                                                                  'Pratinjau Gambar',
                                                                  style: GoogleFonts.poppins(
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ),
                                                              body: Center(
                                                                child: InteractiveViewer(
                                                                  panEnabled:
                                                                      true,
                                                                  boundaryMargin:
                                                                      const EdgeInsets.all(
                                                                        80,
                                                                      ),
                                                                  minScale: 0.5,
                                                                  maxScale: 4,
                                                                  child: Image.network(
                                                                    url,
                                                                    loadingBuilder:
                                                                        (
                                                                          context,
                                                                          child,
                                                                          loadingProgress,
                                                                        ) {
                                                                          if (loadingProgress ==
                                                                              null)
                                                                            return child;
                                                                          return Center(
                                                                            child: CircularProgressIndicator(
                                                                              value:
                                                                                  loadingProgress.expectedTotalBytes !=
                                                                                      null
                                                                                  ? loadingProgress.cumulativeBytesLoaded /
                                                                                        loadingProgress.expectedTotalBytes!
                                                                                  : null,
                                                                              color: Colors.white,
                                                                            ),
                                                                          );
                                                                        },
                                                                    errorBuilder:
                                                                        (
                                                                          context,
                                                                          error,
                                                                          stackTrace,
                                                                        ) {
                                                                          return Center(
                                                                            child: Column(
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                const Icon(
                                                                                  Icons.broken_image,
                                                                                  color: Colors.white,
                                                                                  size: 48,
                                                                                ),
                                                                                const SizedBox(
                                                                                  height: 8,
                                                                                ),
                                                                                Text(
                                                                                  'Gagal memuat gambar',
                                                                                  style: GoogleFonts.poppins(
                                                                                    color: Colors.white,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          );
                                                                        },
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            transition:
                                                                Transition.zoom,
                                                          );
                                                        },
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                vertical: 4,
                                                              ),
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Icons
                                                                    .fullscreen,
                                                                size: 14,
                                                                color: Colors
                                                                    .blue[600],
                                                              ),
                                                              const SizedBox(
                                                                width: 4,
                                                              ),
                                                              Text(
                                                                'Lihat Ukuran Penuh',
                                                                style: GoogleFonts.poppins(
                                                                  fontSize: 10,
                                                                  color: Colors
                                                                      .blue[600],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                          );
                                        }).toList(),
                                      ],
                                    ],
                                  ),
                                );
                              }).toList(),
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../controllers/vaccination_controller.dart';

class VaccinationView extends GetView<VaccinationController> {
  const VaccinationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Imunisasi Anak',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_active_outlined,
              color: Colors.black,
            ),
            tooltip: 'Tes Notifikasi',
            onPressed: () => controller.testNotification(),
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Family Member Selector
            if (controller.familyMembers.length > 1)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                width: double.infinity,
                color: Colors.grey[50],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<Map<String, dynamic>>(
                      value: controller.selectedChild.value,
                      hint: Text(
                        'Pilih Anak',
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      isExpanded: true,
                      items: controller.familyMembers.map((member) {
                        return DropdownMenuItem<Map<String, dynamic>>(
                          value: member,
                          child: Text(
                            member['nm_pasien'] ?? '-',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          controller.selectedChild.value = value;
                          controller.fetchVaccinationHistory(
                            value['no_rkm_medis'],
                            value['tgl_lahir'],
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),

            // Timeline List
            Expanded(
              child: controller.vaccinationList.isEmpty
                  ? Center(
                      child: Text(
                        'Belum ada data imunisasi',
                        style: GoogleFonts.poppins(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: controller.vaccinationList.length,
                      itemBuilder: (context, index) {
                        final vaccine = controller.vaccinationList[index];
                        return _buildVaccineItem(
                          vaccine,
                          index,
                          controller.vaccinationList.length,
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildVaccineItem(dynamic vaccine, int index, int total) {
    final status = vaccine['status'];
    final bool isLast = index == total - 1;
    final bool isDone = status == 'done';

    Color statusColor;
    Color bgColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case 'done':
        statusColor = Colors.green.shade600;
        bgColor = Colors.green.shade50;
        statusText = 'Selesai';
        statusIcon = Icons.check_rounded;
        break;
      case 'due_soon':
        statusColor = Colors.orange.shade700;
        bgColor = Colors.orange.shade50;
        statusText = 'Segera';
        statusIcon = Icons.priority_high_rounded;
        break;
      case 'overdue':
        statusColor = Colors.red.shade600;
        bgColor = Colors.red.shade50;
        statusText = 'Terlewat';
        statusIcon = Icons.warning_amber_rounded;
        break;
      default:
        statusColor = Colors.grey.shade400;
        bgColor = Colors.grey.shade50;
        statusText = 'Belum';
        statusIcon = Icons.calendar_today_rounded;
    }

    // Parse Dates
    String dueDateStr = '-';
    if (vaccine['due_date'] != null) {
      try {
        dueDateStr = DateFormat(
          'dd MMM yyyy',
        ).format(DateTime.parse(vaccine['due_date']));
      } catch (e) {}
    }

    String givenDateStr = '';
    if (isDone &&
        vaccine['transaksi'] != null &&
        vaccine['transaksi']['tgl_pemberian'] != null) {
      try {
        givenDateStr = DateFormat(
          'dd MMM yyyy',
        ).format(DateTime.parse(vaccine['transaksi']['tgl_pemberian']));
      } catch (e) {}
    }

    return InkWell(
      onTap: () {
        if (!isDone) {
          _showMarkAsDoneDialog(vaccine);
        }
      },
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline Line
            Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDone ? statusColor : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDone
                          ? statusColor
                          : statusColor.withOpacity(0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      statusIcon,
                      size: 16,
                      color: isDone ? Colors.white : statusColor,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),

            // Content Card
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade100,
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        // Left Accent Bar
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
                          child: Container(width: 6, color: statusColor),
                        ),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(22, 16, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          vaccine['nama_vaksin'] ?? 'Vaksin',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade50,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            'Usia ${vaccine['usia_bulan']} Bulan',
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.blue.shade700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: bgColor,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: statusColor.withOpacity(0.1),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          statusIcon,
                                          size: 12,
                                          color: statusColor,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          statusText,
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: statusColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              if (vaccine['deskripsi'] != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  vaccine['deskripsi'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    height: 1.5,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],

                              const SizedBox(height: 16),
                              Divider(color: Colors.grey.shade100, height: 1),

                              // Footer Date
                              Row(
                                children: [
                                  Icon(
                                    Icons.event_note_rounded,
                                    size: 16,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isDone ? 'Diberikan:' : 'Jadwal:',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      isDone ? givenDateStr : dueDateStr,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                  if (!isDone)
                                    const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 12,
                                      color: Colors.grey,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMarkAsDoneDialog(dynamic vaccine) {
    final TextEditingController dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
    final TextEditingController notesController = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 48,
                height: 5,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            Text(
              'Konfirmasi Imunisasi',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                text: 'Tandai vaksin ',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                children: [
                  TextSpan(
                    text: vaccine['nama_vaksin'],
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  const TextSpan(text: ' sudah diberikan pada anak?'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Date Picker Field
            Text(
              'Tanggal Pemberian',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: Get.context!,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: Colors.blue[700]!,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  dateController.text = DateFormat('yyyy-MM-dd').format(picked);
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[50], // Light gray background
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      color: Colors.blue[600],
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: IgnorePointer(
                        child: TextField(
                          controller: dateController,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none,
                          ),
                          readOnly: true,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down_rounded,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Notes Field
            Text(
              'Catatan (Opsional)',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: TextField(
                controller: notesController,
                style: GoogleFonts.poppins(fontSize: 14),
                maxLines: 2,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Cth: Vaksin di Posyandu Mawar',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey[400],
                    fontSize: 13,
                  ),
                  icon: Icon(
                    Icons.edit_note_rounded,
                    color: Colors.grey[400],
                    size: 22,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      backgroundColor: Colors.grey[100],
                    ),
                    child: Text(
                      'Batal',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      controller.markAsDone(
                        vaccine['id'],
                        dateController.text,
                        notesController.text,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFF0EA5E9,
                      ), // Modern Sky Blue
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ),
                    child: Text(
                      'Simpan',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    );
  }
}

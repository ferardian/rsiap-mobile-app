import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/values/colors.dart';
import '../controllers/booking_controller.dart';
import 'booking_detail_view.dart';

class BookingView extends GetView<BookingController> {
  const BookingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dummy Data for Poliklinik (matching existing app)
    final List<Map<String, dynamic>> poliklinikList = [
      {
        'title': 'Poliklinik Anak',
        'icon': Icons.child_care,
        'color': Colors.blue,
        'kode_poli': ['P003', 'P008'], // Example codes
        'description': 'Layanan kesehatan khusus anak.',
      },
      {
        'title': 'Poliklinik Kandungan',
        'icon': Icons.pregnant_woman,
        'color': Colors.pink,
        'kode_poli': ['P001', 'P007'],
        'description': 'Layanan kesehatan ibu dan kandungan.',
      },
      // Add more as needed
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Daftar Periksa',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16, // mainAxisSpacing restored
          childAspectRatio: 0.8, // Balanced ratio
        ),
        itemCount: poliklinikList.length,
        itemBuilder: (context, index) {
          final poli = poliklinikList[index];
          return Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20), // More rounded
            elevation: 2,
            shadowColor: Colors.black.withOpacity(0.05),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                controller.selectPoli(poli);
                Get.to(() => const BookingDetailView());
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: (poli['color'] as Color).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        poli['icon'] as IconData,
                        size: 32, // Restored size
                        color: poli['color'] as Color,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        poli['title'] as String,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 15, // Better visibility
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      poli['description'] as String,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 11.5, // Better visibility
                        color: AppColors.textSecondary,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

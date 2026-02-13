import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class InfoSlider extends StatelessWidget {
  const InfoSlider({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy Data for now
    final List<Map<String, String>> banners = [
      {
        'title': 'Layanan Gawat Darurat',
        'subtitle': 'Siap melayani 24 Jam dengan fasilitas lengkap',
        'image': 'assets/images/banner_1.png',
        'color': '0xFF4772E6',
      },
      {
        'title': 'Jadwal Dokter Spesialis',
        'subtitle': 'Cek jadwal dokter spesialis terbaru kami',
        'image': 'assets/images/banner_2.png',
        'color': '0xFF28C76F',
      },
      {
        'title': 'Fasilitas Penunjang',
        'subtitle': 'Laboratorium & Radiologi modern',
        'image': 'assets/images/banner_3.png',
        'color': '0xFFFF9F43',
      },
    ];

    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 160.0,
            autoPlay: true,
            enlargeCenterPage: true,
            aspectRatio: 16 / 9,
            autoPlayCurve: Curves.fastOutSlowIn,
            enableInfiniteScroll: true,
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            viewportFraction: 0.9,
          ),
          items: banners.map((banner) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    color: Color(int.parse(banner['color']!)),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Color(
                          int.parse(banner['color']!),
                        ).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Decorative Circle
                      Positioned(
                        right: -20,
                        top: -20,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              banner['title']!,
                              style: const TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              banner['subtitle']!,
                              style: TextStyle(
                                fontSize: 13.0,
                                color: Colors.white.withOpacity(0.9),
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
          }).toList(),
        ),
      ],
    );
  }
}

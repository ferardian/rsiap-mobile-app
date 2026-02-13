import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/values/colors.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: SalomonBottomBar(
          currentIndex: currentIndex,
          onTap: onTap,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey.shade400,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          itemPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          items: [
            SalomonBottomBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              title: Text(
                'Home',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              selectedColor: AppColors.primary,
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.calendar_month_outlined),
              activeIcon: const Icon(Icons.calendar_month),
              title: Text(
                'Jadwal',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              selectedColor: Colors.orange,
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.history_outlined),
              activeIcon: const Icon(Icons.history),
              title: Text(
                'Riwayat',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              selectedColor: Colors.purple,
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              title: Text(
                'Profil',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              selectedColor: Colors.teal,
            ),
          ],
        ),
      ),
    );
  }
}

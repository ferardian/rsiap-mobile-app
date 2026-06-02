import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../../home/views/home_view.dart';
import '../../profile/views/profile_view.dart';
import '../../history/views/history_view.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import '../../../../core/values/colors.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Make body extend behind the floating nav bar
      body: Obx(() {
        switch (controller.selectedIndex.value) {
          case 0:
            return const HomeView();
          case 1:
            return const HistoryView();
          case 2:
            return const ProfileView();
          default:
            return const HomeView();
        }
      }),
      bottomNavigationBar: Obx(
        () => Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              padding: MediaQuery.of(context).padding.copyWith(
                top: 0,
                bottom: 0,
              ),
            ),
            child: SalomonBottomBar(
              currentIndex: controller.selectedIndex.value,
              onTap: controller.changeTabIndex,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              items: [
                /// Home
                SalomonBottomBarItem(
                  icon: const Icon(Icons.home_outlined),
                  title: const Text("Beranda"),
                  selectedColor: AppColors.primary,
                ),

                /// History
                SalomonBottomBarItem(
                  icon: const Icon(Icons.history_outlined),
                  title: const Text("Riwayat"),
                  selectedColor: Colors.orange,
                ),

                /// Profile
                SalomonBottomBarItem(
                  icon: const Icon(Icons.person_outline),
                  title: const Text("Profil"),
                  selectedColor: Colors.teal,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

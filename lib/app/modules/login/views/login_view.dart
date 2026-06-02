import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/values/colors.dart';
import '../../../routes/app_pages.dart';
import '../../../common/widgets/custom_text_field.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Exact background color matching the illustration
    const Color bgIllustration = Color(0xFFE4F5F2);

    // Responsive layout helpers
    final screenHeight = MediaQuery.of(context).size.height;
    // Calculate form height (approx 60% of screen to fit inputs comfortably)
    final formHeight = screenHeight * 0.60;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            // 1. Full Width Illustration at the Top
            // Occupies the remaining space above the form
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: screenHeight - formHeight + 40,
              child: Container(
                color: bgIllustration,
                child: Image.asset(
                  'assets/ilustrations/login_illustration.png',
                  fit: BoxFit.fitWidth,
                  width: MediaQuery.of(context).size.width,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 400,
                      color: AppColors.primary.withOpacity(0.1),
                      child: const Icon(
                        Icons.medical_services,
                        size: 80,
                        color: AppColors.primary,
                      ),
                    );
                  },
                ),
              ),
            ),

            // 2. Triple Logo Header
            Positioned(
              top: MediaQuery.of(context).padding.top + 15,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Image.asset('assets/images/logo_rsiap.png', height: 28),
                        const SizedBox(width: 8),
                        Container(
                          width: 1,
                          height: 18,
                          color: Colors.grey.withOpacity(0.3),
                        ),
                        const SizedBox(width: 8),
                        Image.asset(
                          'assets/images/logo_rsia_aisyiyah.png',
                          height: 28,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/logo_larsi.png',
                      height: 28,
                    ),
                  ),
                ],
              ),
            ),

            // 3. Login Form Card (Fixed Height at Bottom)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                height: formHeight,
                padding: const EdgeInsets.fromLTRB(
                  30,
                  30,
                  30,
                  10,
                ), // Reduced bottom padding
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 30,
                      offset: Offset(0, -10),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Row(
                        children: [
                          Container(
                            width: 5,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            'Masuk Akun',
                            style: GoogleFonts.poppins(
                              fontSize: 24, // Reduced font size
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),

                      // Subtitle removed
                      SizedBox(
                        height: screenHeight * 0.04,
                      ), // Responsive spacing
                      // Inputs
                      CustomTextField(
                        controller: controller.noRkmMedisController,
                        label: 'Nomor Rekam Medis',
                        hint: 'Contoh: 123456',
                        keyboardType: TextInputType.number,
                        prefixIcon: const Icon(
                          Icons.badge_outlined,
                          color: AppColors.primary,
                          size: 22,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                      ),
                      SizedBox(
                        height: screenHeight * 0.02,
                      ), // Responsive spacing
                      Obx(
                        () => CustomTextField(
                          controller: controller.passwordController,
                          label: 'Password / Tanggal Lahir',
                          hint: 'Format: DDMMYYYY',
                          obscureText: controller.isObscure.value,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isObscure.value
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppColors.textSecondary.withOpacity(0.4),
                              size: 20,
                            ),
                            onPressed: controller.toggleObscure,
                          ),
                        ),
                      ),

                      SizedBox(
                        height: screenHeight * 0.04,
                      ), // Responsive spacing
                      // Button
                      SizedBox(
                        width: double.infinity,
                        height: 55, // Slightly smaller button height
                        child: Obx(
                          () => Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: AppColors.primaryGradient,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(
                                    0.25,
                                  ), // Reduced shadow opacity
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : controller.login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: controller.isLoading.value
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : Text(
                                      'Masuk Sekarang',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16, // Slightly smaller font
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(
                        height: screenHeight * 0.02,
                      ),

                      // Guest Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: OutlinedButton(
                          onPressed: controller.loginAsGuest,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primary, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(
                            'Masuk Sebagai Tamu',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Footer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Belum punya akun? ',
                            style: GoogleFonts.poppins(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Get.toNamed(Routes.REGISTER),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Daftar Baru',
                              style: GoogleFonts.poppins(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
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
          ],
        ),
      ),
    );
  }
}

import 'package:get/get.dart';

import '../modules/booking/bindings/booking_binding.dart';
import '../modules/booking/views/booking_view.dart';
import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/home/views/article_detail_view.dart';
import '../modules/home/views/article_list_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/medical_record/bindings/medical_record_binding.dart';
import '../modules/medical_record/views/lab_result_view.dart';
import '../modules/medical_record/views/radiology_result_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/schedule/bindings/schedule_binding.dart';
import '../modules/schedule/views/schedule_view.dart';
import '../modules/poli_queue/bindings/poli_queue_binding.dart';
import '../modules/poli_queue/views/poli_queue_view.dart';
import '../modules/register/bindings/register_binding.dart';
import '../modules/register/views/register_view.dart';
import '../modules/vaccination/bindings/vaccination_binding.dart';
import '../modules/vaccination/views/vaccination_view.dart';
import '../modules/forgot_account/bindings/forgot_account_binding.dart';
import '../modules/forgot_account/views/forgot_account_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.VACCINATION,
      page: () => const VaccinationView(),
      binding: VaccinationBinding(),
    ),
    GetPage(
      name: _Paths.BOOKING,
      page: () => const BookingView(),
      binding: BookingBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.LAB,
      page: () => const LabResultView(),
      binding: MedicalRecordBinding(),
    ),
    GetPage(
      name: _Paths.RADIOLOGY,
      page: () => const RadiologyResultView(),
      binding: MedicalRecordBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.SCHEDULE,
      page: () => const ScheduleView(),
      binding: ScheduleBinding(),
    ),
    GetPage(
      name: _Paths.ARTICLE_DETAIL,
      page: () => const ArticleDetailView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.ARTICLE_LIST,
      page: () => const ArticleListView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.POLI_QUEUE,
      page: () => const PoliQueueView(),
      binding: PoliQueueBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.FORGOT_ACCOUNT,
      page: () => const ForgotAccountView(),
      binding: ForgotAccountBinding(),
    ),
  ];
}

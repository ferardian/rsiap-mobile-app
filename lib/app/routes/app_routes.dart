part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const HOME = _Paths.HOME;
  static const LOGIN = _Paths.LOGIN;
  static const BOOKING = _Paths.BOOKING;
  static const LAB = _Paths.LAB;
  static const RADIOLOGY = _Paths.RADIOLOGY;
  static const PROFILE = _Paths.PROFILE;
  static const SCHEDULE = _Paths.SCHEDULE;
  static const ARTICLE_DETAIL = _Paths.ARTICLE_DETAIL;
  static const ARTICLE_LIST = _Paths.ARTICLE_LIST;
  static const POLI_QUEUE = _Paths.POLI_QUEUE;
  static const REGISTER = _Paths.REGISTER;
  static const VACCINATION = _Paths.VACCINATION;
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/home';
  static const LOGIN = '/login';
  static const BOOKING = '/booking';
  static const LAB = '/lab';
  static const RADIOLOGY = '/radiology';
  static const PROFILE = '/profile';
  static const SCHEDULE = '/schedule';
  static const ARTICLE_DETAIL = '/article-detail';
  static const ARTICLE_LIST = '/article-list';
  static const POLI_QUEUE = '/poli-queue';
  static const REGISTER = '/register';
  static const VACCINATION = '/vaccination';
}

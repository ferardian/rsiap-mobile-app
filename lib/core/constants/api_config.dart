import 'package:get_storage/get_storage.dart';

class ApiConfig {
  static const String primaryDomain = 'https://sim.rsiaaisyiyah.com/rsiapi-v2';
  static const String backupDomain = 'https://rsiap.my.id/rsiapi-v2';

  static String getBaseUrl(String domain) => '$domain/api/v2/';

  static String get baseUrl {
    final domain = GetStorage().read('active_domain') ?? primaryDomain;
    return getBaseUrl(domain);
  }

  static const String waNumber = '6285640009934';
  static const String waUrl = 'https://wa.me/$waNumber';

  static const String login = 'pasien/auth/login';
  static const String userDetail = 'pasien/auth/detail';
  static const String bookingSearch = 'registrasi/periksa/search';
  static const String jadwalSearch = 'public/jadwal/search';
  static const String bookingRegistrasi = 'booking/registrasi';
  static const String bookingBatal = 'booking/registrasi/batal';
  static const String slider = 'slider';
  static const String article = 'article';
  static const String facility = 'facility';
  static const String poliklinikAntrianSummary = 'public/antrian-poli/summary';
}

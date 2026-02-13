import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../../../data/repositories/schedule_repository.dart';

class ScheduleController extends GetxController {
  final ScheduleRepository _repository;

  ScheduleController(this._repository);

  final isLoading = false.obs;
  final schedules = <Map<String, dynamic>>[].obs;
  final searchQuery = ''.obs;

  final days = <Map<String, dynamic>>[].obs;
  final selectedDate = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    _generateNext7Days();
    // Select today by default
    if (days.isNotEmpty) {
      selectedDate.value = days.first;
    }
    fetchSchedules();
  }

  void _generateNext7Days() {
    final now = DateTime.now();
    final formatter = DateFormat('EEEE, d MMM yyyy', 'id_ID');
    final dayNameFormatter = DateFormat('EEEE', 'id_ID');

    days.clear();
    for (int i = 0; i < 7; i++) {
      final date = now.add(Duration(days: i));
      days.add({
        'date': date,
        'display': formatter.format(date),
        'api_day': dayNameFormatter.format(date).toUpperCase(),
        'day_name': dayNameFormatter.format(
          date,
        ), // For UI short display if needed
        'day_num': DateFormat('d').format(date),
      });
    }
  }

  void changeDay(Map<String, dynamic> dateMap) {
    if (selectedDate.value != dateMap) {
      selectedDate.value = dateMap;
      fetchSchedules();
    }
  }

  Future<void> fetchSchedules() async {
    isLoading.value = true;
    try {
      final response = await _repository.getSchedules(
        day: selectedDate.value?['api_day'],
        search: searchQuery.value,
      );

      final List<dynamic> data = response['data'] ?? [];
      schedules.assignAll(data.cast<Map<String, dynamic>>());
    } catch (e) {
      print('Error fetching schedules: $e');
      Get.snackbar('Error', 'Gagal memuat jadwal dokter');
    } finally {
      isLoading.value = false;
    }
  }

  // Helper to group schedules by Poliklinik
  Map<String, List<Map<String, dynamic>>> get groupedSchedules {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (var schedule in schedules) {
      final poliName = schedule['poliklinik']?['nm_poli'] ?? 'Lainnya';
      if (!grouped.containsKey(poliName)) {
        grouped[poliName] = [];
      }
      grouped[poliName]!.add(schedule);
    }
    return grouped;
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    // Debounce or just trigger fetch
    fetchSchedules();
  }
}

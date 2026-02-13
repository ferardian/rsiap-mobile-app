import 'package:get/get.dart';
import '../../home/controllers/home_controller.dart';
import '../../../data/repositories/history_repository.dart';

class HistoryController extends GetxController {
  final HistoryRepository _repository;

  HistoryController(this._repository);

  final isLoading = false.obs;
  final historyList = <Map<String, dynamic>>[].obs;
  final currentPage = 1.obs;
  final lastPage = 1.obs;
  final hasMore = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHistory();
  }

  Future<void> fetchHistory({bool refresh = false}) async {
    if (isLoading.value) return;

    if (refresh) {
      currentPage.value = 1;
      hasMore.value = true;
      historyList.clear();
    }

    if (!hasMore.value) return;

    try {
      isLoading.value = true;

      // Get noRkmMedis from HomeController
      // Ensure HomeController is loaded or handled safely
      final homeController = Get.find<HomeController>();
      final noRkmMedis = homeController.user.value?.noRkmMedis;

      if (noRkmMedis == null) {
        // User not loaded yet or error
        return;
      }

      final response = await _repository.getHistory(
        noRkmMedis: noRkmMedis,
        page: currentPage.value,
      );

      final List<dynamic> newData = response['data'] ?? [];
      final meta = response['meta'];

      if (newData.isEmpty) {
        hasMore.value = false;
      } else {
        historyList.addAll(newData.cast<Map<String, dynamic>>());
        currentPage.value++;

        if (meta != null) {
          lastPage.value = meta['last_page'];
          if (currentPage.value > lastPage.value) {
            hasMore.value = false;
          }
        }
      }
    } catch (e) {
      print('Error fetching history: $e');
      Get.snackbar('Error', 'Gagal memuat riwayat: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await fetchHistory(refresh: true);
  }
}

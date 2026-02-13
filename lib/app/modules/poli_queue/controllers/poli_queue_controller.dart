import 'package:get/get.dart';
import '../../../data/repositories/poli_queue_repository.dart';

class PoliQueueController extends GetxController {
  final PoliQueueRepository _repository = Get.find<PoliQueueRepository>();

  var isLoading = false.obs;
  var antrianSummary = <dynamic>[].obs;
  var error = ''.obs;
  var selectedDateIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAntrianSummary();
  }

  List<dynamic> get currentPoliklinik {
    if (antrianSummary.isEmpty ||
        selectedDateIndex.value >= antrianSummary.length)
      return [];
    return antrianSummary[selectedDateIndex.value]['poliklinik'] ?? [];
  }

  void setDateIndex(int index) {
    selectedDateIndex.value = index;
  }

  Future<void> fetchAntrianSummary() async {
    isLoading.value = true;
    error.value = '';
    try {
      final data = await _repository.getAntrianSummary();
      antrianSummary.assignAll(data);
    } catch (e) {
      error.value = e.toString().contains('exception:')
          ? e.toString().split('exception:').last
          : e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}

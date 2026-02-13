import 'firebase_api.dart';

class MedicationReminderService {
  static final MedicationReminderService _instance =
      MedicationReminderService._internal();
  factory MedicationReminderService() => _instance;
  MedicationReminderService._internal();

  /// Parses strings like "3x1", "2 x 1", "Sehari 3 kali", "3x7.5ml"
  /// Returns a list of intended hours (e.g., [7, 13, 19])
  List<int> parseFrequency(String aturan) {
    aturan = aturan.toLowerCase();
    final regex = RegExp(r'(\d+)\s*[xX]\s*([\d.,]+)?');
    final match = regex.firstMatch(aturan);

    if (match != null) {
      int freq = int.tryParse(match.group(1)!) ?? 0;
      if (freq == 1) return [7];
      if (freq == 2) return [7, 19];
      if (freq == 3) return [7, 13, 19];
      if (freq >= 4) return [6, 12, 18, 0];
    }

    // Default fallbacks for common text
    if (aturan.contains('tiga kali')) return [9, 13, 19];
    if (aturan.contains('dua kali')) return [9, 19];
    if (aturan.contains('satu kali')) return [9];

    return [7]; // Default to morning
  }

  /// Extracts dose per take in ml or units from aturan_pakai
  double parseDosePerTake(String aturan) {
    aturan = aturan.toLowerCase().replaceAll(',', '.');
    // Match patterns like "x 7.5ml", "x7.5", "x 1.5 sdm"
    final regex = RegExp(
      r'[xX]\s*([\d.]+)\s*(ml|cc|gr|mg|tablet|kapsul|bungkus|sachet|sdm|sdk)?',
    );
    final match = regex.firstMatch(aturan);

    if (match != null) {
      return double.tryParse(match.group(1)!) ?? 1.0;
    }

    // Fallback search for just the number after x
    final simpleRegex = RegExp(r'[xX]\s*([\d.]+)');
    final simpleMatch = simpleRegex.firstMatch(aturan);
    if (simpleMatch != null) {
      return double.tryParse(simpleMatch.group(1)!) ?? 1.0;
    }

    return 1.0; // Default to 1 unit per take
  }

  /// Try to extract total volume (ml) from medicine name
  double extractVolumeFromName(String name) {
    name = name.toLowerCase();
    // Ignore concentration units like "/5ml" or "/ml"
    final cleanName = name.replaceAll(RegExp(r'/\s*[\d.]*\s*ml'), '');

    // Look for all "ml" patterns
    final regex = RegExp(r'(\d+)\s*ml');
    final matches = regex.allMatches(cleanName);

    if (matches.isNotEmpty) {
      double maxVol = 0;
      for (var match in matches) {
        double vol = double.tryParse(match.group(1)!) ?? 0;
        if (vol > maxVol) maxVol = vol;
      }
      return maxVol;
    }
    return 0;
  }

  /// Calculates the time offset based on food instructions
  int getMinuteOffset(String aturan) {
    if (aturan.contains('sebelum makan')) return -30;
    if (aturan.contains('sesudah makan')) return 30;
    return 0;
  }

  /// Get greeting based on selected hour
  String getGreeting(DateTime time) {
    int hour = time.hour;
    if (hour >= 0 && hour < 11) return "Selamat Pagi";
    if (hour >= 11 && hour < 15) return "Selamat Siang";
    if (hour >= 15 && hour < 19) return "Selamat Sore";
    return "Selamat Malam";
  }

  Future<int> scheduleReminders(Map<String, dynamic> prescription) async {
    final String noResep = prescription['no_resep'] ?? 'unknown';
    final String nmPasien = prescription['nm_pasien'] ?? 'Pasien';
    final List<dynamic> obatList = prescription['obat'] ?? [];
    final now = DateTime.now();

    // Map to group medications by their scheduled time
    // Key: scheduled time, Value: List of medication names with their instructions
    final Map<DateTime, List<String>> groupedReminders = {};

    for (var obat in obatList) {
      final String nama = obat['nama_brng'] ?? 'Obat';
      final String aturan = (obat['aturan_pakai'] ?? '')
          .toString()
          .toLowerCase();

      final hours = parseFrequency(aturan);
      final offset = getMinuteOffset(aturan);
      final double dosePerTake = parseDosePerTake(aturan);
      final double qty = double.tryParse(obat['jml'].toString()) ?? 0;

      // --- Option B: Calculate Duration ---
      int durationInDays = 3; // Default

      bool isLiquid =
          nama.toLowerCase().contains('syr') ||
          nama.toLowerCase().contains('drop') ||
          nama.toLowerCase().contains('sirup');

      if (qty > 0 && hours.isNotEmpty) {
        if (isLiquid) {
          double totalVolume = extractVolumeFromName(nama);
          if (totalVolume == 0) {
            totalVolume = 60.0;
            if (nama.toLowerCase().contains('120')) totalVolume = 120.0;
          }

          double dailyConsumption = hours.length * dosePerTake;
          if (dailyConsumption > 0) {
            durationInDays = (totalVolume * qty / dailyConsumption).ceil();
          }
          if (durationInDays > 14) durationInDays = 14;
        } else {
          durationInDays = (qty / (hours.length * dosePerTake)).ceil();
        }
      }

      if (durationInDays < 1) durationInDays = 1;
      if (durationInDays > 30) durationInDays = 30;

      print("Preparing schedule for $nama ($durationInDays days)");

      for (int i = 0; i < hours.length; i++) {
        final hour = hours[i];
        for (int day = 0; day < durationInDays; day++) {
          var scheduleTime = DateTime(
            now.year,
            now.month,
            now.day + day,
            hour,
            0,
          ).add(Duration(minutes: offset));

          if (scheduleTime.isBefore(now)) continue;

          // Add to grouped map
          groupedReminders.putIfAbsent(scheduleTime, () => []);
          groupedReminders[scheduleTime]!.add("$nama - $aturan");
        }
      }
    }

    // Now schedule each time slot once
    for (var entry in groupedReminders.entries) {
      final scheduleTime = entry.key;
      final medications = entry.value;
      final greeting = getGreeting(scheduleTime);

      // Unique ID based on resep and the exact scheduleTime
      final int id = (noResep.hashCode ^ scheduleTime.hashCode).abs() % 100000;

      final String body =
          "$greeting $nmPasien,\nSaatnya minum obat Anda. Klik untuk detail.";

      await FirebaseApi().scheduleNotification(
        id: id,
        title: "Waktunya Minum Obat 💊",
        body: body,
        scheduledDate: scheduleTime,
        payload: '{"type": "MEDICINE_REMINDER", "no_resep": "$noResep"}',
      );

      print(
        "Notification scheduled at $scheduleTime for ${medications.length} items.",
      );
    }
    return groupedReminders.length;
  }
}

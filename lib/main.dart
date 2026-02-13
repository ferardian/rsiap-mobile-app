import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:rsiap_mobile_app/app/routes/app_pages.dart';
import 'package:rsiap_mobile_app/app/bindings/initial_binding.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rsiap_mobile_app/app/data/services/firebase_api.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await initializeDateFormatting('id_ID', null);

  try {
    await Firebase.initializeApp();
    await FirebaseApi().initNotif();
    print("🚀 Firebase Notification Service Started");
  } catch (e) {
    print("Firebase Initialization Failed: $e");
    // Continue running app even if Firebase fails (likely due to missing google-services.json)
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    GetMaterialApp(
      title: "RSIAP Mobile",
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      initialBinding: InitialBinding(),
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
    ),
  );
}

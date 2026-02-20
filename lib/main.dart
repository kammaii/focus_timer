import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';

import 'core/theme/app_theme.dart';
import 'data/providers/local_storage_provider.dart';
import 'modules/home/home_controller.dart';
import 'modules/records/records_controller.dart';
import 'modules/settings/settings_controller.dart';
import 'modules/main_screen.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    final storageProvider = LocalStorageProvider();
    Get.put(storageProvider, permanent: true);
    
    Get.put(SettingsController(storageProvider: storageProvider), permanent: true);
    Get.put(RecordsController(storageProvider: storageProvider), permanent: true);
    
    Get.lazyPut(() => HomeController(
      settings: Get.find<SettingsController>(),
      records: Get.find<RecordsController>(),
    ));
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);
  
  runApp(const FocusTimerApp());
}

class FocusTimerApp extends StatelessWidget {
  const FocusTimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Focus Timer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialBinding: InitialBinding(),
      home: MainScreen(),
    );
  }
}

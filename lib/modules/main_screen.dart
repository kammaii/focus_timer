import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home/home_view.dart';
import 'home/home_controller.dart';
import 'records/records_view.dart';
import 'settings/settings_view.dart';
import 'collection/collection_view.dart';
import '../core/theme/app_colors.dart';

class MainController extends GetxController {
  var currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;
  }
}

class MainScreen extends StatelessWidget {
  MainScreen({super.key});
  
  final MainController controller = Get.put(MainController());

  final List<Widget> pages = [
    const HomeView(),
    const RecordsView(),
    const CollectionView(),
    SettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => IndexedStack(
        index: controller.currentIndex.value,
        children: pages,
      )),
      bottomNavigationBar: Obx(() {
        bool isAmbient = false;
        if (Get.isRegistered<HomeController>()) {
          isAmbient = Get.find<HomeController>().isAmbientMode.value;
        }
        
        if (isAmbient) return const SizedBox.shrink();

        return BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changePage,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textLight,
          backgroundColor: Colors.white,
          elevation: 10,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.timer),
              label: '타이머',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: '기록',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.pets),
              label: '도감',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: '설정',
            ),
          ],
        );
      }),
    );
  }
}

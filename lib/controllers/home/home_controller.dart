import 'package:get/get.dart';

/// Controller for Home Navigation Shell managing active bottom navigation tab.
class HomeController extends GetxController {
  final RxInt selectedTabIndex = 0.obs;

  void changeTab(int index) {
    selectedTabIndex.value = index;
  }
}

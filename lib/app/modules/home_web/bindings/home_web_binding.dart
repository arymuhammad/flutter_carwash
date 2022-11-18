import 'package:get/get.dart';

import '../controllers/home_web_controller.dart';

class HomeWebBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeWebController>(
      () => HomeWebController(),
    );
  }
}

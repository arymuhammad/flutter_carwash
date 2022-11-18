import 'package:get/get.dart';

import '../controllers/laporan_keuangan_controller.dart';

class LaporanKeuanganBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LaporanKeuanganController>(
      () => LaporanKeuanganController(),
    );
  }
}

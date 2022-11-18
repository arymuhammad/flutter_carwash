import 'package:get/get.dart';

import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/home_web/bindings/home_web_binding.dart';
import '../modules/home_web/views/home_web_view.dart';
import '../modules/laporan/bindings/laporan_binding.dart';
import '../modules/laporan/views/laporan_view.dart';
import '../modules/laporan_keuangan/bindings/laporan_keuangan_binding.dart';
import '../modules/laporan_keuangan/views/laporan_keuangan_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/master/bindings/master_binding.dart';
import '../modules/master/views/master_view.dart';
import '../modules/services/bindings/services_binding.dart';
import '../modules/services/views/services_view.dart';
import '../modules/user/bindings/user_binding.dart';
import '../modules/user/views/user_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      page: () => HomeView(),
      name: _Paths.HOME,
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.HOME_WEB,
      page: () => HomeWebView(),
      binding: HomeWebBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.USER,
      page: () => const UserView(),
      binding: UserBinding(),
    ),
    GetPage(
      name: _Paths.SERVICES,
      page: () => ServicesView(),
      binding: ServicesBinding(),
    ),
    GetPage(
      name: _Paths.LAPORAN,
      page: () => LaporanView("", "" as int?),
      binding: LaporanBinding(),
    ),
    GetPage(
      name: _Paths.MASTER,
      page: () => MasterViewTabs(),
      binding: MasterBinding(),
    ),
    GetPage(
      name: _Paths.LAPORAN_KEUANGAN,
      page: () => const LaporanKeuanganView(),
      binding: LaporanKeuanganBinding(),
    ),
  ];
}

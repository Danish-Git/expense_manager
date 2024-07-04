import 'package:expense_manager/routes/routes.dart';
import 'package:get/get.dart';

import '../screens/dashboard/index.dart';
import '../screens/splash/index.dart';

abstract class AppPages {
  static final List<GetPage<dynamic>> pages = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashView(),
    ),
    GetPage(
      name: Routes.dashboard,
      page: () => const DashboardView(),
    ),
  ];
}
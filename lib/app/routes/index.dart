import 'package:get/get.dart';

import '../../presentation/screens/dashboard/index.dart';
import '../../presentation/screens/splash/index.dart';
import 'routes.dart';


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
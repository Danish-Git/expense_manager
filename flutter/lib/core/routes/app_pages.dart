import 'package:get/get.dart';
import '../../presentation/features/home/home_binding.dart';
import '../../presentation/features/home/home_screen.dart';

part 'app_routes.dart';

class AppPages {
  static const initial = Routes.home;

  static final routes = [
    GetPage(
      name: Routes.home,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
    ),
  ];
}

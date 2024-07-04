import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:get/get.dart';

import '../../utils/widgets/responsive_scaffold/index.dart';
import 'controller.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
      global: false,
      init: DashboardController(),
      builder: (controller) => ResponsiveScaffold(
        selectedIndex: controller.selectedIndex,
        onItemSelection: controller.onItemSelection,
        mainDrawerItems: controller.mainDrawerItems,
        bottomNavigationItems: controller.bottomNavigationItems,
        body: body(controller),
        secondaryBody: secondaryBody(controller),
        onAddExpense: controller.onAddExpense,
      )
    );
  }

  SlotLayout body (DashboardController controller) => SlotLayout(
    config: <Breakpoint, SlotLayoutConfig?>{
      Breakpoints.standard: SlotLayout.from(
        key: const Key('body'),
        builder: (_) => controller.pages(controller.selectedIndex)
      )
    }
  );

  SlotLayout secondaryBody (DashboardController controller) => SlotLayout(
      config: <Breakpoint, SlotLayoutConfig?>{
        Breakpoints.mediumAndUp: SlotLayout.from(
          outAnimation: AdaptiveScaffold.stayOnScreen,
          key: const Key('Secondary Body'),
          builder: (_) => controller.pages(controller.selectedIndex)
        )
      }
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:get/get.dart';
import '../../../../app/themes/index.dart';
import '../button/constants/button_type.dart';
import '../button/inidex.dart';
import 'controller.dart';

class ResponsiveScaffold extends StatelessWidget {
  const ResponsiveScaffold({
    super.key,
    this.mainDrawerItems,
    this.bottomNavigationItems,
    this.selectedIndex,
    this.body,
    this.secondaryBody,
    this.onItemSelection,
    this.backgroundColor,
  });

  final List<NavigationRailDestination>? mainDrawerItems;
  final List<NavigationDestination>? bottomNavigationItems;
  final int? selectedIndex;
  final SlotLayout? body;
  final SlotLayout? secondaryBody;
  final Function(int? index)? onItemSelection;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ResponsiveScaffoldController>(
      global: false,
      init: ResponsiveScaffoldController(),
      builder: (controller) => Scaffold(
        backgroundColor: backgroundColor ?? EMAppTheme.themeColors.lightGray,
        body: AdaptiveLayout(
          primaryNavigation: SlotLayout(
            config: <Breakpoint, SlotLayoutConfig?>{
              Breakpoints.medium: SlotLayout.from(
                key: const Key('primaryNavigation'),
                builder: (_) {
                  return AdaptiveScaffold.standardNavigationRail(
                    onDestinationSelected: onItemSelection,
                    selectedIndex: selectedIndex,
                    backgroundColor: EMAppTheme.themeColors.lightGray,
                    destinations: mainDrawerItems ?? [],
                    leading: ScaleTransition(
                      scale: controller.articleIconSlideController,
                      child: CustomButton(
                        buttonType: ButtonType.medium,
                        leadingIcon: const Icon(Icons.add),
                        onTap: () => controller.addExpense(!Breakpoints.mediumAndUp.isActive(context)),
                      ),
                    ),
                  );
                },
              ),
              Breakpoints.large: SlotLayout.from(
                key: const Key('Large primaryNavigation'),
                builder: (_) => SafeArea(
                  child: Container(
                    color: EMAppTheme.themeColors.lightGray,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: CircleAvatar(
                            radius: 50,
                            child: Icon(
                                Icons.person,
                                size: 50,
                                color: EMAppTheme.themeColors.primary
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: AdaptiveScaffold.standardNavigationRail(
                              leading: CustomButton(
                                buttonType: ButtonType.large,
                                leadingIcon: const Icon(Icons.add),
                                onTap: () => controller.addExpense(!Breakpoints.mediumAndUp.isActive(context))
                              ),
                              onDestinationSelected: onItemSelection,
                              selectedIndex: selectedIndex,
                              extended: true,
                              backgroundColor: EMAppTheme.themeColors.lightGray,
                              destinations: (bottomNavigationItems ?? []).map((NavigationDestination destination) {
                                return AdaptiveScaffold.toRailDestination(destination);
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            },
          ),
          body: body,
          secondaryBody: secondaryBody,

          bottomNavigation: SlotLayout(
            config: <Breakpoint, SlotLayoutConfig?>{
              Breakpoints.small: SlotLayout.from(
                key: const Key('bottomNavigation'),
                outAnimation: AdaptiveScaffold.topToBottom,
                builder: (_) => AdaptiveScaffold.standardBottomNavigationBar(
                  onDestinationSelected: onItemSelection,
                  currentIndex: selectedIndex,
                  destinations: bottomNavigationItems ?? [],
                ),
              )
            },
          ),
        ),
      )
    );
  }
}
import 'package:expense_manager/screens/dashboard/controller.dart';
import 'package:expense_manager/screens/history/index.dart';
import 'package:expense_manager/screens/settings/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  DashboardController controller = DashboardController();

  group("DashboardController@pages, Should load correct page", () {

    testWidgets('Should load HistoryView when index is 1', (WidgetTester tester) async {
      Widget widget = controller.pages(1);

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

      expect(find.byType(HistoryView), findsOneWidget);
      expect(find.byType(SettingView), findsNothing);
    });

    testWidgets('Should load SettingView when index is 2', (WidgetTester tester) async {
      Widget widget = controller.pages(2);

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

      expect(find.byType(HistoryView), findsNothing);
      expect(find.byType(SettingView), findsOneWidget);
    });

    testWidgets('Should load Container when index is other than 0, 1, or 2', (WidgetTester tester) async {
      Widget widget = controller.pages(3); // or any other index that is not 0, 1, or 2

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

      expect(find.byType(Container), findsOneWidget);
      expect(find.byType(HistoryView), findsNothing);
      expect(find.byType(SettingView), findsNothing);
    });
  });

  group("DashboardController@onItemSelection,  update selected page correctly", () {
    test('Should sets selected page to provided index', () {
      controller.onItemSelection(2);
      expect(controller.selectedIndex, 2);
    });

    test('Should sets selected page to 0 if index is null', () {
      controller.onItemSelection(null);
      expect(controller.selectedIndex, 0);
    });
  });
}